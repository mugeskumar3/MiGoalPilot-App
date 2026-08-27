import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/goal_health_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

void main() {
  group('GoalHealthCalculator Unit Tests', () {
    final now = DateTime.now();

    test('Completed Goal status and score of 100', () {
      final goal = Goal(
        id: 'completed_1',
        name: 'Completed Goal',
        type: GoalType.custom,
        targetAmount: 10000,
        currentSavings: 10000,
        targetDate: now.add(const Duration(days: 30)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final result = GoalHealthCalculator.calculate(goal, []);
      expect(result.score, equals(100));
      expect(result.status, equals(GoalHealth.completed));
      expect(result.isSavingsPaceHealthy, isTrue);
      expect(result.isDeadlineRealistic, isTrue);
    });

    test('Goal with past deadline has score of 0 and AT RISK status', () {
      final goal = Goal(
        id: 'past_1',
        name: 'Expired Goal',
        type: GoalType.custom,
        targetAmount: 10000,
        currentSavings: 5000,
        targetDate: now.subtract(const Duration(days: 5)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final result = GoalHealthCalculator.calculate(goal, []);
      expect(result.score, equals(0));
      expect(result.status, equals(GoalHealth.atRisk));
    });

    test('New Goal with no savings starts with a middle/baseline score', () {
      final goal = Goal(
        id: 'new_1',
        name: 'New Goal',
        type: GoalType.custom,
        targetAmount: 10000,
        currentSavings: 0,
        targetDate: now.add(const Duration(days: 365)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final result = GoalHealthCalculator.calculate(goal, []);
      // 0 savings -> progress score = 0, gap score = 0, overall rate = required rate -> feasibility = 25, consistency = 15, missed = 10 -> total = 50.
      expect(result.score, equals(50));
      expect(result.status, equals(GoalHealth.needsAttention));
    });

    test('Healthy Goal with high progress and ahead of pace', () {
      final goal = Goal(
        id: 'healthy_1',
        name: 'Healthy Goal',
        type: GoalType.custom,
        targetAmount: 10000,
        currentSavings: 9000,
        targetDate: now.add(const Duration(days: 180)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      );

      final result = GoalHealthCalculator.calculate(goal, [
        SavingsTransaction(id: 't1', goalId: 'healthy_1', amount: 9000, date: now.subtract(const Duration(days: 10))),
      ]);
      expect(result.score, greaterThanOrEqualTo(80));
      expect(result.status, equals(GoalHealth.onTrack));
    });

    test('On Track Goal', () {
      final goal = Goal(
        id: 'ontrack_1',
        name: 'On Track Goal',
        type: GoalType.custom,
        targetAmount: 10000,
        currentSavings: 6500,
        targetDate: now.add(const Duration(days: 180)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final result = GoalHealthCalculator.calculate(goal, [
        SavingsTransaction(id: 't1', goalId: 'ontrack_1', amount: 6500, date: now.subtract(const Duration(days: 180))),
      ]);
      expect(result.score, predicate<int>((score) => score >= 60 && score <= 79, 'is between 60 and 79'));
    });

    test('Gold Goal correctly calculates progress by grams', () {
      final goal = Goal(
        id: 'gold_1',
        name: 'Gold Saving Jewelry',
        type: GoalType.gold,
        targetAmount: 200000,
        currentSavings: 50000,
        targetDate: now.add(const Duration(days: 180)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
        targetGrams: 20.0,
        purchasedGrams: 10.0,
      );

      final result = GoalHealthCalculator.calculate(goal, [
        SavingsTransaction(id: 't1', goalId: 'gold_1', amount: 50000, date: now.subtract(const Duration(days: 30)), goldGrams: 10.0),
      ]);
      expect(goal.progressPercentage, equals(0.5));
      expect(result.score, greaterThanOrEqualTo(60));
    });

    test('No deadline handles gracefully', () {
      final goal = Goal(
        id: 'no_deadline_1',
        name: 'No Deadline Goal',
        type: GoalType.custom,
        targetAmount: 10000,
        currentSavings: 5000,
        targetDate: DateTime(1970), // no deadline indicator
        priority: GoalPriority.low,
        health: GoalHealth.onTrack,
      );

      final result = GoalHealthCalculator.calculate(goal, []);
      expect(result.score, isNot(throwsException));
      expect(result.score, greaterThan(0));
    });
  });
}
