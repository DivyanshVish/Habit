import { db, FieldValue } from "./common";

/**
 * Rewrites users/{uid}/memberships/{groupId} for every person in a group, so it
 * matches groups/{id}/members. Called after any change to a group's members,
 * name or state. Idempotent, and group size is capped, so one batch is enough.
 *
 * Clients list "my groups" from this owner-readable collection. A collection
 * group query over `members` cannot be authorised by security rules, because
 * membership has to be looked up per document.
 */
export async function syncGroupMemberships(groupId: string): Promise<void> {
  try {
    const [group, members] = await Promise.all([
      db.doc(`groups/${groupId}`).get(),
      db.collection(`groups/${groupId}/members`).get(),
    ]);
    const groupData = group.data();
    if (!groupData) return;
    for (let i = 0; i < members.docs.length; i += 400) {
      const batch = db.batch();
      for (const member of members.docs.slice(i, i + 400)) {
        batch.set(
          db.doc(`users/${member.id}/memberships/${groupId}`),
          {
            groupId,
            role: member.get("role"),
            status: member.get("status"),
            groupName: groupData.name ?? "",
            groupStatus: groupData.status ?? "active",
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }
      await batch.commit();
    }
  } catch (error) {
    // The change itself already succeeded; the list catches up on the next sync.
    console.error("syncGroupMemberships failed", groupId, String(error));
  }
}
