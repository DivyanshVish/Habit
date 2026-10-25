import { ApiError, defineCall } from "./runtime";
import {
  db,
  FieldValue,
  MAX_MEMBERS,
  Timestamp,
  auditInTx,
  enforceRateLimit,
  readProfile,
  requireAuth,
  str,
} from "./common";
import type { Member } from "./common";
import { generateCode, hashCode, invitationProblem, normalizeCode } from "./logic";
import type { InvitationProblem } from "./logic";
import { syncGroupMemberships } from "./membershipSync";
import { notify } from "./notifications";

const MAX_TTL_HOURS = 24 * 14;
const MAX_PEOPLE = 100;
const PROBLEM_MESSAGES: Record<InvitationProblem, string> = {
  revoked: "This invitation was cancelled.",
  expired: "This invitation has expired.",
  exhausted: "This code has been used the maximum number of times.",
  used: "This invitation was already used.",
  "not-pending": "This invitation can no longer be used.",
};

type Kind = "shared" | "group";

function targetRef(type: Kind, targetId: string) {
  return type === "shared" ? db.doc(`sharedHabits/${targetId}`) : db.doc(`groups/${targetId}`);
}

function pendingRef(uid: string, invitationId: string) {
  return db.doc(`users/${uid}/pendingInvitations/${invitationId}`);
}

// ---------------------------------------------------------------------------
// Who may invite to what
// ---------------------------------------------------------------------------

/** Throws unless [uid] may invite people to the target. Returns its data. */
async function requireMayInvite(
  tx: FirebaseFirestore.Transaction,
  type: Kind,
  targetId: string,
  uid: string,
): Promise<FirebaseFirestore.DocumentData> {
  const target = await tx.get(targetRef(type, targetId));
  const data = target.data();
  if (!data) throw new ApiError("not-found", "Not found.");
  if (data.status !== "active") {
    throw new ApiError("failed-precondition", "This is archived.");
  }
  if (type === "shared") {
    if (data.ownerUid !== uid) {
      throw new ApiError("permission-denied", "Only the owner can invite.");
    }
  } else {
    const memberSnap = await tx.get(db.doc(`groups/${targetId}/members/${uid}`));
    const member = memberSnap.data() as Member | undefined;
    if (!member || member.status !== "active") {
      throw new ApiError("permission-denied", "You are not a member of this group.");
    }
    const isAdmin = member.role === "owner" || member.role === "admin";
    if (!isAdmin && data.membersCanInvite !== true) {
      throw new ApiError("permission-denied", "Only admins can invite to this group.");
    }
  }
  return data;
}

/** Ids of the groups [uid] is an active member of. */
async function activeGroupIds(uid: string): Promise<string[]> {
  // Filtered in code: a second filter would need another collection group index.
  const snap = await db.collectionGroup("members").where("uid", "==", uid).get();
  return snap.docs.filter((d) => d.get("status") === "active").map((d) => d.ref.parent.parent!.id);
}

// ---------------------------------------------------------------------------
// Creating invitations
// ---------------------------------------------------------------------------

/**
 * Creates an invitation. Without `inviteeUid` it is a code to share (single use
 * for a shared habit, up to 50 uses for a group). With `inviteeUid` it is for
 * one person you already share a group with: they get a notification and see
 * it in their list, and no code is involved.
 */
