/// Calculator for goal template-specific financial computations.
///
/// Provides static utility methods for computing target amounts
/// for emergency funds, down payments, and suggested monthly savings.
class GoalTemplateCalculator {
  GoalTemplateCalculator._();

  /// Calculates emergency fund target as [monthlyExpenses] × [months].
  /// Returns 0 for negative or zero expenses.
  static double calculateEmergencyFundTarget(double monthlyExpenses, int months) {
    if (monthlyExpenses <= 0) return 0.0;
    return monthlyExpenses * months;
  }

  /// Calculates down payment amount as [propertyCost] × [percent] / 100.
  /// Returns 0 for non-positive property cost.
  static double calculateDownPayment(double propertyCost, double percent) {
    if (propertyCost <= 0) return 0.0;
    return propertyCost * percent / 100.0;
  }

  /// Calculates suggested monthly saving to reach [targetAmount] minus
  /// [currentSavings] by [targetDate].
  ///
  /// Returns the remaining amount divided by the number of months left.
  /// Clamps to at least 1 month to prevent division by zero.
  static double calculateSuggestedMonthlySaving({
    required double targetAmount,
    required double currentSavings,
    required DateTime targetDate,
  }) {
    final remaining = (targetAmount - currentSavings).clamp(0.0, double.infinity);
    final daysLeft = targetDate.difference(DateTime.now()).inDays;
    final monthsLeft = (daysLeft / 30).clamp(1.0, double.infinity);
    return remaining / monthsLeft;
  }
}
