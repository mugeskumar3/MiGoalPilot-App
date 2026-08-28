import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_milestone_calculator.dart';

class GoldMilestonesWidget extends StatelessWidget {
  final List<GoalMilestone> milestones;

  const GoldMilestonesWidget({super.key, required this.milestones});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MiSectionHeader(title: 'Milestones'),
        const SizedBox(height: 8),
        _buildSectionCard(
          isLight: isLight,
          child: _buildMilestones(milestones, isLight),
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

  Widget _buildMilestones(List<GoalMilestone> milestones, bool isLight) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    final recentlyReached = milestones.where((m) => m.completed).toList();
    final latestMilestone = recentlyReached.isNotEmpty ? recentlyReached.reduce((a, b) => a.percentage > b.percentage ? a : b) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (latestMilestone != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${latestMilestone.targetAmount.toStringAsFixed(1)} g milestone reached!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ...milestones.map((m) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(
                  m.completed ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: m.completed ? AppColors.success : (isLight ? AppColors.border : AppColors.borderDark),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${m.targetAmount.toStringAsFixed(2)} g',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: m.completed
                        ? (isLight ? AppColors.textPrimary : AppColors.textPrimaryDark)
                        : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${m.percentage}%)',
                  style: AppTextStyles.caption.copyWith(
                    color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                  ),
                ),
                const Spacer(),
                Text(
                  m.completed
                      ? (m.completedAt != null ? 'Reached ${DateFormat('dd MMM').format(m.completedAt!)}' : 'Reached')
                      : 'Pending',
                  style: AppTextStyles.caption.copyWith(
                    color: m.completed ? AppColors.success : (isLight ? AppColors.textSecondary : AppColors.textSecondaryDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
