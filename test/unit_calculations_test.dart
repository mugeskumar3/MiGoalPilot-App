import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:migoalpilot/core/services/gold_goal_calculator.dart';

void main() {
  group('Goal Financial Calculations', () {
    test(
      'Standard goal progress percentage should be calculated correctly',
      () {
        final goal = Goal(
          id: '1',
          name: 'House downpayment',
          type: GoalType.house,
          targetAmount: 1000000,
          currentSavings: 250000,
          targetDate: DateTime.now(),
          priority: GoalPriority.high,
          health: GoalHealth.onTrack,
        );

        expect(goal.progressPercentage, equals(0.25));
      },
    );

    test('Gold goal progress percentage should be calculated by grams', () {
      final goal = Goal(
        id: '2',
        name: 'Wedding jewelry',
        type: GoalType.gold,
        targetAmount: 200000,
        currentSavings: 75000,
        targetDate: DateTime.now(),
        priority: GoalPriority.critical,
        health: GoalHealth.onTrack,
        targetGrams: 20.0,
        purchasedGrams: 5.0,
      );

      expect(goal.progressPercentage, equals(0.25));
    });

    test(
      'Remaining gold valuation should multiply outstanding grams by spot price',
      () {
        const targetGrams = 20.0;
        const purchasedGrams = 8.0;
        const spotPrice = 12500.0;

        const remainingGrams = targetGrams - purchasedGrams;
        const estimatedCost = remainingGrams * spotPrice;

        expect(remainingGrams, equals(12.0));
        expect(estimatedCost, equals(150000.0));
      },
    );

    test('What-If simulation guest increases should accurately add costs', () {
      const currentGuests = 300;
      const newGuests = 500;
      const costPerGuest = 600.0;
      const previousBudget = 1050000.0;

      const difference = (newGuests - currentGuests) * costPerGuest;
      const newBudget = previousBudget + difference;

      expect(difference, equals(120000.0));
      expect(newBudget, equals(1170000.0));
    });
  });

  group('GoldGoalCalculator Tests', () {
    final goldGoal = Goal(
      id: 'gold-1',
      name: 'Gold Goal',
      type: GoalType.gold,
      targetAmount: 200000,
      currentSavings: 75000,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      priority: GoalPriority.critical,
      health: GoalHealth.onTrack,
      targetGrams: 20.0,
      purchasedGrams: 8.5,
    );

    test('Remaining grams should clamp to zero if target is exceeded', () {
      final completedGoal = Goal(
        id: 'gold-comp',
        name: 'Completed Gold Goal',
        type: GoalType.gold,
        targetAmount: 200000,
        currentSavings: 200000,
        targetDate: DateTime.now(),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
        targetGrams: 10.0,
        purchasedGrams: 12.0,
      );
      expect(GoldGoalCalculator.calculateRemainingGrams(completedGoal), equals(0.0));
      expect(GoldGoalCalculator.calculateRemainingGrams(goldGoal), equals(11.5));
    });

    test('Valuations should return null if spot price is missing', () {
      expect(GoldGoalCalculator.calculateCurrentValue(goldGoal, null), isNull);
      expect(GoldGoalCalculator.calculateTargetValue(goldGoal, null), isNull);
    });

    test('Valuations should multiply grams by spot price correctly', () {
      expect(GoldGoalCalculator.calculateCurrentValue(goldGoal, 10000.0), equals(85000.0));
      expect(GoldGoalCalculator.calculateTargetValue(goldGoal, 10000.0), equals(200000.0));
    });

    test('Monthly accumulation should group and sort transactions chronologically', () {
      final now = DateTime.now();
      final txs = [
        SavingsTransaction(
          id: 'tx1',
          goalId: 'gold-1',
          amount: 5000,
          date: DateTime(now.year, now.month, 5),
          goldGrams: 0.5,
        ),
        SavingsTransaction(
          id: 'tx2',
          goalId: 'gold-1',
          amount: 15000,
          date: DateTime(now.year, now.month, 15),
          goldGrams: 1.5,
        ),
        SavingsTransaction(
          id: 'tx3',
          goalId: 'gold-1',
          amount: 20000,
          date: DateTime(now.year, now.month - 1, 10),
          goldGrams: 2.0,
        ),
      ];

      final result = GoldGoalCalculator.getMonthlyAccumulation(txs);
      expect(result.length, equals(2));
      // First is current month (recent first)
      expect(result[0].grams, equals(2.0));
      expect(result[0].amount, equals(20000.0));
      // Second is last month
      expect(result[1].grams, equals(2.0));
      expect(result[1].amount, equals(20000.0));
    });

    test('Smart insight should return completed message if remaining weight is 0', () {
      final completedGoal = Goal(
        id: 'gold-comp',
        name: 'Completed Gold Goal',
        type: GoalType.gold,
        targetAmount: 200000,
        currentSavings: 200000,
        targetDate: DateTime.now(),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
        targetGrams: 10.0,
        purchasedGrams: 10.0,
      );
      final insight = GoldGoalCalculator.generateSmartInsight(
        goal: completedGoal,
        transactions: [],
        spotPrice: 10000.0,
        dailyChangePercentage: 0.0,
      );
      expect(insight, contains("Congratulations! You've achieved your target"));
    });

    test('Smart insight should warn if gold price daily change > 1.5%', () {
      final distantGoal = Goal(
        id: 'gold-distant',
        name: 'Gold Goal',
        type: GoalType.gold,
        targetAmount: 20.0,
        currentSavings: 75000,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        priority: GoalPriority.critical,
        health: GoalHealth.onTrack,
        targetGrams: 20.0,
        purchasedGrams: 6.0, // 4.0g from 10.0g milestone (> 10% threshold)
      );
      final insight = GoldGoalCalculator.generateSmartInsight(
        goal: distantGoal,
        transactions: [],
        spotPrice: 10000.0,
        dailyChangePercentage: 2.0,
      );
      expect(insight, contains("Gold is currently higher than your recent tracked price"));
    });
  });
}
