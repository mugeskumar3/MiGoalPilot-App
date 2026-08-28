import 'dart:math';
import 'package:intl/intl.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalContribution {
  final String goalId;
  final String goalName;
  final GoalType goalType;
  final double totalContributed;
  final double percentage;

  GoalContribution({
    required this.goalId,
    required this.goalName,
    required this.goalType,
    required this.totalContributed,
    required this.percentage,
  });
}

class GoalAnalyticsResult {
  final double totalSaved;
  final double monthlyAverage;
  final String highestMonth;
  final double highestSaving;
  final String lowestMonth;
  final double lowestSaving;
  final double savingTrendPct;
  final String savingTrendDirection;
  final int activeGoalsFunded;
  final double monthOverMonthChangePct;
  final double monthOverMonthChangeAmount;
  final int consistencyScore;
  final String consistencyLabel;
  final List<GoalContribution> goalContributions;
  final Map<DateTime, double> monthlySavingsPoints;

  GoalAnalyticsResult({
    required this.totalSaved,
    required this.monthlyAverage,
    required this.highestMonth,
    required this.highestSaving,
    required this.lowestMonth,
    required this.lowestSaving,
    required this.savingTrendPct,
    required this.savingTrendDirection,
    required this.activeGoalsFunded,
    required this.monthOverMonthChangePct,
    required this.monthOverMonthChangeAmount,
    required this.consistencyScore,
    required this.consistencyLabel,
    required this.goalContributions,
    required this.monthlySavingsPoints,
  });
}

class MonthlyGoldPoint {
  final DateTime month;
  final double weight;
  final double value;
  final double price;

  MonthlyGoldPoint({
    required this.month,
    required this.weight,
    required this.value,
    required this.price,
  });
}

class GoldAnalyticsResult {
  final double totalGoldWeight;
  final double monthlyAverageWeight;
  final String bestMonth;
  final double bestMonthWeight;
  final double currentRate;
  final double priceChangeVsPreviousPct;
  final List<MonthlyGoldPoint> monthlyGoldAdded;
  final Map<DateTime, double> priceHistoryPoints;

  GoldAnalyticsResult({
    required this.totalGoldWeight,
    required this.monthlyAverageWeight,
    required this.bestMonth,
    required this.bestMonthWeight,
    required this.currentRate,
    required this.priceChangeVsPreviousPct,
    required this.monthlyGoldAdded,
    required this.priceHistoryPoints,
  });
}

