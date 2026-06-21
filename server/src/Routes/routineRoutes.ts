import { Router } from "express";
import {
  getRoutines,
  createRoutine,
  logRoutine,
  deleteRoutine,
} from "../Controllers/routineController.js";

const router = Router();

// GET    /api/routines/:userId      → List all routines
router.get("/:userId", getRoutines);

// POST   /api/routines              → Create a routine
router.post("/", createRoutine);

// POST   /api/routines/:id/log      → Quick-log all activities from a routine
router.post("/:id/log", logRoutine);

// DELETE /api/routines/:id          → Delete a routine
router.delete("/:id", deleteRoutine);

export default router;
