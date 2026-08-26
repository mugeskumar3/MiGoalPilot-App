import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  final int step;

  const OnboardingScreen({super.key, required this.step});

  String _getTitle() {
    switch (step) {
      case 1:
        return 'Your goals deserve\na clear destination.';
      case 2:
        return 'Know exactly where\nyour savings stand.';
      case 3:
      default:
        return 'Let AI help navigate\nyour financial gaps.';
    }
  }

  String _getDescription() {
    switch (step) {
      case 1:
        return 'Turn dreams into calculated, actionable savings plans. Keep multiple goals in perfect balance.';
      case 2:
        return 'Track target dates, gold price indices, wedding plans and milestones in a single, minimal feed.';
      case 3:
      default:
        return 'Ask our copilot questions, run guest what-ifs, and adjust plans seamlessly when life changes.';
    }
  }

  String _getEmoji() {
    switch (step) {
      case 1:
        return '🎯';
      case 2:
        return '📈';
      case 3:
      default:
        return '✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColors.primary.withValues(alpha: 0.03)
                      : AppColors.surfaceDark,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getEmoji(),
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _getTitle(),
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.heightM,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  _getDescription(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isLight
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final active = index == (step - 1);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? (isLight
                                ? AppColors.primary
                                : AppColors.primaryDark)
                          : (isLight ? AppColors.border : AppColors.borderDark),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              if (step < 3)
                PrimaryButton(
                  text: 'Next',
                  onPressed: () => context.go('/onboarding/${step + 1}'),
                )
              else
                Column(
                  children: [
                    PrimaryButton(
                      text: 'Create Account',
                      onPressed: () => context.go('/register'),
                    ),
                    AppSpacing.heightS,
                    SecondaryButton(
                      text: 'Sign In',
                      onPressed: () => context.go('/login'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
