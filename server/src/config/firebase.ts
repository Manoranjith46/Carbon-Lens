import { initializeApp, cert, getApps, App } from "firebase-admin/app";
import { getFirestore, Firestore } from "firebase-admin/firestore";
import dotenv from "dotenv";
import { readFileSync } from "fs";
import { resolve } from "path";

dotenv.config();

/**
 * Initialize Firebase Admin SDK.
 *
 * Option 1 — Service account JSON file:
 *   Set FIREBASE_SERVICE_ACCOUNT_PATH in .env
 *
 * Option 2 — Individual environment variables:
 *   Set FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY
 */
function initializeFirebase(): App {
  // Already initialized
  if (getApps().length > 0) {
    return getApps()[0];
  }

  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

  if (serviceAccountPath) {
    // Option 1: Load from JSON file
    const absolutePath = resolve(serviceAccountPath);
    const serviceAccount = JSON.parse(readFileSync(absolutePath, "utf-8"));
    return initializeApp({
      credential: cert(serviceAccount),
    });
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n");

  if (projectId && clientEmail && privateKey) {
    // Option 2: Load from individual env vars
    return initializeApp({
      credential: cert({ projectId, clientEmail, privateKey }),
    });
  }

  // Fallback: Application Default Credentials (e.g. running on GCP)
  return initializeApp();
}

const app = initializeFirebase();
export const db: Firestore = getFirestore(app);

console.log("✅ Firebase Admin SDK initialized");

export default db;
