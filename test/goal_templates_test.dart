import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:migoalpilot/core/models/goal_template_registry.dart';
import 'package:migoalpilot/core/services/goal_template_calculator.dart';
import 'package:migoalpilot/core/viewmodels/goal_template_viewmodel.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class MockGoalsViewModel extends Mock implements GoalsViewModel {
  final List<Goal> savedGoals = [];

  @override
  Future<void> addGoal(Goal goal) async {
    savedGoals.add(goal);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Goal(
        id: '',
        name: '',
        type: GoalType.custom,
        targetAmount: 0.0,
        currentSavings: 0.0,
        targetDate: DateTime.now(),
        priority: GoalPriority.medium,
        health: GoalHealth.onTrack,
      ),
    );
  });

  group('Goal Template Registry Verification', () {
    test('Registry contains all 9 required templates', () {
      final templates = GoalTemplateRegistry.templates;
      expect(templates, hasLength(9));

      final ids = templates.map((t) => t.id).toList();
      expect(ids, contains('marriage'));
      expect(ids, contains('emergency_fund'));
      expect(ids, contains('gold'));
      expect(ids, contains('house'));
      expect(ids, contains('car'));
      expect(ids, contains('travel'));
      expect(ids, contains('education'));
      expect(ids, contains('gadgets'));
      expect(ids, contains('custom'));
    });

    test('Templates define sensible defaults', () {
      final marriage = GoalTemplateRegistry.getTemplateById('marriage');
      expect(marriage.type, equals(GoalType.marriage));
      expect(marriage.defaultTargetAmount, equals(500000.0));
      expect(marriage.defaultDurationMonths, equals(24));

      final gold = GoalTemplateRegistry.getTemplateById('gold');
      expect(gold.type, equals(GoalType.gold));
      expect(gold.defaultDurationMonths, equals(12));

      final house = GoalTemplateRegistry.getTemplateById('house');
      expect(house.type, equals(GoalType.house));
      expect(house.defaultTargetAmount, equals(1000000.0));
      expect(house.defaultDurationMonths, equals(60));
    });
  });

  group('GoalTemplateCalculator Calculations', () {
    test('Emergency Fund target amount dynamic calculation', () {
      final target = GoalTemplateCalculator.calculateEmergencyFundTarget(50000.0, 6);
      expect(target, equals(300000.0));

      final targetZero = GoalTemplateCalculator.calculateEmergencyFundTarget(0.0, 12);
      expect(targetZero, equals(0.0));

      final targetNegative = GoalTemplateCalculator.calculateEmergencyFundTarget(-1000.0, 6);
      expect(targetNegative, equals(0.0));
    });

    test('Down-payment value calculation', () {
      final downPayment = GoalTemplateCalculator.calculateDownPayment(5000000.0, 20.0);
      expect(downPayment, equals(1000000.0));

      final downPaymentZero = GoalTemplateCalculator.calculateDownPayment(0.0, 20.0);
      expect(downPaymentZero, equals(0.0));
    });

    test('Suggested monthly savings computation', () {
      final targetDate = DateTime.now().add(const Duration(days: 365)); // 12 months
      final suggested = GoalTemplateCalculator.calculateSuggestedMonthlySaving(
        targetAmount: 300000.0,
        currentSavings: 60000.0,
        targetDate: targetDate,
      );

      // Remaining needed = 240,000 / ~12.17 months (365/30) ≈ 19,726
      expect(suggested, closeTo(20000.0, 500.0));
    });
  });

  group('GoalTemplateViewModel Setup and Modifications', () {
    test('Initialization pre-fills custom configurations correctly', () {
      final template = GoalTemplateRegistry.getTemplateById('emergency_fund');
      final vm = GoalTemplateViewModel(template);

      expect(vm.state.name, equals('Emergency Safety Buffer'));
      expect(vm.state.essentialExpenses, equals(50000.0));
      expect(vm.state.safetyMonths, equals(6));
      expect(vm.state.targetAmount, equals(300000.0));
    });

    test('Modifying essential expenses recalculates target amount dynamically', () {
      final template = GoalTemplateRegistry.getTemplateById('emergency_fund');
      final vm = GoalTemplateViewModel(template);

      vm.updateEssentialExpenses(60000.0);
      expect(vm.state.targetAmount, equals(360000.0));
    });

    test('Modifying safety buffer months recalculates target amount dynamically', () {
      final template = GoalTemplateRegistry.getTemplateById('emergency_fund');
      final vm = GoalTemplateViewModel(template);

      vm.updateSafetyMonths(12);
      expect(vm.state.targetAmount, equals(600000.0));
    });

    test('Modifying down payment percent recalculates target amount dynamically', () {
      final template = GoalTemplateRegistry.getTemplateById('house');
      final vm = GoalTemplateViewModel(template);

      // House starts with propertyCost=5,00,000 and downPayment=20% -> 100,000
      expect(vm.state.targetAmount, equals(1000000.0));

      vm.updateDownPaymentPercent(10.0);
      expect(vm.state.targetAmount, equals(500000.0));
    });

    test('Saving template goal adds correct Goal entity to notifier', () async {
      final template = GoalTemplateRegistry.getTemplateById('emergency_fund');
      final vm = GoalTemplateViewModel(template);
      final mockGoalsVM = MockGoalsViewModel();

      final success = await vm.saveGoal(mockGoalsVM);

      expect(success, isTrue);
      expect(mockGoalsVM.savedGoals, hasLength(1));

      final createdGoal = mockGoalsVM.savedGoals.first;
      expect(createdGoal.name, equals('Emergency Safety Buffer'));
      expect(createdGoal.targetAmount, equals(300000.0));
      expect(createdGoal.type, equals(GoalType.emergencyFund));
    });

    test('Emergency Fund creates normal Goal entities compatible with health score & milestones', () async {
      final template = GoalTemplateRegistry.getTemplateById('emergency_fund');
      final vm = GoalTemplateViewModel(template);
      final mockGoalsVM = MockGoalsViewModel();

      await vm.saveGoal(mockGoalsVM);
      final createdGoal = mockGoalsVM.savedGoals.first;

      // Integration properties check:
      expect(createdGoal.health, equals(GoalHealth.onTrack));
      expect(createdGoal.healthScore, equals(100));
      expect(createdGoal.completedMilestones, isEmpty);
    });
  });
}
