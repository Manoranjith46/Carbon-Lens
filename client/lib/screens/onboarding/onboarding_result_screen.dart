import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/providers.dart';
import '../../widgets/shared_widgets.dart';
import '../../theme/carbon_colors.dart';

class OnboardingResultScreen extends ConsumerWidget {
  const OnboardingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseline = profile?.weeklyBaselineKgCo2e ?? 50.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Success icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: CarbonColors.neutralGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CarbonColors.tealPrimary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 28),

              // Title
              Center(
                child: Text(
                  'Your estimated weekly footprint',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 12),

              // Big number
              Center(
                child: CarbonValueDisplay(
                  kgCo2e: baseline,
                  valueStyle: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, delay: 500.ms),

              const SizedBox(height: 8),

              // Confidence
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Medium confidence — based on your lifestyle answers',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // Info cards
              _ResultCard(
                icon: Icons.directions_car_rounded,
                iconColor: isDark
                    ? CarbonColors.chartTransportDark
                    : CarbonColors.chartTransportLight,
                title: 'Top source: Transport',
                subtitle:
                    'Your commute is the largest contributor to your weekly footprint.',
              ).animate().fadeIn(delay: 800.ms, duration: 400.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    delay: 800.ms,
                  ),

              const SizedBox(height: 12),

              _ResultCard(
                icon: Icons.lightbulb_rounded,
                iconColor: CarbonColors.warningLight,
                title: 'First suggestion',
                subtitle:
                    'Try taking the bus for one commute trip this week. Potential saving: ~1.8 kgCO₂e.',
              ).animate().fadeIn(delay: 950.ms, duration: 400.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    delay: 950.ms,
                  ),

              const SizedBox(height: 12),

              _ResultCard(
                icon: Icons.calculate_outlined,
                iconColor: isDark
                    ? CarbonColors.infoPrimaryDark
                    : CarbonColors.infoPrimaryLight,
                title: 'How was this calculated?',
                subtitle:
                    'We used your answers about travel, food, home, and purchases with regional emission factors for India.',
              ).animate().fadeIn(delay: 1100.ms, duration: 400.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    delay: 1100.ms,
                  ),

              const SizedBox(height: 36),

              // CTA
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Go to Dashboard'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, delay: 1300.ms),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Improve this estimate later',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1400.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ResultCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
