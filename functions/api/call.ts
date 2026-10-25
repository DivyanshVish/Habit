import "./_init";
import { handleCall } from "../src/http";

interface Req {
  method?: string;
  headers: Record<string, string | string[] | undefined>;
  body?: unknown;
}

interface Res {
  status(code: number): Res;
  setHeader(name: string, value: string): void;
  json(body: unknown): void;
}

export default async function handler(req: Req, res: Res): Promise<void> {
  const header = req.headers.authorization;
  const result = await handleCall(
    req.method,
    Array.isArray(header) ? header[0] : header,
    req.body,
  );
  res.setHeader("Cache-Control", "no-store");
  res.status(result.status).json(result.body);
}