export const createInvitation = defineCall(async (request) => {
  const uid = requireAuth(request);
  const type = str(request.data, "type", 1, 10) as Kind;
  const targetId = str(request.data, "targetId", 1, 100);
  if (type !== "shared" && type !== "group") {
    throw new ApiError("invalid-argument", "type must be shared or group.");
  }
  const inviteeUid =
    typeof request.data?.inviteeUid === "string" && request.data.inviteeUid !== ""
      ? (request.data.inviteeUid as string)
      : null;
  const maxUses = type === "group" && inviteeUid === null ? Number(request.data?.maxUses ?? 1) : 1;
  if (!Number.isInteger(maxUses) || maxUses < 1 || maxUses > MAX_MEMBERS) {
    throw new ApiError("invalid-argument", `maxUses must be 1 to ${MAX_MEMBERS}.`);
  }
  const ttlHours = Number(request.data?.ttlHours ?? 72);
  if (!Number.isFinite(ttlHours) || ttlHours < 1 || ttlHours > MAX_TTL_HOURS) {
    throw new ApiError("invalid-argument", "ttlHours is out of range.");
  }
  await enforceRateLimit(uid, "createInvitation", 20, 60 * 60 * 1000);

  if (inviteeUid !== null) {
    if (inviteeUid === uid) throw new ApiError("invalid-argument", "You cannot invite yourself.");
    // Only people you already share a group with. This stops anyone from
    // sending invitations to arbitrary user ids.
    const [mine, theirs] = await Promise.all([activeGroupIds(uid), activeGroupIds(inviteeUid)]);
    if (!mine.some((id) => theirs.includes(id))) {
      throw new ApiError(
        "permission-denied",
        "You can only invite people you share a group with. Share a code instead.",
      );
    }
  }

  const code = inviteeUid === null ? generateCode() : null;
  const codeHash = code === null ? null : hashCode(code);
  const inviteRef = db.collection("invitations").doc();
  const expiresAt = Timestamp.fromMillis(Date.now() + ttlHours * 3_600_000);

  const targetName = await db.runTransaction(async (tx) => {
    const data = await requireMayInvite(tx, type, targetId, uid);
    if (inviteeUid !== null) {
      const already =
        type === "shared"
          ? (data.participantUids ?? []).includes(inviteeUid)
          : (await tx.get(db.doc(`groups/${targetId}/members/${inviteeUid}`))).data()?.status === "active";
      if (already) throw new ApiError("already-exists", "They are already in.");
    }
    tx.set(inviteRef, {
      type,
      targetId,
      inviterUid: uid,
      ...(codeHash === null ? {} : { codeHash }),
      ...(inviteeUid === null ? {} : { inviteeUid }),
      status: "pending",
      uses: 0,
      maxUses,
      expiresAt,
      createdAt: FieldValue.serverTimestamp(),
    });
    if (codeHash !== null) tx.set(db.doc(`joinCodes/${codeHash}`), { invitationId: inviteRef.id });
    return (data.name as string | undefined) ?? "";
  });

  if (inviteeUid !== null) {
    const inviter = await readProfile(uid);
    await pendingRef(inviteeUid, inviteRef.id).set({
      invitationId: inviteRef.id,
      type,
      targetId,
      targetName,
      inviterName: inviter.displayName,
      expiresAtMs: expiresAt.toMillis(),
      createdAt: FieldValue.serverTimestamp(),
    });
    await notify(inviteeUid, {
      category: "invitations",
      type: "invitation.received",
      title: "New invitation",
      body: "You have been invited to a habit.",
      data: { invitationId: inviteRef.id },
      dedupeKey: `invite|${inviteRef.id}`,
    });
    return { invitationId: inviteRef.id };
  }
  // The plain code is returned once and never stored.
  return { invitationId: inviteRef.id, code };
});

/**
 * People the caller could invite: everyone in the caller's active groups,
 * except the caller and anyone already in the target. Names only.
 */
export const listInvitablePeople = defineCall(async (request) => {
  const uid = requireAuth(request);
  const type = str(request.data, "type", 1, 10) as Kind;
  const targetId = str(request.data, "targetId", 1, 100);
  if (type !== "shared" && type !== "group") {
    throw new ApiError("invalid-argument", "type must be shared or group.");
  }
  await enforceRateLimit(uid, "listPeople", 30, 10 * 60 * 1000);

  const data = await db.runTransaction((tx) => requireMayInvite(tx, type, targetId, uid));
  const alreadyIn = new Set<string>(
    type === "shared"
      ? (data.participantUids ?? [])
      : (
          await db.collection(`groups/${targetId}/members`).where("status", "==", "active").get()
        ).docs.map((d) => d.id),
  );

  const people = new Map<string, string>();
  for (const groupId of (await activeGroupIds(uid)).slice(0, 20)) {
    const members = await db
      .collection(`groups/${groupId}/members`)
      .where("status", "==", "active")
      .get();
    for (const m of members.docs) {
      if (m.id === uid || alreadyIn.has(m.id) || people.has(m.id)) continue;
      people.set(m.id, (m.get("displayName") as string | undefined) ?? "Habitry user");
      if (people.size >= MAX_PEOPLE) break;
    }
    if (people.size >= MAX_PEOPLE) break;
  }
  return {
    people: [...people.entries()]
      .map(([id, displayName]) => ({ uid: id, displayName }))
      .sort((a, b) => a.displayName.localeCompare(b.displayName)),
  };
});

