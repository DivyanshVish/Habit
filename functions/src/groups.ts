import { ApiError, defineCall } from "./runtime";
import {
  db,
  FieldValue,
  MAX_ACTIVE_GROUP_HABITS,
  audit,
  auditInTx,
  optionalStr,
  readProfile,
  requireActiveMember,
  requireAdmin,
  requireAuth,
  str,
  type UpdateData,
} from "./common";
import { isValidRule } from "./engine";
import { syncGroupMemberships } from "./membershipSync";
import type { CompletionRule } from "./engine";
import {
  addDays,
  dateKeyFromUtc,
  normalizeWeekdays,
  parseDateKey,
} from "./logic";

/** Pictures are preset emblems (an icon and a colour) instead of uploads. */
export const EMBLEM_ICONS = [
  "fitness", "book", "run", "heart", "star", "leaf",
  "coffee", "music", "study", "water", "sleep", "people",
] as const;
export const EMBLEM_COLORS = 8;

export function parseEmblem(raw: unknown): { icon: string; color: number } | null {
  if (raw === undefined || raw === null) return null;
  const e = raw as { icon?: unknown; color?: unknown };
  if (
    typeof e.icon !== "string" ||
    !(EMBLEM_ICONS as readonly string[]).includes(e.icon) ||
    !Number.isInteger(e.color) ||
    (e.color as number) < 0 ||
    (e.color as number) >= EMBLEM_COLORS
  ) {
    throw new ApiError("invalid-argument", "That emblem is not valid.");
  }
  return { icon: e.icon, color: e.color as number };
}

function groupRef(groupId: string) {
  return db.doc(`groups/${groupId}`);
}

function memberRef(groupId: string, uid: string) {
  return db.doc(`groups/${groupId}/members/${uid}`);
}

async function activeGroup(tx: FirebaseFirestore.Transaction, groupId: string) {
  const snap = await tx.get(groupRef(groupId));
  const data = snap.data();
  if (!data) throw new ApiError("not-found", "Group not found.");
  if (data.status !== "active") {
    throw new ApiError("failed-precondition", "This group is archived.");
  }
  return data;
}

// ---------------------------------------------------------------------------
// Groups
// ---------------------------------------------------------------------------

export const createGroup = defineCall(async (request) => {
  const uid = requireAuth(request);
  const name = str(request.data, "name", 1, 60);
  const description = optionalStr(request.data, "description", 300);
  const emblem = parseEmblem(request.data?.emblem);
  const membersCanInvite = request.data?.membersCanInvite === true;
  const requireApproval = request.data?.requireApproval === true;
  const profile = await readProfile(uid);

  const ref = db.collection("groups").doc();
  const batch = db.batch();
  batch.set(ref, {
    name,
    description,
    emblem,
    ownerUid: uid,
    memberCount: 1,
    membersCanInvite,
    requireApproval,
    status: "active",
    createdAt: FieldValue.serverTimestamp(),
  });
  batch.set(memberRef(ref.id, uid), {
    uid,
    role: "owner",
    status: "active",
    displayName: profile.displayName,
    shareActivity: profile.shareActivity,
    joinedAt: FieldValue.serverTimestamp(),
  });
  await batch.commit();
  await audit(ref.id, uid, "group.created", { name });
  await syncGroupMemberships(ref.id);
  return { groupId: ref.id };
});

export const leaveGroup = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);

  await db.runTransaction(async (tx) => {
    const group = await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);

    if (me.role === "owner") {
      const others = await tx.get(
        db
          .collection(`groups/${groupId}/members`)
          .where("status", "==", "active")
          .limit(2),
      );
      const hasOthers = others.docs.some((d) => d.id !== uid);
      if (hasOthers) {
        throw new ApiError(
          "failed-precondition",
          "Transfer ownership before leaving, or archive the group.",
        );
      }
      // Last person out: archive instead of leaving an ownerless group.
      tx.update(groupRef(groupId), { status: "archived", archivedAt: FieldValue.serverTimestamp() });
    }
    tx.update(memberRef(groupId, uid), {
      status: "left",
      leftAt: FieldValue.serverTimestamp(),
    });
    tx.update(groupRef(groupId), { memberCount: Math.max(0, (group.memberCount ?? 1) - 1) });
    auditInTx(tx, groupId, uid, "member.left", { uid });
  });
  await syncGroupMemberships(groupId);
  return { ok: true };
});

