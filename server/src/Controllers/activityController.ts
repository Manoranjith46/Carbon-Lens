import { Request, Response } from "express";
import { activitiesCollection, buildActivity } from "../models/Activity.js";
import {
  calculateEmission,
  getEmissionFactor,
} from "../config/emissionFactors.js";
import { QueryDocumentSnapshot } from "firebase-admin/firestore";

/**
 * @desc    Get all activities for a user
 * @route   GET /api/activities/:userId
 */
export const getActivities = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;
    const { category, startDate, endDate, limit = "50" } = req.query;

    let query = activitiesCollection
      .where("userId", "==", userId)
      .orderBy("activityTime", "desc")
      .limit(parseInt(limit as string, 10));

    if (category) {
      query = activitiesCollection
        .where("userId", "==", userId)
        .where("category", "==", category)
        .orderBy("activityTime", "desc")
        .limit(parseInt(limit as string, 10));
    }

    const snapshot = await query.get();
    let activities = snapshot.docs.map((doc: QueryDocumentSnapshot) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Client-side date filtering (Firestore limits compound queries)
    if (startDate) {
      const start = new Date(startDate as string).toISOString();
      activities = activities.filter(
        (a: Record<string, unknown>) => (a["activityTime"] as string) >= start
      );
    }
    if (endDate) {
      const end = new Date(endDate as string).toISOString();
      activities = activities.filter(
        (a: Record<string, unknown>) => (a["activityTime"] as string) <= end
      );
    }

    res.status(200).json({
      success: true,
      data: activities,
      count: activities.length,
    });
  } catch (error) {
    console.error("getActivities error:", error);
    res.status(500).json({ success: false, error: "Failed to fetch activities" });
  }
};

/**
 * @desc    Create a new activity with auto-calculated emissions
 * @route   POST /api/activities
 */
export const createActivity = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { category, activityType, quantity, unit, userId, ...rest } = req.body;

    if (!category || !activityType || quantity == null || !unit || !userId) {
      res.status(400).json({
        success: false,
        error: "Missing required fields: category, activityType, quantity, unit, userId",
      });
      return;
    }

    // Auto-calculate emissions
    const calculatedKgCo2e = calculateEmission(category, activityType, quantity);
    const factor = getEmissionFactor(category, activityType);
    const lowerEstimate = Math.round(factor * 0.8 * quantity * 100) / 100;
    const upperEstimate = Math.round(factor * 1.2 * quantity * 100) / 100;

    const activityData = buildActivity({
      category,
      activityType,
      quantity,
      unit,
      userId,
      calculatedKgCo2e: Math.round(calculatedKgCo2e * 100) / 100,
      lowerEstimate,
      upperEstimate,
      ...rest,
    });

    const docRef = await activitiesCollection.add(activityData);

    res.status(201).json({
      success: true,
      data: { id: docRef.id, ...activityData },
    });
  } catch (error) {
    console.error("createActivity error:", error);
    res.status(500).json({ success: false, error: "Failed to create activity" });
  }
};

/**
 * @desc    Update an activity
 * @route   PUT /api/activities/:id
 */
export const updateActivity = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const id = req.params.id as string;
    const updates = { ...req.body, updatedAt: new Date().toISOString() };

    const docRef = activitiesCollection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "Activity not found" });
      return;
    }

    // Recalculate if quantity/type changed
    const existing = doc.data()!;
    if (updates.quantity || updates.activityType || updates.category) {
      const cat = updates.category || existing.category;
      const type = updates.activityType || existing.activityType;
      const qty = updates.quantity || existing.quantity;
      updates.calculatedKgCo2e = Math.round(calculateEmission(cat, type, qty) * 100) / 100;
      const factor = getEmissionFactor(cat, type);
      updates.lowerEstimate = Math.round(factor * 0.8 * qty * 100) / 100;
      updates.upperEstimate = Math.round(factor * 1.2 * qty * 100) / 100;
    }

    await docRef.update(updates);
    const updated = await docRef.get();

    res.status(200).json({
      success: true,
      data: { id: updated.id, ...updated.data() },
    });
  } catch (error) {
    console.error("updateActivity error:", error);
    res.status(500).json({ success: false, error: "Failed to update activity" });
  }
};

/**
 * @desc    Delete an activity
 * @route   DELETE /api/activities/:id
 */
export const deleteActivity = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const docRef = activitiesCollection.doc(req.params.id as string);
    const doc = await docRef.get();

    if (!doc.exists) {
      res.status(404).json({ success: false, error: "Activity not found" });
      return;
    }

    await docRef.delete();
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    console.error("deleteActivity error:", error);
    res.status(500).json({ success: false, error: "Failed to delete activity" });
  }
};

/**
 * @desc    Get weekly summary for a user (aggregated by category)
 * @route   GET /api/activities/:userId/weekly-summary
 */
export const getWeeklySummary = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;

    // Get start of current week (Monday)
    const now = new Date();
    const dayOfWeek = now.getDay();
    const monday = new Date(now);
    monday.setDate(now.getDate() - ((dayOfWeek + 6) % 7));
    monday.setHours(0, 0, 0, 0);

    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);
    sunday.setHours(23, 59, 59, 999);

    const mondayISO = monday.toISOString();
    const sundayISO = sunday.toISOString();

    // Fetch all activities for this week
    const snapshot = await activitiesCollection
      .where("userId", "==", userId)
      .where("activityTime", ">=", mondayISO)
      .where("activityTime", "<=", sundayISO)
      .get();

    const activities = snapshot.docs.map((doc: QueryDocumentSnapshot) => doc.data());

    // Aggregate by category
    const categoryMap: Record<string, { totalKgCo2e: number; count: number }> = {};
    const dailyMap: Record<string, { totalKgCo2e: number; count: number }> = {};

    for (const act of activities) {
      const cat = act.category as string;
      const co2 = (act.calculatedKgCo2e as number) || 0;
      const dateKey = act.activityTime
        ? (act.activityTime as string).slice(0, 10)
        : "unknown";

      // Category aggregation
      if (!categoryMap[cat]) categoryMap[cat] = { totalKgCo2e: 0, count: 0 };
      categoryMap[cat].totalKgCo2e += co2;
      categoryMap[cat].count += 1;

      // Daily aggregation
      if (!dailyMap[dateKey]) dailyMap[dateKey] = { totalKgCo2e: 0, count: 0 };
      dailyMap[dateKey].totalKgCo2e += co2;
      dailyMap[dateKey].count += 1;
    }

    const totalWeekly = Object.values(categoryMap).reduce(
      (sum, item) => sum + item.totalKgCo2e,
      0
    );

    res.status(200).json({
      success: true,
      data: {
        weekStart: mondayISO,
        weekEnd: sundayISO,
        totalWeeklyKgCo2e: Math.round(totalWeekly * 100) / 100,
        categoryBreakdown: Object.entries(categoryMap)
          .map(([category, data]) => ({
            category,
            totalKgCo2e: Math.round(data.totalKgCo2e * 100) / 100,
            activityCount: data.count,
          }))
          .sort((a, b) => b.totalKgCo2e - a.totalKgCo2e),
        dailyBreakdown: Object.entries(dailyMap)
          .map(([date, data]) => ({
            date,
            totalKgCo2e: Math.round(data.totalKgCo2e * 100) / 100,
            activityCount: data.count,
          }))
          .sort((a, b) => a.date.localeCompare(b.date)),
      },
    });
  } catch (error) {
    console.error("getWeeklySummary error:", error);
    res.status(500).json({ success: false, error: "Failed to fetch weekly summary" });
  }
};
