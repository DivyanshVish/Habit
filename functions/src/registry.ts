import { deleteAccount, syncProfile } from "./account";
import { migrateAccount } from "./migrate";
import { refreshCycle } from "./cycles";
import {
  archiveGroup,
  archiveGroupHabit,
  createGroup,
  createGroupHabit,
  leaveGroup,
  removeMember,
  setMemberRole,
  transferOwnership,
  updateGroupHabit,
  updateGroupSettings,
} from "./groups";
import {
  createInvitation,
  listInvitablePeople,
  previewInvitation,
  respondToInvitation,
  reviewJoinRequest,
  revokeInvitation,
} from "./invitations";
import type { CallHandler } from "./runtime";
import {
  createSharedHabit,
  leaveSharedHabit,
  mirrorPersonalCompletion,
} from "./sharedHabits";

/** Every function the app can call, by name. Anything not listed is a 404. */
export const handlers: Readonly<Record<string, CallHandler>> = {
  ping: async () => ({ ok: true }),

  createGroup,
  updateGroupSettings,
  leaveGroup,
  removeMember,
  setMemberRole,
  transferOwnership,
  archiveGroup,
  createGroupHabit,
  updateGroupHabit,
  archiveGroupHabit,

  createSharedHabit,
  leaveSharedHabit,
  mirrorPersonalCompletion,

  createInvitation,
  listInvitablePeople,
  previewInvitation,
  respondToInvitation,
  reviewJoinRequest,
  revokeInvitation,

  refreshCycle,

  syncProfile,
  deleteAccount,
  migrateAccount,
};
