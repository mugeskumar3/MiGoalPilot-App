import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/repositories/repositories.dart';
import 'package:migoalpilot/core/viewmodels/goal_analytics_state.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/goal_analytics_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

class GoalAnalyticsViewModel extends StateNotifier<GoalAnalyticsState> {
  final GoalRepository _goalRepo;
  final GoldRepository _goldRepo;

  GoalAnalyticsViewModel(this._goalRepo, this._goldRepo) : super(GoalAnalyticsState()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Fetch goals and compile all transactions
      final goals = await _goalRepo.getGoals();
      final List<SavingsTransaction> allTransactions = [];
      for (final g in goals) {
        final txs = await _goalRepo.getTransactions(g.id);
        allTransactions.addAll(txs);
      }

      // 2. Fetch gold data
      final livePrice = await _goldRepo.getLivePrice();
      // Fetch 60D history to have enough historical data points
      final priceHistory = await _goldRepo.getPriceHistory('60D');

      // 3. Determine start and end date of range
      final now = DateTime.now();
      DateTime start = DateTime(now.year, now.month - 5, 1);
      DateTime end = DateTime(now.year, now.month, 1);

      switch (state.range) {
        case AnalyticsRange.threeMonths:
          start = DateTime(now.year, now.month - 2, 1);
          break;
        case AnalyticsRange.sixMonths:
          start = DateTime(now.year, now.month - 5, 1);
          break;
        case AnalyticsRange.twelveMonths:
          start = DateTime(now.year, now.month - 11, 1);
          break;
        case AnalyticsRange.custom:
          start = state.customStartDate ?? DateTime(now.year, now.month - 5, 1);
          end = state.customEndDate ?? DateTime(now.year, now.month, 1);
          break;
      }

      // 4. Calculate general metrics
      final generalResult = GoalAnalyticsCalculator.calculate(
        goals: goals,
        allTransactions: allTransactions,
        rangeStart: start,
        rangeEnd: end,
        filterGoalType: state.selectedGoalType,
        filterGoalId: state.selectedGoalId,
      );

      // 5. Calculate gold metrics if gold goal exists
      final goldGoal = goals.firstWhere(
        (g) => g.type == GoalType.gold,
        orElse: () => Goal(
          id: 'g_gold',
          name: 'Gold Accumulation',
          type: GoalType.gold,
          targetAmount: 0,
          currentSavings: 0,
          targetDate: DateTime.now(),
          priority: GoalPriority.medium,
          health: GoalHealth.paused,
        ),
      );

      final goldTransactions = allTransactions.where((t) => t.goalId == goldGoal.id).toList();
      final goldResult = GoalAnalyticsCalculator.calculateGold(
        goldGoal: goldGoal,
        transactions: goldTransactions,
        rangeStart: start,
        rangeEnd: end,
        livePrice: livePrice,
        priceHistory: priceHistory,
        purity: state.goldPurity,
      );

      // 6. Generate deterministic insights
      final isGoldMode = state.selectedGoalType == GoalType.gold || state.selectedGoalId == goldGoal.id;
      final insights = GoalAnalyticsCalculator.generateSmartInsights(
        generalResult: generalResult,
        goldResult: goldResult,
        isGoldMode: isGoldMode,
      );

      state = state.copyWith(
        isLoading: false,
        generalResult: generalResult,
        goldResult: goldResult,
        insights: insights,
        customStartDate: start,
        customEndDate: end,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setRange(AnalyticsRange newRange, {DateTime? start, DateTime? end}) {
    state = state.copyWith(
      range: newRange,
      customStartDate: start,
      customEndDate: end,
    );
    loadAnalytics();
  }

  void setGoalFilter(GoalType? type, String? id) {
    if (type == null && id == null) {
      // Clear filters
      state = state.copyWith(
        clearGoalId: true,
        clearGoalType: true,
      );
    } else {
      state = state.copyWith(
        selectedGoalType: type,
        selectedGoalId: id,
        clearGoalId: id == null,
        clearGoalType: type == null,
      );
    }
    loadAnalytics();
  }

  void setGoldPurity(String purity) {
    state = state.copyWith(goldPurity: purity);
    loadAnalytics();
  }

  void setGoldChartMetric(String metric) {
    state = state.copyWith(goldChartMetric: metric);
    // Calculations remain same, only chart representation changes
  }
}

final goalAnalyticsViewModelProvider =
    StateNotifierProvider<GoalAnalyticsViewModel, GoalAnalyticsState>((ref) {
  return GoalAnalyticsViewModel(
    ref.watch(goalRepositoryProvider),
    ref.watch(goldRepositoryProvider),
  );
});
