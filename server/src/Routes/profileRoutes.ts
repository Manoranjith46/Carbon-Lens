import { Router } from "express";
import {
  getProfile,
  createOrUpdateProfile,
  completeOnboarding,
  deleteProfile,
} from "../Controllers/profileController.js";

const router = Router();

// GET    /api/profile/:userId               → Get user profile
router.get("/:userId", getProfile);

// POST   /api/profile                       → Create or update profile
router.post("/", createOrUpdateProfile);

// POST   /api/profile/:userId/onboarding    → Complete onboarding flow
router.post("/:userId/onboarding", completeOnboarding);

// DELETE /api/profile/:userId               → Delete profile
router.delete("/:userId", deleteProfile);

export default router;
