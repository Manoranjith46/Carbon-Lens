import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/onboarding_result_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/track/track_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/goals/goals_screen.dart';
import '../screens/profile/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding-result',
        builder: (context, state) => const OnboardingResultScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/track',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const TrackScreen(),
            ),
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const InsightsScreen(),
            ),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const GoalsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

/// Main shell with bottom navigation bar.
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _tabs = [
    ('/home', Icons.home_rounded, Icons.home_outlined, 'Home'),
    ('/track', Icons.add_circle_rounded, Icons.add_circle_outline, 'Track'),
    ('/insights', Icons.insights_rounded, Icons.insights_outlined, 'Insights'),
    ('/goals', Icons.flag_rounded, Icons.flag_outlined, 'Goals'),
    ('/profile', Icons.person_rounded, Icons.person_outlined, 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].$1) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _currentIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => context.go(_tabs[i].$1),
          destinations: _tabs.map((tab) {
            return NavigationDestination(
              icon: Icon(tab.$3),
              selectedIcon: Icon(tab.$2),
              label: tab.$4,
            );
          }).toList(),
        ),
      ),
    );
  }
}
