import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/goal_analytics_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

void main() {
  group('GoalAnalyticsCalculator - Savings Analytics Tests', () {
    final now = DateTime.now();
    final goals = [
      Goal(
        id: 'g_marriage',
        name: 'Wedding Ceremony',
        type: GoalType.marriage,
        targetAmount: 500000,
        currentSavings: 100000,
        targetDate: now.add(const Duration(days: 365)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
      ),
      Goal(
        id: 'g_gold',
        name: 'Gold jewelry',
        type: GoalType.gold,
        targetAmount: 200000,
        currentSavings: 50000,
        targetDate: now.add(const Duration(days: 365)),
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
        targetGrams: 20.0,
        purchasedGrams: 5.0,
      ),
      Goal(
        id: 'g_travel',
        name: 'Europe trip',
        type: GoalType.travel,
        targetAmount: 150000,
        currentSavings: 30000,
        targetDate: now.add(const Duration(days: 180)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      ),
    ];

    final baseTxs = [
      SavingsTransaction(
        id: 'tx1',
        goalId: 'g_marriage',
        amount: 30000,
        date: DateTime(now.year, now.month, 5),
      ),
      SavingsTransaction(
        id: 'tx2',
        goalId: 'g_gold',
        amount: 15000,
        date: DateTime(now.year, now.month, 10),
        goldGrams: 1.5,
      ),
      SavingsTransaction(
        id: 'tx3',
        goalId: 'g_marriage',
        amount: 20000,
        date: DateTime(now.year, now.month - 1, 15),
      ),
      SavingsTransaction(
        id: 'tx4',
        goalId: 'g_travel',
        amount: 10000,
        date: DateTime(now.year, now.month - 1, 20),
      ),
      SavingsTransaction(
        id: 'tx5',
        goalId: 'g_gold',
        amount: 12000,
        date: DateTime(now.year, now.month - 2, 25),
        goldGrams: 1.2,
      ),
    ];

    test('Monthly totals are calculated correctly across the range', () {
      final rangeStart = DateTime(now.year, now.month - 2, 1);
      final rangeEnd = DateTime(now.year, now.month, 1);

      final result = GoalAnalyticsCalculator.calculate(
        goals: goals,
        allTransactions: baseTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );

      expect(result.totalSaved, equals(87000.0));
      expect(result.monthlyAverage, equals(29000.0));
    });

    test('Best and lowest months are identified correctly', () {
      final rangeStart = DateTime(now.year, now.month - 2, 1);
      final rangeEnd = DateTime(now.year, now.month, 1);

      final result = GoalAnalyticsCalculator.calculate(
        goals: goals,
        allTransactions: baseTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );

      expect(result.highestSaving, equals(45000.0));
      expect(result.lowestSaving, equals(12000.0));
    });

    test('Goal filtering updates calculations based on target goal', () {
      final rangeStart = DateTime(now.year, now.month - 2, 1);
      final rangeEnd = DateTime(now.year, now.month, 1);

      // Filter by Marriage goal type
      final resultType = GoalAnalyticsCalculator.calculate(
        goals: goals,
        allTransactions: baseTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        filterGoalType: GoalType.marriage,
      );
      expect(resultType.totalSaved, equals(50000.0));

      // Filter by specific gold goal ID
      final resultId = GoalAnalyticsCalculator.calculate(
        goals: goals,
        allTransactions: baseTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        filterGoalId: 'g_gold',
      );
      expect(resultId.totalSaved, equals(27000.0));
    });

    test('Time range filters restrict calculations properly (3M, 6M, 12M)', () {
      final rangeStart = DateTime(now.year, now.month - 1, 1);
      final rangeEnd = DateTime(now.year, now.month, 1);

      final result = GoalAnalyticsCalculator.calculate(
        goals: goals,
        allTransactions: baseTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );

      expect(result.totalSaved, equals(75000.0));
    });

    test('Savings consistency score is computed correctly based on regularity and deviation', () {
      final scoreSteady = GoalAnalyticsCalculator.calculateConsistencyScore([20000, 20000, 20000]);
      expect(scoreSteady, equals(100));

      final scoreFluctuate = GoalAnalyticsCalculator.calculateConsistencyScore([20000, 25000, 15000]);
      expect(scoreFluctuate, greaterThan(75));
      expect(scoreFluctuate, lessThan(100));

      final scoreZero = GoalAnalyticsCalculator.calculateConsistencyScore([0, 0, 0]);
      expect(scoreZero, equals(0));
    });
  });

  group('GoalAnalyticsCalculator - Gold Mode Analytics Tests', () {
    final now = DateTime.now();
    final goldGoal = Goal(
      id: 'g_gold',
      name: 'Gold jewelry',
      type: GoalType.gold,
      targetAmount: 200000,
      currentSavings: 50000,
      targetDate: now.add(const Duration(days: 365)),
      priority: GoalPriority.high,
      health: GoalHealth.onTrack,
      targetGrams: 20.0,
      purchasedGrams: 5.0,
    );

    final goldTxs = [
      SavingsTransaction(
        id: 'gt1',
        goalId: 'g_gold',
        amount: 15000,
        date: DateTime(now.year, now.month, 10),
        goldGrams: 1.5,
      ),
      SavingsTransaction(
        id: 'gt2',
        goalId: 'g_gold',
        amount: 12000,
        date: DateTime(now.year, now.month - 1, 20),
        goldGrams: 1.2,
      ),
    ];

    final livePrice = GoldPrice(
      rate22K: 10000.0,
      rate24K: 11000.0,
      dailyChangePercentage: 2.5,
      lastUpdated: now,
    );

    final historyPrices = [9800.0, 9900.0, 10000.0];

    test('Gold accumulation weight and monthly added weight are correct', () {
      final rangeStart = DateTime(now.year, now.month - 1, 1);
      final rangeEnd = DateTime(now.year, now.month, 1);

      final result = GoalAnalyticsCalculator.calculateGold(
        goldGoal: goldGoal,
        transactions: goldTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        livePrice: livePrice,
        priceHistory: historyPrices,
        purity: '22K',
      );

      expect(result.totalGoldWeight, equals(2.7));
      expect(result.monthlyAverageWeight, equals(1.35));
    });

    test('22K and 24K price conversions map history points properly without mixing', () {
      final rangeStart = DateTime(now.year, now.month - 1, 1);
      final rangeEnd = DateTime(now.year, now.month, 1);

      final result22K = GoalAnalyticsCalculator.calculateGold(
        goldGoal: goldGoal,
        transactions: goldTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        livePrice: livePrice,
        priceHistory: historyPrices,
        purity: '22K',
      );
      expect(result22K.currentRate, equals(10000.0));
      expect(result22K.priceHistoryPoints.values.last, equals(10000.0));

      final result24K = GoalAnalyticsCalculator.calculateGold(
        goldGoal: goldGoal,
        transactions: goldTxs,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        livePrice: livePrice,
        priceHistory: historyPrices,
        purity: '24K',
      );
      expect(result24K.currentRate, equals(11000.0));
      expect(result24K.priceHistoryPoints.values.last, equals(11000.0));
    });

    test('Missing gold data/price feeds handles gracefully', () {
      final rangeStart = DateTime(now.year, now.month - 1, 1);
      final rangeEnd = DateTime(now.year, now.month, 1);

      final result = GoalAnalyticsCalculator.calculateGold(
        goldGoal: goldGoal,
        transactions: [],
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        livePrice: null,
        priceHistory: [],
        purity: '22K',
      );

      expect(result.totalGoldWeight, equals(0.0));
      expect(result.currentRate, equals(0.0));
      expect(result.priceChangeVsPreviousPct, equals(0.0));
    });
  });
}
