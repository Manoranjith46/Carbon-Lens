import { Router } from "express";
import {
  getActivities,
  createActivity,
  updateActivity,
  deleteActivity,
  getWeeklySummary,
} from "../Controllers/activityController.js";

const router = Router();

// GET    /api/activities/:userId              → List activities (with optional filters)
// GET    /api/activities/:userId/weekly-summary → Weekly aggregated summary
router.get("/:userId/weekly-summary", getWeeklySummary);
router.get("/:userId", getActivities);

// POST   /api/activities                      → Create new activity
router.post("/", createActivity);

// PUT    /api/activities/:id                   → Update activity
router.put("/:id", updateActivity);

// DELETE /api/activities/:id                   → Delete activity
router.delete("/:id", deleteActivity);

export default router;
