import { Router } from "express";
import { getRecommendations } from "../Controllers/recommendationController.js";

const router = Router();

// GET /api/recommendations/:userId → Personalized recommendations
router.get("/:userId", getRecommendations);

export default router;
