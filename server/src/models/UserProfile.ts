import { db } from "../config/firebase.js";

// ─── TypeScript Interface ───────────────────────────────────────────

export interface IUserProfile {
  id?: string;
  userId: string;
  regionCode: string | null;
  dietPattern: string | null;
  travelPattern: string | null;
  householdType: string | null;
  householdSize: number | null;
  consumptionPattern: string | null;
  onboardingCompleted: boolean;
  weeklyBaselineKgCo2e: number;
  weeklyLimitKgCo2e: number | null;
  createdAt: string;
  updatedAt: string;
}

// ─── Firestore Collection Reference ─────────────────────────────────

export const profilesCollection = db.collection("userProfiles");

// ─── Helper: Build default profile ──────────────────────────────────

export function buildDefaultProfile(userId: string): Omit<IUserProfile, "id"> {
  const now = new Date().toISOString();
  return {
    userId,
    regionCode: null,
    dietPattern: null,
    travelPattern: null,
    householdType: null,
    householdSize: null,
    consumptionPattern: null,
    onboardingCompleted: false,
    weeklyBaselineKgCo2e: 0,
    weeklyLimitKgCo2e: null,
    createdAt: now,
    updatedAt: now,
  };
}
