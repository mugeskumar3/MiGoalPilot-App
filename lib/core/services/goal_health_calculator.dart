import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalHealthResult {
  final int score;
  final GoalHealth status;
  final bool isSavingsPaceHealthy;
  final bool isDeadlineRealistic;
  final bool isMonthlyTargetAchievable;
  final bool isConsistencyHealthy;
  final DateTime? projectedCompletionDate;
  final String recommendation;

  const GoalHealthResult({
    required this.score,
    required this.status,
    required this.isSavingsPaceHealthy,
    required this.isDeadlineRealistic,
    required this.isMonthlyTargetAchievable,
    required this.isConsistencyHealthy,
    this.projectedCompletionDate,
    required this.recommendation,
  });
}

class GoalHealthCalculator {
  static GoalHealthResult calculate(
    Goal goal,
    List<SavingsTransaction> transactions, {
    double? simulatedMonthlySavings,
  }) {
    final now = DateTime.now();

    // 1. Edge Case: Goal Completed
    final bool isCompleted = goal.type == GoalType.gold
        ? (goal.targetGrams > 0 && goal.purchasedGrams >= goal.targetGrams)
        : (goal.targetAmount > 0 && goal.currentSavings >= goal.targetAmount);

    if (isCompleted) {
      return GoalHealthResult(
        score: 100,
        status: GoalHealth.completed,
        isSavingsPaceHealthy: true,
        isDeadlineRealistic: true,
        isMonthlyTargetAchievable: true,
        isConsistencyHealthy: true,
        projectedCompletionDate: transactions.isNotEmpty
            ? transactions
                  .map((t) => t.date)
                  .reduce((a, b) => a.isAfter(b) ? a : b)
            : now,
        recommendation: "Congratulations! You have achieved your goal.",
      );
    }

    // 2. Edge Case: Past Deadline (and not completed)
    final bool isPastDeadline = goal.targetDate.isBefore(now);
    if (isPastDeadline && goal.targetDate.year > 2000) {
      return const GoalHealthResult(
        score: 0,
        status: GoalHealth.atRisk,
        isSavingsPaceHealthy: false,
        isDeadlineRealistic: false,
        isMonthlyTargetAchievable: false,
        isConsistencyHealthy: false,
        projectedCompletionDate: null,
        recommendation:
            "The target date has passed. Please update your deadline.",
      );
    }

    // 3. Edge Case: Invalid or Zero Target
    final double target = goal.type == GoalType.gold
        ? goal.targetGrams
        : goal.targetAmount;
    final double current = goal.type == GoalType.gold
        ? goal.purchasedGrams
        : goal.currentSavings;
    if (target <= 0) {
      return const GoalHealthResult(
        score: 0,
        status: GoalHealth.atRisk,
        isSavingsPaceHealthy: false,
        isDeadlineRealistic: false,
        isMonthlyTargetAchievable: false,
        isConsistencyHealthy: false,
        projectedCompletionDate: null,
        recommendation:
            "Please set a valid target amount or grams to begin tracking.",
      );
    }

    DateTime start = now;
    if (transactions.isNotEmpty) {
      start = transactions
          .map((t) => t.date)
          .reduce((a, b) => a.isBefore(b) ? a : b);
    }

    final double totalDurationDays = goal.targetDate
        .difference(start)
        .inDays
        .toDouble();
    final double totalDurationMonths = (totalDurationDays / 30.4368).clamp(
      1.0,
      double.infinity,
    );

    final double elapsedDays = now.difference(start).inDays.toDouble();
    final double elapsedMonths = (elapsedDays / 30.4368).clamp(
      0.0,
      double.infinity,
    );

    final double daysRemaining = goal.targetDate
        .difference(now)
        .inDays
        .toDouble();
    final double monthsRemaining = (daysRemaining / 30.4368).clamp(
      0.1,
      double.infinity,
    );

    final double remainingNeeded = (target - current).clamp(0.0, target);

    // Calculate rates
    final double overallRate = target / totalDurationMonths;
    final double requiredRateNow = remainingNeeded / monthsRemaining;

    // --- Sub-scores ---

    // 1. Current Progress Score (35%)
    final double progressPct = goal.progressPercentage;
    final double progressScore = progressPct * 35.0;

    // 2. Deadline Feasibility Score (25%)
    final bool hasNoDeadline = goal.targetDate.year <= 1970;
    double feasibilityScore = 25.0;
    if (!hasNoDeadline) {
      if (requiredRateNow <= overallRate) {
        feasibilityScore = 25.0;
      } else {
        feasibilityScore =
            (overallRate / requiredRateNow).clamp(0.0, 1.0) * 25.0;
      }
    }

    // 3. Saving Consistency Score (15%)
    double consistencyScore = 15.0;
    double averageMonthlySavings = 0.0;
    if (transactions.isNotEmpty) {
      // Find number of active calendar months from start to now
      final int startYearMonth = start.year * 12 + start.month;
      final int nowYearMonth = now.year * 12 + now.month;
      final int totalActiveCalendarMonths =
          (nowYearMonth - startYearMonth).abs() + 1;

      // Find unique months with transactions
      final uniqueMonths = transactions
          .map((t) => '${t.date.year}-${t.date.month}')
          .toSet()
          .length;

      final double consistencyRatio = uniqueMonths / totalActiveCalendarMonths;
      consistencyScore = consistencyRatio.clamp(0.0, 1.0) * 15.0;

      // Compute actual average monthly savings
      final double totalSavedInTransactions = transactions.fold(
        0.0,
        (sum, t) =>
            sum +
            (goal.type == GoalType.gold ? (t.goldGrams ?? 0.0) : t.amount),
      );
      averageMonthlySavings = totalSavedInTransactions / elapsedMonths.clamp(0.1, double.infinity);
    } else {
      // No transactions: if we have initial savings, assume consistent initial deposit.
      if (current > 0) {
        consistencyScore = 15.0;
        averageMonthlySavings = current / elapsedMonths.clamp(0.1, double.infinity);
      } else {
        // Brand new goal
        consistencyScore = 15.0;
        averageMonthlySavings = 0.0;
      }
    }

    if (simulatedMonthlySavings != null) {
      averageMonthlySavings = simulatedMonthlySavings;
    }

    // 4. Remaining Funding Gap (15%)
    final double gapPct = remainingNeeded / target;
    final double fundingGapScore = (1.0 - gapPct).clamp(0.0, 1.0) * 15.0;

    // 5. Missed Contributions (10%)
    double missedScore = 10.0;
    if (!hasNoDeadline) {
      final double expectedSavingsSoFar = (overallRate * elapsedMonths).clamp(
        0.0,
        target,
      );
      if (current >= expectedSavingsSoFar || expectedSavingsSoFar <= 0) {
        missedScore = 10.0;
      } else {
        final double missedFraction =
            (expectedSavingsSoFar - current) / expectedSavingsSoFar;
        missedScore = (1.0 - missedFraction).clamp(0.0, 1.0) * 10.0;
      }
    }

    // Total Score
    final int score =
        (progressScore +
                feasibilityScore +
                consistencyScore +
                fundingGapScore +
                missedScore)
            .round()
            .clamp(0, 100);

    // Map to GoalHealth status
    GoalHealth status;
    if (score >= 80) {
      status = GoalHealth.onTrack; // HEALTHY
    } else if (score >= 60) {
      status = GoalHealth.onTrack; // ON TRACK
    } else if (score >= 40) {
      status = GoalHealth.needsAttention; // NEEDS ATTENTION
    } else {
      status = GoalHealth.atRisk; // AT RISK
    }

    // Projected Completion Date calculation
    DateTime? projectedDate;
    if (averageMonthlySavings > 0) {
      final double remainingMonthsToFinish =
          remainingNeeded / averageMonthlySavings;
      if (remainingMonthsToFinish.isFinite && remainingMonthsToFinish < 1200) {
        projectedDate = now.add(
          Duration(days: (remainingMonthsToFinish * 30.4368).toInt()),
        );
      }
    }

    // Generate Actionable Recommendation
    String recommendation;
    if (requiredRateNow <= averageMonthlySavings || remainingNeeded <= 0) {
      recommendation = "You're ahead of your plan. Keep it up!";
    } else {
      final double diff = requiredRateNow - averageMonthlySavings;
      if (goal.type == GoalType.gold) {
        recommendation =
            "You need ${diff.toStringAsFixed(2)}g more/month to stay on track.";
      } else {
        recommendation =
            "You need ₹${diff.toStringAsFixed(0)} more/month to stay on track.";
      }
    }

    return GoalHealthResult(
      score: score,
      status: status,
      isSavingsPaceHealthy: progressScore >= 28.0 || progressPct >= 0.8,
      isDeadlineRealistic: feasibilityScore >= 18.0,
      isMonthlyTargetAchievable: feasibilityScore >= 15.0,
      isConsistencyHealthy: consistencyScore >= 11.0,
      projectedCompletionDate: projectedDate,
      recommendation: recommendation,
    );
  }
}
