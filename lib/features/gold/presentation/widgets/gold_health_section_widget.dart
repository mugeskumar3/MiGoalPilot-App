import 'package:flutter/material.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_health_calculator.dart';
import 'package:migoalpilot/core/models/models.dart';

class GoldHealthSectionWidget extends StatelessWidget {
  final GoalHealthResult healthResult;
  final GoldPrice? livePrice;
  final DateTime targetDate;
  final bool showDetails;
  final VoidCallback onToggleDetails;

  const GoldHealthSectionWidget({
    super.key,
    required this.healthResult,
    required this.livePrice,
    required this.targetDate,
    required this.showDetails,
    required this.onToggleDetails,
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
            const MiSectionHeader(title: 'Gold Goal Health'),
            TextButton(
              onPressed: onToggleDetails,
              child: Text(
                showDetails ? 'Hide Details' : 'View Details',
                style: TextStyle(
                  color: isLight ? AppColors.primary : AppColors.accentDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          isLight: isLight,
          child: Column(
            children: [
              Row(
                children: [
                  GoalHealthScoreWidget(result: healthResult),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCheckRow(
                          label: 'Gold accumulation is on track',
                          isOk: healthResult.isSavingsPaceHealthy,
                          isLight: isLight,
                        ),
                        const SizedBox(height: 8),
                        _buildCheckRow(
                          label: 'Target weight is achievable',
                          isOk: healthResult.isDeadlineRealistic,
                          isLight: isLight,
                        ),
                        const SizedBox(height: 8),
                        _buildCheckRow(
                          label: 'Current gold price increased',
                          isOk: livePrice != null && livePrice!.dailyChangePercentage > 0,
                          isWarning: true,
                          isLight: isLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showDetails) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(),
                ),
                GoalHealthBreakdownWidget(
                  result: healthResult,
                  targetDate: targetDate,
                ),
              ],
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

  Widget _buildCheckRow({required String label, required bool isOk, required bool isLight, bool isWarning = false}) {
    IconData icon;
    Color iconColor;
    if (isWarning) {
      icon = isOk ? Icons.warning_amber_rounded : Icons.check_circle_rounded;
      iconColor = isOk ? AppColors.warning : AppColors.success;
    } else {
      icon = isOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded;
      iconColor = isOk ? AppColors.success : AppColors.warning;
    }

    String text = label;
    if (isWarning) {
      text = isOk ? 'Current gold price increased' : 'Current gold price is stable';
    }

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
