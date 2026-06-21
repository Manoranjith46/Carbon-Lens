import { db } from "../config/firebase.js";

// ─── TypeScript Interfaces ──────────────────────────────────────────

export interface IActivity {
  id?: string;
  category: "transport" | "food" | "homeEnergy" | "purchases" | "waste";
  activityType: string;
  quantity: number;
  unit: string;
  activityTime: string; // ISO date string
  sourceType: "manual" | "routine" | "detection" | "integration" | "weeklyCheckIn";
  confidenceLevel:
    | "confirmed"
    | "connected"
    | "detected"
    | "estimated"
    | "defaultAssumption";
  calculatedKgCo2e: number | null;
  lowerEstimate: number | null;
  upperEstimate: number | null;
  metadata: Record<string, unknown> | null;
  userId: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Firestore Collection Reference ─────────────────────────────────

export const activitiesCollection = db.collection("activities");

// ─── Helper: Build Activity document with defaults ──────────────────

export function buildActivity(
  data: Partial<IActivity> & { category: string; activityType: string; quantity: number; unit: string; userId: string }
): Omit<IActivity, "id"> {
  const now = new Date().toISOString();
  return {
    category: data.category as IActivity["category"],
    activityType: data.activityType,
    quantity: data.quantity,
    unit: data.unit,
    activityTime: data.activityTime || now,
    sourceType: data.sourceType || "manual",
    confidenceLevel: data.confidenceLevel || "confirmed",
    calculatedKgCo2e: data.calculatedKgCo2e ?? null,
    lowerEstimate: data.lowerEstimate ?? null,
    upperEstimate: data.upperEstimate ?? null,
    metadata: data.metadata ?? null,
    userId: data.userId,
    createdAt: data.createdAt || now,
    updatedAt: now,
  };
}
