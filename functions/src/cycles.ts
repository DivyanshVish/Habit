import {
  ApiError,
  defineCall,
} from "./runtime";
import { db, FieldValue, requireAuth, str } from "./common";
import { computeProgress } from "./engine";
import type { CompletionRule } from "./engine";
import {
  addDays,
  aggregateCycle,
  applyClosedCycle,
  dateKeyFromUtc,
  isCycleClosable,
  isScheduled,
  normalizeWeekdays,
  parseDateKey,
} from "./logic";
import { notify } from "./notifications";

const ALREADY_EXISTS = 6;
const INDIVIDUAL: CompletionRule = { type: "individual" };

interface HabitSettings {
  weekdays: number[];
  target: CompletionRule;
}

/** The schedule and rule that apply to the cycle for [key]. */
function settingsFor(habit: FirebaseFirestore.DocumentData, key: string): HabitSettings {
  const pending = habit.pending as
    | { weekdays: number[]; target: CompletionRule; effectiveFrom: string }
    | null
    | undefined;
  if (pending && key >= pending.effectiveFrom) {
    return { weekdays: normalizeWeekdays(pending.weekdays), target: pending.target };
  }
  return {
    weekdays: normalizeWeekdays(habit.weekdays),
    target: (habit.target as CompletionRule | undefined) ?? INDIVIDUAL,
  };
}

