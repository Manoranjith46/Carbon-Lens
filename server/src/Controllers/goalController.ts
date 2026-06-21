import { Request, Response } from "express";
import {
  goalsCollection,
  buildGoal,
  getProgressPercent,
  getDaysRemaining,
  IGoal,
} from "../models/Goal.js";
import { QueryDocumentSnapshot } from "firebase-admin/firestore";

/**
 * @desc    Get all goals for a user
 * @route   GET /api/goals/:userId
 */
export const getGoals = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;
    const { status } = req.query;

    let query = goalsCollection.where("userId", "==", userId);

    if (status) {
      query = query.where("status", "==", status);
    }

    const snapshot = await query.orderBy("createdAt", "desc").get();

    const goals = snapshot.docs.map((doc: QueryDocumentSnapshot) => {
      const data = doc.data() as IGoal;
      return {
        id: doc.id,
        ...data,
        progressPercent: getProgressPercent(data),
        daysRemaining: getDaysRemaining(data),
      };
    });

    res.status(200).json({ success: true, data: goals });
  } catch (error) {
    console.error("getGoals error:", error);
    res.status(500).json({ success: false, error: "Failed to fetch goals" });
  }
};

/**
 * @desc    Create a new goal
 * @route   POST /api/goals
 */
export const createGoal = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { title, goalType, targetValue, baselineValue, userId } = req.body;

    if (!title || !goalType || targetValue == null || baselineValue == null || !userId) {
      res.status(400).json({
        success: false,
        error: "Missing required fields: title, goalType, targetValue, baselineValue, userId",
      });
      return;
    }

    const goalData = buildGoal(req.body);
    const docRef = await goalsCollection.add(goalData);

    res.status(201).json({
      success: true,
      data: {
        id: docRef.id,
        ...goalData,
        progressPercent: getProgressPercent(goalData as IGoal),
        daysRemaining: getDaysRemaining(goalData as IGoal),
      },
    });
  } catch (error) {
    console.error("createGoal error:", error);
    res.status(500).json({ success: false, error: "Failed to create goal" });
  }
};

/**
 * @desc    Update goal progress or status
 * @route   PUT /api/goals/:id
 */
export const updateGoal = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const id = req.params.id as string;
    const updates = { ...req.body, updatedAt: new Date().toISOString() };

    const docRef = goalsCollection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "Goal not found" });
      return;
    }

    await docRef.update(updates);
    const updated = await docRef.get();
    const data = updated.data() as IGoal;

    res.status(200).json({
      success: true,
      data: {
        id: updated.id,
        ...data,
        progressPercent: getProgressPercent(data),
        daysRemaining: getDaysRemaining(data),
      },
    });
  } catch (error) {
    console.error("updateGoal error:", error);
    res.status(500).json({ success: false, error: "Failed to update goal" });
  }
};

/**
 * @desc    Delete a goal
 * @route   DELETE /api/goals/:id
 */
export const deleteGoal = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const docRef = goalsCollection.doc(req.params.id as string);
    const doc = await docRef.get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "Goal not found" });
      return;
    }

    await docRef.delete();
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    console.error("deleteGoal error:", error);
    res.status(500).json({ success: false, error: "Failed to delete goal" });
  }
};
