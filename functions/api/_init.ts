// Imported first by every route so the Admin SDK is ready before any module
// that touches Firestore is loaded.
import { applicationDefault, cert, getApps, initializeApp } from "firebase-admin/app";

if (getApps().length === 0) {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  initializeApp(
    raw
      ? { credential: cert(JSON.parse(raw)) }
      : { credential: applicationDefault() },
  );
}