class GoalAnalyticsCalculator {
  static List<DateTime> getMonthsInRange(DateTime start, DateTime end) {
    final List<DateTime> months = [];
    DateTime current = DateTime(start.year, start.month, 1);
    final limit = DateTime(end.year, end.month, 1);
    while (!current.isAfter(limit)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    return months;
  }

  static GoalAnalyticsResult calculate({
    required List<Goal> goals,
    required List<SavingsTransaction> allTransactions,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    GoalType? filterGoalType,
    String? filterGoalId,
  }) {
    // 1. Generate month ranges
    final months = getMonthsInRange(rangeStart, rangeEnd);
    final startLimit = DateTime(rangeStart.year, rangeStart.month, 1);
    final endLimit = DateTime(rangeEnd.year, rangeEnd.month + 1, 1).subtract(const Duration(seconds: 1));

    // 2. Filter transactions by date range and selected filters
    final filteredTxs = allTransactions.where((t) {
      if (t.date.isBefore(startLimit) || t.date.isAfter(endLimit)) return false;
      if (t.amount <= 0) return false;

      // Filter by goal type or specific goal ID
      if (filterGoalId != null) {
        return t.goalId == filterGoalId;
      }
      if (filterGoalType != null) {
        final goal = goals.firstWhere((g) => g.id == t.goalId, orElse: () => Goal(
          id: '', name: '', type: GoalType.custom, targetAmount: 0, currentSavings: 0, targetDate: DateTime.now(), priority: GoalPriority.low, health: GoalHealth.paused,
        ));
        return goal.id.isNotEmpty && goal.type == filterGoalType;
      }
      return true;
    }).toList();

    // 3. Map monthly savings
    final Map<DateTime, double> monthlySavingsPoints = {};
    for (final m in months) {
      monthlySavingsPoints[m] = 0.0;
    }
    for (final t in filteredTxs) {
      final mKey = DateTime(t.date.year, t.date.month, 1);
      if (monthlySavingsPoints.containsKey(mKey)) {
        monthlySavingsPoints[mKey] = (monthlySavingsPoints[mKey] ?? 0) + t.amount;
      }
    }

    final double totalSaved = filteredTxs.fold(0.0, (sum, t) => sum + t.amount);
    final double monthlyAverage = months.isNotEmpty ? totalSaved / months.length : 0.0;

    // Highest and Lowest Month
    String highestMonth = 'N/A';
    double highestSaving = 0.0;
    String lowestMonth = 'N/A';
    double lowestSaving = double.infinity;

    for (final entry in monthlySavingsPoints.entries) {

      if (entry.value >= highestSaving) {
        highestSaving = entry.value;
        highestMonth = DateFormat('MMMM').format(entry.key);
      }
      if (entry.value < lowestSaving) {
        lowestSaving = entry.value;
        lowestMonth = DateFormat('MMMM').format(entry.key);
      }
    }

    if (lowestSaving == double.infinity || filteredTxs.isEmpty) {
      lowestSaving = 0.0;
      lowestMonth = 'N/A';
    }
    if (highestSaving == 0.0) {
      highestMonth = 'N/A';
    }

    // MoM change between last month and previous
    double momChangePct = 0.0;
    double momChangeAmount = 0.0;
    if (months.length >= 2) {
      final lastMonthKey = months.last;
      final prevMonthKey = months[months.length - 2];
      final currentMonthSavings = monthlySavingsPoints[lastMonthKey] ?? 0.0;
      final prevMonthSavings = monthlySavingsPoints[prevMonthKey] ?? 0.0;
      momChangeAmount = currentMonthSavings - prevMonthSavings;
      if (prevMonthSavings > 0) {
        momChangePct = (momChangeAmount / prevMonthSavings) * 100;
      }
    }

    // Saving Trend
    // Computed by comparing the average of the second half of range to the first half.
    double trendPct = 0.0;
    String trendDirection = 'Stable';
    if (months.length >= 2) {
      final midPoint = (months.length / 2).floor();
      final firstHalf = months.take(midPoint).toList();
      final secondHalf = months.skip(midPoint).toList();

      final firstHalfAvg = firstHalf.isNotEmpty
          ? firstHalf.map((m) => monthlySavingsPoints[m] ?? 0.0).reduce((a, b) => a + b) / firstHalf.length
          : 0.0;
      final secondHalfAvg = secondHalf.isNotEmpty
          ? secondHalf.map((m) => monthlySavingsPoints[m] ?? 0.0).reduce((a, b) => a + b) / secondHalf.length
          : 0.0;

      if (firstHalfAvg > 0) {
        trendPct = ((secondHalfAvg - firstHalfAvg) / firstHalfAvg) * 100;
      } else if (secondHalfAvg > 0) {
        trendPct = 100.0;
      }

      if (trendPct > 5.0) {
        trendDirection = 'Improving';
      } else if (trendPct < -5.0) {
        trendDirection = 'Declining';
      }
    }

    // Active Goals Funded
    final Set<String> activeFundedIds = filteredTxs.map((t) => t.goalId).toSet();
    final int activeGoalsFunded = activeFundedIds.length;

    // Consistency score
    final List<double> monthlySavingsList = months.map((m) => monthlySavingsPoints[m] ?? 0.0).toList();
    final int consistencyScore = calculateConsistencyScore(monthlySavingsList);
    String consistencyLabel = 'INCONSISTENT';
    if (consistencyScore >= 80) {
      consistencyLabel = 'CONSISTENT';
    } else if (consistencyScore >= 50) {
      consistencyLabel = 'MODERATE';
    }

    // Goal Contributions
    final Map<String, double> contributionsMap = {};
    for (final t in filteredTxs) {
      contributionsMap[t.goalId] = (contributionsMap[t.goalId] ?? 0) + t.amount;
    }

    final List<GoalContribution> goalContributions = contributionsMap.entries.map((entry) {
      final goal = goals.firstWhere((g) => g.id == entry.key, orElse: () => Goal(
        id: entry.key,
        name: 'Unknown Goal',
        type: GoalType.custom,
        targetAmount: 0,
        currentSavings: 0,
        targetDate: DateTime.now(),
        priority: GoalPriority.low,
        health: GoalHealth.paused,
      ));
      final pct = totalSaved > 0 ? (entry.value / totalSaved) * 100 : 0.0;
      return GoalContribution(
        goalId: entry.key,
        goalName: goal.name,
        goalType: goal.type,
        totalContributed: entry.value,
        percentage: pct,
      );
    }).toList();

    // Sort by contribution amount desc
    goalContributions.sort((a, b) => b.totalContributed.compareTo(a.totalContributed));

    return GoalAnalyticsResult(
      totalSaved: totalSaved,
      monthlyAverage: monthlyAverage,
      highestMonth: highestMonth,
      highestSaving: highestSaving,
      lowestMonth: lowestMonth,
      lowestSaving: lowestSaving,
      savingTrendPct: trendPct,
      savingTrendDirection: trendDirection,
      activeGoalsFunded: activeGoalsFunded,
      monthOverMonthChangePct: momChangePct,
      monthOverMonthChangeAmount: momChangeAmount,
      consistencyScore: consistencyScore,
      consistencyLabel: consistencyLabel,
      goalContributions: goalContributions,
      monthlySavingsPoints: monthlySavingsPoints,
    );
  }

  static int calculateConsistencyScore(List<double> monthlySavings) {
    if (monthlySavings.isEmpty) return 0;
    
    // 1. Regularity score: ratio of months with savings to total months
    final totalMonths = monthlySavings.length;
    final activeMonths = monthlySavings.where((s) => s > 0).length;
    final regularityRatio = activeMonths / totalMonths;
    
    // 2. Deviation score: coefficient of variation of the savings amounts
    double deviationScore = 1.0;
    if (activeMonths >= 2) {
      final activeSavings = monthlySavings.where((s) => s > 0).toList();
      final average = activeSavings.reduce((a, b) => a + b) / activeSavings.length;
      if (average > 0) {
        final variance = activeSavings.map((s) => (s - average) * (s - average)).reduce((a, b) => a + b) / activeSavings.length;
        final stdDev = sqrt(variance);
        final cv = stdDev / average;
        // Map CV to deviationScore: CV of 0 = 1.0, CV >= 1.0 = 0.0
        deviationScore = (1.0 - cv).clamp(0.0, 1.0);
      }
    } else if (activeMonths == 1) {
      // Only one active month
      deviationScore = 0.5;
    } else {
      deviationScore = 0.0;
    }
    
    // Combine regularity (60%) and deviation stability (40%)
    final score = (regularityRatio * 60 + deviationScore * 40).round().clamp(0, 100);
    return score;
  }

  static GoldAnalyticsResult calculateGold({
    required Goal goldGoal,
    required List<SavingsTransaction> transactions,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required GoldPrice? livePrice,
    required List<double> priceHistory, // Assume this represents 22K spot prices
    required String purity, // "22K" or "24K"
  }) {
    final months = getMonthsInRange(rangeStart, rangeEnd);
    final startLimit = DateTime(rangeStart.year, rangeStart.month, 1);
    final endLimit = DateTime(rangeEnd.year, rangeEnd.month + 1, 1).subtract(const Duration(seconds: 1));

    // Filter transactions
    final filteredTxs = transactions.where((t) {
      if (t.date.isBefore(startLimit) || t.date.isAfter(endLimit)) return false;
      return t.goldGrams != null && t.goldGrams! > 0;
    }).toList();

    // Group gold weight and value by month
    final Map<DateTime, double> monthlyGrams = {};
    final Map<DateTime, double> monthlyValues = {};
    for (final m in months) {
      monthlyGrams[m] = 0.0;
      monthlyValues[m] = 0.0;
    }

    for (final t in filteredTxs) {
      final mKey = DateTime(t.date.year, t.date.month, 1);
      if (monthlyGrams.containsKey(mKey)) {
        monthlyGrams[mKey] = (monthlyGrams[mKey] ?? 0.0) + (t.goldGrams ?? 0.0);
        monthlyValues[mKey] = (monthlyValues[mKey] ?? 0.0) + t.amount;
      }
    }

    final double totalGoldWeight = filteredTxs.fold(0.0, (sum, t) => sum + (t.goldGrams ?? 0.0));
    final double monthlyAverageWeight = months.isNotEmpty ? totalGoldWeight / months.length : 0.0;

    // Best Gold Month
    String bestMonth = 'N/A';
    double bestMonthWeight = 0.0;
    for (final entry in monthlyGrams.entries) {
      if (entry.value >= bestMonthWeight) {
        bestMonthWeight = entry.value;
        bestMonth = DateFormat('MMMM').format(entry.key);
      }
    }
    if (bestMonthWeight == 0.0) {
      bestMonth = 'N/A';
    }

    // Determine current rate and daily price change from repository
    final double currentRate = livePrice != null
        ? (purity == '24K' ? livePrice.rate24K : livePrice.rate22K)
        : 0.0;

    final double priceChangeVsPreviousPct = livePrice?.dailyChangePercentage ?? 0.0;

    // Price history points - mapping the input priceHistory list to DateTime keys of the range
    final Map<DateTime, double> priceHistoryPoints = {};
    final conversionFactor = purity == '24K' && livePrice != null && livePrice.rate22K > 0
        ? livePrice.rate24K / livePrice.rate22K
        : 1.0;

    for (int i = 0; i < months.length; i++) {
      final mKey = months[i];
      double rate = currentRate;
      if (priceHistory.isNotEmpty) {
        final histIdx = (priceHistory.length - months.length + i).clamp(0, priceHistory.length - 1);
        rate = priceHistory[histIdx] * conversionFactor;
      }
      priceHistoryPoints[mKey] = rate;
    }

    final List<MonthlyGoldPoint> monthlyGoldAdded = [];
    for (final m in months) {
      final grams = monthlyGrams[m] ?? 0.0;
      final val = monthlyValues[m] ?? 0.0;
      final price = priceHistoryPoints[m] ?? currentRate;
      monthlyGoldAdded.add(MonthlyGoldPoint(
        month: m,
        weight: grams,
        value: val,
        price: price,
      ));
    }

    return GoldAnalyticsResult(
      totalGoldWeight: totalGoldWeight,
      monthlyAverageWeight: monthlyAverageWeight,
      bestMonth: bestMonth,
      bestMonthWeight: bestMonthWeight,
      currentRate: currentRate,
      priceChangeVsPreviousPct: priceChangeVsPreviousPct,
      monthlyGoldAdded: monthlyGoldAdded,
      priceHistoryPoints: priceHistoryPoints,
    );
  }

  static List<String> generateSmartInsights({
    required GoalAnalyticsResult generalResult,
    GoldAnalyticsResult? goldResult,
    bool isGoldMode = false,
  }) {
    final List<String> insights = [];

    if (!isGoldMode) {
      // 1. Saving increase insight
      if (generalResult.savingTrendPct > 5.0) {
        insights.add("Your average monthly saving increased by ${generalResult.savingTrendPct.toStringAsFixed(0)}%.");
      } else if (generalResult.savingTrendPct < -5.0) {
        insights.add("Your average monthly saving decreased by ${generalResult.savingTrendPct.abs().toStringAsFixed(0)}% compared to the first half of the period.");
      }

      // 2. Best saving month insight
      if (generalResult.highestMonth != 'N/A' && generalResult.highestSaving > 0) {
        insights.add("${generalResult.highestMonth} was your strongest saving month with ₹${NumberFormat('#,##,###').format(generalResult.highestSaving)} saved.");
      }

      // 3. Consistency trend insight
      if (generalResult.consistencyScore >= 80) {
        insights.add("Your saving consistency is outstanding (${generalResult.consistencyScore}% score). Keep it up!");
      } else if (generalResult.consistencyScore >= 50) {
        insights.add("Your saving consistency is moderate (${generalResult.consistencyScore}% score). Try setting recurring monthly savings to improve.");
      } else if (generalResult.totalSaved > 0) {
        insights.add("Your savings are inconsistent. Consider setting up smart reminders to make regular contributions.");
      }

      // 4. Contribution highlight
      if (generalResult.goalContributions.isNotEmpty) {
        final top = generalResult.goalContributions.first;
        insights.add("${top.goalName} received most of your contributions (${top.percentage.toStringAsFixed(0)}% of total savings).");
      }
    } else if (goldResult != null) {
      // Gold-specific insights
      if (goldResult.bestMonth != 'N/A' && goldResult.bestMonthWeight > 0) {
        insights.add("Your gold accumulation was highest in ${goldResult.bestMonth} with ${goldResult.bestMonthWeight.toStringAsFixed(2)}g added.");
      }
      if (goldResult.totalGoldWeight > 0) {
        insights.add("You accumulated a total of ${goldResult.totalGoldWeight.toStringAsFixed(2)}g of gold in this period.");
      }
      if (goldResult.priceChangeVsPreviousPct > 0) {
        insights.add("Gold prices increased by ${goldResult.priceChangeVsPreviousPct.toStringAsFixed(1)}% today.");
      } else if (goldResult.priceChangeVsPreviousPct < 0) {
        insights.add("Gold prices fell by ${goldResult.priceChangeVsPreviousPct.abs().toStringAsFixed(1)}% today, representing a potential accumulation opportunity.");
      }
    }

    if (insights.isEmpty) {
      insights.add("Start recording transactions to generate smart savings insights.");
    }

    return insights;
  }
}
