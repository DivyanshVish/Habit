import "./_init";
import { runCloseCycles } from "../src/cycles";

interface Req {
  headers: Record<string, string | string[] | undefined>;
}

interface Res {
  status(code: number): Res;
  json(body: unknown): void;
}

/**
 * Daily backstop: freezes finished days for habits nobody opened, so group
 * streaks stay current. Vercel sends `Authorization: Bearer $CRON_SECRET`.
 */
export default async function handler(req: Req, res: Res): Promise<void> {
  const secret = process.env.CRON_SECRET;
  if (!secret || req.headers.authorization !== `Bearer ${secret}`) {
    res.status(401).json({ error: "unauthorized" });
    return;
  }
  res.status(200).json(await runCloseCycles());
}
