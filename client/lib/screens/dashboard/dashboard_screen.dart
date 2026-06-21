import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:ui';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../theme/carbon_colors.dart';
import '../../theme/carbon_status.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/premium_cards.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final profile = ref.watch(profileProvider);
    final recommendations = ref.watch(recommendationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = dashboard.carbonStatus;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Premium App Bar ──────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: _gradientForStatus(status, isDark),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: CarbonColors.tealPrimary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'CarbonLens',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => showComingSoonPopup(context),
                  icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Hero Card ──────────────────────────
                _HeroCard(
                  weeklyFootprint: dashboard.weeklyFootprint,
                  weeklyLimit: dashboard.weeklyLimit,
                  status: status,
                  isDark: isDark,
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.12,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 16),

                // ── Stats Row ──────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.today_rounded,
                        label: 'Today',
                        kgCo2e: dashboard.todayFootprint,
                        color: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.trending_down_rounded,
                        label: 'vs Avg',
                        kgCo2e: dashboard.todayFootprint - (profile?.weeklyBaselineKgCo2e ?? 50) / 7,
                        color: dashboard.todayFootprint < (profile?.weeklyBaselineKgCo2e ?? 50) / 7
                            ? (isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary)
                            : (isDark ? CarbonColors.redDark : CarbonColors.redPrimary),
                        showSign: true,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
                      begin: 0.08,
                      end: 0,
                      delay: 200.ms,
                    ),

                const SizedBox(height: 20),

                // ── Category Breakdown ──────────────────
                if (dashboard.categoryBreakdown.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Category Breakdown',
                    icon: Icons.donut_small_rounded,
                    iconColor: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                  ),
                  _CategoryBreakdownPremium(
                    breakdown: dashboard.categoryBreakdown,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
                ],

                const SizedBox(height: 20),

                // ── Suggestion Card ────────────────────
                if (recommendations.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Smart Suggestion',
                    icon: Icons.auto_awesome_rounded,
                    iconColor: CarbonColors.warningLight,
                  ),
                  _PremiumSuggestionCard(
                    recommendation: recommendations.first,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(
                        begin: 0.06,
                        end: 0,
                        delay: 500.ms,
                      ),
                ],

                const SizedBox(height: 20),

                // ── Top Source Card ─────────────────────
                if (dashboard.topCategory != null) ...[
                  SectionHeader(
                    title: 'Top Source',
                    icon: Icons.whatshot_rounded,
                    iconColor: isDark ? CarbonColors.redDark : CarbonColors.redPrimary,
                  ),
                  _TopSourceCard(
                    category: dashboard.topCategory!,
                    kgCo2e: dashboard.categoryBreakdown[dashboard.topCategory] ?? 0,
                    total: dashboard.weeklyFootprint,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 650.ms, duration: 500.ms),
                ],

                // Empty state
                if (dashboard.weeklyFootprint == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: EmptyStateWidget(
                      icon: Icons.add_circle_outline,
                      title: 'Start tracking',
                      subtitle: 'Add your usual commute to create your first daily estimate.',
                      actionLabel: 'Log your first activity',
                      onAction: () => context.go('/track'),
                    ),
                  ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _gradientForStatus(CarbonStatus status, bool isDark) {
    switch (status) {
      case CarbonStatus.neutral:
        return isDark ? CarbonColors.neutralGradientDark : CarbonColors.neutralGradient;
      case CarbonStatus.safe:
      case CarbonStatus.nearLimit:
        return isDark ? CarbonColors.withinLimitGradientDark : CarbonColors.withinLimitGradient;
      case CarbonStatus.overLimit:
        return isDark ? CarbonColors.overLimitGradientDark : CarbonColors.overLimitGradient;
    }
  }
}

