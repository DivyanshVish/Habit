// Framework-neutral request handling. The handlers in this folder are plain
// functions of (request) => result. `api/call.ts` exposes them over HTTP on
// Vercel; nothing here depends on Cloud Functions.

/** Error codes mirror gRPC/Firebase names so the app can map them. */
export type ErrorCode =
  | "unauthenticated"
  | "permission-denied"
  | "not-found"
  | "invalid-argument"
  | "failed-precondition"
  | "already-exists"
  | "resource-exhausted"
  | "internal";

export class ApiError extends Error {
  constructor(
    readonly code: ErrorCode,
    message: string,
    readonly details?: unknown,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

export interface CallRequest {
  /** Body of the call. Validated by each handler. */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: any;
  /** Set by the HTTP layer after verifying the Firebase ID token. */
  auth?: { uid: string };
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type CallHandler = (request: CallRequest) => Promise<any>;

/** Marks a function as an API handler. Exists for readability and typing. */
export function defineCall(handler: CallHandler): CallHandler {
  return handler;
}

/** HTTP status for each error code. */
export function statusFor(code: ErrorCode): number {
  switch (code) {
    case "unauthenticated":
      return 401;
    case "permission-denied":
      return 403;
    case "not-found":
      return 404;
    case "invalid-argument":
      return 400;
    case "failed-precondition":
    case "already-exists":
      return 409;
    case "resource-exhausted":
      return 429;
    default:
      return 500;
  }
}