// ---------------------------------------------------------------------------
// Looking up and answering
// ---------------------------------------------------------------------------

async function loadByCode(rawCode: string) {
  const codeHash = hashCode(rawCode);
  const mapping = await db.doc(`joinCodes/${codeHash}`).get();
  if (!mapping.exists) throw new ApiError("not-found", "That code was not recognised.");
  const inviteRef = db.doc(`invitations/${mapping.data()!.invitationId}`);
  return { inviteRef, codeHash };
}

function problemOf(invite: FirebaseFirestore.DocumentData): InvitationProblem | null {
  return invitationProblem(
    {
      status: invite.status,
      expiresAtMs: (invite.expiresAt as FirebaseFirestore.Timestamp).toMillis(),
      uses: invite.uses,
      maxUses: invite.maxUses,
    },
    Date.now(),
  );
}

/** Shows what the code is for, without revealing anything private. */
export const previewInvitation = defineCall(async (request) => {
  const uid = requireAuth(request);
  const code = str(request.data, "code", 4, 32);
  if (normalizeCode(code).length < 4) throw new ApiError("invalid-argument", "Bad code.");
  await enforceRateLimit(uid, "inviteLookup", 20, 10 * 60 * 1000);

  const { inviteRef } = await loadByCode(code);
  const invite = (await inviteRef.get()).data();
  if (!invite) throw new ApiError("not-found", "That code was not recognised.");
  const problem = problemOf(invite);
  if (problem) throw new ApiError("failed-precondition", PROBLEM_MESSAGES[problem], { reason: problem });

  const target = await targetRef(invite.type, invite.targetId).get();
  const inviter = await readProfile(invite.inviterUid);
  return {
    type: invite.type,
    name: target.data()?.name ?? "",
    inviterName: inviter.displayName,
  };
});

interface Outcome {
  type: Kind;
  targetId: string;
  inviter: string;
  accepted: boolean;
  /** True when an admin still has to approve. The person is not in yet. */
  pendingApproval: boolean;
  groupName: string;
}

