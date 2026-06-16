import 'package:flutter/material.dart';

/// Formats and displays a CO₂ value with proper units.
class CarbonValueDisplay extends StatelessWidget {
  final double kgCo2e;
  final TextStyle? valueStyle;
  final TextStyle? unitStyle;
  final bool showUnit;

  const CarbonValueDisplay({
    super.key,
    required this.kgCo2e,
    this.valueStyle,
    this.unitStyle,
    this.showUnit = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String value;
    String unit;

    if (kgCo2e >= 1000) {
      value = (kgCo2e / 1000).toStringAsFixed(1);
      unit = 'tCO₂e';
    } else if (kgCo2e >= 1) {
      value = kgCo2e.toStringAsFixed(1);
      unit = 'kgCO₂e';
    } else {
      value = (kgCo2e * 1000).toStringAsFixed(0);
      unit = 'gCO₂e';
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: valueStyle ??
                theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (showUnit) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: unit,
              style: unitStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge showing the confidence level of an activity.
class ConfidenceBadge extends StatelessWidget {
  final String level;

  const ConfidenceBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, label, color) = switch (level) {
      'confirmed' => (Icons.check_circle, 'Confirmed', theme.colorScheme.primary),
      'connected' => (Icons.link, 'Connected', theme.colorScheme.secondary),
      'detected' => (Icons.sensors, 'Detected', theme.colorScheme.tertiary),
      'estimated' => (Icons.calculate_outlined, 'Estimated', theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      _ => (Icons.info_outline, 'Default', theme.colorScheme.onSurface.withValues(alpha: 0.4)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon for a carbon category with colored background.
class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;
  final Color? color;
  final bool showBackground;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 24,
    this.color,
    this.showBackground = false,
  });

  static IconData iconFor(String category) {
    return switch (category) {
      'transport' => Icons.directions_car_rounded,
      'food' => Icons.restaurant_rounded,
      'homeEnergy' => Icons.bolt_rounded,
      'purchases' => Icons.shopping_bag_rounded,
      'waste' => Icons.delete_rounded,
      _ => Icons.eco_rounded,
    };
  }

  static String labelFor(String category) {
    return switch (category) {
      'transport' => 'Transport',
      'food' => 'Food',
      'homeEnergy' => 'Home Energy',
      'purchases' => 'Purchases',
      'waste' => 'Waste',
      _ => 'Other',
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    if (!showBackground) {
      return Icon(iconFor(category), size: size, color: c);
    }
    return Container(
      padding: EdgeInsets.all(size * 0.4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.withValues(alpha: 0.18),
            c.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.45),
        border: Border.all(color: c.withValues(alpha: 0.15)),
      ),
      child: Icon(iconFor(category), size: size, color: c),
    );
  }
}

/// Friendly empty state widget with premium styling.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 44,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
