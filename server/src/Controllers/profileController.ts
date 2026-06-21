import { Request, Response } from "express";
import { profilesCollection, buildDefaultProfile } from "../models/UserProfile.js";
import { estimateWeeklyBaseline } from "../config/emissionFactors.js";

/**
 * @desc    Get user profile
 * @route   GET /api/profile/:userId
 */
export const getProfile = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;

    // Look up by userId field
    const snapshot = await profilesCollection
      .where("userId", "==", userId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      // Create default profile if not found
      const defaultProfile = buildDefaultProfile(userId);
      const docRef = await profilesCollection.add(defaultProfile);
      res.status(200).json({
        success: true,
        data: { id: docRef.id, ...defaultProfile },
      });
      return;
    }

    const doc = snapshot.docs[0];
    res.status(200).json({
      success: true,
      data: { id: doc.id, ...doc.data() },
    });
  } catch (error) {
    console.error("getProfile error:", error);
    res.status(500).json({ success: false, error: "Failed to fetch profile" });
  }
};

/**
 * @desc    Create or update user profile (upsert)
 * @route   POST /api/profile
 */
export const createOrUpdateProfile = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const { userId, ...profileData } = req.body;

    if (!userId) {
      res.status(400).json({ success: false, error: "userId is required" });
      return;
    }

    const snapshot = await profilesCollection
      .where("userId", "==", userId)
      .limit(1)
      .get();

    let resultData;

    if (snapshot.empty) {
      // Create new profile
      const newProfile = {
        ...buildDefaultProfile(userId),
        ...profileData,
        updatedAt: new Date().toISOString(),
      };
      const docRef = await profilesCollection.add(newProfile);
      resultData = { id: docRef.id, ...newProfile };
    } else {
      // Update existing profile
      const docRef = snapshot.docs[0].ref;
      const updates = { ...profileData, updatedAt: new Date().toISOString() };
      await docRef.update(updates);
      const updated = await docRef.get();
      resultData = { id: updated.id, ...updated.data() };
    }

    res.status(200).json({ success: true, data: resultData });
  } catch (error) {
    console.error("createOrUpdateProfile error:", error);
    res.status(500).json({ success: false, error: "Failed to update profile" });
  }
};

/**
 * @desc    Complete onboarding — calculate baseline and set weekly limit
 * @route   POST /api/profile/:userId/onboarding
 */
export const completeOnboarding = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;
    const {
      travelPattern,
      dietPattern,
      householdType,
      consumptionPattern,
      regionCode,
      householdSize,
    } = req.body;

    if (!travelPattern || !dietPattern || !householdType || !consumptionPattern) {
      res.status(400).json({
        success: false,
        error: "All onboarding fields are required: travelPattern, dietPattern, householdType, consumptionPattern",
      });
      return;
    }

    // Calculate estimated weekly baseline
    const weeklyBaselineKgCo2e = estimateWeeklyBaseline(
      travelPattern,
      dietPattern,
      householdType,
      consumptionPattern
    );

    // Set weekly limit to 90% of baseline (10% reduction target)
    const weeklyLimitKgCo2e = Math.round(weeklyBaselineKgCo2e * 0.9 * 100) / 100;

    const profileUpdates = {
      travelPattern,
      dietPattern,
      householdType,
      consumptionPattern,
      regionCode: regionCode || "IN",
      householdSize: householdSize || 1,
      onboardingCompleted: true,
      weeklyBaselineKgCo2e: Math.round(weeklyBaselineKgCo2e * 100) / 100,
      weeklyLimitKgCo2e,
      updatedAt: new Date().toISOString(),
    };

    // Upsert profile
    const snapshot = await profilesCollection
      .where("userId", "==", userId)
      .limit(1)
      .get();

    let resultData;

    if (snapshot.empty) {
      const newProfile = {
        ...buildDefaultProfile(userId),
        ...profileUpdates,
      };
      const docRef = await profilesCollection.add(newProfile);
      resultData = { id: docRef.id, ...newProfile };
    } else {
      const docRef = snapshot.docs[0].ref;
      await docRef.update(profileUpdates);
      const updated = await docRef.get();
      resultData = { id: updated.id, ...updated.data() };
    }

    res.status(200).json({
      success: true,
      data: resultData,
      meta: {
        estimatedWeeklyBaseline: Math.round(weeklyBaselineKgCo2e * 100) / 100,
        weeklyLimit: weeklyLimitKgCo2e,
        message: `Your estimated weekly carbon footprint is ${weeklyBaselineKgCo2e.toFixed(1)} kgCO₂e. We've set a target of ${weeklyLimitKgCo2e.toFixed(1)} kgCO₂e (10% reduction).`,
      },
    });
  } catch (error) {
    console.error("completeOnboarding error:", error);
    res.status(500).json({ success: false, error: "Failed to complete onboarding" });
  }
};

/**
 * @desc    Delete user profile
 * @route   DELETE /api/profile/:userId
 */
export const deleteProfile = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;

    const snapshot = await profilesCollection
      .where("userId", "==", userId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      res.status(404).json({ success: false, error: "Profile not found" });
      return;
    }

    await snapshot.docs[0].ref.delete();
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    console.error("deleteProfile error:", error);
    res.status(500).json({ success: false, error: "Failed to delete profile" });
  }
};
