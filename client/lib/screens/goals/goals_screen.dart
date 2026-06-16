import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../theme/carbon_colors.dart';
import '../../widgets/premium_cards.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              'Goals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          goals.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [const Color(0xFF1A2E1A), const Color(0xFF0D1A0D)]
                                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: CarbonColors.greenPrimary.withValues(alpha: 0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.flag_rounded,
                              size: 48,
                              color: isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Set your first goal',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Create a carbon reduction goal and track your progress towards a greener lifestyle.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: FilledButton.icon(
                              onPressed: () => _showCreateGoal(context, ref),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create a Goal',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SectionHeader(
                        title: 'Active Goals',
                        icon: Icons.flag_rounded,
                        iconColor: isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${goals.length} goals',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      ...goals.asMap().entries.map((entry) {
                        final goal = entry.value;
                        return _PremiumGoalCard(
                          goal: goal,
                          isDark: isDark,
                          index: entry.key,
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: entry.key * 100),
                              duration: 500.ms,
                            ).slideY(
                              begin: 0.08,
                              end: 0,
                              delay: Duration(milliseconds: entry.key * 100),
                            );
                      }),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
        ],
      ),
      floatingActionButton: goals.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showCreateGoal(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Goal', style: TextStyle(fontWeight: FontWeight.w700)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          : null,
    );
  }

  void _showCreateGoal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PremiumCreateGoalSheet(
        onCreate: (goal) {
          ref.read(goalProvider.notifier).addGoal(goal);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ─── Premium Goal Card ────────────────────────────────

class _PremiumGoalCard extends StatelessWidget {
  final Goal goal;
  final bool isDark;
  final int index;

  const _PremiumGoalCard({
    required this.goal,
    required this.isDark,
    required this.index,
  });

  static const _gradientColors = [
    [Color(0xFF00897B), Color(0xFF004D40)],
    [Color(0xFF1976D2), Color(0xFF0D47A1)],
    [Color(0xFF7B1FA2), Color(0xFF4A148C)],
    [Color(0xFFF57C00), Color(0xFFE65100)],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = goal.progressPercent;
    final colors = _gradientColors[index % _gradientColors.length];
    final accentColor = isDark ? colors[0] : colors[1];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: isDark ? 0.18 : 0.1),
            accentColor.withValues(alpha: isDark ? 0.06 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
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
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.flag_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.15),
                      accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 12, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.daysRemaining}d',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct.clamp(0, 1),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${(pct * 100).toInt()}% complete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${goal.progressValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} kgCO₂e',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Premium Create Goal Sheet ────────────────────────

class _PremiumCreateGoalSheet extends StatefulWidget {
  final ValueChanged<Goal> onCreate;
  const _PremiumCreateGoalSheet({required this.onCreate});

  @override
  State<_PremiumCreateGoalSheet> createState() => _PremiumCreateGoalSheetState();
}

class _PremiumCreateGoalSheetState extends State<_PremiumCreateGoalSheet> {
  final _titleController = TextEditingController(text: 'Reduce weekly footprint');
  double _targetValue = 5.0;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF004D40)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Text(
                  'Create a Goal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Goal title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A2E1A), const Color(0xFF0D1A0D)]
                      : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target reduction',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: CarbonColors.greenPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_targetValue.toStringAsFixed(1)} kgCO₂e/week',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary,
                      thumbColor: isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary,
                      inactiveTrackColor: CarbonColors.greenPrimary.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      value: _targetValue,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      onChanged: (v) => setState(() => _targetValue = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: () {
                    widget.onCreate(Goal(
                      id: const Uuid().v4(),
                      title: _titleController.text,
                      goalType: GoalType.weeklyReduction,
                      targetValue: _targetValue,
                      baselineValue: 0,
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(const Duration(days: 7)),
                      createdAt: DateTime.now(),
                    ));
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Create Goal', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
