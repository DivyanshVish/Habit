import { ApiError, defineCall } from "./runtime";
import {
  db,
  FieldValue,
  optionalStr,
  readProfile,
  requireAuth,
  str,
  type UpdateData,
} from "./common";
import { refreshSharedCycle } from "./cycles";
import { dateKeyFromUtc, normalizeWeekdays, parseDateKey } from "./logic";

/**
 * Creates a shared habit. When sourceHabitId is given, the personal habit is
 * linked (sharedHabitId is written on it) and otherwise left untouched, so its
 * history and the existing Today flows keep working.
 */
export const createSharedHabit = defineCall(async (request) => {
  const uid = requireAuth(request);
  const name = str(request.data, "name", 1, 60);
  const description = optionalStr(request.data, "description", 200);
  const points = request.data?.points;
  if (!Number.isInteger(points) || points < 1 || points > 1000) {
    throw new ApiError("invalid-argument", "points must be 1 to 1000.");
  }
  const weekdays = normalizeWeekdays(request.data?.weekdays);
  const startDate: string = request.data?.startDate ?? dateKeyFromUtc(Date.now());
  try {
    parseDateKey(startDate);
  } catch {
    throw new ApiError("invalid-argument", "startDate must be yyyy-MM-dd.");
  }
  const sourceHabitId =
    typeof request.data?.sourceHabitId === "string" ? request.data.sourceHabitId : null;
  const profile = await readProfile(uid);

  const ref = db.collection("sharedHabits").doc();
  await db.runTransaction(async (tx) => {
    if (sourceHabitId !== null) {
      const source = await tx.get(db.doc(`users/${uid}/habits/${sourceHabitId}`));
      if (!source.exists) throw new ApiError("not-found", "Your habit was not found.");
      if (source.data()?.sharedHabitId) {
        throw new ApiError("already-exists", "This habit is already shared.");
      }
      tx.update(source.ref, { sharedHabitId: ref.id });
    }
    tx.set(ref, {
      ownerUid: uid,
      name,
      description,
      points,
      weekdays,
      startDate,
      status: "active",
      participantUids: [uid],
      participantCount: 1,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(ref.collection("participants").doc(uid), {
      uid,
      status: "active",
      displayName: profile.displayName,
      shareActivity: profile.shareActivity,
      joinedAt: FieldValue.serverTimestamp(),
    });
  });
  return { sharedHabitId: ref.id };
});

/**
 * Leaving keeps every historical record. If the owner leaves and others
 * remain, the earliest participant becomes the owner. If nobody remains the
 * habit is archived.
 */
export const leaveSharedHabit = defineCall(async (request) => {
  const uid = requireAuth(request);
  const sharedId = str(request.data, "sharedHabitId", 1, 100);

  await db.runTransaction(async (tx) => {
    const ref = db.doc(`sharedHabits/${sharedId}`);
    const snap = await tx.get(ref);
    const habit = snap.data();
    if (!habit) throw new ApiError("not-found", "Shared habit not found.");
    const participants: string[] = habit.participantUids ?? [];
    if (!participants.includes(uid)) {
      throw new ApiError("permission-denied", "You are not part of this habit.");
    }
    const remaining = participants.filter((p) => p !== uid);
    const patch: UpdateData = {
      participantUids: remaining,
      participantCount: remaining.length,
    };
    if (remaining.length === 0) {
      patch.status = "archived";
    } else if (habit.ownerUid === uid) {
      patch.ownerUid = remaining[0];
    }
    tx.update(ref, patch);
    tx.update(ref.collection("participants").doc(uid), {
      status: "left",
      leftAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

/**
 * Mirrors the owner's personal completion of a linked habit into the shared
 * habit, so ticking it on Today also counts for the group. The app calls this
 * after it toggles a habit; a habit that is not linked is a no-op. The shared
 * completion uses the same deterministic id, so repeats cannot duplicate it.
 *
 * One way only: completing in the Shared Habits screen does not tick the
 * personal habit.
 */
export const mirrorPersonalCompletion = defineCall(async (request) => {
  const uid = requireAuth(request);
  const habitId = str(request.data, "habitId", 1, 200);
  const dateKey = str(request.data, "dateKey", 10, 10);
  const done = request.data?.done === true;
  try {
    parseDateKey(dateKey);
  } catch {
    throw new ApiError("invalid-argument", "dateKey must be yyyy-MM-dd.");
  }

  const habit = await db.doc(`users/${uid}/habits/${habitId}`).get();
  const sharedId = habit.data()?.sharedHabitId;
  if (typeof sharedId !== "string") return { mirrored: false };

  const shared = await db.doc(`sharedHabits/${sharedId}`).get();
  const participants: string[] = shared.data()?.participantUids ?? [];
  if (!participants.includes(uid)) return { mirrored: false };

  const target = db.doc(`sharedHabits/${sharedId}/completions/${uid}_${dateKey}`);
  if (done) {
    await target.set({ uid, dateKey, completedAt: FieldValue.serverTimestamp() });
  } else {
    await target.delete();
  }
  await refreshSharedCycle(sharedId, dateKey);
  return { mirrored: true, sharedHabitId: sharedId };
});