async function createCycleIfMissing(
  cycleRef: FirebaseFirestore.DocumentReference,
  eligibleUids: string[],
  rule: CompletionRule,
): Promise<void> {
  const progress = computeProgress(rule, eligibleUids.length, 0);
  try {
    await cycleRef.create({
      dateKey: cycleRef.id,
      eligibleUids,
      eligibleCount: eligibleUids.length,
      rule,
      hasTarget: progress.hasTarget,
      requiredCount: progress.required,
      completedCount: 0,
      visibleCompletedUids: [],
      percent: 0,
      targetReached: false,
      closed: false,
      openedAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    if ((error as { code?: number }).code !== ALREADY_EXISTS) throw error;
  }
}

// ---------------------------------------------------------------------------
// Opening a cycle
// ---------------------------------------------------------------------------

/**
 * Opens the cycle for [dateKey] if the habit is scheduled that day. Runs the
 * first time anyone asks about that day, so the eligible list is the people
 * who were active at that moment: anyone who joins later is not in it and
 * counts from the next day; anyone who leaves later stays in it.
 *
 * Returns false when the habit is not scheduled (nothing to count).
 */
async function ensureGroupCycle(
  groupId: string,
  habitId: string,
  dateKey: string,
): Promise<boolean> {
  const habitRef = db.doc(`groups/${groupId}/habits/${habitId}`);
  const [habitSnap, groupSnap] = await Promise.all([
    habitRef.get(),
    db.doc(`groups/${groupId}`).get(),
  ]);
  const habit = habitSnap.data();
  if (!habit || habit.status !== "active") return false;
  if (groupSnap.data()?.status !== "active") return false;
  if (dateKey < habit.startDate) return false;
  if (habit.endDate && dateKey > habit.endDate) return false;

  const settings = settingsFor(habit, dateKey);
  if (!isScheduled(dateKey, settings.weekdays)) return false;

  const cycleRef = habitRef.collection("cycles").doc(dateKey);
  if (!(await cycleRef.get()).exists) {
    const members = await db
      .collection(`groups/${groupId}/members`)
      .where("status", "==", "active")
      .get();
    await createCycleIfMissing(
      cycleRef,
      members.docs.map((m) => m.id),
      settings.target,
    );
  }

  // Promote a queued schedule change once its start day has arrived.
  const pending = habit.pending as { effectiveFrom: string; weekdays: number[]; target: CompletionRule } | null;
  if (pending && dateKey >= pending.effectiveFrom) {
    await habitRef.update({ weekdays: pending.weekdays, target: pending.target, pending: null });
  }
  return true;
}

async function ensureSharedCycle(sharedId: string, dateKey: string): Promise<boolean> {
  const ref = db.doc(`sharedHabits/${sharedId}`);
  const habit = (await ref.get()).data();
  if (!habit || habit.status !== "active") return false;
  if (dateKey < habit.startDate) return false;
  if (!isScheduled(dateKey, normalizeWeekdays(habit.weekdays))) return false;
  const cycleRef = ref.collection("cycles").doc(dateKey);
  if (!(await cycleRef.get()).exists) {
    await createCycleIfMissing(cycleRef, habit.participantUids ?? [], INDIVIDUAL);
  }
  return true;
}

// ---------------------------------------------------------------------------
// Recomputing a cycle from its source completions
// ---------------------------------------------------------------------------

interface Recomputed {
  reachedNow: boolean;
  reachedBefore: boolean;
  eligibleUids: string[];
}

/**
 * Rebuilds a cycle's numbers from the completion documents. It never adds or
 * subtracts, so a repeated call or two simultaneous completions end in the
 * same state. The transaction makes the read-modify-write atomic.
 */
async function recomputeCycle(
  cycleRef: FirebaseFirestore.DocumentReference,
  completionsCol: FirebaseFirestore.CollectionReference,
  peopleCol: FirebaseFirestore.CollectionReference,
  dateKey: string,
): Promise<Recomputed | null> {
  return db.runTransaction(async (tx) => {
    const cycleSnap = await tx.get(cycleRef);
    const cycle = cycleSnap.data();
    if (!cycle || cycle.closed === true) return null;

    const completions = await tx.get(completionsCol.where("dateKey", "==", dateKey).limit(500));
    const hidden = await tx.get(peopleCol.where("shareActivity", "==", false));

    const eligible: string[] = cycle.eligibleUids ?? [];
    const agg = aggregateCycle(
      eligible,
      completions.docs.map((d) => d.get("uid") as string),
      hidden.docs.map((d) => d.id),
    );
    const progress = computeProgress(
      (cycle.rule as CompletionRule) ?? INDIVIDUAL,
      eligible.length,
      agg.completedCount,
    );
    tx.update(cycleRef, {
      completedCount: agg.completedCount,
      visibleCompletedUids: agg.visibleCompletedUids,
      percent: progress.percent,
      requiredCount: progress.required,
      targetReached: progress.reached,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return {
      reachedNow: progress.reached,
      reachedBefore: cycle.targetReached === true,
      eligibleUids: eligible,
    };
  });
}

/** Opens (if needed) and recomputes a shared habit's cycle. */
export async function refreshSharedCycle(sharedId: string, dateKey: string): Promise<void> {
  if (!(await ensureSharedCycle(sharedId, dateKey))) return;
  const ref = db.doc(`sharedHabits/${sharedId}`);
  await recomputeCycle(
    ref.collection("cycles").doc(dateKey),
    ref.collection("completions"),
    ref.collection("participants"),
    dateKey,
  );
}

async function refreshGroupCycle(groupId: string, habitId: string, dateKey: string): Promise<void> {
  if (!(await ensureGroupCycle(groupId, habitId, dateKey))) return;
  const habitRef = db.doc(`groups/${groupId}/habits/${habitId}`);
  const result = await recomputeCycle(
    habitRef.collection("cycles").doc(dateKey),
    habitRef.collection("completions"),
    db.collection(`groups/${groupId}/members`),
    dateKey,
  );
  if (result && result.reachedNow && !result.reachedBefore) {
    // Group milestone. Sent once per cycle per member, and never throws.
    await Promise.all(
      result.eligibleUids.map((uid) =>
        notify(uid, {
          category: "milestones",
          type: "group.target_reached",
          title: "Group target reached",
          body: "Your group reached its goal for today.",
          data: { groupId, habitId, dateKey },
          dedupeKey: `milestone|${groupId}|${habitId}|${dateKey}`,
        }),
      ),
    );
  }
}

/** Same window the security rules allow for a completion's date. */
function requireNearbyDate(dateKey: string): void {
  let ms: number;
  try {
    ms = parseDateKey(dateKey);
  } catch {
    throw new ApiError("invalid-argument", "dateKey must be yyyy-MM-dd.");
  }
  const todayMs = parseDateKey(dateKeyFromUtc(Date.now()));
  if (Math.abs(ms - todayMs) > 86_400_000) {
    throw new ApiError("invalid-argument", "That date is too far from today.");
  }
}

/**
 * Called by the app when a screen opens and after a completion is saved. It
 * opens the day's cycle if needed, recomputes it from the completions, and
 * closes this habit's finished days. The caller must be a current member or
 * participant, and the result depends only on stored data, so a caller cannot
 * influence the numbers by calling it.
 */
export const refreshCycle = defineCall(async (request) => {
  const uid = requireAuth(request);
  const kind = str(request.data, "kind", 1, 10);
  const dateKey = str(request.data, "dateKey", 10, 10);
  requireNearbyDate(dateKey);

  if (kind === "shared") {
    const sharedId = str(request.data, "sharedId", 1, 100);
    const habit = (await db.doc(`sharedHabits/${sharedId}`).get()).data();
    if (!habit || !(habit.participantUids ?? []).includes(uid)) {
      throw new ApiError("permission-denied", "You are not part of this habit.");
    }
    await refreshSharedCycle(sharedId, dateKey);
    return { ok: true };
  }

  if (kind === "group") {
    const groupId = str(request.data, "groupId", 1, 100);
    const habitId = str(request.data, "habitId", 1, 100);
    const member = (await db.doc(`groups/${groupId}/members/${uid}`).get()).data();
    if (!member || member.status !== "active") {
      throw new ApiError("permission-denied", "You are not a member of this group.");
    }
    await refreshGroupCycle(groupId, habitId, dateKey);
    await closeDueCycles(db.doc(`groups/${groupId}/habits/${habitId}`));
    return { ok: true };
  }

  throw new ApiError("invalid-argument", "kind must be group or shared.");
});

// ---------------------------------------------------------------------------
// Closing cycles
// ---------------------------------------------------------------------------

/**
 * Once no client can write to a cycle any more (see cycleCloseAtMs), freeze it
 * and, for group habits, fold the result into the group streak. Cycles are
 * applied oldest first so the streak is applied in date order.
 */
async function closeCycleDoc(cycleDoc: FirebaseFirestore.QueryDocumentSnapshot): Promise<void> {
  const dateKey = cycleDoc.id;
  if (!isCycleClosable(dateKey, Date.now())) return;
  await db.runTransaction(async (tx) => {
    const cycleSnap = await tx.get(cycleDoc.ref);
    const cycle = cycleSnap.data();
    if (!cycle || cycle.closed === true) return;

    const isGroup = cycleDoc.ref.path.startsWith("groups/");
    let habitUpdate: { ref: FirebaseFirestore.DocumentReference; streak: unknown } | null = null;
    if (isGroup) {
      const habitRef = cycleDoc.ref.parent.parent!;
      const habitSnap = await tx.get(habitRef);
      const habit = habitSnap.data() ?? {};
      let streak = habit.groupStreak ?? { current: 0, best: 0, lastDateKey: null };
      // A scheduled day nobody opened has no cycle. It still counts as a miss
      // for the group, otherwise the streak would survive an idle day.
      if (cycle.hasTarget === true && streak.lastDateKey) {
        const weekdays = normalizeWeekdays(habit.weekdays);
        let day = addDays(streak.lastDateKey, 1);
        for (let i = 0; i < 400 && day < dateKey; i++, day = addDays(day, 1)) {
          if (day >= habit.startDate && isScheduled(day, weekdays)) {
            streak = applyClosedCycle(streak, day, true, false);
          }
        }
      }
      habitUpdate = {
        ref: habitRef,
        streak: applyClosedCycle(streak, dateKey, cycle.hasTarget === true, cycle.targetReached === true),
      };
    }
    tx.update(cycleDoc.ref, { closed: true, closedAt: FieldValue.serverTimestamp() });
    if (habitUpdate) tx.update(habitUpdate.ref, { groupStreak: habitUpdate.streak });
  });
}

function closeCutoff(): string {
  return addDays(dateKeyFromUtc(Date.now()), -2);
}

/** Closes the finished days of one habit. Used when its screen is opened. */
async function closeDueCycles(habitRef: FirebaseFirestore.DocumentReference): Promise<void> {
  const due = await habitRef
    .collection("cycles")
    .where("closed", "==", false)
    .where("dateKey", "<=", closeCutoff())
    .orderBy("dateKey")
    .limit(50)
    .get();
  for (const doc of due.docs) await closeCycleDoc(doc);
}

/** Daily backstop for habits nobody has opened. */
export async function runCloseCycles(): Promise<{ closed: number; failed: number }> {
  const open = await db
    .collectionGroup("cycles")
    .where("closed", "==", false)
    .where("dateKey", "<=", closeCutoff())
    .orderBy("dateKey")
    .limit(500)
    .get();

  let closed = 0;
  let failed = 0;
  for (const doc of open.docs) {
    try {
      await closeCycleDoc(doc);
      closed++;
    } catch (error) {
      failed++;
      console.error("closeCycles failed", doc.ref.path, String(error));
    }
  }
  return { closed, failed };
}
