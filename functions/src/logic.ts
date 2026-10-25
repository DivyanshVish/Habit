// Pure helpers shared by the Cloud Functions. No Firebase imports, so they are
// unit-tested directly with `node --test`.

import { createHash, randomBytes } from "node:crypto";

const DAY_MS = 86_400_000;

// ---------------------------------------------------------------------------
// Date keys (yyyy-MM-dd)
// ---------------------------------------------------------------------------

export function dateKeyFromUtc(ms: number): string {
  return new Date(ms).toISOString().slice(0, 10);
}

export function parseDateKey(key: string): number {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(key)) {
    throw new Error(`Bad date key: ${key}`);
  }
  const ms = Date.parse(`${key}T00:00:00.000Z`);
  if (Number.isNaN(ms) || dateKeyFromUtc(ms) !== key) {
    throw new Error(`Bad date key: ${key}`);
  }
  return ms;
}

export function addDays(key: string, days: number): string {
  return dateKeyFromUtc(parseDateKey(key) + days * DAY_MS);
}

/** 1 = Monday ... 7 = Sunday. */
export function weekdayOf(key: string): number {
  const js = new Date(parseDateKey(key)).getUTCDay(); // 0 = Sunday
  return js === 0 ? 7 : js;
}

export const ALL_WEEKDAYS = [1, 2, 3, 4, 5, 6, 7];

/**
 * Every date key that is "today" in at least one time zone right now
 * (UTC-12 to UTC+14). That is two or three keys.
 */
export function activeDateKeys(nowMs: number): string[] {
  const keys = new Set<string>();
  for (let offsetHours = -12; offsetHours <= 14; offsetHours++) {
    keys.add(dateKeyFromUtc(nowMs + offsetHours * 3_600_000));
  }
  return [...keys].sort();
}

/**
 * A cycle closes when no client can write to it any more. The rules accept a
 * date key only from UTC yesterday to UTC tomorrow, so the last moment for
 * key D is the end of UTC day D+1, which is D+2 at 00:00 UTC.
 */
export function cycleCloseAtMs(key: string): number {
  return parseDateKey(key) + 2 * DAY_MS;
}

export function isCycleClosable(key: string, nowMs: number): boolean {
  return nowMs >= cycleCloseAtMs(key);
}

// ---------------------------------------------------------------------------
// Schedules
// ---------------------------------------------------------------------------

export function isScheduled(key: string, weekdays: number[]): boolean {
  return weekdays.includes(weekdayOf(key));
}

export function normalizeWeekdays(input: unknown): number[] {
  if (!Array.isArray(input) || input.length === 0) return [...ALL_WEEKDAYS];
  const days = [...new Set(input.filter((d) => Number.isInteger(d) && d >= 1 && d <= 7))];
  return days.length === 0 ? [...ALL_WEEKDAYS] : (days as number[]).sort();
}

// ---------------------------------------------------------------------------
// Cycle aggregates
// ---------------------------------------------------------------------------

export interface CycleAggregate {
  /** Eligible members who completed. Drives the engine and the percent. */
  completedCount: number;
  /** Only the members who allow others to see their activity. */
  visibleCompletedUids: string[];
}

/**
 * Intersects the completions with the eligibility snapshot (a member who
 * joined after the cycle opened does not count) and applies each member's
 * visibility setting. Calling this twice with the same input gives the same
 * answer, which is what makes the trigger safe to retry.
 */
export function aggregateCycle(
  eligibleUids: string[],
  completedUids: string[],
  hiddenUids: string[],
): CycleAggregate {
  const eligible = new Set(eligibleUids);
  const hidden = new Set(hiddenUids);
  const counted = [...new Set(completedUids)].filter((uid) => eligible.has(uid));
  return {
    completedCount: counted.length,
    visibleCompletedUids: counted.filter((uid) => !hidden.has(uid)).sort(),
  };
}

// ---------------------------------------------------------------------------
// Streaks
// ---------------------------------------------------------------------------

export interface StreakStats {
  currentStreak: number;
  bestStreak: number;
  completed: number;
  missed: number;
}

