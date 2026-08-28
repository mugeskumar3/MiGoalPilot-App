import 'package:migoalpilot/core/models/goal_template_registry.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalTemplateState {
  final GoalTemplate template;
  final String name;
  final double targetAmount;
  final DateTime targetDate;
  final GoalPriority priority;
  final double currentSavings;

  // Emergency Fund
  final double essentialExpenses;
  final int safetyMonths;
  final bool isCustomSafetyMonths;

  // Gold
  final double targetGrams;
  final int goldPurity; // 22 or 24

  // House / Car
  final double propertyCost;
  final double downPaymentPercent;

  final bool isLoading;
  final String? error;

  GoalTemplateState({
    required this.template,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    required this.priority,
    required this.currentSavings,
    this.essentialExpenses = 50000.0,
    this.safetyMonths = 6,
    this.isCustomSafetyMonths = false,
    this.targetGrams = 10.0,
    this.goldPurity = 22,
    this.propertyCost = 1000000.0,
    this.downPaymentPercent = 20.0,
    this.isLoading = false,
    this.error,
  });

  GoalTemplateState copyWith({
    GoalTemplate? template,
    String? name,
    double? targetAmount,
    DateTime? targetDate,
    GoalPriority? priority,
    double? currentSavings,
    double? essentialExpenses,
    int? safetyMonths,
    bool? isCustomSafetyMonths,
    double? targetGrams,
    int? goldPurity,
    double? propertyCost,
    double? downPaymentPercent,
    bool? isLoading,
    String? error,
  }) {
    return GoalTemplateState(
      template: template ?? this.template,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      currentSavings: currentSavings ?? this.currentSavings,
      essentialExpenses: essentialExpenses ?? this.essentialExpenses,
      safetyMonths: safetyMonths ?? this.safetyMonths,
      isCustomSafetyMonths: isCustomSafetyMonths ?? this.isCustomSafetyMonths,
      targetGrams: targetGrams ?? this.targetGrams,
      goldPurity: goldPurity ?? this.goldPurity,
      propertyCost: propertyCost ?? this.propertyCost,
      downPaymentPercent: downPaymentPercent ?? this.downPaymentPercent,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can clear error if null is passed
    );
  }
}
