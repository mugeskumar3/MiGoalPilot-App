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
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Choose Path',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Create a New Plan',
                style: AppTextStyles.displayLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.heightS,
              Text(
                'Build custom targets manually or describe your dream to GoalPilot AI.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // Manual Builder option
              InkWell(
                onTap: () => context.go('/create-goal'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('✍️', style: TextStyle(fontSize: 28)),
                      ),
                      AppSpacing.heightM,
                      const Text(
                        'Manual Goal Builder',
                        style: AppTextStyles.headlineMedium,
                      ),
                      AppSpacing.heightXS,
                      Text(
                        'Target amount, deadlines, categories and custom weekly targets.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // AI builder option
              InkWell(
                onTap: () => context.go('/ai-goal-creation'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLight ? AppColors.accent.withValues(alpha: 0.3) : AppColors.accentDark.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('✨', style: TextStyle(fontSize: 28)),
                      ),
                      AppSpacing.heightM,
                      const Text(
                        'Create with GoalPilot AI',
                        style: AppTextStyles.headlineMedium,
                      ),
                      AppSpacing.heightXS,
                      Text(
                        'Tell our copilot your target naturally and let AI draft the steps.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
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
      ),
    );
  }
}
