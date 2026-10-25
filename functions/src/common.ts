import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import type { DocumentReference, Transaction } from "firebase-admin/firestore";
import { ApiError } from "./runtime";
import type { CallRequest } from "./runtime";
import { takeToken } from "./logic";
import type { RateWindow } from "./logic";

export const db = getFirestore();
// A stray `undefined` field is dropped instead of failing the whole request.
db.settings({ ignoreUndefinedProperties: true });

/** Payload for Firestore updates built up field by field. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type UpdateData = Record<string, any>;
export { FieldValue, Timestamp };

/** Maximum active members in a group, or active participants in a shared habit. */
export const MAX_MEMBERS = 50;
export const MAX_ACTIVE_GROUP_HABITS = 20;

export function requireAuth(request: CallRequest): string {
  const uid = request.auth?.uid;
  if (!uid) throw new ApiError("unauthenticated", "Sign in first.");
  return uid;
}

export function str(data: unknown, key: string, min: number, max: number): string {
  const value = (data as Record<string, unknown> | undefined)?.[key];
  if (typeof value !== "string") {
    throw new ApiError("invalid-argument", `${key} is required.`);
  }
  const trimmed = value.trim();
  if (trimmed.length < min || trimmed.length > max) {
    throw new ApiError("invalid-argument", `${key} must be ${min} to ${max} characters.`);
  }
  return trimmed;
}

export function optionalStr(data: unknown, key: string, max: number): string {
  const value = (data as Record<string, unknown> | undefined)?.[key];
  if (value === undefined || value === null || value === "") return "";
  return str(data, key, 0, max);
}

/** Rate limits per user and bucket. Throws resource-exhausted when exceeded. */
export async function enforceRateLimit(
  uid: string,
  bucket: string,
  limit: number,
  windowMs: number,
): Promise<void> {
  const ref = db.doc(`rateLimits/${uid}_${bucket}`);
  const allowed = await db.runTransaction(async (tx: Transaction) => {
    const snap = await tx.get(ref);
    const state = snap.exists ? (snap.data() as RateWindow) : undefined;
    const { next, allowed } = takeToken(state, Date.now(), limit, windowMs);
    tx.set(ref, next);
    return allowed;
  });
  if (!allowed) {
    throw new ApiError("resource-exhausted", "Too many attempts. Try again later.");
  }
}

export interface Profile {
  displayName: string;
  shareActivity: boolean;
  /** Optional IANA name. */
  timezone?: string;
  /** Minutes east of UTC, reported by the app on each launch. */
  utcOffsetMinutes: number;
}

export async function readProfile(uid: string): Promise<Profile> {
  const snap = await db.doc(`users/${uid}/settings/profile`).get();
  const data = snap.data() ?? {};
  return {
    displayName:
      typeof data.displayName === "string" && data.displayName.trim() !== ""
        ? data.displayName
        : "Habitry user",
    shareActivity: data.visibility !== "countsOnly",
    timezone: typeof data.timezone === "string" ? data.timezone : undefined,
    utcOffsetMinutes:
      typeof data.utcOffsetMinutes === "number" ? data.utcOffsetMinutes : 0,
  };
}

export async function audit(
  groupId: string,
  actorUid: string,
  action: string,
  details: Record<string, unknown> = {},
): Promise<void> {
  await db.collection(`groups/${groupId}/auditLog`).add({
    action,
    actorUid,
    details,
    at: FieldValue.serverTimestamp(),
  });
}

export function auditInTx(
  tx: Transaction,
  groupId: string,
  actorUid: string,
  action: string,
  details: Record<string, unknown> = {},
): void {
  const ref: DocumentReference = db.collection(`groups/${groupId}/auditLog`).doc();
  tx.set(ref, { action, actorUid, details, at: FieldValue.serverTimestamp() });
}

export type Role = "owner" | "admin" | "member";

export interface Member {
  uid: string;
  role: Role;
  status: "active" | "left" | "removed";
  displayName: string;
  shareActivity: boolean;
}

export async function requireActiveMember(
  tx: Transaction,
  groupId: string,
  uid: string,
): Promise<Member> {
  const snap = await tx.get(db.doc(`groups/${groupId}/members/${uid}`));
  const data = snap.data() as Member | undefined;
  if (!data || data.status !== "active") {
    throw new ApiError("permission-denied", "You are not a member of this group.");
  }
  return data;
}

export function requireAdmin(member: Member): void {
  if (member.role !== "owner" && member.role !== "admin") {
    throw new ApiError("permission-denied", "Only admins can do this.");
  }
}
