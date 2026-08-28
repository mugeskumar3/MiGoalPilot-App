import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/goal_template_registry.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_template_calculator.dart';
import 'package:migoalpilot/features/goals/presentation/viewmodels/goal_template_state.dart';
import 'package:migoalpilot/features/goals/presentation/viewmodels/goals_viewmodel.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalTemplateViewModel extends StateNotifier<GoalTemplateState> {
  GoalTemplateViewModel(GoalTemplate template)
      : super(
          GoalTemplateState(
            template: template,
            name: _getDefaultName(template),
            targetAmount: template.defaultTargetAmount,
            targetDate: DateTime.now().add(Duration(days: 30 * template.defaultDurationMonths)),
            priority: GoalPriority.medium,
            currentSavings: 0.0,
          ),
        ) {
    _initializeDefaults();
  }

  static String _getDefaultName(GoalTemplate template) {
    switch (template.id) {
      case 'marriage':
        return 'Dream Wedding';
      case 'emergency_fund':
        return 'Emergency Safety Buffer';
      case 'gold':
        return 'Gold Accumulation';
      case 'house':
        return 'Home Property Down-Payment';
      case 'car':
        return 'New Vehicle Purchase';
      case 'travel':
        return 'Travel Adventure';
      case 'education':
        return 'Tuition Fund';
      case 'gadgets':
        return 'Gadget Upgrade';
      default:
        return 'Custom Savings Target';
    }
  }

  void _initializeDefaults() {
    final t = state.template;
    if (t.id == 'emergency_fund') {
      final target = GoalTemplateCalculator.calculateEmergencyFundTarget(50000.0, 6);
      state = state.copyWith(
        essentialExpenses: 50000.0,
        safetyMonths: 6,
        isCustomSafetyMonths: false,
        targetAmount: target,
      );
    } else if (t.id == 'house') {
      final target = GoalTemplateCalculator.calculateDownPayment(5000000.0, 20.0);
      state = state.copyWith(
        propertyCost: 5000000.0,
        downPaymentPercent: 20.0,
        targetAmount: target,
      );
    } else if (t.id == 'car') {
      final target = GoalTemplateCalculator.calculateDownPayment(1000000.0, 20.0);
      state = state.copyWith(
        propertyCost: 1000000.0,
        downPaymentPercent: 20.0,
        targetAmount: target,
      );
    }
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateTargetAmount(double amt) {
    state = state.copyWith(targetAmount: amt);
  }

  void updateTargetDate(DateTime date) {
    state = state.copyWith(targetDate: date);
  }

  void updatePriority(GoalPriority priority) {
    state = state.copyWith(priority: priority);
  }

  void updateCurrentSavings(double savings) {
    state = state.copyWith(currentSavings: savings);
  }

  // Emergency Fund Setup Actions
  void updateEssentialExpenses(double expenses) {
    final target = GoalTemplateCalculator.calculateEmergencyFundTarget(expenses, state.safetyMonths);
    state = state.copyWith(
      essentialExpenses: expenses,
      targetAmount: target,
    );
  }

  void updateSafetyMonths(int months) {
    final target = GoalTemplateCalculator.calculateEmergencyFundTarget(state.essentialExpenses, months);
    state = state.copyWith(
      safetyMonths: months,
      targetAmount: target,
    );
  }

  void toggleCustomSafetyMonths(bool isCustom) {
    state = state.copyWith(isCustomSafetyMonths: isCustom);
  }

  // Gold Setup Actions
  void updateTargetGrams(double grams) {
    state = state.copyWith(targetGrams: grams);
  }

  void updateGoldPurity(int purity) {
    state = state.copyWith(goldPurity: purity);
  }

  // Property / Down-payment Actions
  void updatePropertyCost(double cost) {
    final target = GoalTemplateCalculator.calculateDownPayment(cost, state.downPaymentPercent);
    state = state.copyWith(
      propertyCost: cost,
      targetAmount: target,
    );
  }

  void updateDownPaymentPercent(double percent) {
    final target = GoalTemplateCalculator.calculateDownPayment(state.propertyCost, percent);
    state = state.copyWith(
      downPaymentPercent: percent,
      targetAmount: target,
    );
  }

  Future<bool> saveGoal(GoalsViewModel goalsNotifier) async {
    final name = state.name.trim();
    if (name.isEmpty) {
      state = state.copyWith(error: 'Goal name cannot be empty');
      return false;
    }

    if (state.template.id == 'gold') {
      if (state.targetGrams <= 0) {
        state = state.copyWith(error: 'Target weight must be greater than 0 grams');
        return false;
      }
    } else {
      if (state.targetAmount <= 0) {
        state = state.copyWith(error: 'Target amount must be greater than ₹0');
        return false;
      }
    }

    if (state.targetDate.isBefore(DateTime.now())) {
      state = state.copyWith(error: 'Target date must be in the future');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = Goal(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: state.template.type,
        targetAmount: state.template.id == 'gold' ? 0.0 : state.targetAmount,
        currentSavings: state.currentSavings,
        targetDate: state.targetDate,
        priority: state.priority,
        health: GoalHealth.onTrack,
        targetGrams: state.template.id == 'gold' ? state.targetGrams : 0.0,
      );

      goalsNotifier.addGoal(goal);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create goal: $e');
      return false;
    }
  }
}

// Family provider to instantiate setup viewmodels dynamically by templateId
final goalTemplateViewModelProvider =
    StateNotifierProvider.family<GoalTemplateViewModel, GoalTemplateState, String>((ref, templateId) {
  final template = GoalTemplateRegistry.getTemplateById(templateId);
  return GoalTemplateViewModel(template);
});
