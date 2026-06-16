import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/providers.dart';
import '../../theme/carbon_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize anonymous session
    await ref.read(authProvider.notifier).initialize();
    final userId = ref.read(authProvider);

    if (userId != null) {
      await ref.read(profileProvider.notifier).initialize(userId);
    }

    // Wait for splash animation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final profile = ref.read(profileProvider);
    if (profile != null && profile.onboardingCompleted) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? CarbonColors.backgroundDark : CarbonColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo icon with animation
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: CarbonColors.neutralGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: CarbonColors.tealPrimary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 52,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // App name
            Text(
              'CarbonLens',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'See the impact behind your day.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 600.ms),

            const SizedBox(height: 48),

            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: CarbonColors.tealPrimary,
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
