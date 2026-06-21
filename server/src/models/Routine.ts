import { db } from "../config/firebase.js";

// ─── TypeScript Interfaces ──────────────────────────────────────────

export interface IRoutineActivity {
  category: string;
  activityType: string;
  quantity: number;
  unit: string;
}

export interface IRoutine {
  id?: string;
  name: string;
  activities: IRoutineActivity[];
  daysOfWeek: number[]; // 1=Monday, 7=Sunday
  userId: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Firestore Collection Reference ─────────────────────────────────

export const routinesCollection = db.collection("routines");

// ─── Helper: Build Routine document with defaults ───────────────────

export function buildRoutine(
  data: Partial<IRoutine> & { name: string; activities: IRoutineActivity[]; userId: string }
): Omit<IRoutine, "id"> {
  const now = new Date().toISOString();
  return {
    name: data.name,
    activities: data.activities,
    daysOfWeek: data.daysOfWeek ?? [],
    userId: data.userId,
    createdAt: data.createdAt || now,
    updatedAt: now,
  };
}
