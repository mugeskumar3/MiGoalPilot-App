import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/smart_savings_planner.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

void main() {
  group('SmartSavingsPlanner Unit Tests', () {
    final now = DateTime.now();

    test('Single Goal default required savings is calculated correctly', () {
      final goal = Goal(
        id: 'g1',
        name: 'Wedding flight',
        type: GoalType.travel,
        targetAmount: 12000,
        currentSavings: 2000,
        targetDate: now.add(const Duration(days: 304)), // ~10 months
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final result = SmartSavingsPlanner.calculateDefaultPlan([goal]);
      // Remaining = 10000. Time = 10 months. required = 1000/month.
      expect(result.recommendedTotalMonthly, closeTo(1000.0, 50.0));
      expect(result.defaultAllocations['g1'], closeTo(1000.0, 50.0));
    });

    test('Multiple Goals allocations sum up to the total recommended saving amount', () {
      final g1 = Goal(
        id: 'g1',
        name: 'Marriage Goal',
        type: GoalType.marriage,
        targetAmount: 1050000,
        currentSavings: 450000,
        targetDate: now.add(const Duration(days: 540)), // ~17.7 months
        priority: GoalPriority.critical,
        health: GoalHealth.onTrack,
      );

      final g2 = Goal(
        id: 'g2',
        name: 'Gold Goal',
        type: GoalType.gold,
        targetAmount: 200000,
        currentSavings: 50000,
        targetDate: now.add(const Duration(days: 365)), // ~12 months
        priority: GoalPriority.high,
        health: GoalHealth.onTrack,
        targetGrams: 20,
        purchasedGrams: 5,
      );

      final result = SmartSavingsPlanner.calculateDefaultPlan([g1, g2]);
      
      final sumAllocations = result.defaultAllocations.values.fold(0.0, (sum, val) => sum + val);
      expect(sumAllocations, equals(result.recommendedTotalMonthly));
    });

    test('Rebalancing allocates remainder correctly and maintains total constraint', () {
      final currentAllocations = {
        'marriage': 25000.0,
        'gold': 10000.0,
        'travel': 5000.0,
      };

      final newAllocations = SmartSavingsPlanner.rebalanceAllocations(
        currentAllocations: currentAllocations,
        changedGoalId: 'marriage',
        newValue: 30000.0,
        totalCapacity: 40000.0,
      );

      // totalCapacity is 40k. Marriage increased from 25k to 30k (diff +5k).
      // The remaining 10k capacity should be shared between gold and travel (ratio gold:travel was 10:5 = 2:1).
      // So gold gets 2/3 of 10k = 6666.67, travel gets 1/3 of 10k = 3333.33.
      expect(newAllocations['marriage'], equals(30000.0));
      expect(newAllocations['gold'], closeTo(6666.67, 10.0));
      expect(newAllocations['travel'], closeTo(3333.33, 10.0));

      final double totalSum = newAllocations.values.fold(0.0, (sum, v) => sum + v);
      expect(totalSum, equals(40000.0));
    });

    test('Completed goal gets zero allocation', () {
      final goal = Goal(
        id: 'completed_1',
        name: 'Completed Custom Goal',
        type: GoalType.custom,
        targetAmount: 10000,
        currentSavings: 10000,
        targetDate: now.add(const Duration(days: 30)),
        priority: GoalPriority.medium,
        health: GoalHealth.completed,
      );

      final result = SmartSavingsPlanner.calculateDefaultPlan([goal]);
      expect(result.defaultAllocations['completed_1'], equals(0.0));
      expect(result.recommendedTotalMonthly, equals(0.0));
    });

    test('Recalculate Projections matches required months', () {
      final goal = Goal(
        id: 'g1',
        name: 'Travel trip',
        type: GoalType.travel,
        targetAmount: 10000,
        currentSavings: 5000,
        targetDate: now.add(const Duration(days: 180)),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      );

      final allocations = {'g1': 1000.0};
      final projections = SmartSavingsPlanner.recalculateProjections(
        goals: [goal],
        allocations: allocations,
      );

      // Remaining = 5000. Allocation = 1000. Finish in 5 months.
      final projDate = projections['g1'];
      expect(projDate, isNotNull);
      final daysDiff = projDate!.difference(now).inDays;
      expect(daysDiff, closeTo(152, 5)); // 5 months is ~152 days
    });
  });
}
