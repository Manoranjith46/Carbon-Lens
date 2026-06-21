import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import '../data/mock/mock_data.dart';
import '../theme/carbon_status.dart';
import '../config/api_config.dart';

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
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/profile/$userId'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          state = UserProfile.fromJson(body['data'] as Map<String, dynamic>);
          return;
        }
      }
    } catch (e) {
      debugPrint("Error initializing profile from backend: $e");
    }

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
        weeklyBaselineKgCo2e: prefs.getDouble('weekly_baseline') ?? 50.0,
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

    final localProfile = UserProfile(
      userId: userId,
      regionCode: 'IN',
      travelPattern: travelPattern,
      dietPattern: dietPattern,
      householdType: householdType,
      consumptionPattern: consumptionPattern,
      onboardingCompleted: true,
      weeklyBaselineKgCo2e: baseline,
      weeklyLimitKgCo2e: baseline * 0.9,
      createdAt: DateTime.now(),
    );

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/profile/$userId/onboarding'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'travelPattern': travelPattern,
          'dietPattern': dietPattern,
          'householdType': householdType,
          'consumptionPattern': consumptionPattern,
          'regionCode': 'IN',
          'householdSize': 1,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          state = UserProfile.fromJson(body['data'] as Map<String, dynamic>);
          await _saveLocal(state!);
          return;
        }
      }
    } catch (e) {
      debugPrint("Error completing onboarding on backend: $e");
    }

    state = localProfile;
    await _saveLocal(localProfile);
  }

  Future<void> _saveLocal(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('travel_pattern', profile.travelPattern ?? '');
    await prefs.setString('diet_pattern', profile.dietPattern ?? '');
    await prefs.setString('household_type', profile.householdType ?? '');
    await prefs.setString('consumption_pattern', profile.consumptionPattern ?? '');
    await prefs.setDouble('weekly_baseline', profile.weeklyBaselineKgCo2e);
    await prefs.setDouble('weekly_limit', profile.weeklyLimitKgCo2e ?? (profile.weeklyBaselineKgCo2e * 0.9));
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

  String? _userId;

  Future<void> initialize(String userId) async {
    _userId = userId;
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/activities/$userId'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          state = (body['data'] as List)
              .map((json) => Activity.fromJson(json as Map<String, dynamic>))
              .toList();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching activities from backend: $e");
    }
  }

  Future<void> addActivity(Activity activity) async {
    if (_userId == null) return;

    final kgCo2e = MockEmissionFactors.calculate(
      activity.category,
      activity.activityType,
      activity.quantity,
    );
    final tempActivity = activity.copyWith(
      calculatedKgCo2e: kgCo2e,
      lowerEstimate: kgCo2e * 0.8,
      upperEstimate: kgCo2e * 1.2,
    );

    state = [...state, tempActivity];

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/activities'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          ...activity.toJson(),
          'userId': _userId,
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final saved = Activity.fromJson(body['data'] as Map<String, dynamic>);
          state = state.map((a) => a.id == activity.id || a.id == '' ? saved : a).toList();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error adding activity to backend: $e");
    }
  }

  Future<void> removeActivity(String id) async {
    final previousState = state;
    state = state.where((a) => a.id != id).toList();

    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/activities/$id'));
      if (response.statusCode == 200) {
        return;
      }
    } catch (e) {
      debugPrint("Error removing activity from backend: $e");
    }
    state = previousState;
  }

  Future<void> updateActivity(Activity updated) async {
    final previousState = state;
    state = state.map((a) => a.id == updated.id ? updated : a).toList();

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/activities/${updated.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updated.toJson()),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final saved = Activity.fromJson(body['data'] as Map<String, dynamic>);
          state = state.map((a) => a.id == updated.id ? saved : a).toList();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error updating activity on backend: $e");
    }
    state = previousState;
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
            a.activityTime.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
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

final recommendationProvider =
    StateNotifierProvider<RecommendationNotifier, List<Recommendation>>((ref) {
  return RecommendationNotifier();
});

class RecommendationNotifier extends StateNotifier<List<Recommendation>> {
  RecommendationNotifier() : super([]);

  Future<void> initialize(String userId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/recommendations/$userId'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          state = (body['data'] as List)
              .map((json) => Recommendation.fromJson(json as Map<String, dynamic>))
              .toList();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching recommendations from backend: $e");
    }
  }
}

// ═══════════════════════════════════════════════════════
// GOAL PROVIDER
// ═══════════════════════════════════════════════════════

final goalProvider =
    StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<List<Goal>> {
  GoalNotifier() : super([]);

  String? _userId;

  Future<void> initialize(String userId) async {
    _userId = userId;
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/goals/$userId'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          state = (body['data'] as List)
              .map((json) => Goal.fromJson(json as Map<String, dynamic>))
              .toList();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching goals from backend: $e");
    }
  }

  Future<void> addGoal(Goal goal) async {
    if (_userId == null) return;

    state = [...state, goal];

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/goals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          ...goal.toJson(),
          'userId': _userId,
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final saved = Goal.fromJson(body['data'] as Map<String, dynamic>);
          state = state.map((g) => g.id == goal.id || g.id == '' ? saved : g).toList();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error adding goal to backend: $e");
    }
  }

  Future<void> updateGoal(Goal updated) async {
    final previousState = state;
    state = state.map((g) => g.id == updated.id ? updated : g).toList();

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/goals/${updated.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updated.toJson()),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final saved = Goal.fromJson(body['data'] as Map<String, dynamic>);
          state = state.map((g) => g.id == updated.id ? saved : g).toList();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error updating goal on backend: $e");
    }
    state = previousState;
  }

  Future<void> removeGoal(String id) async {
    final previousState = state;
    state = state.where((g) => g.id != id).toList();

    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/goals/$id'));
      if (response.statusCode == 200) {
        return;
      }
    } catch (e) {
      debugPrint("Error removing goal from backend: $e");
    }
    state = previousState;
  }
}

// ═══════════════════════════════════════════════════════
// THEME MODE PROVIDER
// ═══════════════════════════════════════════════════════

final themeModeProvider = StateProvider<ThemeModeSetting>((ref) {
  return ThemeModeSetting.system;
});

enum ThemeModeSetting { system, light, dark }
