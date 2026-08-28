import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:migoalpilot/core/services/goal_health_calculator.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/goal_milestone_calculator.dart';

class GoalHealthScoreWidget extends StatelessWidget {
  final GoalHealthResult result;

  const GoalHealthScoreWidget({super.key, required this.result});

  Color _getColor() {
    if (result.score >= 80) return AppColors.success;
    if (result.score >= 60) return AppColors.success.withValues(alpha: 0.8);
    if (result.score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _getStatusText() {
    if (result.score >= 80) return "HEALTHY";
    if (result.score >= 60) return "ON TRACK";
    if (result.score >= 40) return "NEEDS ATTENTION";
    return "AT RISK";
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final color = _getColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: result.score / 100.0,
                strokeWidth: 10,
                backgroundColor: isLight
                    ? AppColors.border.withValues(alpha: 0.5)
                    : AppColors.borderDark.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${result.score}',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: isLight
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusText(),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class GoalHealthBreakdownWidget extends StatelessWidget {
  final GoalHealthResult result;
  final DateTime targetDate;

  const GoalHealthBreakdownWidget({
    super.key,
    required this.result,
    required this.targetDate,
  });

  Widget _buildCheckItem({
    required String title,
    required bool isOk,
    required BuildContext context,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isOk ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight
                    ? AppColors.textPrimary
                    : AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hasNoDeadline = targetDate.year <= 1970;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckItem(
          title: "Savings pace",
          isOk: result.isSavingsPaceHealthy,
          context: context,
        ),
        _buildCheckItem(
          title: "Deadline realistic",
          isOk: result.isDeadlineRealistic,
          context: context,
        ),
        _buildCheckItem(
          title: "Monthly target achievable",
          isOk: result.isMonthlyTargetAchievable,
          context: context,
        ),
        _buildCheckItem(
          title: "Contribution consistency",
          isOk: result.isConsistencyHealthy,
          context: context,
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        if (result.projectedCompletionDate != null) ...[
          Text(
            "Projected completion:",
            style: AppTextStyles.caption.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMMM yyyy').format(result.projectedCompletionDate!),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (!hasNoDeadline) ...[
          Text(
            "Target date:",
            style: AppTextStyles.caption.copyWith(
              color: isLight
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMMM yyyy').format(targetDate),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight
                ? AppColors.primary.withValues(alpha: 0.04)
                : AppColors.primaryDark.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.primaryDark.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            result.recommendation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.primary : AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class GoalMilestonesTimelineWidget extends StatefulWidget {
  final Goal goal;
  final List<SavingsTransaction> transactions;

  const GoalMilestonesTimelineWidget({
    super.key,
    required this.goal,
    required this.transactions,
  });

  @override
  State<GoalMilestonesTimelineWidget> createState() =>
      _GoalMilestonesTimelineWidgetState();
}

class _GoalMilestonesTimelineWidgetState
    extends State<GoalMilestonesTimelineWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default to the first upcoming milestone
    final milestones = GoalMilestoneCalculator.calculateMilestones(
      widget.goal,
      widget.transactions,
    );
    final upcomingIndex = milestones.indexWhere((m) => !m.completed);
    if (upcomingIndex != -1) {
      _selectedIndex = upcomingIndex;
    } else {
      _selectedIndex = milestones.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final milestones = GoalMilestoneCalculator.calculateMilestones(
      widget.goal,
      widget.transactions,
    );
    if (milestones.isEmpty) return const SizedBox.shrink();

    final selectedMilestone = milestones[_selectedIndex];
    final contextMessage = GoalMilestoneCalculator.getContextMessage(
      widget.goal,
      milestones,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR JOURNEY',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: isLight
                ? AppColors.textSecondary
                : AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 24),

        // Horizontal Timeline Row
        Stack(
          alignment: Alignment.center,
          children: [
            // Timeline Line
            Positioned(
              left: 40,
              right: 40,
              top: 15,
              child: Container(
                height: 3,
                color: isLight ? AppColors.border : AppColors.borderDark,
              ),
            ),
            // Timeline Completed Highlight Line
            Positioned(
              left: 40,
              right: 40,
              top: 15,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final completedCount = milestones
                      .where((m) => m.completed)
                      .length;
                  double progressFraction = 0.0;
                  if (completedCount > 0) {
                    progressFraction =
                        (completedCount - 1) / (milestones.length - 1);
                  }
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progressFraction.clamp(0.0, 1.0),
                      child: Container(
                        height: 3,
                        color: isLight
                            ? AppColors.primary
                            : AppColors.primaryDark,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Timeline Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(milestones.length, (idx) {
                final m = milestones[idx];
                final isSelected = idx == _selectedIndex;

                Color dotColor;
                if (m.completed) {
                  dotColor = isLight ? AppColors.success : AppColors.success;
                } else if (isSelected) {
                  dotColor = isLight
                      ? AppColors.primary
                      : AppColors.primaryDark;
                } else {
                  dotColor = isLight ? AppColors.border : AppColors.borderDark;
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = idx),
                  child: Column(
                    children: [
                      // Circular Dot
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: m.completed
                              ? dotColor
                              : (isLight
                                    ? Colors.white
                                    : AppColors.surfaceDark),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (isLight
                                      ? AppColors.primary
                                      : AppColors.accentDark)
                                : dotColor,
                            width: isSelected ? 3.0 : 2.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: m.completed
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${m.percentage}%',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? (isLight
                                              ? AppColors.primary
                                              : AppColors.textPrimaryDark)
                                        : (isLight
                                              ? AppColors.textSecondary
                                              : AppColors.textSecondaryDark),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text Label
                      Text(
                        m.completed
                            ? 'Done'
                            : (idx ==
                                      milestones.indexWhere(
                                        (ms) => !ms.completed,
                                      )
                                  ? 'Next'
                                  : 'Goal'),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? (isLight
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryDark)
                              : (isLight
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Milestone Target
                      Text(
                        widget.goal.type == GoalType.gold
                            ? '${m.targetAmount.toStringAsFixed(1)}g'
                            : '₹${(m.targetAmount / 1000).toStringAsFixed(0)}K',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: isLight
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Milestone Details Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLight ? AppColors.border : AppColors.borderDark,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedMilestone.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (selectedMilestone.completed
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedMilestone.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: selectedMilestone.completed
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedMilestone.completed
                              ? 'Completed'
                              : 'Upcoming',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: selectedMilestone.completed
                               ? AppColors.success
                               : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                selectedMilestone.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isLight
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryDark,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target amount', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        widget.goal.type == GoalType.gold
                            ? '${selectedMilestone.targetAmount.toStringAsFixed(2)} grams'
                            : "₹${NumberFormat('#,##,###').format(selectedMilestone.targetAmount)}",
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (selectedMilestone.completed) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Completed on',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedMilestone.completedAt != null
                              ? DateFormat(
                                  'd MMMM y',
                                ).format(selectedMilestone.completedAt!)
                              : 'Pending',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Remaining', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          widget.goal.type == GoalType.gold
                              ? '${(selectedMilestone.targetAmount - selectedMilestone.currentAmount).toStringAsFixed(2)} grams'
                              : "₹${NumberFormat('#,##,###').format(selectedMilestone.targetAmount - selectedMilestone.currentAmount)}",
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Context message card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isLight
                ? AppColors.primary.withValues(alpha: 0.04)
                : AppColors.primaryDark.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contextMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLight ? AppColors.primary : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
