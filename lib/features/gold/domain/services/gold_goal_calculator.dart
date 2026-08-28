import 'package:intl/intl.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_milestone_calculator.dart';

class MonthlyAccumulation {
  final String label;
  final double grams;
  final double amount;

  MonthlyAccumulation({
    required this.label,
    required this.grams,
    required this.amount,
  });
}

class GoldGoalCalculator {
  static double calculateRemainingGrams(Goal goal) {
    if (goal.targetGrams <= 0) return 0.0;
    return (goal.targetGrams - goal.purchasedGrams).clamp(0.0, double.infinity);
  }

  static double? calculateCurrentValue(Goal goal, double? spotPrice) {
    if (spotPrice == null) return null;
    final val = goal.purchasedGrams * spotPrice;
    return val.isNaN || val.isInfinite || val < 0 ? 0.0 : val;
  }

  static double? calculateTargetValue(Goal goal, double? spotPrice) {
    if (spotPrice == null) return null;
    final val = goal.targetGrams * spotPrice;
    return val.isNaN || val.isInfinite || val < 0 ? 0.0 : val;
  }

  static List<MonthlyAccumulation> getMonthlyAccumulation(List<SavingsTransaction> txs) {
    final Map<String, List<SavingsTransaction>> grouped = {};
    
    // Sort transactions chronologically (recent first)
    final sorted = List<SavingsTransaction>.from(txs)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final t in sorted) {
      if (t.goldGrams != null && t.goldGrams! > 0) {
        final key = DateFormat('MMM yyyy').format(t.date).toUpperCase();
        grouped.putIfAbsent(key, () => []).add(t);
      }
    }

    return grouped.entries.map((entry) {
      final grams = entry.value.fold(0.0, (sum, t) => sum + (t.goldGrams ?? 0.0));
      final amount = entry.value.fold(0.0, (sum, t) => sum + t.amount);
      return MonthlyAccumulation(
        label: entry.key,
        grams: grams,
        amount: amount,
      );
    }).toList();
  }

  static String generateSmartInsight({
    required Goal goal,
    required List<SavingsTransaction> transactions,
    required double? spotPrice,
    required double? dailyChangePercentage,
  }) {
    final target = goal.targetGrams;
    final current = goal.purchasedGrams;
    final remaining = (target - current).clamp(0.0, double.infinity);

    if (remaining <= 0) {
      return "Congratulations! You've achieved your target of ${target.toStringAsFixed(1)}g.";
    }

    // 1. Proximity to next milestone
    final milestones = GoalMilestoneCalculator.calculateMilestones(goal, transactions);
    final nextUpcoming = milestones.firstWhere((m) => !m.completed, orElse: () => milestones.last);
    if (!nextUpcoming.completed) {
      final diff = nextUpcoming.targetAmount - current;
      if (diff > 0 && diff <= target * 0.10) {
        return "You're only ${diff.toStringAsFixed(2)}g away from your next milestone.";
      }
    }

    // 2. High Price alert
    if (dailyChangePercentage != null && dailyChangePercentage > 1.5) {
      return "Gold is currently higher than your recent tracked price.";
    }

    // 3. Monthly trend / addition
    final now = DateTime.now();
    final currentMonthTxs = transactions.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
    final currentMonthGrams = currentMonthTxs.fold(0.0, (sum, t) => sum + (t.goldGrams ?? 0.0));
    if (currentMonthGrams > 0) {
      // Check if we can compare to last month
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      final lastMonthTxs = transactions.where((t) => t.date.year == lastMonth.year && t.date.month == lastMonth.month).toList();
      final lastMonthGrams = lastMonthTxs.fold(0.0, (sum, t) => sum + (t.goldGrams ?? 0.0));
      if (lastMonthGrams > 0) {
        final pctChange = ((currentMonthGrams - lastMonthGrams) / lastMonthGrams) * 100;
        if (pctChange > 0) {
          return "Your gold accumulation increased ${pctChange.toStringAsFixed(0)}% this month.";
        }
      }
      return "You added ${currentMonthGrams.toStringAsFixed(2)}g of gold this month.";
    }

    return "You need ${remaining.toStringAsFixed(2)}g more to reach your target.";
  }
}