// ─── Hero Card ────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final double weeklyFootprint;
  final double? weeklyLimit;
  final CarbonStatus status;
  final bool isDark;

  const _HeroCard({
    required this.weeklyFootprint,
    required this.weeklyLimit,
    required this.status,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = weeklyLimit != null && weeklyLimit! > 0
        ? (weeklyFootprint / weeklyLimit!).clamp(0.0, 1.5)
        : 0.0;

    final gradient = switch (status) {
      CarbonStatus.neutral => isDark ? CarbonColors.neutralGradientDark : CarbonColors.neutralGradient,
      CarbonStatus.safe || CarbonStatus.nearLimit =>
        isDark ? CarbonColors.withinLimitGradientDark : CarbonColors.withinLimitGradient,
      CarbonStatus.overLimit =>
        isDark ? CarbonColors.overLimitGradientDark : CarbonColors.overLimitGradient,
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'This Week',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CarbonValueDisplay(
                      kgCo2e: weeklyFootprint,
                      valueStyle: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                      unitStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            carbonStatusIcon(status),
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          carbonStatusLabel(status),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Progress ring
              CircularPercentIndicator(
                radius: 56,
                lineWidth: 9,
                percent: percent.clamp(0.0, 1.0),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'used',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1200,
              ),
            ],
          ),
          // Limit indicator
          if (weeklyLimit != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_rounded, color: Colors.white.withValues(alpha: 0.7), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Weekly limit: ${weeklyLimit!.toStringAsFixed(1)} kgCO₂e',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Mini Stat Card ───────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double kgCo2e;
  final Color color;
  final bool showSign;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.kgCo2e,
    required this.color,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefix = showSign ? (kgCo2e >= 0 ? '+' : '') : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.18 : 0.1),
            color.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$prefix${kgCo2e.toStringAsFixed(1)} kg',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Suggestion Card ──────────────────────────────────

class _PremiumSuggestionCard extends StatelessWidget {
  final Recommendation recommendation;
  final bool isDark;

  const _PremiumSuggestionCard({required this.recommendation, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = isDark ? const Color(0xFFFFD54F) : const Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2E2408), const Color(0xFF1A1505)]
              : [const Color(0xFFFFF8E1), const Color(0xFFFFF3E0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.25 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.2),
                      accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Smart Suggestion',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '−${recommendation.estimatedReductionKgCo2e.toStringAsFixed(1)} kg',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            recommendation.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            recommendation.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => showComingSoonPopup(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Try this', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => showComingSoonPopup(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Skip', style: TextStyle(color: accentColor.withValues(alpha: 0.7))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Top Source Card ───────────────────────────────────

class _TopSourceCard extends StatelessWidget {
  final ActivityCategory category;
  final double kgCo2e;
  final double total;
  final bool isDark;

  const _TopSourceCard({
    required this.category,
    required this.kgCo2e,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = _colorForCategory(category, isDark);
    final pct = total > 0 ? (kgCo2e / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            catColor.withValues(alpha: isDark ? 0.18 : 0.1),
            catColor.withValues(alpha: isDark ? 0.06 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: catColor.withValues(alpha: isDark ? 0.25 : 0.15)),
        boxShadow: [
          BoxShadow(
            color: catColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CategoryIcon(
            category: category.name,
            size: 26,
            color: catColor,
            showBackground: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CategoryIcon.labelFor(category.name),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pct% of your weekly total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                kgCo2e.toStringAsFixed(1),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: catColor,
                ),
              ),
              Text(
                'kgCO₂e',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: catColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Category Breakdown Premium ───────────────────────

class _CategoryBreakdownPremium extends StatelessWidget {
  final Map<ActivityCategory, double> breakdown;
  final bool isDark;

  const _CategoryBreakdownPremium({required this.breakdown, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = breakdown.values.fold<double>(0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.6)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: sorted.asMap().entries.map((entry) {
                  final e = entry.value;
                  final pct = e.value / total;
                  return Flexible(
                    flex: (pct * 100).round().clamp(1, 100),
                    child: Container(
                      margin: EdgeInsets.only(left: entry.key == 0 ? 0 : 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _colorForCategory(e.key, isDark),
                            _colorForCategory(e.key, isDark).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Category rows
          ...sorted.map((e) {
            final pct = (e.value / total * 100).toInt();
            final catColor = _colorForCategory(e.key, isDark);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [catColor, catColor.withValues(alpha: 0.6)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: catColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CategoryIcon(category: e.key.name, size: 16, color: catColor),
                  const SizedBox(width: 8),
                  Text(
                    CategoryIcon.labelFor(e.key.name),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$pct%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: catColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${e.value.toStringAsFixed(1)} kg',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

Color _colorForCategory(ActivityCategory cat, bool isDark) {
  return switch (cat) {
    ActivityCategory.transport =>
      isDark ? CarbonColors.chartTransportDark : CarbonColors.chartTransportLight,
    ActivityCategory.food =>
      isDark ? CarbonColors.chartFoodDark : CarbonColors.chartFoodLight,
    ActivityCategory.homeEnergy =>
      isDark ? CarbonColors.chartHomeDark : CarbonColors.chartHomeLight,
    ActivityCategory.purchases =>
      isDark ? CarbonColors.chartPurchasesDark : CarbonColors.chartPurchasesLight,
    ActivityCategory.waste =>
      isDark ? CarbonColors.chartWasteDark : CarbonColors.chartWasteLight,
  };
}
