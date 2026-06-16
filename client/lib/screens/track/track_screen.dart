import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/premium_cards.dart';
import '../../theme/carbon_colors.dart';

class TrackScreen extends ConsumerWidget {
  const TrackScreen({super.key});

  static const _categoryColors = {
    ActivityCategory.transport: (Color(0xFF4FC3F7), Color(0xFF0288D1)),
    ActivityCategory.food: (Color(0xFF81C784), Color(0xFF388E3C)),
    ActivityCategory.homeEnergy: (Color(0xFFFFB74D), Color(0xFFF57C00)),
    ActivityCategory.purchases: (Color(0xFFBA68C8), Color(0xFF7B1FA2)),
    ActivityCategory.waste: (Color(0xFF90A4AE), Color(0xFF546E7A)),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final todayActivities = activities.where((a) {
      final now = DateTime.now();
      return a.activityTime.year == now.year &&
          a.activityTime.month == now.month &&
          a.activityTime.day == now.day;
    }).toList();

    final todayTotal = todayActivities.fold<double>(
        0, (s, a) => s + (a.calculatedKgCo2e ?? 0));

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
              'Track',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.today_rounded, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${todayTotal.toStringAsFixed(1)} kg',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Quick Log Categories ──────────────
                SectionHeader(
                  title: 'Quick Log',
                  icon: Icons.bolt_rounded,
                  iconColor: CarbonColors.warningLight,
                ),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ActivityCategory.values.asMap().entries.map((entry) {
                      final cat = entry.value;
                      final colors = _categoryColors[cat]!;
                      return Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: _PremiumCategoryCard(
                          category: cat,
                          lightColor: colors.$1,
                          darkColor: colors.$2,
                          isDark: isDark,
                          onTap: () => _showQuickLog(context, ref, cat),
                        ),
                      );
                    }).toList()
                        .animate(interval: 80.ms)
                        .fadeIn(duration: 350.ms)
                        .slideX(begin: 0.08, end: 0),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Today's Activities ────────────────
                SectionHeader(
                  title: "Today's Log",
                  icon: Icons.history_rounded,
                  iconColor: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                  trailing: todayActivities.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${todayActivities.length} items',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
                ),

