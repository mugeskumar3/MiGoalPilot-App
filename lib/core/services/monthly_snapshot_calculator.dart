import 'package:intl/intl.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalMonthlyProgress {
  final String goalId;
  final String goalName;
  final GoalType goalType;
  final GoalHealth health;
  final double overallProgress;
  final double monthlyContribution;
  final double progressIncrease; // progress % gained this month

  GoalMonthlyProgress({
    required this.goalId,
    required this.goalName,
    required this.goalType,
    required this.health,
    required this.overallProgress,
    required this.monthlyContribution,
    required this.progressIncrease,
  });
}

class MonthlyAchievement {
  final String emoji;
  final String title;
  final String description;

  MonthlyAchievement({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class MonthlySnapshotResult {
  final DateTime month;
  final double totalSaved;
  final double previousMonthSaved;
  final double percentChange;
  final int goalsFunded;
  final int activeGoals;
  final List<GoalMonthlyProgress> goalProgressList;
  final String? bestPerformingGoalName;
  final String? bestPerformingReason;
  final double averageContribution;
  final List<MonthlyAchievement> achievements;
  final String insight;
  final String recommendation;
  final String? recommendationRoute;
  final String? recommendationLabel;
  final Map<String, double> trendData; // "MMM yyyy" -> amount
  final bool isFutureMonth;
  final bool isFirstMonth;

  MonthlySnapshotResult({
    required this.month,
    required this.totalSaved,
    required this.previousMonthSaved,
    required this.percentChange,
    required this.goalsFunded,
    required this.activeGoals,
    required this.goalProgressList,
    this.bestPerformingGoalName,
    this.bestPerformingReason,
    required this.averageContribution,
    required this.achievements,
    required this.insight,
    required this.recommendation,
    this.recommendationRoute,
    this.recommendationLabel,
    required this.trendData,
    this.isFutureMonth = false,
    this.isFirstMonth = false,
  });
}

class MonthlySnapshotCalculator {
  static MonthlySnapshotResult calculate({
    required List<Goal> goals,
    required List<SavingsTransaction> allTransactions,
    required DateTime selectedMonth,
  }) {
    final now = DateTime.now();
    final monthStart = DateTime(selectedMonth.year, selectedMonth.month, 1);

    // Future month guard
    if (monthStart.isAfter(DateTime(now.year, now.month + 1, 0))) {
      return MonthlySnapshotResult(
        month: selectedMonth,
        totalSaved: 0,
        previousMonthSaved: 0,
        percentChange: 0,
        goalsFunded: 0,
        activeGoals: goals.length,
        goalProgressList: [],
        averageContribution: 0,
        achievements: [],
        insight: 'No activity yet.',
        recommendation: 'Check back when this month arrives.',
        trendData: {},
        isFutureMonth: true,
      );
    }

    // Filter transactions for selected month
    final monthTxs = allTransactions.where((t) =>
        t.date.year == selectedMonth.year &&
        t.date.month == selectedMonth.month &&
        t.amount > 0).toList();

    // Filter transactions for previous month
    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    final prevMonthTxs = allTransactions.where((t) =>
        t.date.year == prevMonth.year &&
        t.date.month == prevMonth.month &&
        t.amount > 0).toList();

    final double totalSaved = monthTxs.fold(0.0, (sum, t) => sum + t.amount);
    final double previousMonthSaved = prevMonthTxs.fold(0.0, (sum, t) => sum + t.amount);
    final bool isFirstMonth = prevMonthTxs.isEmpty && monthTxs.isNotEmpty;

    double percentChange = 0;
    if (previousMonthSaved > 0) {
      percentChange = ((totalSaved - previousMonthSaved) / previousMonthSaved) * 100;
    }

    // Goals funded this month
    final Set<String> fundedGoalIds = monthTxs.map((t) => t.goalId).toSet();
    final int goalsFunded = fundedGoalIds.length;

    // Goal progress breakdown
    final List<GoalMonthlyProgress> goalProgressList = [];
    String? bestGoalName;
    String? bestGoalReason;
    double bestProgressIncrease = -1;

    for (final g in goals) {
      final goalMonthTxs = monthTxs.where((t) => t.goalId == g.id).toList();
      final double monthlyContribution = goalMonthTxs.fold(0.0, (sum, t) => sum + t.amount);

      double progressIncrease = 0;
      if (g.type == GoalType.gold && g.targetGrams > 0) {
        final double gramsThisMonth = goalMonthTxs.fold(0.0, (sum, t) => sum + (t.goldGrams ?? 0.0));
        progressIncrease = (gramsThisMonth / g.targetGrams) * 100;
      } else if (g.targetAmount > 0) {
        progressIncrease = (monthlyContribution / g.targetAmount) * 100;
      }

      goalProgressList.add(GoalMonthlyProgress(
        goalId: g.id,
        goalName: g.name,
        goalType: g.type,
        health: g.health,
        overallProgress: g.progressPercentage,
        monthlyContribution: monthlyContribution,
        progressIncrease: progressIncrease,
      ));

      if (progressIncrease > bestProgressIncrease && monthlyContribution > 0) {
        bestProgressIncrease = progressIncrease;
        bestGoalName = g.name;
        bestGoalReason = '+${progressIncrease.toStringAsFixed(1)}% progress this month';
      }
    }

    // Average contribution
    final double averageContribution = goalsFunded > 0 ? totalSaved / goalsFunded : 0;

    // Achievements
    final List<MonthlyAchievement> achievements = [];

    if (totalSaved > 0 && (previousMonthSaved == 0 || totalSaved > previousMonthSaved)) {
      achievements.add(MonthlyAchievement(
        emoji: '🎉',
        title: 'Highest Monthly Saving',
        description: '₹${NumberFormat('#,##,###').format(totalSaved)} saved this month',
      ));
    }

    if (percentChange > 0 && previousMonthSaved > 0) {
      achievements.add(MonthlyAchievement(
        emoji: '🔥',
        title: 'Saving Streak',
        description: 'Improved ${percentChange.toStringAsFixed(1)}% from last month',
      ));
    }

    // Trend data (last 4 months including selected)
    final Map<String, double> trendData = {};
    for (int i = 3; i >= 0; i--) {
      final m = DateTime(selectedMonth.year, selectedMonth.month - i, 1);
      final label = DateFormat('MMM').format(m);
      final mTxs = allTransactions.where((t) =>
          t.date.year == m.year &&
          t.date.month == m.month &&
          t.amount > 0).toList();
      trendData[label] = mTxs.fold(0.0, (sum, t) => sum + t.amount);
    }

    // Deterministic insight
    String insight;
    if (monthTxs.isEmpty) {
      insight = 'No savings recorded this month.';
    } else if (isFirstMonth) {
      insight = 'Your first month of tracking — great start!';
    } else if (percentChange > 0) {
      insight = 'You saved ${percentChange.toStringAsFixed(1)}% more than ${DateFormat('MMMM').format(prevMonth)}.';
    } else if (percentChange < 0) {
      insight = 'You saved ${percentChange.abs().toStringAsFixed(1)}% less than ${DateFormat('MMMM').format(prevMonth)}.';
    } else if (previousMonthSaved > 0) {
      insight = 'You saved the same amount as ${DateFormat('MMMM').format(prevMonth)}.';
    } else {
      insight = '₹${NumberFormat('#,##,###').format(totalSaved)} saved across $goalsFunded goal${goalsFunded == 1 ? '' : 's'}.';
    }

    if (bestGoalName != null && monthTxs.isNotEmpty) {
      insight += ' $bestGoalName received the highest contribution.';
    }

    // Smart recommendation
    String recommendation;
    String? recommendationRoute;
    String? recommendationLabel;

    // Find weakest goal
    final behindGoals = goalProgressList
        .where((gp) => gp.health == GoalHealth.atRisk || gp.health == GoalHealth.needsAttention)
        .toList();

    if (behindGoals.isNotEmpty) {
      final weakest = behindGoals.first;
      recommendation = 'Your ${weakest.goalName} needs attention. Consider adding extra savings next month.';
      recommendationRoute = weakest.goalType == GoalType.gold ? '/gold-goals/${weakest.goalId}' : '/goals/${weakest.goalId}';
      recommendationLabel = 'View Goal';
    } else if (percentChange > 10) {
      recommendation = 'Great month — keep your current saving pace!';
      recommendationRoute = '/dashboard';
      recommendationLabel = 'View Dashboard';
    } else if (monthTxs.isEmpty) {
      recommendation = 'Start saving this month to build momentum.';
      recommendationRoute = '/goals';
      recommendationLabel = 'View Goals';
    } else {
      recommendation = 'Steady progress. Review your savings plan for next month.';
      recommendationRoute = '/multi-goal';
      recommendationLabel = 'Adjust Savings Plan';
    }

    return MonthlySnapshotResult(
      month: selectedMonth,
      totalSaved: totalSaved,
      previousMonthSaved: previousMonthSaved,
      percentChange: percentChange,
      goalsFunded: goalsFunded,
      activeGoals: goals.length,
      goalProgressList: goalProgressList,
      bestPerformingGoalName: bestGoalName,
      bestPerformingReason: bestGoalReason,
      averageContribution: averageContribution,
      achievements: achievements,
      insight: insight,
      recommendation: recommendation,
      recommendationRoute: recommendationRoute,
      recommendationLabel: recommendationLabel,
      trendData: trendData,
      isFirstMonth: isFirstMonth,
    );
  }
}
