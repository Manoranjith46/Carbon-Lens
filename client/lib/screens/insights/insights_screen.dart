import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../theme/carbon_colors.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/premium_cards.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final activities = ref.watch(activityProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final total = dashboard.categoryBreakdown.values.fold<double>(0, (s, v) => s + v);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
            title: Text(
              'Insights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          activities.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.insights_outlined,
                    title: 'No data yet',
                    subtitle: 'Log some activities to see your carbon breakdown.',
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Donut Chart ────────────────────
                      if (total > 0) ...[
                        SectionHeader(
                          title: 'Weekly Breakdown',
                          icon: Icons.donut_small_rounded,
                          iconColor: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [const Color(0xFF1A2332), const Color(0xFF0D1520)]
                                  : [const Color(0xFFF8FAFF), const Color(0xFFEFF4FF)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: dashboard.categoryBreakdown.entries.map((e) {
                                      final pct = (e.value / total * 100);
                                      final color = _colorForCat(e.key, isDark);
                                      return PieChartSectionData(
                                        value: e.value,
                                        color: color,
                                        radius: 40,
                                        title: '${pct.toInt()}%',
                                        titleStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        badgeWidget: null,
                                      );
                                    }).toList(),
                                    sectionsSpace: 4,
                                    centerSpaceRadius: 48,
                                    centerSpaceColor: Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Legend
                              Wrap(
                                spacing: 16,
                                runSpacing: 10,
                                children: dashboard.categoryBreakdown.entries.map((e) {
                                  final color = _colorForCat(e.key, isDark);
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [color, color.withValues(alpha: 0.6)],
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.withValues(alpha: 0.3),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        CategoryIcon.labelFor(e.key.name),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms).scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                              duration: 600.ms,
                            ),
                      ],

                      const SizedBox(height: 24),

                      // ── Category Detail Cards ──────────
                      SectionHeader(
                        title: 'By Category',
                        icon: Icons.category_rounded,
                        iconColor: isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary,
                      ),
                      ...(dashboard.categoryBreakdown.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)))
                          .asMap()
                          .entries
                          .map((entry) {
                        final e = entry.value;
                        final pct = total > 0 ? (e.value / total * 100).toInt() : 0;
                        final catColor = _colorForCat(e.key, isDark);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                catColor.withValues(alpha: isDark ? 0.15 : 0.08),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: catColor.withValues(alpha: isDark ? 0.25 : 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              CategoryIcon(
                                category: e.key.name,
                                size: 22,
                                color: catColor,
                                showBackground: true,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CategoryIcon.labelFor(e.key.name),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: total > 0 ? e.value / total : 0,
                                        minHeight: 6,
                                        backgroundColor: catColor.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation(catColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$pct%',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: catColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${e.value.toStringAsFixed(1)} kg',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 200 + entry.key * 80),
                              duration: 400.ms,
                            );
                      }),

                      const SizedBox(height: 24),

                      // ── Recent Activities ──────────────
                      SectionHeader(
                        title: 'Recent Activities',
                        icon: Icons.history_rounded,
                        iconColor: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                      ),
                      ...activities.reversed.take(15).toList().asMap().entries.map((entry) {
                        final a = entry.value;
                        final catColor = _colorForCat(a.category, isDark);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                catColor.withValues(alpha: isDark ? 0.08 : 0.04),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  CategoryIcon.iconFor(a.category.name),
                                  size: 16,
                                  color: catColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.activityType, style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    )),
                                    Text(
                                      '${a.quantity} ${a.unit}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (a.calculatedKgCo2e != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${a.calculatedKgCo2e!.toStringAsFixed(1)} kg',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: catColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
        ],
      ),
    );
  }

  Color _colorForCat(ActivityCategory cat, bool isDark) {
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
}