export const removeMember = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);
  const targetUid = str(request.data, "uid", 1, 128);
  if (targetUid === uid) {
    throw new ApiError("invalid-argument", "Use leave to remove yourself.");
  }

  await db.runTransaction(async (tx) => {
    const group = await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);
    requireAdmin(me);
    const target = await requireActiveMember(tx, groupId, targetUid);
    if (target.role === "owner") {
      throw new ApiError("permission-denied", "The owner cannot be removed.");
    }
    if (target.role === "admin" && me.role !== "owner") {
      throw new ApiError("permission-denied", "Only the owner can remove an admin.");
    }
    tx.update(memberRef(groupId, targetUid), {
      status: "removed",
      leftAt: FieldValue.serverTimestamp(),
    });
    tx.update(groupRef(groupId), { memberCount: Math.max(0, (group.memberCount ?? 1) - 1) });
    auditInTx(tx, groupId, uid, "member.removed", { uid: targetUid });
  });
  await syncGroupMemberships(groupId);
  return { ok: true };
});

export const setMemberRole = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);
  const targetUid = str(request.data, "uid", 1, 128);
  const role = str(request.data, "role", 1, 10);
  if (role !== "admin" && role !== "member") {
    throw new ApiError("invalid-argument", "role must be admin or member.");
  }

  await db.runTransaction(async (tx) => {
    await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);
    if (me.role !== "owner") {
      throw new ApiError("permission-denied", "Only the owner can change roles.");
    }
    const target = await requireActiveMember(tx, groupId, targetUid);
    if (target.role === "owner") {
      throw new ApiError("failed-precondition", "Transfer ownership instead.");
    }
    tx.update(memberRef(groupId, targetUid), { role });
    auditInTx(tx, groupId, uid, "member.role", { uid: targetUid, role });
  });
  await syncGroupMemberships(groupId);
  return { ok: true };
});

export const transferOwnership = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);
  const targetUid = str(request.data, "uid", 1, 128);
  if (targetUid === uid) {
    throw new ApiError("invalid-argument", "You already own this group.");
  }

  await db.runTransaction(async (tx) => {
    await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);
    if (me.role !== "owner") {
      throw new ApiError("permission-denied", "Only the owner can transfer ownership.");
    }
    await requireActiveMember(tx, groupId, targetUid);
    tx.update(memberRef(groupId, targetUid), { role: "owner" });
    tx.update(memberRef(groupId, uid), { role: "admin" });
    tx.update(groupRef(groupId), { ownerUid: targetUid });
    auditInTx(tx, groupId, uid, "group.ownership", { to: targetUid });
  });
  await syncGroupMemberships(groupId);
  return { ok: true };
});

export const archiveGroup = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);

  const habitIds = await db.runTransaction(async (tx) => {
    await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);
    if (me.role !== "owner") {
      throw new ApiError("permission-denied", "Only the owner can archive the group.");
    }
    const habits = await tx.get(
      db.collection(`groups/${groupId}/habits`).where("status", "==", "active"),
    );
    tx.update(groupRef(groupId), { status: "archived", archivedAt: FieldValue.serverTimestamp() });
    for (const habit of habits.docs) {
      tx.update(habit.ref, { status: "archived", archivedAt: FieldValue.serverTimestamp() });
    }
    auditInTx(tx, groupId, uid, "group.archived");
    return habits.docs.map((d) => d.id);
  });
  await syncGroupMemberships(groupId);
  return { ok: true, archivedHabits: habitIds.length };
});

export const updateGroupSettings = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);

  await db.runTransaction(async (tx) => {
    await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);
    requireAdmin(me);
    const patch: UpdateData = {};
    if (request.data?.name !== undefined) patch.name = str(request.data, "name", 1, 60);
    if (request.data?.description !== undefined) {
      patch.description = optionalStr(request.data, "description", 300);
    }
    if (request.data?.membersCanInvite !== undefined) {
      patch.membersCanInvite = request.data.membersCanInvite === true;
    }
    if (request.data?.requireApproval !== undefined) {
      patch.requireApproval = request.data.requireApproval === true;
    }
    if (request.data?.emblem !== undefined) patch.emblem = parseEmblem(request.data.emblem);
    if (Object.keys(patch).length === 0) return;
    tx.update(groupRef(groupId), patch);
    auditInTx(tx, groupId, uid, "group.updated", { fields: Object.keys(patch) });
  });
  await syncGroupMemberships(groupId);
  return { ok: true };
});

// ---------------------------------------------------------------------------
// Group habits
// ---------------------------------------------------------------------------

/**
 * Reads a rule from a request. The result has a `value` key only when a number
 * was given: Firestore refuses to store `undefined`.
 */
export function parseRule(raw: unknown): CompletionRule {
  const r = raw as { type?: unknown; value?: unknown } | undefined;
  const rule: CompletionRule = {
    type: (typeof r?.type === "string" ? r.type : "individual") as CompletionRule["type"],
    ...(typeof r?.value === "number" ? { value: r.value } : {}),
  };
  if (!isValidRule(rule)) {
    throw new ApiError("invalid-argument", "The completion rule is not valid.");
  }
  return rule;
}

function parseKey(raw: unknown, field: string): string {
  if (typeof raw !== "string") {
    throw new ApiError("invalid-argument", `${field} must be yyyy-MM-dd.`);
  }
  try {
    parseDateKey(raw);
  } catch {
    throw new ApiError("invalid-argument", `${field} must be yyyy-MM-dd.`);
  }
  return raw;
}

