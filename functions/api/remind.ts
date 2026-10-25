import "./_init";
import { runReminders } from "../src/notifications";

interface Req {
  headers: Record<string, string | string[] | undefined>;
}

interface Res {
  status(code: number): Res;
  json(body: unknown): void;
}

/**
 * Sends the reminders due in this 15 minute window. Needs something to call it
 * every 15 minutes (Vercel's free cron only runs daily), with
 * `Authorization: Bearer $CRON_SECRET`.
 */
export default async function handler(req: Req, res: Res): Promise<void> {
  const secret = process.env.CRON_SECRET;
  if (!secret || req.headers.authorization !== `Bearer ${secret}`) {
    res.status(401).json({ error: "unauthorized" });
    return;
  }
  res.status(200).json(await runReminders());
}
