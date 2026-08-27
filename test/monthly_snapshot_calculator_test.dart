import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/monthly_snapshot_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

void main() {
  group('MonthlySnapshotCalculator Unit Tests', () {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 15);
    final previousMonth = DateTime(now.year, now.month - 1, 15);

    test('Calculates monthly total and goals funded correctly', () {
      final goal1 = Goal(
        id: 'g1',
        name: 'Marriage',
        type: GoalType.marriage,
        targetAmount: 100000,
        currentSavings: 20000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      );

      final goal2 = Goal(
        id: 'g2',
        name: 'Gold purchase',
        type: GoalType.gold,
        targetAmount: 50000,
        currentSavings: 15000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
        targetGrams: 10.0,
        purchasedGrams: 3.0,
      );

      final txs = [
        SavingsTransaction(id: 't1', goalId: 'g1', amount: 5000, date: currentMonth),
        SavingsTransaction(id: 't2', goalId: 'g1', amount: 3000, date: currentMonth),
        SavingsTransaction(id: 't3', goalId: 'g2', amount: 4000, date: currentMonth, goldGrams: 0.8),
        SavingsTransaction(id: 't4', goalId: 'g1', amount: 10000, date: previousMonth),
      ];

      final result = MonthlySnapshotCalculator.calculate(
        goals: [goal1, goal2],
        allTransactions: txs,
        selectedMonth: currentMonth,
      );

      expect(result.totalSaved, equals(12000));
      expect(result.previousMonthSaved, equals(10000));
      expect(result.goalsFunded, equals(2));
      expect(result.percentChange, closeTo(20.0, 0.01));
    });

    test('Handles no previous month transactions gracefully', () {
      final goal = Goal(
        id: 'g1',
        name: 'Marriage',
        type: GoalType.marriage,
        targetAmount: 100000,
        currentSavings: 20000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      );

      final txs = [
        SavingsTransaction(id: 't1', goalId: 'g1', amount: 5000, date: currentMonth),
      ];

      final result = MonthlySnapshotCalculator.calculate(
        goals: [goal],
        allTransactions: txs,
        selectedMonth: currentMonth,
      );

      expect(result.totalSaved, equals(5000));
      expect(result.previousMonthSaved, equals(0));
      expect(result.percentChange, equals(0));
      expect(result.isFirstMonth, isTrue);
    });

    test('Handles no current month transactions gracefully', () {
      final goal = Goal(
        id: 'g1',
        name: 'Marriage',
        type: GoalType.marriage,
        targetAmount: 100000,
        currentSavings: 20000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      );

      final result = MonthlySnapshotCalculator.calculate(
        goals: [goal],
        allTransactions: [],
        selectedMonth: currentMonth,
      );

      expect(result.totalSaved, equals(0));
      expect(result.goalsFunded, equals(0));
      expect(result.bestPerformingGoalName, isNull);
    });

    test('Future month returns empty activity and correct flag', () {
      final futureMonth = DateTime(now.year, now.month + 2, 1);
      final result = MonthlySnapshotCalculator.calculate(
        goals: [],
        allTransactions: [],
        selectedMonth: futureMonth,
      );

      expect(result.isFutureMonth, isTrue);
      expect(result.totalSaved, equals(0));
      expect(result.insight, equals('No activity yet.'));
    });

    test('Determines best performing goal correctly', () {
      final goal1 = Goal(
        id: 'g1',
        name: 'Marriage',
        type: GoalType.marriage,
        targetAmount: 100000,
        currentSavings: 20000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      );

      final goal2 = Goal(
        id: 'g2',
        name: 'Travel',
        type: GoalType.travel,
        targetAmount: 50000,
        currentSavings: 15000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final txs = [
        SavingsTransaction(id: 't1', goalId: 'g1', amount: 5000, date: currentMonth), // 5% progress
        SavingsTransaction(id: 't2', goalId: 'g2', amount: 5000, date: currentMonth), // 10% progress
      ];

      final result = MonthlySnapshotCalculator.calculate(
        goals: [goal1, goal2],
        allTransactions: txs,
        selectedMonth: currentMonth,
      );

      expect(result.bestPerformingGoalName, equals('Travel'));
    });

    test('Ignores invalid transactions (negative or zero amount)', () {
      final goal = Goal(
        id: 'g1',
        name: 'Marriage',
        type: GoalType.marriage,
        targetAmount: 100000,
        currentSavings: 20000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      );

      final txs = [
        SavingsTransaction(id: 't1', goalId: 'g1', amount: 5000, date: currentMonth),
        SavingsTransaction(id: 't2', goalId: 'g1', amount: -2000, date: currentMonth),
        SavingsTransaction(id: 't3', goalId: 'g1', amount: 0, date: currentMonth),
      ];

      final result = MonthlySnapshotCalculator.calculate(
        goals: [goal],
        allTransactions: txs,
        selectedMonth: currentMonth,
      );

      expect(result.totalSaved, equals(5000));
    });
  });
}
