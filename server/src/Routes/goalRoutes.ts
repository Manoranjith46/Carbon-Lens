import { Router } from "express";
import {
  getGoals,
  createGoal,
  updateGoal,
  deleteGoal,
} from "../Controllers/goalController.js";

const router = Router();

// GET    /api/goals/:userId    → List all goals for a user
router.get("/:userId", getGoals);

// POST   /api/goals            → Create a new goal
router.post("/", createGoal);

// PUT    /api/goals/:id        → Update goal (progress, status)
router.put("/:id", updateGoal);

// DELETE /api/goals/:id        → Delete a goal
router.delete("/:id", deleteGoal);

export default router;