/** Mirrors lib/features/groups/domain/services/streak_history_calculator.dart. */
export function calculateStreak(
  doneDates: string[],
  start: string,
  today: string,
  weekdays: number[] = ALL_WEEKDAYS,
): StreakStats {
  const empty = { currentStreak: 0, bestStreak: 0, completed: 0, missed: 0 };
  if (today < start || weekdays.length === 0) return empty;

  const done = new Set(doneDates);
  let completed = 0;
  let missed = 0;
  let run = 0;
  let best = 0;

  for (let day = start; day <= today; day = addDays(day, 1)) {
    if (!weekdays.includes(weekdayOf(day))) continue;
    if (done.has(day)) {
      completed++;
      run++;
      if (run > best) best = run;
    } else if (day === today) {
      // Still open: neither extends nor breaks the run.
    } else {
      missed++;
      run = 0;
    }
  }
  return { currentStreak: run, bestStreak: best, completed, missed };
}

export interface GroupStreak {
  current: number;
  best: number;
  lastDateKey: string | null;
}

/**
 * Applies one finalized cycle to the group streak. Cycles must be applied in
 * date order. A cycle at or before lastDateKey is ignored, so closing twice
 * is harmless. Habits without a shared target never build a group streak.
 */
export function applyClosedCycle(
  streak: GroupStreak,
  dateKey: string,
  hasTarget: boolean,
  reached: boolean,
): GroupStreak {
  if (streak.lastDateKey !== null && dateKey <= streak.lastDateKey) return streak;
  if (!hasTarget) return { ...streak, lastDateKey: dateKey };
  if (!reached) return { current: 0, best: streak.best, lastDateKey: dateKey };
  const current = streak.current + 1;
  return { current, best: Math.max(streak.best, current), lastDateKey: dateKey };
}

// ---------------------------------------------------------------------------
// Invitations and join codes
// ---------------------------------------------------------------------------

const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O/1/I

export function generateCode(length = 8): string {
  const bytes = randomBytes(length);
  let out = "";
  for (let i = 0; i < length; i++) {
    out += CODE_ALPHABET[bytes[i] % CODE_ALPHABET.length];
  }
  return out;
}

export function normalizeCode(input: string): string {
  return input.toUpperCase().replace(/[^A-Z0-9]/g, "");
}

export function hashCode(code: string): string {
  return createHash("sha256").update(normalizeCode(code)).digest("hex");
}

export type InvitationProblem =
  | "revoked"
  | "expired"
  | "exhausted"
  | "used"
  | "not-pending";

export interface InvitationState {
  status: "pending" | "accepted" | "declined" | "revoked";
  expiresAtMs: number;
  uses: number;
  maxUses: number;
}

export function invitationProblem(
  invite: InvitationState,
  nowMs: number,
): InvitationProblem | null {
  if (invite.status === "revoked") return "revoked";
  if (nowMs >= invite.expiresAtMs) return "expired";
  if (invite.uses >= invite.maxUses) {
    return invite.maxUses === 1 ? "used" : "exhausted";
  }
  if (invite.status !== "pending") return "not-pending";
  return null;
}

// ---------------------------------------------------------------------------
// Rate limiting
// ---------------------------------------------------------------------------

export interface RateWindow {
  windowStartMs: number;
  count: number;
}

/** Fixed window limiter. Returns the next state and whether to allow. */
export function takeToken(
  state: RateWindow | undefined,
  nowMs: number,
  limit: number,
  windowMs: number,
): { next: RateWindow; allowed: boolean } {
  if (!state || nowMs - state.windowStartMs >= windowMs) {
    return { next: { windowStartMs: nowMs, count: 1 }, allowed: true };
  }
  if (state.count >= limit) return { next: state, allowed: false };
  return { next: { ...state, count: state.count + 1 }, allowed: true };
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

/**
 * Where a user is. The app reports its UTC offset on every launch (Flutter has
 * no built-in IANA zone name), so the offset is the normal case. An IANA
 * [zone] wins when present.
 */
export interface ZoneSpec {
  zone?: string;
  offsetMinutes?: number;
}

export function localMinutesFor(nowMs: number, spec: ZoneSpec): number {
  if (spec.zone && isValidTimeZone(spec.zone)) return localMinutes(nowMs, spec.zone);
  const shifted = new Date(nowMs + (spec.offsetMinutes ?? 0) * 60_000);
  return shifted.getUTCHours() * 60 + shifted.getUTCMinutes();
}

export function localDateKeyFor(nowMs: number, spec: ZoneSpec): string {
  if (spec.zone && isValidTimeZone(spec.zone)) return localDateKey(nowMs, spec.zone);
  return dateKeyFromUtc(nowMs + (spec.offsetMinutes ?? 0) * 60_000);
}

export function localMinutes(nowMs: number, timeZone: string): number {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone,
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).formatToParts(new Date(nowMs));
  const hour = Number(parts.find((p) => p.type === "hour")?.value ?? "0");
  const minute = Number(parts.find((p) => p.type === "minute")?.value ?? "0");
  return hour * 60 + minute;
}

