import '../models/models.dart';

/// Mock emission factors for India region (kgCO₂e per unit).
/// Source: IPCC, DEFRA, MoEFCC approximations.
class MockEmissionFactors {
  MockEmissionFactors._();

  /// Transport emission factors (kgCO₂e per km)
  static const Map<String, double> transport = {
    'walking': 0.0,
    'cycling': 0.0,
    'motorcycle': 0.065,
    'car': 0.170,
    'carpool': 0.085,
    'taxi': 0.170,
    'autoRickshaw': 0.060,
    'bus': 0.030,
    'train': 0.015,
    'metro': 0.010,
    'domesticFlight': 0.255,
    'internationalFlight': 0.195,
  };

  /// Food emission factors (kgCO₂e per meal)
  static const Map<String, double> food = {
    'plantBased': 0.40,
    'vegetarian': 0.65,
    'eggBased': 0.80,
    'chicken': 1.50,
    'fish': 1.20,
    'redMeat': 3.50,
    'dairy': 0.60,
    'foodWaste': 0.50,
  };

  /// Home energy emission factors
  static const Map<String, double> homeEnergy = {
    'electricity': 0.82, // kgCO₂e per kWh (India grid)
    'cookingGas': 2.98, // kgCO₂e per kg LPG
    'airConditioner': 1.64, // kgCO₂e per hour
    'heating': 2.10, // kgCO₂e per hour
    'majorAppliance': 0.50, // kgCO₂e per hour (average)
    'renewableEnergy': 0.05, // kgCO₂e per kWh
  };

  /// Purchase emission factors (kgCO₂e per item/event)
  static const Map<String, double> purchases = {
    'clothing': 8.0,
    'electronics': 25.0,
    'furniture': 50.0,
    'onlineDelivery': 2.5,
    'personalProducts': 1.5,
    'generalShopping': 5.0,
  };

  /// Waste emission factors (kgCO₂e per kg)
  static const Map<String, double> waste = {
    'generalWaste': 0.50,
    'recycled': 0.10,
    'composting': 0.05,
    'foodWaste': 0.50,
    'electronicWaste': 2.00,
  };

  /// Get factor for a given activity type string.
  static double getFactor(ActivityCategory category, String type) {
    switch (category) {
      case ActivityCategory.transport:
        return transport[type] ?? 0.1;
      case ActivityCategory.food:
        return food[type] ?? 0.5;
      case ActivityCategory.homeEnergy:
        return homeEnergy[type] ?? 0.5;
      case ActivityCategory.purchases:
        return purchases[type] ?? 5.0;
      case ActivityCategory.waste:
        return waste[type] ?? 0.3;
    }
  }

  /// Calculate kgCO₂e for an activity.
  static double calculate(ActivityCategory category, String type, double quantity) {
    return getFactor(category, type) * quantity;
  }

  /// Estimate weekly baseline from onboarding answers.
  static double estimateWeeklyBaseline({
    required String travelPattern,
    required String dietPattern,
    required String householdType,
    required String consumptionPattern,
  }) {
    double weekly = 0;

    // Travel contribution (5 days commute)
    switch (travelPattern) {
      case 'walk':
      case 'bicycle':
        weekly += 0;
        break;
      case 'motorcycle':
        weekly += 0.065 * 15 * 5; // 15km * 5 days
        break;
      case 'car':
        weekly += 0.170 * 15 * 5;
        break;
      case 'carpool':
        weekly += 0.085 * 15 * 5;
        break;
      case 'bus':
        weekly += 0.030 * 15 * 5;
        break;
      case 'train':
        weekly += 0.015 * 20 * 5;
        break;
      case 'workFromHome':
        weekly += 0;
        break;
      case 'combination':
        weekly += 0.060 * 15 * 5;
        break;
      default:
        weekly += 0.060 * 15 * 5;
    }

    // Food contribution (3 meals * 7 days)
    switch (dietPattern) {
      case 'plantBased':
        weekly += 0.40 * 3 * 7;
        break;
      case 'vegetarian':
        weekly += 0.65 * 3 * 7;
        break;
      case 'mostlyVegetarian':
        weekly += 0.80 * 3 * 7;
        break;
      case 'mixed':
        weekly += 1.20 * 3 * 7;
        break;
      case 'meatMostDays':
        weekly += 2.00 * 3 * 7;
        break;
      default:
        weekly += 1.00 * 3 * 7;
    }

    // Home energy (weekly)
    switch (householdType) {
      case 'sharedRoom':
        weekly += 3.0;
        break;
      case 'apartment':
        weekly += 8.0;
        break;
      case 'smallHouse':
        weekly += 12.0;
        break;
      case 'mediumHouse':
        weekly += 18.0;
        break;
      case 'largeHouse':
        weekly += 28.0;
        break;
      default:
        weekly += 10.0;
    }

    // Consumption/purchases
    switch (consumptionPattern) {
      case 'rarely':
        weekly += 2.0;
        break;
      case 'onceOrTwice':
        weekly += 5.0;
        break;
      case 'weekly':
        weekly += 10.0;
        break;
      case 'severalTimes':
        weekly += 18.0;
        break;
      default:
        weekly += 5.0;
    }

    // Add waste estimate
    weekly += 3.5; // average waste

    return weekly;
  }
}

