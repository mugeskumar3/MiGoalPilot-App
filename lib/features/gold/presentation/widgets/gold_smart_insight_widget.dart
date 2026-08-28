import 'package:flutter/material.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';

class GoldSmartInsightWidget extends StatelessWidget {
  final String insight;

  const GoldSmartInsightWidget({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [
                  AppColors.lightGold.withValues(alpha: 0.3),
                  AppColors.accent.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.surfaceDark,
                  AppColors.elevatedSurfaceDark,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART GOLD INSIGHT',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
