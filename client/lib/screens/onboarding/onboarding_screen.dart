import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Answers
  String? _travelPattern;
  String? _dietPattern;
  String? _householdType;
  String? _consumptionPattern;

  final _totalPages = 4;

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _complete() async {
    final userId = ref.read(authProvider) ?? 'guest';
    await ref.read(profileProvider.notifier).completeOnboarding(
          userId: userId,
          travelPattern: _travelPattern ?? 'combination',
          dietPattern: _dietPattern ?? 'mixed',
          householdType: _householdType ?? 'apartment',
          consumptionPattern: _consumptionPattern ?? 'onceOrTwice',
        );
    if (mounted) context.go('/onboarding-result');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            )
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _totalPages,
                        backgroundColor: theme.colorScheme.outlineVariant,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentPage + 1}/$_totalPages',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _TravelQuestion(
                    selected: _travelPattern,
                    onSelected: (v) {
                      setState(() => _travelPattern = v);
                      _next();
                    },
                  ),
                  _FoodQuestion(
                    selected: _dietPattern,
                    onSelected: (v) {
                      setState(() => _dietPattern = v);
                      _next();
                    },
                  ),
                  _HomeQuestion(
                    selected: _householdType,
                    onSelected: (v) {
                      setState(() => _householdType = v);
                      _next();
                    },
                  ),
                  _ConsumptionQuestion(
                    selected: _consumptionPattern,
                    onSelected: (v) {
                      setState(() => _consumptionPattern = v);
                      _next();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Question Widgets ─────────────────────────────────

class _QuestionPage extends StatelessWidget {
  final String emoji;
  final String question;
  final String subtitle;
  final List<_OptionItem> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _QuestionPage({
    required this.emoji,
    required this.question,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 16),
          Text(
            question,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideX(
                begin: 0.1,
                end: 0,
                delay: 150.ms,
              ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selected == option.value;
                return _OptionTile(
                  icon: option.icon,
                  label: option.label,
                  isSelected: isSelected,
                  onTap: () => onSelected(option.value),
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 300 + index * 60),
                      duration: 350.ms,
                    )
                    .slideX(
                      begin: 0.05,
                      end: 0,
                      delay: Duration(milliseconds: 300 + index * 60),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String label;
  final String value;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Individual Questions ───────────────────────────────

class _TravelQuestion extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _TravelQuestion({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _QuestionPage(
      emoji: '🚗',
      question: 'How do you usually travel?',
      subtitle: 'Select your most common transport during a normal week.',
      selected: selected,
      onSelected: onSelected,
      options: const [
        _OptionItem(icon: Icons.directions_walk, label: 'Walk', value: 'walk'),
        _OptionItem(icon: Icons.pedal_bike, label: 'Bicycle', value: 'bicycle'),
        _OptionItem(icon: Icons.two_wheeler, label: 'Motorcycle', value: 'motorcycle'),
        _OptionItem(icon: Icons.directions_car, label: 'Car', value: 'car'),
        _OptionItem(icon: Icons.groups, label: 'Carpool', value: 'carpool'),
        _OptionItem(icon: Icons.directions_bus, label: 'Bus', value: 'bus'),
        _OptionItem(icon: Icons.train, label: 'Train', value: 'train'),
        _OptionItem(icon: Icons.home_work, label: 'Work from home', value: 'workFromHome'),
        _OptionItem(icon: Icons.swap_horiz, label: 'Combination', value: 'combination'),
        _OptionItem(icon: Icons.help_outline, label: 'Not sure', value: 'combination'),
      ],
    );
  }
}

class _FoodQuestion extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _FoodQuestion({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _QuestionPage(
      emoji: '🥗',
      question: 'What describes your usual meals?',
      subtitle: 'This helps estimate the food portion of your footprint.',
      selected: selected,
      onSelected: onSelected,
      options: const [
        _OptionItem(icon: Icons.eco, label: 'Plant-based', value: 'plantBased'),
        _OptionItem(icon: Icons.grass, label: 'Vegetarian', value: 'vegetarian'),
        _OptionItem(icon: Icons.lunch_dining, label: 'Mostly vegetarian', value: 'mostlyVegetarian'),
        _OptionItem(icon: Icons.restaurant, label: 'Mixed diet', value: 'mixed'),
        _OptionItem(icon: Icons.kebab_dining, label: 'Meat most days', value: 'meatMostDays'),
        _OptionItem(icon: Icons.help_outline, label: 'Prefer not to answer', value: 'mixed'),
      ],
    );
  }
}

class _HomeQuestion extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _HomeQuestion({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _QuestionPage(
      emoji: '🏠',
      question: 'Which best describes your home?',
      subtitle: 'This helps estimate your energy usage.',
      selected: selected,
      onSelected: onSelected,
      options: const [
        _OptionItem(icon: Icons.hotel, label: 'Shared room or hostel', value: 'sharedRoom'),
        _OptionItem(icon: Icons.apartment, label: 'Apartment', value: 'apartment'),
        _OptionItem(icon: Icons.cottage, label: 'Small house', value: 'smallHouse'),
        _OptionItem(icon: Icons.home, label: 'Medium house', value: 'mediumHouse'),
        _OptionItem(icon: Icons.villa, label: 'Large house', value: 'largeHouse'),
        _OptionItem(icon: Icons.help_outline, label: 'Not sure', value: 'apartment'),
      ],
    );
  }
}

class _ConsumptionQuestion extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _ConsumptionQuestion({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _QuestionPage(
      emoji: '🛒',
      question: 'How often do you buy non-essential products?',
      subtitle: 'Clothing, electronics, gadgets, online orders, etc.',
      selected: selected,
      onSelected: onSelected,
      options: const [
        _OptionItem(icon: Icons.event_busy, label: 'Rarely', value: 'rarely'),
        _OptionItem(icon: Icons.calendar_today, label: 'Once or twice a month', value: 'onceOrTwice'),
        _OptionItem(icon: Icons.date_range, label: 'Weekly', value: 'weekly'),
        _OptionItem(icon: Icons.shopping_cart, label: 'Several times a week', value: 'severalTimes'),
        _OptionItem(icon: Icons.help_outline, label: 'Not sure', value: 'onceOrTwice'),
      ],
    );
  }
}
