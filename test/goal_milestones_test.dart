import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/goal_milestone_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

void main() {
  group('GoalMilestoneCalculator Unit Tests', () {
    final now = DateTime.now();

    test('0% completion milestones targets and status check', () {
      final goal = Goal(
        id: 'g1',
        name: 'Europe Trip',
        type: GoalType.travel,
        targetAmount: 100000,
        currentSavings: 0,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final milestones = GoalMilestoneCalculator.calculateMilestones(goal, []);
      
      expect(milestones[0].percentage, equals(25));
      expect(milestones[0].targetAmount, equals(25000.0));
      expect(milestones[0].completed, isFalse);

      expect(milestones[1].percentage, equals(50));
      expect(milestones[1].targetAmount, equals(50000.0));
      expect(milestones[1].completed, isFalse);

      expect(milestones[2].percentage, equals(75));
      expect(milestones[3].percentage, equals(100));
    });

    test('Milestones completion status dynamically computed', () {
      final goal = Goal(
        id: 'g1',
        name: 'Europe Trip',
        type: GoalType.travel,
        targetAmount: 100000,
        currentSavings: 55000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final milestones = GoalMilestoneCalculator.calculateMilestones(goal, [
        SavingsTransaction(id: 't1', goalId: 'g1', amount: 30000, date: now.subtract(const Duration(days: 10))),
        SavingsTransaction(id: 't2', goalId: 'g1', amount: 25000, date: now.subtract(const Duration(days: 5))),
      ]);

      expect(milestones[0].percentage, equals(25)); // Target 25,000
      expect(milestones[0].completed, isTrue);
      // Crossed at t1 (since t1 is 30,000 >= 25,000)
      expect(milestones[0].completedAt, isNotNull);
      expect(milestones[0].completedAt!.day, equals(now.subtract(const Duration(days: 10)).day));

      expect(milestones[1].percentage, equals(50)); // Target 50,000
      expect(milestones[1].completed, isTrue);
      // Crossed at t2 (cumulative savings at t2: 30,000 + 25,000 = 55,000 >= 50,000)
      expect(milestones[1].completedAt, isNotNull);
      expect(milestones[1].completedAt!.day, equals(now.subtract(const Duration(days: 5)).day));

      expect(milestones[2].percentage, equals(75)); // Target 75,000
      expect(milestones[2].completed, isFalse);
    });

    test('Above 100% completion marks all milestones as completed', () {
      final goal = Goal(
        id: 'g1',
        name: 'Europe Trip',
        type: GoalType.travel,
        targetAmount: 100000,
        currentSavings: 120000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.medium,
        health: GoalHealth.completed,
      );

      final milestones = GoalMilestoneCalculator.calculateMilestones(goal, []);
      for (final m in milestones) {
        expect(m.completed, isTrue);
      }
    });

    test('Gold Goal milestone calculates progress using gold grams', () {
      final goal = Goal(
        id: 'g2',
        name: 'Wedding Jewelry Gold',
        type: GoalType.gold,
        targetAmount: 200000,
        currentSavings: 50000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
        targetGrams: 20.0,
        purchasedGrams: 11.0,
      );

      final milestones = GoalMilestoneCalculator.calculateMilestones(goal, [
        SavingsTransaction(id: 't1', goalId: 'g2', amount: 50000, date: now, goldGrams: 11.0),
      ]);

      // 11g of 20g = 55% progress
      expect(milestones[0].completed, isTrue); // 25% (5g) -> Completed
      expect(milestones[1].completed, isTrue); // 50% (10g) -> Completed
      expect(milestones[2].completed, isFalse); // 75% (15g) -> Upcoming
    });

    test('Milestone warning contextual messages calculation', () {
      final goal = Goal(
        id: 'g1',
        name: 'Europe Trip',
        type: GoalType.travel,
        targetAmount: 100000,
        currentSavings: 48000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final milestones = GoalMilestoneCalculator.calculateMilestones(goal, []);
      final msg = GoalMilestoneCalculator.getContextMessage(goal, milestones);

      // Next is 50% (Target 50,000). Current is 48,000. Diff = 2,000.
      // 2,000 is within 10% (10,000) threshold, so shows "only away from" message
      expect(msg, contains("only"));
      expect(msg, contains("2,000"));
    });
  });
}