/** Accepts or declines an invitation that was already looked up. */
async function answer(
  inviteRef: FirebaseFirestore.DocumentReference,
  uid: string,
  accept: boolean,
  requireInvitee: boolean,
): Promise<Outcome> {
  const profile = await readProfile(uid);
  return db.runTransaction(async (tx) => {
    const invite = (await tx.get(inviteRef)).data();
    if (!invite) throw new ApiError("not-found", "That invitation was not found.");
    if (requireInvitee && invite.inviteeUid !== uid) {
      throw new ApiError("permission-denied", "This invitation is not for you.");
    }
    const problem = problemOf(invite);
    if (problem) throw new ApiError("failed-precondition", PROBLEM_MESSAGES[problem], { reason: problem });
    if (invite.inviterUid === uid) {
      throw new ApiError("invalid-argument", "You cannot accept your own invitation.");
    }
    const base = {
      type: invite.type as Kind,
      targetId: invite.targetId as string,
      inviter: invite.inviterUid as string,
    };

    if (!accept) {
      if (invite.maxUses === 1) tx.update(inviteRef, { status: "declined" });
      return { ...base, accepted: false, pendingApproval: false, groupName: "" };
    }

    const target = targetRef(invite.type, invite.targetId);
    const targetData = (await tx.get(target)).data();
    if (!targetData || targetData.status !== "active") {
      throw new ApiError("failed-precondition", "This is no longer available.");
    }
    let pendingApproval = false;

    if (invite.type === "shared") {
      const participants: string[] = targetData.participantUids ?? [];
      if (participants.includes(uid)) {
        throw new ApiError("already-exists", "You are already taking part.");
      }
      if (participants.length >= MAX_MEMBERS) {
        throw new ApiError("resource-exhausted", "This habit is full.");
      }
      tx.update(target, {
        participantUids: [...participants, uid],
        participantCount: participants.length + 1,
      });
      tx.set(target.collection("participants").doc(uid), {
        uid,
        status: "active",
        displayName: profile.displayName,
        shareActivity: profile.shareActivity,
        joinedAt: FieldValue.serverTimestamp(),
      });
    } else {
      const memberRef = target.collection("members").doc(uid);
      const existing = (await tx.get(memberRef)).data();
      if (existing?.status === "active") {
        throw new ApiError("already-exists", "You are already a member.");
      }
      if (existing?.status === "removed") {
        throw new ApiError("permission-denied", "You were removed from this group.");
      }
      if ((targetData.memberCount ?? 0) >= MAX_MEMBERS) {
        throw new ApiError("resource-exhausted", "This group is full.");
      }
      if (targetData.requireApproval === true) {
        // An admin decides. Nothing is joined yet.
        pendingApproval = true;
        tx.set(target.collection("joinRequests").doc(uid), {
          uid,
          displayName: profile.displayName,
          shareActivity: profile.shareActivity,
          status: "pending",
          createdAt: FieldValue.serverTimestamp(),
        });
        auditInTx(tx, invite.targetId, uid, "member.requested", { invitationId: inviteRef.id });
      } else {
        tx.set(memberRef, {
          uid,
          role: "member",
          status: "active",
          displayName: profile.displayName,
          shareActivity: profile.shareActivity,
          joinedAt: FieldValue.serverTimestamp(),
        });
        tx.update(target, { memberCount: (targetData.memberCount ?? 0) + 1 });
        auditInTx(tx, invite.targetId, uid, "member.joined", { via: "invitation", invitationId: inviteRef.id });
      }
    }

    const uses = invite.uses + 1;
    tx.update(inviteRef, {
      uses,
      status: uses >= invite.maxUses && invite.maxUses === 1 ? "accepted" : invite.status,
    });
    return {
      ...base,
      accepted: true,
      pendingApproval,
      groupName: (targetData.name as string | undefined) ?? "",
    };
  });
}

/**
 * Accepts or declines. Send either `code` (a shared code) or `invitationId`
 * (an invitation made for you). Accepting adds the caller as a participant or
 * member, or files a join request when the group wants approval.
 */
export const respondToInvitation = defineCall(async (request) => {
  const uid = requireAuth(request);
  const accept = request.data?.accept === true;
  await enforceRateLimit(uid, "inviteLookup", 20, 10 * 60 * 1000);

  const byId = typeof request.data?.invitationId === "string" && request.data.invitationId !== "";
  const inviteRef = byId
    ? db.doc(`invitations/${str(request.data, "invitationId", 1, 100)}`)
    : (await loadByCode(str(request.data, "code", 4, 32))).inviteRef;

  const outcome = await answer(inviteRef, uid, accept, byId);

  // The invitation is answered either way, so it leaves the person's list.
  if (byId) await pendingRef(uid, inviteRef.id).delete();
  if (outcome.accepted && outcome.type === "group" && !outcome.pendingApproval) {
    await syncGroupMemberships(outcome.targetId);
  }

  if (outcome.pendingApproval) {
    // Tell the admins there is somebody waiting.
    const admins = await db.collection(`groups/${outcome.targetId}/members`).where("status", "==", "active").get();
    await Promise.all(
      admins.docs
        .filter((m) => m.get("role") === "owner" || m.get("role") === "admin")
        .map((m) =>
          notify(m.id, {
            category: "invitations",
            type: "group.join_request",
            title: "Join request",
            body: "Someone asked to join your group.",
            data: { groupId: outcome.targetId },
            dedupeKey: `join-request|${outcome.targetId}|${uid}`,
          }),
        ),
    );
  } else {
    // Tell the inviter. Failures here never affect the result.
    await notify(outcome.inviter, {
      category: "invitations",
      type: outcome.accepted ? "invitation.accepted" : "invitation.declined",
      title: outcome.accepted ? "Invitation accepted" : "Invitation declined",
      body: outcome.accepted ? "Someone joined from your invitation." : "Someone declined your invitation.",
      data: { type: outcome.type, targetId: outcome.targetId },
      dedupeKey: `invite-response|${inviteRef.id}|${uid}|${outcome.accepted}`,
    });
  }
  return {
    ok: true,
    accepted: outcome.accepted,
    type: outcome.type,
    targetId: outcome.targetId,
    pendingApproval: outcome.pendingApproval,
  };
});

