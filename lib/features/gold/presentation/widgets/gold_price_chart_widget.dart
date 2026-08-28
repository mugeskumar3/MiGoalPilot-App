import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';

class GoldPriceChartWidget extends StatelessWidget {
  final List<double> history;
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  const GoldPriceChartWidget({
    super.key,
    required this.history,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MiSectionHeader(title: "Price History"),
            Row(
              children: ['7D', '30D', '3M', '1Y'].map((val) {
                final active = selectedRange == val;
                return GestureDetector(
                  onTap: () => onRangeChanged(val),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? (isLight
                                ? AppColors.primary
                                : AppColors.accentDark)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      val,
                      style: AppTextStyles.caption.copyWith(
                        color: active
                            ? (isLight
                                  ? Colors.white
                                  : AppColors.backgroundDark)
                            : (isLight
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          height: 180,
          padding: const EdgeInsets.only(
            top: 20,
            right: 20,
            bottom: 8,
            left: 8,
          ),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: history.isEmpty
              ? const Center(child: Text('Loading price indices...'))
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(history.length, (
                          idx,
                        ) {
                          return FlSpot(
                            idx.toDouble(),
                            history[idx],
                          );
                        }),
                        isCurved: true,
                        color: isLight
                            ? AppColors.primary
                            : AppColors.accentDark,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, percent, barData, index) {
                                final isLast =
                                    index == barData.spots.length - 1;
                                return FlDotCirclePainter(
                                  radius: isLast ? 5 : 0,
                                  color: AppColors.accent,
                                  strokeColor: AppColors.accent,
                                  strokeWidth: 1,
                                );
                              },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              (isLight
                                      ? AppColors.primary
                                      : AppColors.accentDark)
                                  .withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 32),

        const MiSectionHeader(title: "Statistics"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
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
              _statIndexRow('7 Day High', 12850, context),
              _statIndexRow('7 Day Low', 12380, context),
              _statIndexRow('30 Day Average', 12610, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statIndexRow(String label, double val, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          MoneyDisplay(
            amount: val,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
