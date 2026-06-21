import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../providers/providers.dart';
import '../../theme/carbon_colors.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/premium_cards.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);
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
              'Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Profile Header ──────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1A2E2E), const Color(0xFF0D1A1A)]
                          : [const Color(0xFF00897B), const Color(0xFF004D40)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: CarbonColors.tealPrimary.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest User',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded,
                                      size: 12, color: Colors.white.withValues(alpha: 0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'India',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0),

                const SizedBox(height: 16),

                // ── Sync Card ───────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1A2332), const Color(0xFF0D1520)]
                          : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: (isDark ? CarbonColors.infoPrimaryDark : CarbonColors.infoPrimaryLight)
                          .withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? CarbonColors.infoPrimaryDark : CarbonColors.infoPrimaryLight)
                            .withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF42A5F5), const Color(0xFF1565C0)]
                                : [const Color(0xFF1976D2), const Color(0xFF0D47A1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.cloud_upload_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keep your progress safe',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Connect an account to sync across devices.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 8),

                // ── Account Options ─────────────────
                _PremiumOption(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  iconGradient: const [Color(0xFF4285F4), Color(0xFF1A73E8)],
                  onTap: () => _showComingSoon(context),
                ),
                _PremiumOption(
                  icon: Icons.apple_rounded,
                  label: 'Continue with Apple',
                  iconGradient: isDark
                      ? [Colors.white, Colors.white70]
                      : [Colors.black, Colors.black87],
                  onTap: () => _showComingSoon(context),
                ),
                _PremiumOption(
                  icon: Icons.key_rounded,
                  label: 'Create a passkey',
                  iconGradient: const [Color(0xFFFF9800), Color(0xFFE65100)],
                  onTap: () => _showComingSoon(context),
                ),

                const SizedBox(height: 24),

                // ── Theme ───────────────────────────
                SectionHeader(
                  title: 'Appearance',
                  icon: Icons.palette_rounded,
                  iconColor: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SegmentedButton<ThemeModeSetting>(
                    selected: {themeMode},
                    onSelectionChanged: (v) {
                      ref.read(themeModeProvider.notifier).state = v.first;
                    },
                    segments: const [
                      ButtonSegment(
                        value: ThemeModeSetting.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment(
                        value: ThemeModeSetting.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeModeSetting.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Lifestyle Profile ───────────────
                if (profile != null) ...[
                  SectionHeader(
                    title: 'Your Lifestyle',
                    icon: Icons.eco_rounded,
                    iconColor: isDark ? CarbonColors.greenDark : CarbonColors.greenPrimary,
                  ),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1A2E1A), const Color(0xFF0D1A0D)]
                            : [const Color(0xFFF1F8E9), const Color(0xFFDCEDC8)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: CarbonColors.greenPrimary.withValues(alpha: isDark ? 0.2 : 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        _PremiumInfoRow(
                          icon: Icons.directions_car_rounded,
                          label: 'Travel',
                          value: profile.travelPattern ?? 'Not set',
                          color: const Color(0xFF4FC3F7),
                        ),
                        _PremiumInfoRow(
                          icon: Icons.restaurant_rounded,
                          label: 'Diet',
                          value: profile.dietPattern ?? 'Not set',
                          color: const Color(0xFF81C784),
                        ),
                        _PremiumInfoRow(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          value: profile.householdType ?? 'Not set',
                          color: const Color(0xFFFFB74D),
                        ),
                        _PremiumInfoRow(
                          icon: Icons.shopping_bag_rounded,
                          label: 'Shopping',
                          value: profile.consumptionPattern ?? 'Not set',
                          color: const Color(0xFFBA68C8),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: CarbonColors.tealPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.speed_rounded, size: 16,
                                  color: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary),
                            ),
                            const SizedBox(width: 10),
                            Text('Weekly baseline', style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: CarbonColors.tealPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${profile.weeklyBaselineKgCo2e.toStringAsFixed(1)} kgCO₂e',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Data Section ────────────────────
                SectionHeader(
                  title: 'Data',
                  icon: Icons.storage_rounded,
                  iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                _PremiumOption(
                  icon: Icons.download_rounded,
                  label: 'Export data',
                  iconGradient: [
                    isDark ? CarbonColors.tealDark : CarbonColors.tealPrimary,
                    isDark ? CarbonColors.tealDark.withValues(alpha: 0.7) : const Color(0xFF004D40),
                  ],
                  onTap: () => _showComingSoon(context),
                ),
                _PremiumOption(
                  icon: Icons.delete_forever_rounded,
                  label: 'Delete all data',
                  iconGradient: const [Color(0xFFE53935), Color(0xFFB71C1C)],
                  isDestructive: true,
                  onTap: () => _showDeleteConfirm(context, ref),
                ),

                const SizedBox(height: 32),

                // ── App Info ────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: CarbonColors.neutralGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: CarbonColors.tealPrimary.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'CarbonLens v1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'See the impact behind your day.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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

  void _showComingSoon(BuildContext context) {
    showComingSoonPopup(context);
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete all data?'),
        content: const Text(
          'This will permanently remove your profile, activities, and goals. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              showComingSoonPopup(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Premium Option Tile ──────────────────────────────

class _PremiumOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> iconGradient;
  final VoidCallback onTap;
  final bool isDestructive;

  const _PremiumOption({
    required this.icon,
    required this.label,
    required this.iconGradient,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  iconGradient.first.withValues(alpha: isDark ? 0.08 : 0.04),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: iconGradient.first.withValues(alpha: isDark ? 0.15 : 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: iconGradient),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: iconGradient.first.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? theme.colorScheme.error : null,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Premium Info Row ─────────────────────────────────

class _PremiumInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PremiumInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            )),
          ),
        ],
      ),
    );
  }
}
