import { getAuth } from "firebase-admin/auth";
import { ApiError, defineCall } from "./runtime";
import {
  FieldValue,
  db,
  enforceRateLimit,
  requireAuth,
  str,
  type UpdateData,
} from "./common";
import { renameCompletionId, swapUid } from "./logic";
import { syncGroupMemberships } from "./membershipSync";

const BATCH = 400;

type Doc = FirebaseFirestore.QueryDocumentSnapshot;

/** Runs [action] on every document of [query], [BATCH] at a time. */
async function forEachDoc(
  query: FirebaseFirestore.Query,
  action: (docs: Doc[]) => Promise<void>,
): Promise<void> {
  let last: Doc | undefined;
  for (;;) {
    let page = query.orderBy("__name__").limit(BATCH);
    if (last) page = page.startAfter(last);
    const snap = await page.get();
    if (snap.empty) return;
    await action(snap.docs);
    last = snap.docs[snap.docs.length - 1];
    if (snap.size < BATCH) return;
  }
}

/** Copies a collection and everything below it. Safe to repeat. */
async function copyCollection(
  source: FirebaseFirestore.CollectionReference,
  target: FirebaseFirestore.CollectionReference,
): Promise<void> {
  await forEachDoc(source, async (docs) => {
    const batch = db.batch();
    for (const doc of docs) batch.set(target.doc(doc.id), doc.data());
    await batch.commit();
    for (const doc of docs) {
      for (const sub of await doc.ref.listCollections()) {
        await copyCollection(sub, target.doc(doc.id).collection(sub.id));
      }
    }
  });
}

/** Top level collections under users/{uid} that stay with the device or are rebuilt. */
const NOT_COPIED = new Set(["devices", "memberships"]);

async function accountHasData(uid: string): Promise<boolean> {
  const [habits, members, participants] = await Promise.all([
    db.collection(`users/${uid}/habits`).limit(1).get(),
    db.collectionGroup("members").where("uid", "==", uid).limit(1).get(),
    db.collectionGroup("participants").where("uid", "==", uid).limit(1).get(),
  ]);
  return !habits.empty || !members.empty || !participants.empty;
}

/**
 * Moves one account's data to another, for someone who now signs in with a
 * different Google account.
 *
 * The caller is signed in as the NEW account (its token authorizes the call).
 * The OLD account proves it belongs to the same person by passing its own,
 * still valid, ID token as `fromIdToken`. Nobody can move another person's
 * data without holding both logins.
 *
 * Rules:
 * - The new account must have no Habitry data (unless this is a retry of the
 *   same move). Merging two accounts is not attempted.
 * - Every step can be repeated, so a move that timed out is finished by
 *   calling it again.
 * - The old account is emptied at the end.
 */
