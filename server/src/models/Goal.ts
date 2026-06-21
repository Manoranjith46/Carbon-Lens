import { db } from "../config/firebase.js";

// ─── TypeScript Interface ───────────────────────────────────────────

export interface IGoal {
  id?: string;
  title: string;
  goalType:
    | "weeklyReduction"
    | "monthlyReduction"
    | "categorySpecific"
    | "habit"
    | "activity";
  category: string | null;
  targetValue: number;
  baselineValue: number;
  progressValue: number;
  startDate: string;
  endDate: string;
  status: "active" | "completed" | "expired";
  userId: string;
  createdAt: string;
  updatedAt: string;
}

// ─── Firestore Collection Reference ─────────────────────────────────

export const goalsCollection = db.collection("goals");

// ─── Helper: Build Goal document with defaults ──────────────────────

export function buildGoal(
  data: Partial<IGoal> & { title: string; goalType: string; targetValue: number; baselineValue: number; userId: string }
): Omit<IGoal, "id"> {
  const now = new Date().toISOString();
  const oneWeekLater = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
  return {
    title: data.title,
    goalType: data.goalType as IGoal["goalType"],
    category: data.category ?? null,
    targetValue: data.targetValue,
    baselineValue: data.baselineValue,
    progressValue: data.progressValue ?? 0,
    startDate: data.startDate || now,
    endDate: data.endDate || oneWeekLater,
    status: data.status || "active",
    userId: data.userId,
    createdAt: data.createdAt || now,
    updatedAt: now,
  };
}

// ─── Computed Helpers (mirrors Flutter's Goal getters) ───────────────

export function getProgressPercent(goal: IGoal): number {
  if (goal.targetValue <= 0) return 0;
  return Math.min((goal.progressValue / goal.targetValue) * 100, 150);
}

export function getDaysRemaining(goal: IGoal): number {
  const diff = new Date(goal.endDate).getTime() - Date.now();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}