export const createGroupHabit = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);
  const name = str(request.data, "name", 1, 60);
  const description = optionalStr(request.data, "description", 200);
  const weekdays = normalizeWeekdays(request.data?.weekdays);
  const rule = parseRule(request.data?.target);
  const startDate = parseKey(request.data?.startDate ?? dateKeyFromUtc(Date.now()), "startDate");
  const endDate =
    request.data?.endDate === undefined || request.data?.endDate === null
      ? null
      : parseKey(request.data.endDate, "endDate");
  if (endDate !== null && endDate < startDate) {
    throw new ApiError("invalid-argument", "endDate must not be before startDate.");
  }

  const habitRef = db.collection(`groups/${groupId}/habits`).doc();
  await db.runTransaction(async (tx) => {
    await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);
    requireAdmin(me);
    const active = await tx.get(
      db.collection(`groups/${groupId}/habits`).where("status", "==", "active"),
    );
    if (active.size >= MAX_ACTIVE_GROUP_HABITS) {
      throw new ApiError("resource-exhausted", "This group has too many active habits.");
    }
    tx.set(habitRef, {
      name,
      description,
      weekdays,
      target: rule,
      startDate,
      endDate,
      status: "active",
      revision: 1,
      pending: null,
      groupStreak: { current: 0, best: 0, lastDateKey: null },
      createdBy: uid,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(habitRef.collection("revisions").doc("1"), {
      revision: 1,
      weekdays,
      target: rule,
      effectiveFrom: startDate,
      changedBy: uid,
      at: FieldValue.serverTimestamp(),
    });
    auditInTx(tx, groupId, uid, "habit.created", { habitId: habitRef.id, name });
  });
  return { habitId: habitRef.id };
});

/**
 * Name and description change immediately. A new schedule or target becomes a
 * pending revision that takes effect two UTC days from now, so no cycle that
 * is already open, anywhere in the world, is rewritten.
 */
export const updateGroupHabit = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);
  const habitId = str(request.data, "habitId", 1, 100);

  const result = await db.runTransaction(async (tx) => {
    await activeGroup(tx, groupId);
    const me = await requireActiveMember(tx, groupId, uid);
    requireAdmin(me);
    const habitRef = db.doc(`groups/${groupId}/habits/${habitId}`);
    const snap = await tx.get(habitRef);
    const habit = snap.data();
    if (!habit) throw new ApiError("not-found", "Habit not found.");
    if (habit.status !== "active") {
      throw new ApiError("failed-precondition", "This habit is archived.");
    }

    const patch: UpdateData = {};
    if (request.data?.name !== undefined) patch.name = str(request.data, "name", 1, 60);
    if (request.data?.description !== undefined) {
      patch.description = optionalStr(request.data, "description", 200);
    }
    if (request.data?.endDate !== undefined) {
      patch.endDate = request.data.endDate === null ? null : parseKey(request.data.endDate, "endDate");
    }

    let effectiveFrom: string | null = null;
    if (request.data?.weekdays !== undefined || request.data?.target !== undefined) {
      const weekdays =
        request.data.weekdays !== undefined
          ? normalizeWeekdays(request.data.weekdays)
          : (habit.pending?.weekdays ?? habit.weekdays);
      const target =
        request.data.target !== undefined
          ? parseRule(request.data.target)
          : (habit.pending?.target ?? habit.target);
      effectiveFrom = addDays(dateKeyFromUtc(Date.now()), 2);
      const revision = (habit.revision ?? 1) + 1;
      patch.revision = revision;
      patch.pending = { weekdays, target, effectiveFrom, revision };
      tx.set(habitRef.collection("revisions").doc(String(revision)), {
        revision,
        weekdays,
        target,
        effectiveFrom,
        changedBy: uid,
        at: FieldValue.serverTimestamp(),
      });
    }
    if (Object.keys(patch).length === 0) return { effectiveFrom: null };
    tx.update(habitRef, patch);
    auditInTx(tx, groupId, uid, "habit.updated", { habitId, fields: Object.keys(patch) });
    return { effectiveFrom };
  });
  return { ok: true, ...result };
});

export const archiveGroupHabit = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);
  const habitId = str(request.data, "habitId", 1, 100);

  await db.runTransaction(async (tx) => {
    const me = await requireActiveMember(tx, groupId, uid);
    requireAdmin(me);
    const habitRef = db.doc(`groups/${groupId}/habits/${habitId}`);
    const snap = await tx.get(habitRef);
    if (!snap.exists) throw new ApiError("not-found", "Habit not found.");
    tx.update(habitRef, { status: "archived", archivedAt: FieldValue.serverTimestamp() });
    auditInTx(tx, groupId, uid, "habit.archived", { habitId });
  });
  return { ok: true };
});
