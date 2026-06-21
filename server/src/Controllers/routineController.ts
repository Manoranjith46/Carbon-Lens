import { Request, Response } from "express";
import { routinesCollection, buildRoutine } from "../models/Routine.js";
import { activitiesCollection, buildActivity, IActivity } from "../models/Activity.js";
import {
  calculateEmission,
  getEmissionFactor,
} from "../config/emissionFactors.js";
import { QueryDocumentSnapshot } from "firebase-admin/firestore";

/**
 * @desc    Get all routines for a user
 * @route   GET /api/routines/:userId
 */
export const getRoutines = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;

    const snapshot = await routinesCollection
      .where("userId", "==", userId)
      .orderBy("createdAt", "desc")
      .get();

    const routines = snapshot.docs.map((doc: QueryDocumentSnapshot) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json({ success: true, data: routines });
  } catch (error) {
    console.error("getRoutines error:", error);
    res.status(500).json({ success: false, error: "Failed to fetch routines" });
  }
};

/**
 * @desc    Create a new routine
 * @route   POST /api/routines
 */
export const createRoutine = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { name, activities, userId } = req.body;

    if (!name || !activities || !Array.isArray(activities) || !userId) {
      res.status(400).json({
        success: false,
        error: "Missing required fields: name, activities (array), userId",
      });
      return;
    }

    const routineData = buildRoutine(req.body);
    const docRef = await routinesCollection.add(routineData);

    res.status(201).json({
      success: true,
      data: { id: docRef.id, ...routineData },
    });
  } catch (error) {
    console.error("createRoutine error:", error);
    res.status(500).json({ success: false, error: "Failed to create routine" });
  }
};

/**
 * @desc    Log all activities from a routine (quick-log)
 * @route   POST /api/routines/:id/log
 */
export const logRoutine = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const id = req.params.id as string;

    const docRef = routinesCollection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "Routine not found" });
      return;
    }

    const routine = doc.data()!;
    const activities = routine.activities as Array<{
      category: string;
      activityType: string;
      quantity: number;
      unit: string;
    }>;

    // Create an activity document for each item in the routine
    const createdActivities = [];

    for (const act of activities) {
      const calculatedKgCo2e = calculateEmission(
        act.category,
        act.activityType,
        act.quantity
      );
      const factor = getEmissionFactor(act.category, act.activityType);

      const activityData = buildActivity({
        category: act.category as IActivity["category"],
        activityType: act.activityType,
        quantity: act.quantity,
        unit: act.unit,
        userId: routine.userId as string,
        sourceType: "routine",
        calculatedKgCo2e: Math.round(calculatedKgCo2e * 100) / 100,
        lowerEstimate: Math.round(factor * 0.8 * act.quantity * 100) / 100,
        upperEstimate: Math.round(factor * 1.2 * act.quantity * 100) / 100,
      });

      const ref = await activitiesCollection.add(activityData);
      createdActivities.push({ id: ref.id, ...activityData });
    }

    res.status(201).json({
      success: true,
      data: createdActivities,
      meta: {
        routineName: routine.name,
        activitiesLogged: createdActivities.length,
        totalKgCo2e: Math.round(
          createdActivities.reduce(
            (sum, a) => sum + (a.calculatedKgCo2e || 0),
            0
          ) * 100
        ) / 100,
      },
    });
  } catch (error) {
    console.error("logRoutine error:", error);
    res.status(500).json({ success: false, error: "Failed to log routine" });
  }
};

/**
 * @desc    Delete a routine
 * @route   DELETE /api/routines/:id
 */
export const deleteRoutine = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const docRef = routinesCollection.doc(req.params.id as string);
    const doc = await docRef.get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "Routine not found" });
      return;
    }

    await docRef.delete();
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    console.error("deleteRoutine error:", error);
    res.status(500).json({ success: false, error: "Failed to delete routine" });
  }
};
