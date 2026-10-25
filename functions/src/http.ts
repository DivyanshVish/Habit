import { getAuth } from "firebase-admin/auth";
import { ApiError, statusFor } from "./runtime";
import type { ErrorCode } from "./runtime";
import { handlers } from "./registry";

export interface HttpResult {
  status: number;
  body: unknown;
}

function bearerToken(header: string | undefined): string | null {
  if (!header) return null;
  const match = /^Bearer\s+(.+)$/i.exec(header.trim());
  return match ? match[1] : null;
}

function fail(code: ErrorCode, message: string, details?: unknown): HttpResult {
  return {
    status: statusFor(code),
    body: { error: { code, message, ...(details === undefined ? {} : { details }) } },
  };
}

/**
 * Handles one call: POST body `{ "name": "createGroup", "data": {...} }` and an
 * `Authorization: Bearer <Firebase ID token>` header. The user id always comes
 * from the verified token, never from the body.
 */
export async function handleCall(
  method: string | undefined,
  authorization: string | undefined,
  body: unknown,
): Promise<HttpResult> {
  if (method !== "POST") return fail("invalid-argument", "Use POST.");

  const name = (body as { name?: unknown } | null)?.name;
  if (typeof name !== "string" || !Object.hasOwn(handlers, name)) {
    return fail("not-found", "Unknown function.");
  }

  const token = bearerToken(authorization);
  if (!token) return fail("unauthenticated", "Sign in first.");
  let uid: string;
  try {
    uid = (await getAuth().verifyIdToken(token)).uid;
  } catch {
    return fail("unauthenticated", "Your session is not valid. Sign in again.");
  }

  try {
    const data = (body as { data?: unknown }).data ?? {};
    const result = await handlers[name]({ data, auth: { uid } });
    return { status: 200, body: { result: result ?? {} } };
  } catch (error) {
    if (error instanceof ApiError) {
      return fail(error.code, error.message, error.details);
    }
    console.error("call failed", name, String(error));
    return fail("internal", "Something went wrong. Please try again.");
  }
}
