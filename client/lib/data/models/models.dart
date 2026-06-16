/// Carbon tracking activity categories.
enum ActivityCategory {
  transport,
  food,
  homeEnergy,
  purchases,
  waste,
}

/// Confidence level of a recorded activity.
enum ConfidenceLevel {
  confirmed,
  connected,
  detected,
  estimated,
  defaultAssumption,
}

/// Source type for an activity.
enum SourceType {
  manual,
  routine,
  detection,
  integration,
  weeklyCheckIn,
}

/// Transport sub-types.
enum TransportType {
  walking,
  cycling,
  motorcycle,
  car,
  carpool,
  taxi,
  autoRickshaw,
  bus,
  train,
  metro,
  domesticFlight,
  internationalFlight,
}

/// Food sub-types.
enum FoodType {
  plantBased,
  vegetarian,
  eggBased,
  chicken,
  fish,
  redMeat,
  dairy,
  foodWaste,
}

/// Home energy sub-types.
enum HomeEnergyType {
  electricity,
  cookingGas,
  airConditioner,
  heating,
  majorAppliance,
  renewableEnergy,
}

/// Purchase sub-types.
enum PurchaseType {
  clothing,
  electronics,
  furniture,
  onlineDelivery,
  personalProducts,
  generalShopping,
}

/// Waste sub-types.
enum WasteType {
  generalWaste,
  recycled,
  composting,
  foodWaste,
  electronicWaste,
}

/// A single tracked activity.
class Activity {
  final String id;
  final ActivityCategory category;
  final String activityType;
  final double quantity;
  final String unit;
  final DateTime activityTime;
  final SourceType sourceType;
  final ConfidenceLevel confidenceLevel;
  final double? calculatedKgCo2e;
  final double? lowerEstimate;
  final double? upperEstimate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activity({
    required this.id,
    required this.category,
    required this.activityType,
    required this.quantity,
    required this.unit,
    required this.activityTime,
    this.sourceType = SourceType.manual,
    this.confidenceLevel = ConfidenceLevel.confirmed,
    this.calculatedKgCo2e,
    this.lowerEstimate,
    this.upperEstimate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Activity copyWith({
    String? id,
    ActivityCategory? category,
    String? activityType,
    double? quantity,
    String? unit,
    DateTime? activityTime,
    SourceType? sourceType,
    ConfidenceLevel? confidenceLevel,
    double? calculatedKgCo2e,
    double? lowerEstimate,
    double? upperEstimate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      category: category ?? this.category,
      activityType: activityType ?? this.activityType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      activityTime: activityTime ?? this.activityTime,
      sourceType: sourceType ?? this.sourceType,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      calculatedKgCo2e: calculatedKgCo2e ?? this.calculatedKgCo2e,
      lowerEstimate: lowerEstimate ?? this.lowerEstimate,
      upperEstimate: upperEstimate ?? this.upperEstimate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// A saved routine for quick logging.
class Routine {
  final String id;
  final String name;
  final List<Activity> activities;
  final List<int> daysOfWeek; // 1=Monday, 7=Sunday
  final DateTime createdAt;

  const Routine({
    required this.id,
    required this.name,
    required this.activities,
    this.daysOfWeek = const [],
    required this.createdAt,
  });
}

/// User's personal goal.
class Goal {
  final String id;
  final String title;
  final GoalType goalType;
  final ActivityCategory? category;
  final double targetValue;
  final double baselineValue;
  final double progressValue;
  final DateTime startDate;
  final DateTime endDate;
  final GoalStatus status;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.title,
    required this.goalType,
    this.category,
    required this.targetValue,
    required this.baselineValue,
    this.progressValue = 0,
    required this.startDate,
    required this.endDate,
    this.status = GoalStatus.active,
    required this.createdAt,
  });

  double get progressPercent {
    if (targetValue <= 0) return 0;
    return (progressValue / targetValue).clamp(0.0, 1.5);
  }

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  Goal copyWith({
    double? progressValue,
    GoalStatus? status,
  }) {
    return Goal(
      id: id,
      title: title,
      goalType: goalType,
      category: category,
      targetValue: targetValue,
      baselineValue: baselineValue,
      progressValue: progressValue ?? this.progressValue,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

enum GoalType { weeklyReduction, monthlyReduction, categorySpecific, habit, activity }

enum GoalStatus { active, completed, expired }

/// User profile built from onboarding.
class UserProfile {
  final String userId;
  final String? regionCode;
  final String? dietPattern;
  final String? travelPattern;
  final String? householdType;
  final int? householdSize;
  final String? consumptionPattern;
  final bool onboardingCompleted;
  final double weeklyBaselineKgCo2e;
  final double? weeklyLimitKgCo2e;
  final DateTime createdAt;

  const UserProfile({
    required this.userId,
    this.regionCode,
    this.dietPattern,
    this.travelPattern,
    this.householdType,
    this.householdSize,
    this.consumptionPattern,
    this.onboardingCompleted = false,
    this.weeklyBaselineKgCo2e = 0,
    this.weeklyLimitKgCo2e,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? regionCode,
    String? dietPattern,
    String? travelPattern,
    String? householdType,
    int? householdSize,
    String? consumptionPattern,
    bool? onboardingCompleted,
    double? weeklyBaselineKgCo2e,
    double? weeklyLimitKgCo2e,
  }) {
    return UserProfile(
      userId: userId,
      regionCode: regionCode ?? this.regionCode,
      dietPattern: dietPattern ?? this.dietPattern,
      travelPattern: travelPattern ?? this.travelPattern,
      householdType: householdType ?? this.householdType,
      householdSize: householdSize ?? this.householdSize,
      consumptionPattern: consumptionPattern ?? this.consumptionPattern,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      weeklyBaselineKgCo2e: weeklyBaselineKgCo2e ?? this.weeklyBaselineKgCo2e,
      weeklyLimitKgCo2e: weeklyLimitKgCo2e ?? this.weeklyLimitKgCo2e,
      createdAt: createdAt,
    );
  }
}

/// A recommendation for the user.
class Recommendation {
  final String id;
  final String title;
  final String description;
  final String reason;
  final ActivityCategory category;
  final double estimatedReductionKgCo2e;
  final String costLevel; // 'free', 'low', 'medium', 'high'
  final String effortLevel; // 'low', 'medium', 'high'
  final String? alternativeAction;

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.reason,
    required this.category,
    required this.estimatedReductionKgCo2e,
    required this.costLevel,
    required this.effortLevel,
    this.alternativeAction,
  });
}
