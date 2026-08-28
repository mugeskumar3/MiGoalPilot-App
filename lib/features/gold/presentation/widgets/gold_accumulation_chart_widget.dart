import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/features/gold/domain/services/gold_goal_calculator.dart';

class GoldAccumulationChartWidget extends StatelessWidget {
  final List<MonthlyAccumulation> monthlyData;

  const GoldAccumulationChartWidget({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MiSectionHeader(title: 'Gold Accumulation'),
        const SizedBox(height: 8),
        _buildSectionCard(
          isLight: isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MONTHLY GRAMS ADDED',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildMonthlyAccumulation(monthlyData, isLight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required bool isLight, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight ? AppColors.border : AppColors.borderDark,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildMonthlyAccumulation(List<MonthlyAccumulation> data, bool isLight) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'No accumulation history yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
            ),
          ),
        ),
      );
    }

    final maxGrams = data.map((e) => e.grams).reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.map((item) {
        final double fraction = maxGrams > 0 ? (item.grams / maxGrams) : 0.0;
        final barFlex = (fraction * 100).toInt().clamp(1, 100);
        final emptyFlex = ((1.0 - fraction) * 100).toInt().clamp(0, 100);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  item.label.split(' ')[0],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: barFlex,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.lightGold,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    if (emptyFlex > 0)
                      Expanded(
                        flex: emptyFlex,
                        child: const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${item.grams.toStringAsFixed(1)} g',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '₹${NumberFormat('#,##,###').format(item.amount)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
