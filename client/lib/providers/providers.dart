import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import '../data/mock/mock_data.dart';
import '../theme/carbon_status.dart';

// ═══════════════════════════════════════════════════════
// ANONYMOUS AUTH PROVIDER
// ═══════════════════════════════════════════════════════

final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<String?> {
  AuthNotifier() : super(null);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('anonymous_user_id');
    if (userId == null) {
      userId = 'guest_${const Uuid().v4().substring(0, 10)}';
      await prefs.setString('anonymous_user_id', userId);
    }
    state = userId;
  }
}

// ═══════════════════════════════════════════════════════
// USER PROFILE PROVIDER
// ═══════════════════════════════════════════════════════

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null);

  Future<void> initialize(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    if (completed) {
      state = UserProfile(
        userId: userId,
        regionCode: prefs.getString('region_code') ?? 'IN',
        travelPattern: prefs.getString('travel_pattern'),
        dietPattern: prefs.getString('diet_pattern'),
        householdType: prefs.getString('household_type'),
        consumptionPattern: prefs.getString('consumption_pattern'),
        onboardingCompleted: true,
        weeklyBaselineKgCo2e:
            prefs.getDouble('weekly_baseline') ?? 50.0,
        weeklyLimitKgCo2e: prefs.getDouble('weekly_limit') ?? 50.0,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> completeOnboarding({
    required String userId,
    required String travelPattern,
    required String dietPattern,
    required String householdType,
    required String consumptionPattern,
  }) async {
    final baseline = MockEmissionFactors.estimateWeeklyBaseline(
      travelPattern: travelPattern,
      dietPattern: dietPattern,
      householdType: householdType,
      consumptionPattern: consumptionPattern,
    );

    final profile = UserProfile(
      userId: userId,
      regionCode: 'IN',
      travelPattern: travelPattern,
      dietPattern: dietPattern,
      householdType: householdType,
      consumptionPattern: consumptionPattern,
      onboardingCompleted: true,
      weeklyBaselineKgCo2e: baseline,
      weeklyLimitKgCo2e: baseline * 0.9, // Target 10% reduction
      createdAt: DateTime.now(),
    );

    state = profile;

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('travel_pattern', travelPattern);
    await prefs.setString('diet_pattern', dietPattern);
    await prefs.setString('household_type', householdType);
    await prefs.setString('consumption_pattern', consumptionPattern);
    await prefs.setDouble('weekly_baseline', baseline);
    await prefs.setDouble('weekly_limit', baseline * 0.9);
  }
}

// ═══════════════════════════════════════════════════════
// ACTIVITY PROVIDER
// ═══════════════════════════════════════════════════════

final activityProvider =
    StateNotifierProvider<ActivityNotifier, List<Activity>>((ref) {
  return ActivityNotifier();
});

class ActivityNotifier extends StateNotifier<List<Activity>> {
  ActivityNotifier() : super([]);

  void addActivity(Activity activity) {
    // Calculate CO2
    final kgCo2e = MockEmissionFactors.calculate(
      activity.category,
      activity.activityType,
      activity.quantity,
    );
    state = [
      ...state,
      activity.copyWith(
        calculatedKgCo2e: kgCo2e,
        lowerEstimate: kgCo2e * 0.8,
        upperEstimate: kgCo2e * 1.2,
      ),
    ];
  }

  void removeActivity(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void updateActivity(Activity updated) {
    state = state.map((a) => a.id == updated.id ? updated : a).toList();
  }

  List<Activity> getForDate(DateTime date) {
    return state
        .where((a) =>
            a.activityTime.year == date.year &&
            a.activityTime.month == date.month &&
            a.activityTime.day == date.day)
        .toList();
  }

  List<Activity> getForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return state
        .where((a) =>
            a.activityTime.isAfter(weekStart) &&
            a.activityTime.isBefore(weekEnd))
        .toList();
  }
}

// ═══════════════════════════════════════════════════════
// DASHBOARD PROVIDER (Derived)
// ═══════════════════════════════════════════════════════

class DashboardState {
  final double todayFootprint;
  final double weeklyFootprint;
  final double? weeklyLimit;
  final ActivityCategory? topCategory;
  final Map<ActivityCategory, double> categoryBreakdown;
  final CarbonStatus carbonStatus;

  const DashboardState({
    this.todayFootprint = 0,
    this.weeklyFootprint = 0,
    this.weeklyLimit,
    this.topCategory,
    this.categoryBreakdown = const {},
    this.carbonStatus = CarbonStatus.neutral,
  });
}

final dashboardProvider = Provider<DashboardState>((ref) {
  final activities = ref.watch(activityProvider);
  final profile = ref.watch(profileProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));

  // Today's footprint
  final todayActivities = activities.where((a) =>
      a.activityTime.year == today.year &&
      a.activityTime.month == today.month &&
      a.activityTime.day == today.day);
  final todayTotal =
      todayActivities.fold<double>(0, (sum, a) => sum + (a.calculatedKgCo2e ?? 0));

  // Weekly footprint
  final weekEnd = weekStart.add(const Duration(days: 7));
  final weekActivities = activities.where((a) =>
      a.activityTime.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
      a.activityTime.isBefore(weekEnd));
  final weeklyTotal =
      weekActivities.fold<double>(0, (sum, a) => sum + (a.calculatedKgCo2e ?? 0));

  // Category breakdown
  final breakdown = <ActivityCategory, double>{};
  for (final a in weekActivities) {
    breakdown[a.category] = (breakdown[a.category] ?? 0) + (a.calculatedKgCo2e ?? 0);
  }

  // Top category
  ActivityCategory? topCat;
  double topVal = 0;
  for (final entry in breakdown.entries) {
    if (entry.value > topVal) {
      topVal = entry.value;
      topCat = entry.key;
    }
  }

  final limit = profile?.weeklyLimitKgCo2e;
  final status = getCarbonStatus(weeklyTotal, limit);

  return DashboardState(
    todayFootprint: todayTotal,
    weeklyFootprint: weeklyTotal,
    weeklyLimit: limit,
    topCategory: topCat,
    categoryBreakdown: breakdown,
    carbonStatus: status,
  );
});

// ═══════════════════════════════════════════════════════
// CARBON STATUS PROVIDER (Derived)
// ═══════════════════════════════════════════════════════

final carbonStatusProvider = Provider<CarbonStatus>((ref) {
  return ref.watch(dashboardProvider).carbonStatus;
});

// ═══════════════════════════════════════════════════════
// RECOMMENDATION PROVIDER
// ═══════════════════════════════════════════════════════

final recommendationProvider = Provider<List<Recommendation>>((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) return [];
  return MockRecommendations.getForProfile(
    travelPattern: profile.travelPattern ?? 'combination',
    dietPattern: profile.dietPattern ?? 'mixed',
  );
});

// ═══════════════════════════════════════════════════════
// GOAL PROVIDER
// ═══════════════════════════════════════════════════════

final goalProvider =
    StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<List<Goal>> {
  GoalNotifier() : super([]);

  void addGoal(Goal goal) {
    state = [...state, goal];
  }

  void updateGoal(Goal updated) {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
  }

  void removeGoal(String id) {
    state = state.where((g) => g.id != id).toList();
  }
}

// ═══════════════════════════════════════════════════════
// THEME MODE PROVIDER
// ═══════════════════════════════════════════════════════

final themeModeProvider = StateProvider<ThemeModeSetting>((ref) {
  return ThemeModeSetting.system;
});

enum ThemeModeSetting { system, light, dark }
