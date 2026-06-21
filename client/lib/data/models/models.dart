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

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String? ?? '',
      category: ActivityCategory.values.byName(json['category'] as String),
      activityType: json['activityType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      activityTime: DateTime.parse(json['activityTime'] as String),
      sourceType: SourceType.values.byName(json['sourceType'] as String? ?? 'manual'),
      confidenceLevel: ConfidenceLevel.values.byName(json['confidenceLevel'] as String? ?? 'confirmed'),
      calculatedKgCo2e: json['calculatedKgCo2e'] != null ? (json['calculatedKgCo2e'] as num).toDouble() : null,
      lowerEstimate: json['lowerEstimate'] != null ? (json['lowerEstimate'] as num).toDouble() : null,
      upperEstimate: json['upperEstimate'] != null ? (json['upperEstimate'] as num).toDouble() : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'activityType': activityType,
      'quantity': quantity,
      'unit': unit,
      'activityTime': activityTime.toIso8601String(),
      'sourceType': sourceType.name,
      'confidenceLevel': confidenceLevel.name,
      if (calculatedKgCo2e != null) 'calculatedKgCo2e': calculatedKgCo2e,
      if (lowerEstimate != null) 'lowerEstimate': lowerEstimate,
      if (upperEstimate != null) 'upperEstimate': upperEstimate,
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      activities: (json['activities'] as List<dynamic>?)?.map((actJson) {
        final map = actJson as Map<String, dynamic>;
        return Activity(
          id: '',
          category: ActivityCategory.values.byName(map['category'] as String),
          activityType: map['activityType'] as String,
          quantity: (map['quantity'] as num).toDouble(),
          unit: map['unit'] as String,
          activityTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList() ?? [],
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'activities': activities.map((act) => {
        'category': act.category.name,
        'activityType': act.activityType,
        'quantity': act.quantity,
        'unit': act.unit,
      }).toList(),
      'daysOfWeek': daysOfWeek,
      'createdAt': createdAt.toIso8601String(),
    };
  }
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

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String? ?? '',
      title: json['title'] as String,
      goalType: GoalType.values.byName(json['goalType'] as String),
      category: json['category'] != null ? ActivityCategory.values.byName(json['category'] as String) : null,
      targetValue: (json['targetValue'] as num).toDouble(),
      baselineValue: (json['baselineValue'] as num).toDouble(),
      progressValue: (json['progressValue'] as num? ?? 0.0).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: GoalStatus.values.byName(json['status'] as String? ?? 'active'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'goalType': goalType.name,
      if (category != null) 'category': category!.name,
      'targetValue': targetValue,
      'baselineValue': baselineValue,
      'progressValue': progressValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      regionCode: json['regionCode'] as String?,
      dietPattern: json['dietPattern'] as String?,
      travelPattern: json['travelPattern'] as String?,
      householdType: json['householdType'] as String?,
      householdSize: json['householdSize'] as int?,
      consumptionPattern: json['consumptionPattern'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      weeklyBaselineKgCo2e: (json['weeklyBaselineKgCo2e'] as num? ?? 0.0).toDouble(),
      weeklyLimitKgCo2e: json['weeklyLimitKgCo2e'] != null ? (json['weeklyLimitKgCo2e'] as num).toDouble() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (regionCode != null) 'regionCode': regionCode,
      if (dietPattern != null) 'dietPattern': dietPattern,
      if (travelPattern != null) 'travelPattern': travelPattern,
      if (householdType != null) 'householdType': householdType,
      if (householdSize != null) 'householdSize': householdSize,
      if (consumptionPattern != null) 'consumptionPattern': consumptionPattern,
      'onboardingCompleted': onboardingCompleted,
      'weeklyBaselineKgCo2e': weeklyBaselineKgCo2e,
      if (weeklyLimitKgCo2e != null) 'weeklyLimitKgCo2e': weeklyLimitKgCo2e,
      'createdAt': createdAt.toIso8601String(),
    };
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

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String,
      reason: json['reason'] as String,
      category: ActivityCategory.values.byName(json['category'] as String),
      estimatedReductionKgCo2e: (json['estimatedReductionKgCo2e'] as num).toDouble(),
      costLevel: json['costLevel'] as String,
      effortLevel: json['effortLevel'] as String,
      alternativeAction: json['alternativeAction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reason': reason,
      'category': category.name,
      'estimatedReductionKgCo2e': estimatedReductionKgCo2e,
      'costLevel': costLevel,
      'effortLevel': effortLevel,
      if (alternativeAction != null) 'alternativeAction': alternativeAction,
    };
  }
}
