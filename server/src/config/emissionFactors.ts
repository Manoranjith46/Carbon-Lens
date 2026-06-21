/**
 * Emission factors for India region (kgCO₂e per unit).
 * Source: IPCC, DEFRA, MoEFCC approximations.
 */

/** Transport emission factors (kgCO₂e per km) */
export const transportFactors: Record<string, number> = {
  walking: 0.0,
  cycling: 0.0,
  motorcycle: 0.065,
  car: 0.17,
  carpool: 0.085,
  taxi: 0.17,
  autoRickshaw: 0.06,
  bus: 0.03,
  train: 0.015,
  metro: 0.01,
  domesticFlight: 0.255,
  internationalFlight: 0.195,
};

/** Food emission factors (kgCO₂e per meal) */
export const foodFactors: Record<string, number> = {
  plantBased: 0.4,
  vegetarian: 0.65,
  eggBased: 0.8,
  chicken: 1.5,
  fish: 1.2,
  redMeat: 3.5,
  dairy: 0.6,
  foodWaste: 0.5,
};

/** Home energy emission factors */
export const homeEnergyFactors: Record<string, number> = {
  electricity: 0.82, // kgCO₂e per kWh (India grid)
  cookingGas: 2.98, // kgCO₂e per kg LPG
  airConditioner: 1.64, // kgCO₂e per hour
  heating: 2.1, // kgCO₂e per hour
  majorAppliance: 0.5, // kgCO₂e per hour (average)
  renewableEnergy: 0.05, // kgCO₂e per kWh
};

/** Purchase emission factors (kgCO₂e per item/event) */
export const purchaseFactors: Record<string, number> = {
  clothing: 8.0,
  electronics: 25.0,
  furniture: 50.0,
  onlineDelivery: 2.5,
  personalProducts: 1.5,
  generalShopping: 5.0,
};

/** Waste emission factors (kgCO₂e per kg) */
export const wasteFactors: Record<string, number> = {
  generalWaste: 0.5,
  recycled: 0.1,
  composting: 0.05,
  foodWaste: 0.5,
  electronicWaste: 2.0,
};

/**
 * Get the emission factor for a given category and activity type.
 */
export function getEmissionFactor(
  category: string,
  activityType: string
): number {
  const factorMaps: Record<string, Record<string, number>> = {
    transport: transportFactors,
    food: foodFactors,
    homeEnergy: homeEnergyFactors,
    purchases: purchaseFactors,
    waste: wasteFactors,
  };

  const map = factorMaps[category];
  if (!map) return 0.1;
  return map[activityType] ?? 0.1;
}

/**
 * Calculate kgCO₂e for a given activity.
 */
export function calculateEmission(
  category: string,
  activityType: string,
  quantity: number
): number {
  return getEmissionFactor(category, activityType) * quantity;
}

/**
 * Estimate weekly baseline from onboarding answers.
 */
export function estimateWeeklyBaseline(
  travelPattern: string,
  dietPattern: string,
  householdType: string,
  consumptionPattern: string
): number {
  let weekly = 0;

  // Travel contribution (5 days commute, ~15km avg)
  const travelFactorMap: Record<string, number> = {
    walk: 0,
    bicycle: 0,
    motorcycle: 0.065 * 15 * 5,
    car: 0.17 * 15 * 5,
    carpool: 0.085 * 15 * 5,
    bus: 0.03 * 15 * 5,
    train: 0.015 * 20 * 5,
    workFromHome: 0,
    combination: 0.06 * 15 * 5,
  };
  weekly += travelFactorMap[travelPattern] ?? 0.06 * 15 * 5;

  // Food contribution (3 meals × 7 days)
  const dietFactorMap: Record<string, number> = {
    plantBased: 0.4 * 3 * 7,
    vegetarian: 0.65 * 3 * 7,
    mostlyVegetarian: 0.8 * 3 * 7,
    mixed: 1.2 * 3 * 7,
    meatMostDays: 2.0 * 3 * 7,
  };
  weekly += dietFactorMap[dietPattern] ?? 1.0 * 3 * 7;

  // Home energy (weekly)
  const householdFactorMap: Record<string, number> = {
    sharedRoom: 3.0,
    apartment: 8.0,
    smallHouse: 12.0,
    mediumHouse: 18.0,
    largeHouse: 28.0,
  };
  weekly += householdFactorMap[householdType] ?? 10.0;

  // Consumption / purchases
  const consumptionFactorMap: Record<string, number> = {
    rarely: 2.0,
    onceOrTwice: 5.0,
    weekly: 10.0,
    severalTimes: 18.0,
  };
  weekly += consumptionFactorMap[consumptionPattern] ?? 5.0;

  // Waste estimate
  weekly += 3.5;

  return weekly;
}