export const migrateAccount = defineCall(async (request) => {
  const toUid = requireAuth(request);
  const fromToken = str(request.data, "fromIdToken", 20, 4096);
  await enforceRateLimit(toUid, "migrate", 5, 60 * 60 * 1000);

  let fromUid: string;
  try {
    fromUid = (await getAuth().verifyIdToken(fromToken)).uid;
  } catch {
    throw new ApiError(
      "unauthenticated",
      "The previous account's sign in expired. Switch back to it and try again.",
    );
  }
  if (fromUid === toUid) {
    throw new ApiError(
      "invalid-argument",
      "That is the same account. Pick a different Google account.",
    );
  }

  const record = db.doc(`migrations/${fromUid}`);
  const existing = (await record.get()).data();
  if (existing?.status === "done") {
    throw new ApiError("failed-precondition", "That account was already moved.");
  }
  const isRetry = existing?.status === "running" && existing.to === toUid;
  if (existing?.status === "running" && existing.to !== toUid) {
    throw new ApiError(
      "failed-precondition",
      "A move to another account is already in progress.",
    );
  }
  if (!isRetry && (await accountHasData(toUid))) {
    throw new ApiError(
      "failed-precondition",
      "The account you picked already has habits or groups. Move to an empty " +
        "account, or sign in to that one instead.",
    );
  }
  await record.set({ to: toUid, status: "running", startedAt: FieldValue.serverTimestamp() });

  const groupIds = new Set<string>();

  // --- groups: memberships and ownership --------------------------------------
  await forEachDoc(db.collectionGroup("members").where("uid", "==", fromUid), async (docs) => {
    for (const doc of docs) {
      const groupRef = doc.ref.parent.parent!;
      groupIds.add(groupRef.id);
      const batch = db.batch();
      batch.set(groupRef.collection("members").doc(toUid), { ...doc.data(), uid: toUid });
      batch.delete(doc.ref);
      const group = (await groupRef.get()).data();
      if (group?.ownerUid === fromUid) batch.update(groupRef, { ownerUid: toUid });
      batch.set(groupRef.collection("auditLog").doc(), {
        action: "member.accountMoved",
        actorUid: toUid,
        details: { from: fromUid },
        at: FieldValue.serverTimestamp(),
      });
      await batch.commit();
    }
  });

  // --- shared habits ------------------------------------------------------------
  await forEachDoc(db.collectionGroup("participants").where("uid", "==", fromUid), async (docs) => {
    for (const doc of docs) {
      const habitRef = doc.ref.parent.parent!;
      const batch = db.batch();
      batch.set(habitRef.collection("participants").doc(toUid), { ...doc.data(), uid: toUid });
      batch.delete(doc.ref);
      const habit = (await habitRef.get()).data();
      if (habit) {
        const patch: UpdateData = {
          participantUids: swapUid(habit.participantUids ?? [], fromUid, toUid),
        };
        if (habit.ownerUid === fromUid) patch.ownerUid = toUid;
        batch.update(habitRef, patch);
      }
      await batch.commit();
    }
  });

  // --- completions in groups and shared habits (renamed {uid}_{date}) ---------
  await forEachDoc(db.collectionGroup("completions").where("uid", "==", fromUid), async (docs) => {
    const batch = db.batch();
    for (const doc of docs) {
      const newId = renameCompletionId(doc.id, fromUid, toUid);
      batch.set(doc.ref.parent.doc(newId), { ...doc.data(), uid: toUid });
      batch.delete(doc.ref);
    }
    await batch.commit();
  });

  // --- day snapshots that list the old account ------------------------------------
  for (const field of ["eligibleUids", "visibleCompletedUids"]) {
    await forEachDoc(db.collectionGroup("cycles").where(field, "array-contains", fromUid), async (docs) => {
      const batch = db.batch();
      for (const doc of docs) {
        batch.update(doc.ref, { [field]: swapUid(doc.get(field) ?? [], fromUid, toUid) });
      }
      await batch.commit();
    });
  }

  // --- invitations the old account created ------------------------------------------
  await forEachDoc(db.collection("invitations").where("inviterUid", "==", fromUid), async (docs) => {
    const batch = db.batch();
    for (const doc of docs) batch.update(doc.ref, { inviterUid: toUid });
    await batch.commit();
  });

  // --- personal data: habits, completions, profile, settings, inbox ---------------------
  const source = db.doc(`users/${fromUid}`);
  const target = db.doc(`users/${toUid}`);
  for (const collection of await source.listCollections()) {
    if (NOT_COPIED.has(collection.id)) continue;
    await copyCollection(collection, target.collection(collection.id));
  }

  for (const groupId of groupIds) await syncGroupMemberships(groupId);

  // --- finish: empty the old account ----------------------------------------------------
  await db.recursiveDelete(source);
  await record.set({ to: toUid, status: "done", finishedAt: FieldValue.serverTimestamp() });

  // A guest account has no way back in, so remove it. A Google account stays,
  // empty, in case its owner signs in to it again.
  try {
    const user = await getAuth().getUser(fromUid);
    if (user.providerData.length === 0) await getAuth().deleteUser(fromUid);
  } catch (error) {
    console.error("could not remove the old sign in", fromUid, String(error));
  }

  return { ok: true, groups: groupIds.size };
});