export function localDateKey(nowMs: number, timeZone: string): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date(nowMs));
  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? "";
  return `${get("year")}-${get("month")}-${get("day")}`;
}

/** Quiet hours as minutes after local midnight. Wraps past midnight. */
export function inQuietHours(
  minutes: number,
  startMinutes: number,
  endMinutes: number,
): boolean {
  if (startMinutes === endMinutes) return false;
  if (startMinutes < endMinutes) {
    return minutes >= startMinutes && minutes < endMinutes;
  }
  return minutes >= startMinutes || minutes < endMinutes;
}

export function dedupeKey(...parts: string[]): string {
  return createHash("sha256").update(parts.join("|")).digest("hex").slice(0, 40);
}

export function isValidTimeZone(zone: string): boolean {
  try {
    new Intl.DateTimeFormat("en", { timeZone: zone });
    return true;
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Account moves
// ---------------------------------------------------------------------------

/**
 * Replaces [from] with [to] in a list of user ids. Safe to repeat: if [from]
 * is already gone it changes nothing, and [to] never appears twice.
 */
export function swapUid(uids: string[], from: string, to: string): string[] {
  const out: string[] = [];
  for (const uid of uids) {
    const next = uid === from ? to : uid;
    if (!out.includes(next)) out.push(next);
  }
  return out;
}

/** Completion documents are named {uid}_{dateKey}. Returns the new name. */
export function renameCompletionId(id: string, from: string, to: string): string {
  const prefix = `${from}_`;
  return id.startsWith(prefix) ? `${to}_${id.slice(prefix.length)}` : id;
}

// ---------------------------------------------------------------------------
// Reminders
// ---------------------------------------------------------------------------

export const REMINDER_SLOT_MINUTES = 15;

/**
 * Whether a reminder set for [reminderMinutes] (minutes after local midnight)
 * is due now. The job runs every [slot] minutes, so a reminder fires in the
 * run whose window contains its time, and only in that one.
 */
export function isReminderDue(
  nowMinutes: number,
  reminderMinutes: number,
  slot: number = REMINDER_SLOT_MINUTES,
): boolean {
  const slotStart = reminderMinutes - (reminderMinutes % slot);
  return nowMinutes >= slotStart && nowMinutes < slotStart + slot;
}

export interface Reminder {
  enabled: boolean;
  /** 'personal' | 'shared' | 'group' */
  kind: string;
  /** Personal: the habit id. */
  itemId?: string;
  /** Shared habit id. */
  sharedId?: string;
  /** Group habit: the group and the habit. */
  groupId?: string;
  habitId?: string;
  /** Minutes after local midnight. */
  minutesOfDay: number;
  /** Skip the reminder when the habit is already done today. */
  onlyIfIncomplete?: boolean;
}

/**
 * The completion document to check for [uid] on [today]. Built here, never
 * taken from the reminder, and always named after [uid]: a reminder can only
 * ever look at its owner's own records.
 */
export function completionPathFor(reminder: Reminder, uid: string, today: string): string | null {
  const safe = (v: string | undefined): v is string => typeof v === "string" && /^[A-Za-z0-9_-]{1,128}$/.test(v);
  switch (reminder.kind) {
    case "personal":
      return safe(reminder.itemId) ? `users/${uid}/completions/${reminder.itemId}_${today}` : null;
    case "shared":
      return safe(reminder.sharedId) ? `sharedHabits/${reminder.sharedId}/completions/${uid}_${today}` : null;
    case "group":
      return safe(reminder.groupId) && safe(reminder.habitId)
        ? `groups/${reminder.groupId}/habits/${reminder.habitId}/completions/${uid}_${today}`
        : null;
    default:
      return null;
  }
}
