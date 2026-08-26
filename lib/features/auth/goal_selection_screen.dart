import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Choose Path',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Create a New Plan',
              style: AppTextStyles.displayMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.heightS,
            Text(
              'Input parameters manually or describe your dream to GoalPilot AI.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),

            InkWell(
              onTap: () => context.go('/create-goal'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                  ),
                ),
                child: Column(
                  children: [
                    const Text('✍️', style: TextStyle(fontSize: 32)),
                    AppSpacing.heightS,
                    const Text(
                      'Manual Goal Builder',
                      style: AppTextStyles.titleLarge,
                    ),
                    AppSpacing.heightXS,
                    Text(
                      'Target amount, deadlines, categories and custom weekly targets.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: () => context.go('/ai-goal-creation'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColors.secondary.withValues(alpha: 0.04)
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLight
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.primaryDark.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 32)),
                    AppSpacing.heightS,
                    const Text(
                      'Create with GoalPilot AI',
                      style: AppTextStyles.titleLarge,
                    ),
                    AppSpacing.heightXS,
                    Text(
                      'Tell our copilot your target naturally and let AI draft the steps.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
