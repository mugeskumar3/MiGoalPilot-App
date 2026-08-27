import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:intl/intl.dart';

class GoalMilestone {
  final int percentage;
  final double targetAmount;
  final double currentAmount;
  final bool completed;
  final DateTime? completedAt;
  final String title;
  final String description;

  GoalMilestone({
    required this.percentage,
    required this.targetAmount,
    required this.currentAmount,
    required this.completed,
    this.completedAt,
    required this.title,
    required this.description,
  });
}

class GoalMilestoneCalculator {
  static List<GoalMilestone> calculateMilestones(
    Goal goal,
    List<SavingsTransaction> transactions,
  ) {
    final List<int> percentages = [25, 50, 75, 100];
    final List<GoalMilestone> milestones = [];

    final double totalTarget = goal.type == GoalType.gold ? goal.targetGrams : goal.targetAmount;
    final double currentTotal = goal.type == GoalType.gold ? goal.purchasedGrams : goal.currentSavings;

    // Sort transactions chronologically to calculate accurate completedAt dates
    final sortedTxs = List<SavingsTransaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final pct in percentages) {
      if (totalTarget <= 0) {
        milestones.add(GoalMilestone(
          percentage: pct,
          targetAmount: 0.0,
          currentAmount: 0.0,
          completed: false,
          title: '$pct% Milestone',
          description: _getDescription(pct),
        ));
        continue;
      }

      final double milestoneTarget = totalTarget * (pct / 100.0);
      final bool completed = currentTotal >= milestoneTarget;
      
      // Calculate completion date if completed
      DateTime? completedAt;
      if (completed) {
        double runningSum = 0.0;
        for (final tx in sortedTxs) {
          runningSum += (goal.type == GoalType.gold ? (tx.goldGrams ?? 0.0) : tx.amount);
          if (runningSum >= milestoneTarget) {
            completedAt = tx.date;
            break;
          }
        }
        // Fallback to latest transaction or now if empty
        completedAt ??= sortedTxs.isNotEmpty ? sortedTxs.last.date : DateTime.now();
      }

      milestones.add(GoalMilestone(
        percentage: pct,
        targetAmount: milestoneTarget,
        currentAmount: currentTotal.clamp(0.0, milestoneTarget),
        completed: completed,
        completedAt: completedAt,
        title: '$pct% Milestone',
        description: _getDescription(pct),
      ));
    }

    return milestones;
  }

  static String _getDescription(int percentage) {
    switch (percentage) {
      case 25:
        return 'Quarter-way there! Off to a solid start.';
      case 50:
        return 'Halfway mark crossed! You are flying close to your dream.';
      case 75:
        return 'Three-quarters complete! The finish line is in sight.';
      case 100:
        return 'Milestone Achieved! Goal completed successfully.';
      default:
        return '';
    }
  }

  static String getContextMessage(Goal goal, List<GoalMilestone> milestones) {
    final nextUpcoming = milestones.firstWhere(
      (m) => !m.completed,
      orElse: () => milestones.last,
    );

    if (nextUpcoming.completed) {
      return 'Congratulations! You have completed 100% of your ${goal.name}.';
    }

    final double totalTarget = goal.type == GoalType.gold ? goal.targetGrams : goal.targetAmount;
    final double currentTotal = goal.type == GoalType.gold ? goal.purchasedGrams : goal.currentSavings;
    final double diff = (nextUpcoming.targetAmount - currentTotal).clamp(0.0, double.infinity);
    final String unit = goal.type == GoalType.gold ? 'g' : '₹';

    final String formattedDiff = goal.type == GoalType.gold 
        ? diff.toStringAsFixed(2) 
        : _formatMoney(diff);

    // If close (within 10% of total target value)
    final double threshold = totalTarget * 0.10;
    if (diff <= threshold) {
      return "You're only $unit$formattedDiff away from your next milestone.";
    } else {
      return "$unit$formattedDiff more to unlock your next milestone.";
    }
  }

  static String _formatMoney(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000.0).toStringAsFixed(1)}L';
    }
    return NumberFormat('#,##,###').format(amount);
  }
}
