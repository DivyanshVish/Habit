import { getMessaging } from "firebase-admin/messaging";
import { db, FieldValue, readProfile } from "./common";
import {
  dedupeKey,
  inQuietHours,
  isReminderDue,
  localDateKeyFor,
  localMinutesFor,
} from "./logic";
import { completionPathFor } from "./logic";
import type { Reminder } from "./logic";

export type Category = "invitations" | "reminders" | "milestones";

export interface NotificationEvent {
  category: Category;
  type: string;
  title: string;
  body: string;
  /** Opaque ids only. Never put habit names or other private text here. */
  data?: Record<string, string>;
  /** Same key + same recipient is delivered once. */
  dedupeKey: string;
}

const DEFAULT_QUIET_START = 22 * 60;
const DEFAULT_QUIET_END = 7 * 60;

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function sendPush(uid: string, event: NotificationEvent): Promise<void> {
  const devices = await db.collection(`users/${uid}/devices`).get();
  const tokens = devices.docs.map((d) => d.id);
  if (tokens.length === 0) return;

  let lastError: unknown;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await getMessaging().sendEachForMulticast({
        tokens,
        notification: { title: event.title, body: event.body },
        data: { type: event.type, ...(event.data ?? {}) },
      });
      // Drop tokens that are no longer valid.
      const dead: string[] = [];
      response.responses.forEach((r, i) => {
        const code = r.error?.code ?? "";
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token"
        ) {
          dead.push(tokens[i]);
        }
      });
      await Promise.all(dead.map((t) => db.doc(`users/${uid}/devices/${t}`).delete()));
      return;
    } catch (error) {
      lastError = error;
      await sleep(500 * 2 ** attempt);
    }
  }
  throw lastError;
}

/**
 * Delivers one notification. Never throws: a failed notification must not
 * affect the action that caused it.
 * Returns true when it was newly delivered (or at least recorded).
 */
export async function notify(uid: string, event: NotificationEvent): Promise<boolean> {
  try {
    const key = dedupeKey(event.dedupeKey, uid);
    const eventRef = db.doc(`notificationEvents/${key}`);
    try {
      await eventRef.create({ uid, type: event.type, at: FieldValue.serverTimestamp() });
    } catch (error) {
      if ((error as { code?: number }).code === 6) return false; // already sent
      throw error;
    }

    const prefsSnap = await db.doc(`users/${uid}/settings/notifications`).get();
    const prefs = prefsSnap.data() ?? {};
    const categories = (prefs.categories ?? {}) as Record<string, boolean>;
    if (categories[event.category] === false) return false;

    // The inbox entry is written first, so it exists even if push fails.
    await db.doc(`users/${uid}/notifications/${key}`).set({
      type: event.type,
      title: event.title,
      body: event.body,
      data: event.data ?? {},
      read: false,
      createdAt: FieldValue.serverTimestamp(),
    });

    if (prefs.push === false) return true;
    const profile = await readProfile(uid);
    const minutes = localMinutesFor(Date.now(), {
      zone: profile.timezone,
      offsetMinutes: profile.utcOffsetMinutes,
    });
    const start = typeof prefs.quietStartMinutes === "number" ? prefs.quietStartMinutes : DEFAULT_QUIET_START;
    const end = typeof prefs.quietEndMinutes === "number" ? prefs.quietEndMinutes : DEFAULT_QUIET_END;
    if (inQuietHours(minutes, start, end)) return true;

    try {
      await sendPush(uid, event);
    } catch (error) {
      console.error("push failed", { uid, type: event.type, error: String(error) });
      await eventRef.set({ pushFailed: true }, { merge: true });
    }
    return true;
  } catch (error) {
    console.error("notify failed", { uid, type: event.type, error: String(error) });
    return false;
  }
}

// ---------------------------------------------------------------------------
// Reminders
// ---------------------------------------------------------------------------

/**
 * Sends the reminders that are due in this 15 minute window, in each person's
 * own time zone. Call it every 15 minutes (see functions/README.md). Quiet
 * hours are applied by [notify]. Reads every enabled reminder per run, which is
 * fine for an app this size; index reminders by time slot if that grows.
 */
export async function runReminders(): Promise<{ checked: number; sent: number }> {
  const now = Date.now();
  const reminders = await db.collectionGroup("reminders").where("enabled", "==", true).get();
  let sent = 0;

  for (const doc of reminders.docs) {
    try {
      const reminder = doc.data() as Reminder;
      const uid = doc.ref.parent.parent?.id;
      if (!uid) continue;
      const profile = await readProfile(uid);
      const zone = { zone: profile.timezone, offsetMinutes: profile.utcOffsetMinutes };
      if (!isReminderDue(localMinutesFor(now, zone), reminder.minutesOfDay)) continue;

      const today = localDateKeyFor(now, zone);
      const path = completionPathFor(reminder, uid, today);
      if (path === null) continue; // malformed reminder
      if (reminder.onlyIfIncomplete !== false && (await db.doc(path).get()).exists) continue;

      const delivered = await notify(uid, {
        category: "reminders",
        type: "habit.reminder",
        title: "Habit reminder",
        // No habit names: this can show on a lock screen.
        body: "You have a habit waiting for today.",
        data: { reminderId: doc.id },
        dedupeKey: `reminder|${doc.id}|${today}`,
      });
      if (delivered) sent++;
    } catch (error) {
      console.error("reminder failed", doc.ref.path, String(error));
    }
  }
  return { checked: reminders.size, sent };
}
