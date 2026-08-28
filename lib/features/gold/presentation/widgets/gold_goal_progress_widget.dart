import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/models/models.dart';

class GoldGoalProgressWidget extends StatelessWidget {
  final Goal goal;
  final double? spotPrice;

  const GoldGoalProgressWidget({
    super.key,
    required this.goal,
    required this.spotPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final double targetGrams = goal.targetGrams;
    final double purchasedGrams = goal.purchasedGrams;
    final double remainingGrams = (targetGrams - purchasedGrams).clamp(0.0, double.infinity);
    final double progressPercentage = goal.progressPercentage;

    final String formattedCurrentValue = spotPrice != null 
        ? '₹${NumberFormat('#,##,###').format(purchasedGrams * spotPrice!)}' 
        : 'Gold price unavailable';
    final String formattedTargetValue = spotPrice != null 
        ? '₹${NumberFormat('#,##,###').format(targetGrams * spotPrice!)}' 
        : 'Gold price unavailable';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GOLD GOAL PROGRESS',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLight ? AppColors.softSurface : AppColors.borderDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(progressPercentage * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.primary : AppColors.accentDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${purchasedGrams.toStringAsFixed(2)} g',
              style: AppTextStyles.displayLarge.copyWith(
                fontWeight: FontWeight.w900,
                color: isLight ? AppColors.primary : AppColors.accentDark,
              ),
            ),
            Text(
              'of ${targetGrams.toStringAsFixed(1)} g target',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildProgressBar(progressPercentage, isLight),
        const SizedBox(height: 12),
        Text(
          remainingGrams <= 0 
              ? 'Goal Completed! 🎉'
              : '${remainingGrams.toStringAsFixed(2)} g remaining',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: remainingGrams <= 0 
                ? AppColors.success 
                : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT VALUE',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedCurrentValue,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARGET VALUE',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTargetValue,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '22K GOLD',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              spotPrice != null 
                  ? '₹${NumberFormat('#,##,###').format(spotPrice)} / g' 
                  : 'Gold price unavailable',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
              ),
            ),
            const Spacer(),
            Text(
              'Updated today',
              style: AppTextStyles.caption.copyWith(
                color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, bool isLight) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLight ? AppColors.softSurface : AppColors.borderDark,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.accent,
                AppColors.lightGold,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