export const revokeInvitation = defineCall(async (request) => {
  const uid = requireAuth(request);
  const invitationId = str(request.data, "invitationId", 1, 100);

  const inviteeUid = await db.runTransaction(async (tx) => {
    const ref = db.doc(`invitations/${invitationId}`);
    const invite = (await tx.get(ref)).data();
    if (!invite) throw new ApiError("not-found", "Invitation not found.");
    let allowed = invite.inviterUid === uid;
    if (!allowed && invite.type === "group") {
      const member = (await tx.get(db.doc(`groups/${invite.targetId}/members/${uid}`))).data() as
        | Member
        | undefined;
      allowed = !!member && member.status === "active" && (member.role === "owner" || member.role === "admin");
    }
    if (!allowed) throw new ApiError("permission-denied", "You cannot cancel this invitation.");
    // The code mapping stays, so a revoked code reports "cancelled" rather
    // than "not recognised".
    tx.update(ref, { status: "revoked" });
    return (invite.inviteeUid as string | undefined) ?? null;
  });
  if (inviteeUid !== null) await pendingRef(inviteeUid, invitationId).delete();
  return { ok: true };
});

// ---------------------------------------------------------------------------
// Join requests (groups that want approval)
// ---------------------------------------------------------------------------

/** An admin approves or rejects somebody who asked to join. */
export const reviewJoinRequest = defineCall(async (request) => {
  const uid = requireAuth(request);
  const groupId = str(request.data, "groupId", 1, 100);
  const requesterUid = str(request.data, "uid", 1, 128);
  const approve = request.data?.approve === true;

  await db.runTransaction(async (tx) => {
    const groupRef = db.doc(`groups/${groupId}`);
    const group = (await tx.get(groupRef)).data();
    if (!group || group.status !== "active") {
      throw new ApiError("failed-precondition", "This group is not available.");
    }
    const me = (await tx.get(db.doc(`groups/${groupId}/members/${uid}`))).data() as Member | undefined;
    if (!me || me.status !== "active" || (me.role !== "owner" && me.role !== "admin")) {
      throw new ApiError("permission-denied", "Only admins can review requests.");
    }
    const requestRef = db.doc(`groups/${groupId}/joinRequests/${requesterUid}`);
    const req = (await tx.get(requestRef)).data();
    if (!req || req.status !== "pending") {
      throw new ApiError("not-found", "That request is no longer waiting.");
    }
    const memberRef = db.doc(`groups/${groupId}/members/${requesterUid}`);
    const existing = (await tx.get(memberRef)).data();

    if (!approve) {
      tx.update(requestRef, { status: "rejected", reviewedBy: uid });
      auditInTx(tx, groupId, uid, "member.request_rejected", { uid: requesterUid });
      return;
    }
    if (existing?.status === "removed") {
      throw new ApiError("permission-denied", "That person was removed from this group.");
    }
    if ((group.memberCount ?? 0) >= MAX_MEMBERS) {
      throw new ApiError("resource-exhausted", "This group is full.");
    }
    tx.set(memberRef, {
      uid: requesterUid,
      role: "member",
      status: "active",
      displayName: req.displayName ?? "Habitry user",
      shareActivity: req.shareActivity !== false,
      joinedAt: FieldValue.serverTimestamp(),
    });
    tx.update(groupRef, { memberCount: (group.memberCount ?? 0) + 1 });
    tx.update(requestRef, { status: "approved", reviewedBy: uid });
    auditInTx(tx, groupId, uid, "member.request_approved", { uid: requesterUid });
  });

  if (approve) await syncGroupMemberships(groupId);
  await notify(requesterUid, {
    category: "invitations",
    type: approve ? "group.request_approved" : "group.request_rejected",
    title: approve ? "You're in" : "Request declined",
    body: approve ? "Your request to join a group was approved." : "Your request to join a group was declined.",
    data: { groupId },
    dedupeKey: `join-review|${groupId}|${requesterUid}|${approve}`,
  });
  return { ok: true };
});