                if (todayActivities.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_circle_outline_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activities today',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap a category above to log your first activity',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...todayActivities.asMap().entries.map((entry) {
                    final a = entry.value;
                    final catColors = _categoryColors[a.category]!;
                    return _PremiumActivityTile(
                      activity: a,
                      ref: ref,
                      catColor: isDark ? catColors.$1 : catColors.$2,
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: entry.key * 60),
                          duration: 350.ms,
                        )
                        .slideX(begin: 0.04, end: 0);
                  }),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
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
          onPressed: () => _showQuickLog(context, ref, ActivityCategory.transport),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Log Activity', style: TextStyle(fontWeight: FontWeight.w700)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showQuickLog(BuildContext context, WidgetRef ref, ActivityCategory category) {
    final options = _optionsForCategory(category);
    final colors = _categoryColors[category]!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PremiumLogSheet(
        category: category,
        options: options,
        accentColor: Theme.of(context).brightness == Brightness.dark ? colors.$1 : colors.$2,
        onLog: (type, quantity, unit) {
          ref.read(activityProvider.notifier).addActivity(Activity(
                id: const Uuid().v4(),
                category: category,
                activityType: type,
                quantity: quantity,
                unit: unit,
                activityTime: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Activity logged ✓'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  List<_QuickOption> _optionsForCategory(ActivityCategory cat) {
    return switch (cat) {
      ActivityCategory.transport => const [
          _QuickOption('Bus', 'bus', Icons.directions_bus, 'km', 10),
          _QuickOption('Car', 'car', Icons.directions_car, 'km', 15),
          _QuickOption('Train', 'train', Icons.train, 'km', 20),
          _QuickOption('Motorcycle', 'motorcycle', Icons.two_wheeler, 'km', 10),
          _QuickOption('Walk', 'walking', Icons.directions_walk, 'km', 2),
          _QuickOption('Cycle', 'cycling', Icons.pedal_bike, 'km', 5),
          _QuickOption('Metro', 'metro', Icons.subway, 'km', 10),
          _QuickOption('Auto', 'autoRickshaw', Icons.electric_rickshaw, 'km', 5),
        ],
      ActivityCategory.food => const [
          _QuickOption('Veg meal', 'vegetarian', Icons.grass, 'meals', 1),
          _QuickOption('Plant-based', 'plantBased', Icons.eco, 'meals', 1),
          _QuickOption('Chicken', 'chicken', Icons.restaurant, 'meals', 1),
          _QuickOption('Fish', 'fish', Icons.set_meal, 'meals', 1),
          _QuickOption('Red meat', 'redMeat', Icons.kebab_dining, 'meals', 1),
          _QuickOption('Dairy', 'dairy', Icons.local_cafe, 'servings', 1),
        ],
      ActivityCategory.homeEnergy => const [
          _QuickOption('Electricity', 'electricity', Icons.bolt, 'kWh', 5),
          _QuickOption('AC', 'airConditioner', Icons.ac_unit, 'hours', 2),
          _QuickOption('Gas', 'cookingGas', Icons.local_fire_department, 'kg', 0.5),
        ],
      ActivityCategory.purchases => const [
          _QuickOption('Online order', 'onlineDelivery', Icons.local_shipping, 'items', 1),
          _QuickOption('Clothing', 'clothing', Icons.checkroom, 'items', 1),
          _QuickOption('Electronics', 'electronics', Icons.devices, 'items', 1),
        ],
      ActivityCategory.waste => const [
          _QuickOption('General', 'generalWaste', Icons.delete, 'kg', 1),
          _QuickOption('Recycled', 'recycled', Icons.recycling, 'kg', 1),
          _QuickOption('Compost', 'composting', Icons.compost, 'kg', 0.5),
        ],
    };
  }
}

// ─── Data Models ──────────────────────────────────────

class _QuickOption {
  final String label;
  final String type;
  final IconData icon;
  final String unit;
  final double defaultQty;
  const _QuickOption(this.label, this.type, this.icon, this.unit, this.defaultQty);
}

// ─── Premium Category Card ────────────────────────────

class _PremiumCategoryCard extends StatelessWidget {
  final ActivityCategory category;
  final Color lightColor;
  final Color darkColor;
  final bool isDark;
  final VoidCallback onTap;

  const _PremiumCategoryCard({
    required this.category,
    required this.lightColor,
    required this.darkColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? lightColor : darkColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: isDark ? 0.2 : 0.12),
              color.withValues(alpha: isDark ? 0.08 : 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                CategoryIcon.iconFor(category.name),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              CategoryIcon.labelFor(category.name),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Premium Activity Tile ────────────────────────────

class _PremiumActivityTile extends StatelessWidget {
  final Activity activity;
  final WidgetRef ref;
  final Color catColor;

  const _PremiumActivityTile({
    required this.activity,
    required this.ref,
    required this.catColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(activity.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(activityProvider.notifier).removeActivity(activity.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.error.withValues(alpha: 0.05),
              theme.colorScheme.error.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              catColor.withValues(alpha: isDark ? 0.1 : 0.06),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: catColor.withValues(alpha: isDark ? 0.2 : 0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    catColor.withValues(alpha: 0.15),
                    catColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                CategoryIcon.iconFor(activity.category.name),
                color: catColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.activityType,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activity.quantity} ${activity.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            if (activity.calculatedKgCo2e != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${activity.calculatedKgCo2e!.toStringAsFixed(1)} kg',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: catColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Premium Log Bottom Sheet ─────────────────────────

class _PremiumLogSheet extends StatefulWidget {
  final ActivityCategory category;
  final List<_QuickOption> options;
  final Color accentColor;
  final void Function(String type, double quantity, String unit) onLog;

  const _PremiumLogSheet({
    required this.category,
    required this.options,
    required this.accentColor,
    required this.onLog,
  });

  @override
  State<_PremiumLogSheet> createState() => _PremiumLogSheetState();
}

class _PremiumLogSheetState extends State<_PremiumLogSheet> {
  _QuickOption? _selected;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
  }

  @override
  void dispose() {
    _qtyController.dispose();
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
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.accentColor, widget.accentColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CategoryIcon.iconFor(widget.category.name),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Log ${CategoryIcon.labelFor(widget.category.name)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: widget.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final opt = widget.options[index];
                    final isSelected = _selected == opt;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selected = opt;
                          _qtyController.text = opt.defaultQty.toString();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    widget.accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                    widget.accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? widget.accentColor
                                : theme.colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (isSelected ? widget.accentColor : theme.colorScheme.onSurface)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(opt.icon, size: 20,
                                  color: isSelected ? widget.accentColor : null),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(opt.label, style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              )),
                            ),
                            if (isSelected)
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _qtyController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: widget.accentColor,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    suffixText: opt.unit,
                                    suffixStyle: TextStyle(
                                      fontSize: 10,
                                      color: widget.accentColor.withValues(alpha: 0.6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: widget.accentColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: widget.accentColor, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_selected != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: () {
                        final qty = double.tryParse(_qtyController.text) ?? _selected!.defaultQty;
                        widget.onLog(_selected!.type, qty, _selected!.unit);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Activity', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
