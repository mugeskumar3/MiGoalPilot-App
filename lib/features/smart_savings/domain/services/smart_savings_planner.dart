import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_health_calculator.dart';

class SmartSavingsPlannerResult {
  final double recommendedTotalMonthly;
  final Map<String, double> defaultAllocations;

  SmartSavingsPlannerResult({
    required this.recommendedTotalMonthly,
    required this.defaultAllocations,
  });
}

class SmartSavingsPlanner {
  static SmartSavingsPlannerResult calculateDefaultPlan(List<Goal> goals) {
    final now = DateTime.now();
    double totalRecommended = 0.0;
    final Map<String, double> allocations = {};

    for (final g in goals) {
      final bool isCompleted = g.type == GoalType.gold
          ? (g.targetGrams > 0 && g.purchasedGrams >= g.targetGrams)
          : (g.targetAmount > 0 && g.currentSavings >= g.targetAmount);

      if (isCompleted || g.targetDate.isBefore(now)) {
        allocations[g.id] = 0.0;
        continue;
      }

      final double remaining = g.type == GoalType.gold
          ? (g.targetGrams - g.purchasedGrams).clamp(0.0, g.targetGrams)
          : (g.targetAmount - g.currentSavings).clamp(0.0, g.targetAmount);

      final double days = g.targetDate.difference(now).inDays.toDouble();
      final double months = (days / 30.4368).clamp(0.1, double.infinity);

      double requiredMonthly = remaining / months;

      // If gold goal, convert to Rupees for UI visual symmetry (assuming standard gold rate 10,000 for calculation if targetAmount is set)
      if (g.type == GoalType.gold) {
        // Gold goals have targetAmount as well, so we can use targetAmount-based monthly required saving
        final double remainingMoney = (g.targetAmount - g.currentSavings).clamp(
          0.0,
          g.targetAmount,
        );
        requiredMonthly = remainingMoney / months;
      }

      requiredMonthly = requiredMonthly.clamp(0.0, double.infinity);
      allocations[g.id] = double.parse(requiredMonthly.toStringAsFixed(2));
      totalRecommended += requiredMonthly;
    }

    return SmartSavingsPlannerResult(
      recommendedTotalMonthly: double.parse(
        totalRecommended.toStringAsFixed(2),
      ),
      defaultAllocations: allocations,
    );
  }

  static Map<String, double> rebalanceAllocations({
    required Map<String, double> currentAllocations,
    required String changedGoalId,
    required double newValue,
    required double totalCapacity,
  }) {
    final Map<String, double> newAllocations = Map.from(currentAllocations);

    // Clamp newValue to totalCapacity
    final double clampedNewValue = newValue.clamp(0.0, totalCapacity);
    newAllocations[changedGoalId] = clampedNewValue;

    final otherGoalIds = currentAllocations.keys
        .where((id) => id != changedGoalId)
        .toList();
    if (otherGoalIds.isEmpty) {
      newAllocations[changedGoalId] = totalCapacity;
      return newAllocations;
    }

    final double remainingCapacity = (totalCapacity - clampedNewValue).clamp(
      0.0,
      totalCapacity,
    );
    final double sumOthers = otherGoalIds.fold(
      0.0,
      (sum, id) => sum + (currentAllocations[id] ?? 0.0),
    );

    if (sumOthers > 0) {
      double allocatedToOthers = 0.0;
      for (int i = 0; i < otherGoalIds.length; i++) {
        final id = otherGoalIds[i];
        if (i == otherGoalIds.length - 1) {
          // Put remainder to last to avoid floating point precision issue
          newAllocations[id] = double.parse(
            (remainingCapacity - allocatedToOthers).toStringAsFixed(2),
          );
        } else {
          final double share = (currentAllocations[id] ?? 0.0) / sumOthers;
          final double val = double.parse(
            (remainingCapacity * share).toStringAsFixed(2),
          );
          newAllocations[id] = val;
          allocatedToOthers += val;
        }
      }
    } else {
      // Divide remaining capacity equally
      double allocatedToOthers = 0.0;
      for (int i = 0; i < otherGoalIds.length; i++) {
        final id = otherGoalIds[i];
        if (i == otherGoalIds.length - 1) {
          newAllocations[id] = double.parse(
            (remainingCapacity - allocatedToOthers).toStringAsFixed(2),
          );
        } else {
          final double val = double.parse(
            (remainingCapacity / otherGoalIds.length).toStringAsFixed(2),
          );
          newAllocations[id] = val;
          allocatedToOthers += val;
        }
      }
    }

    // Double check total sum is exactly totalCapacity
    double finalSum = newAllocations.values.fold(0.0, (sum, v) => sum + v);
    if ((finalSum - totalCapacity).abs() > 0.01 && newAllocations.isNotEmpty) {
      final firstKey = newAllocations.keys.first;
      newAllocations[firstKey] = double.parse(
        (newAllocations[firstKey]! + (totalCapacity - finalSum))
            .toStringAsFixed(2),
      );
    }

    return newAllocations;
  }

  static Map<String, DateTime?> recalculateProjections({
    required List<Goal> goals,
    required Map<String, double> allocations,
  }) {
    final Map<String, DateTime?> projections = {};
    final now = DateTime.now();

    for (final g in goals) {
      final double allocation = allocations[g.id] ?? 0.0;
      if (allocation <= 0) {
        projections[g.id] = null;
        continue;
      }

      final double remaining = (g.targetAmount - g.currentSavings).clamp(
        0.0,
        g.targetAmount,
      );
      final double monthsToFinish = remaining / allocation;
      if (monthsToFinish.isFinite && monthsToFinish < 1200) {
        projections[g.id] = now.add(
          Duration(days: (monthsToFinish * 30.4368).toInt()),
        );
      } else {
        projections[g.id] = null;
      }
    }

    return projections;
  }

  static Map<String, int> recalculateHealthScores({
    required List<Goal> goals,
    required Map<String, double> allocations,
    required Map<String, List<SavingsTransaction>> transactionsMap,
  }) {
    final Map<String, int> healthScores = {};

    for (final g in goals) {
      final double allocation = allocations[g.id] ?? 0.0;
      final txs = transactionsMap[g.id] ?? [];
      final result = GoalHealthCalculator.calculate(
        g,
        txs,
        simulatedMonthlySavings: allocation,
      );
      healthScores[g.id] = result.score;
    }

    return healthScores;
  }
}
