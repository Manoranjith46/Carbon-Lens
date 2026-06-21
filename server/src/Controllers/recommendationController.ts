import { Request, Response } from "express";
import { profilesCollection } from "../models/UserProfile.js";
import { activitiesCollection } from "../models/Activity.js";

// ─── Recommendation Interface ───────────────────────────────────────

interface Recommendation {
  id: string;
  title: string;
  description: string;
  reason: string;
  category: string;
  estimatedReductionKgCo2e: number;
  costLevel: string;
  effortLevel: string;
  alternativeAction?: string;
}

// ─── Recommendation Templates ───────────────────────────────────────

const TRANSPORT_RECS: Recommendation[] = [
  {
    id: "rec_bus_commute",
    title: "Take the bus for one trip this week",
    description:
      "Switching one car trip to public transport can save significant emissions.",
    reason: "Car travel is your largest transport source.",
    category: "transport",
    estimatedReductionKgCo2e: 1.8,
    costLevel: "low",
    effortLevel: "low",
    alternativeAction: "Try carpooling instead",
  },
  {
    id: "rec_cycle_short",
    title: "Cycle for trips under 3 km",
    description:
      "Short trips by bicycle produce zero emissions and improve fitness.",
    reason: "Many short trips can be done without a vehicle.",
    category: "transport",
    estimatedReductionKgCo2e: 0.8,
    costLevel: "free",
    effortLevel: "medium",
  },
  {
    id: "rec_metro_weekly",
    title: "Use metro for 2 commutes this week",
    description:
      "Metro produces 85% fewer emissions per km than a personal car.",
    reason: "Switching to rail-based transit is one of the highest-impact changes.",
    category: "transport",
    estimatedReductionKgCo2e: 2.4,
    costLevel: "low",
    effortLevel: "low",
  },
];

const FOOD_RECS: Recommendation[] = [
  {
    id: "rec_plant_meal",
    title: "Try two plant-based meals this week",
    description:
      "Plant-based meals have a significantly lower carbon footprint than meat-based ones.",
    reason: "Food contributes significantly to your footprint.",
    category: "food",
    estimatedReductionKgCo2e: 4.2,
    costLevel: "low",
    effortLevel: "low",
    alternativeAction: "Start with one vegetarian day",
  },
  {
    id: "rec_reduce_food_waste",
    title: "Plan meals to reduce food waste",
    description:
      "Food waste in landfills produces methane. Planning meals helps reduce waste by 30%.",
    reason: "Reducing food waste is an easy first step.",
    category: "food",
    estimatedReductionKgCo2e: 1.5,
    costLevel: "free",
    effortLevel: "low",
  },
];

const HOME_RECS: Recommendation[] = [
  {
    id: "rec_ac_reduce",
    title: "Reduce AC usage by 1 hour per day",
    description:
      "Setting your AC timer can reduce energy consumption without sacrificing comfort.",
    reason: "Air conditioning is a major home energy contributor.",
    category: "homeEnergy",
    estimatedReductionKgCo2e: 11.5,
    costLevel: "free",
    effortLevel: "low",
  },
  {
    id: "rec_led_switch",
    title: "Switch remaining bulbs to LED",
    description:
      "LED bulbs use 75% less energy than incandescent bulbs and last 25 times longer.",
    reason: "Lighting is an easy win for reducing home energy use.",
    category: "homeEnergy",
    estimatedReductionKgCo2e: 2.0,
    costLevel: "low",
    effortLevel: "low",
  },
];

const WASTE_RECS: Recommendation[] = [
  {
    id: "rec_reduce_waste",
    title: "Start composting food scraps",
    description:
      "Composting diverts organic waste from landfills where it produces methane.",
    reason: "Food waste in landfills creates greenhouse gases.",
    category: "waste",
    estimatedReductionKgCo2e: 1.5,
    costLevel: "low",
    effortLevel: "medium",
  },
];

const PURCHASE_RECS: Recommendation[] = [
  {
    id: "rec_reduce_delivery",
    title: "Reduce online deliveries by batching orders",
    description:
      "Combining multiple orders into one delivery reduces packaging and transport emissions.",
    reason: "Frequent deliveries add up in packaging and transport.",
    category: "purchases",
    estimatedReductionKgCo2e: 2.0,
    costLevel: "free",
    effortLevel: "low",
  },
  {
    id: "rec_buy_secondhand",
    title: "Buy one secondhand item instead of new",
    description:
      "Secondhand purchases avoid manufacturing emissions entirely.",
    reason: "New clothing and electronics have high embedded carbon.",
    category: "purchases",
    estimatedReductionKgCo2e: 5.0,
    costLevel: "low",
    effortLevel: "low",
  },
];

/**
 * @desc    Get personalized recommendations for a user
 * @route   GET /api/recommendations/:userId
 */
export const getRecommendations = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const userId = req.params.userId as string;

    // 1. Fetch user profile
    const profileSnap = await profilesCollection
      .where("userId", "==", userId)
      .limit(1)
      .get();

    const profile = profileSnap.empty ? null : profileSnap.docs[0].data();

    // 2. Fetch recent activity data for smarter recommendations
    const now = new Date();
    const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const activitySnap = await activitiesCollection
      .where("userId", "==", userId)
      .where("activityTime", ">=", oneWeekAgo.toISOString())
      .get();

    // Category totals from recent activities
    const categoryTotals: Record<string, number> = {};
    for (const doc of activitySnap.docs) {
      const data = doc.data();
      const cat = data.category as string;
      categoryTotals[cat] = (categoryTotals[cat] || 0) + ((data.calculatedKgCo2e as number) || 0);
    }

    // 3. Build personalized recommendation list
    const recommendations: Recommendation[] = [];
    const travelPattern = profile?.travelPattern || "combination";
    const dietPattern = profile?.dietPattern || "mixed";

    // Transport recommendations (if user drives or has high transport emissions)
    if (
      travelPattern === "car" ||
      travelPattern === "motorcycle" ||
      (categoryTotals["transport"] && categoryTotals["transport"] > 5)
    ) {
      recommendations.push(...TRANSPORT_RECS);
    }

    // Food recommendations (if non-vegetarian diet)
    if (
      dietPattern === "meatMostDays" ||
      dietPattern === "mixed" ||
      (categoryTotals["food"] && categoryTotals["food"] > 10)
    ) {
      recommendations.push(...FOOD_RECS);
    }

    // Home energy — always relevant
    recommendations.push(...HOME_RECS);

    // Waste — always relevant
    recommendations.push(...WASTE_RECS);

    // Purchases — always relevant
    recommendations.push(...PURCHASE_RECS);

    // Sort by estimated impact (highest first)
    recommendations.sort(
      (a, b) => b.estimatedReductionKgCo2e - a.estimatedReductionKgCo2e
    );

    res.status(200).json({
      success: true,
      data: recommendations,
      meta: {
        basedOn: {
          travelPattern,
          dietPattern,
          recentActivityCategories: Object.keys(categoryTotals),
        },
        totalPotentialReduction: Math.round(
          recommendations.reduce(
            (sum, r) => sum + r.estimatedReductionKgCo2e,
            0
          ) * 100
        ) / 100,
      },
    });
  } catch (error) {
    console.error("getRecommendations error:", error);
    res
      .status(500)
      .json({ success: false, error: "Failed to fetch recommendations" });
  }
};
