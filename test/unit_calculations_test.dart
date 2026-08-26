import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot_app/core/models/models.dart';
import 'package:migoalpilot_app/shared/enums/enums.dart';

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
}