/// Pre-built recommendation templates.
class MockRecommendations {
  MockRecommendations._();

  static List<Recommendation> getForProfile({
    required String travelPattern,
    required String dietPattern,
  }) {
    final recommendations = <Recommendation>[];

    // Transport recommendations
    if (travelPattern == 'car' || travelPattern == 'motorcycle') {
      recommendations.add(const Recommendation(
        id: 'rec_bus_commute',
        title: 'Take the bus for one trip this week',
        description:
            'Switching one car trip to public transport can save significant emissions.',
        reason: 'Car travel is your largest transport source.',
        category: ActivityCategory.transport,
        estimatedReductionKgCo2e: 1.8,
        costLevel: 'low',
        effortLevel: 'low',
        alternativeAction: 'Try carpooling instead',
      ));
      recommendations.add(const Recommendation(
        id: 'rec_cycle_short',
        title: 'Cycle for trips under 3 km',
        description:
            'Short trips by bicycle produce zero emissions and improve fitness.',
        reason: 'Many short trips can be done without a vehicle.',
        category: ActivityCategory.transport,
        estimatedReductionKgCo2e: 0.8,
        costLevel: 'free',
        effortLevel: 'medium',
      ));
    }

    // Food recommendations
    if (dietPattern == 'meatMostDays' || dietPattern == 'mixed') {
      recommendations.add(const Recommendation(
        id: 'rec_plant_meal',
        title: 'Try two plant-based meals this week',
        description:
            'Plant-based meals have a significantly lower carbon footprint than meat-based ones.',
        reason: 'Food contributes significantly to your footprint.',
        category: ActivityCategory.food,
        estimatedReductionKgCo2e: 4.2,
        costLevel: 'low',
        effortLevel: 'low',
        alternativeAction: 'Start with one vegetarian day',
      ));
    }

    // Home energy recommendations
    recommendations.add(const Recommendation(
      id: 'rec_ac_reduce',
      title: 'Reduce AC usage by 1 hour per day',
      description:
          'Setting your AC timer can reduce energy consumption without sacrificing comfort.',
      reason: 'Air conditioning is a major home energy contributor.',
      category: ActivityCategory.homeEnergy,
      estimatedReductionKgCo2e: 11.5,
      costLevel: 'free',
      effortLevel: 'low',
    ));

    // Waste recommendations
    recommendations.add(const Recommendation(
      id: 'rec_reduce_waste',
      title: 'Start composting food scraps',
      description:
          'Composting diverts organic waste from landfills where it produces methane.',
      reason: 'Food waste in landfills creates greenhouse gases.',
      category: ActivityCategory.waste,
      estimatedReductionKgCo2e: 1.5,
      costLevel: 'low',
      effortLevel: 'medium',
    ));

    // Purchases recommendations
    recommendations.add(const Recommendation(
      id: 'rec_reduce_delivery',
      title: 'Reduce online deliveries by batching orders',
      description:
          'Combining multiple orders into one delivery reduces packaging and transport emissions.',
      reason: 'Frequent deliveries add up in packaging and transport.',
      category: ActivityCategory.purchases,
      estimatedReductionKgCo2e: 2.0,
      costLevel: 'free',
      effortLevel: 'low',
    ));

    return recommendations;
  }
}
