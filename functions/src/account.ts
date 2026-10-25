import { getAuth } from "firebase-admin/auth";
import { ApiError, defineCall } from "./runtime";
import { db, FieldValue, optionalStr, requireAuth, type UpdateData } from "./common";
import { isValidTimeZone } from "./logic";

const DELETED_NAME = "Deleted user";
const BATCH = 400;

async function updateInBatches(
  docs: FirebaseFirestore.QueryDocumentSnapshot[],
  data: UpdateData,
): Promise<void> {
  for (let i = 0; i < docs.length; i += BATCH) {
    const batch = db.batch();
    for (const doc of docs.slice(i, i + BATCH)) batch.update(doc.ref, data);
    await batch.commit();
  }
}

/**
 * Saves the profile and copies the display name and activity visibility onto
 * every membership, so other members see the change.
 */
export const syncProfile = defineCall(async (request) => {
  const uid = requireAuth(request);
  const displayName = optionalStr(request.data, "displayName", 40);
  if (displayName === "") throw new ApiError("invalid-argument", "displayName is required.");
  const visibility = request.data?.visibility === "countsOnly" ? "countsOnly" : "everyone";
  const timezone: string | undefined = request.data?.timezone;
  if (timezone !== undefined && !isValidTimeZone(timezone)) {
    throw new ApiError("invalid-argument", "timezone is not valid.");
  }
  const offset = request.data?.utcOffsetMinutes;
  if (offset !== undefined && (!Number.isInteger(offset) || offset < -720 || offset > 840)) {
    throw new ApiError("invalid-argument", "utcOffsetMinutes is not valid.");
  }

  await db.doc(`users/${uid}/settings/profile`).set(
    {
      displayName,
      visibility,
      ...(timezone !== undefined ? { timezone } : {}),
      ...(offset !== undefined ? { utcOffsetMinutes: offset } : {}),
    },
    { merge: true },
  );

  const patch = { displayName, shareActivity: visibility !== "countsOnly" };
  const members = await db.collectionGroup("members").where("uid", "==", uid).get();
  const participants = await db.collectionGroup("participants").where("uid", "==", uid).get();
  await updateInBatches(members.docs, patch);
  await updateInBatches(participants.docs, patch);
  return { ok: true };
});

/**
 * Deletes the caller's account.
 *
 * - Blocked while the caller owns a group that still has other members, or a
 *   shared habit that still has other participants. They must transfer
 *   ownership (or leave, for shared habits) first.
 * - Memberships end ("left"), the name becomes "Deleted user", and the
 *   caller's own completion documents are deleted.
 * - Cycle documents keep their counts, so group history stays correct.
 * - Personal data under users/{uid} is deleted, then the auth user.
 */
export const deleteAccount = defineCall(async (request) => {
  const uid = requireAuth(request);

  const memberships = await db.collectionGroup("members").where("uid", "==", uid).get();
  const active = memberships.docs.filter((d) => d.get("status") === "active");

  const blockers: string[] = [];
  for (const m of active) {
    if (m.get("role") !== "owner") continue;
    const groupRef = m.ref.parent.parent!;
    const others = await groupRef.collection("members").where("status", "==", "active").limit(2).get();
    if (others.docs.some((d) => d.id !== uid)) blockers.push(groupRef.id);
  }
  const owned = await db.collection("sharedHabits").where("ownerUid", "==", uid).get();
  for (const s of owned.docs) {
    const participants: string[] = s.get("participantUids") ?? [];
    if (participants.some((p) => p !== uid)) blockers.push(s.id);
  }
  if (blockers.length > 0) {
    throw new ApiError(
      "failed-precondition",
      "Transfer ownership of your groups before deleting your account.",
      { blockers },
    );
  }

  for (const m of active) {
    const groupRef = m.ref.parent.parent!;
    const groupSnap = await groupRef.get();
    const update: UpdateData = {
      memberCount: Math.max(0, (groupSnap.get("memberCount") ?? 1) - 1),
    };
    if (m.get("role") === "owner") update.status = "archived"; // nobody else is left
    await groupRef.update(update);
  }
  await updateInBatches(memberships.docs, {
    status: "left",
    displayName: DELETED_NAME,
    shareActivity: false,
    leftAt: FieldValue.serverTimestamp(),
  });

  const participations = await db.collectionGroup("participants").where("uid", "==", uid).get();
  for (const p of participations.docs) {
    const habitRef = p.ref.parent.parent!;
    const habit = await habitRef.get();
    const remaining: string[] = (habit.get("participantUids") ?? []).filter((x: string) => x !== uid);
    await habitRef.update({
      participantUids: remaining,
      participantCount: remaining.length,
      ...(remaining.length === 0 ? { status: "archived" } : {}),
    });
  }
  await updateInBatches(participations.docs, {
    status: "left",
    displayName: DELETED_NAME,
    shareActivity: false,
    leftAt: FieldValue.serverTimestamp(),
  });

  // Remove the caller's own completion records.
  const completions = await db.collectionGroup("completions").where("uid", "==", uid).get();
  for (let i = 0; i < completions.docs.length; i += BATCH) {
    const batch = db.batch();
    for (const doc of completions.docs.slice(i, i + BATCH)) batch.delete(doc.ref);
    await batch.commit();
  }

  await db.recursiveDelete(db.doc(`users/${uid}`));
  await getAuth().deleteUser(uid);
  return { ok: true };
});
