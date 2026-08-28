import 'package:flutter/material.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_spacing.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.border.withValues(alpha: 0.5)
            : AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 140, height: 24),
          AppSpacing.heightM,
          SkeletonLoader(width: double.infinity, height: 160, borderRadius: 12),
          AppSpacing.heightL,
          SkeletonLoader(width: 80, height: 20),
          AppSpacing.heightM,
          SkeletonLoader(width: double.infinity, height: 50, borderRadius: 8),
          AppSpacing.heightS,
          SkeletonLoader(width: double.infinity, height: 50, borderRadius: 8),
          AppSpacing.heightS,
          SkeletonLoader(width: double.infinity, height: 50, borderRadius: 8),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            AppSpacing.heightM,
            const Text(
              'A small turbulence occurred',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.heightXS,
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.heightL,
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✈️', style: TextStyle(fontSize: 40)),
            AppSpacing.heightM,
            Text(
              title,
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            AppSpacing.heightXS,
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              AppSpacing.heightL,
              ElevatedButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}
