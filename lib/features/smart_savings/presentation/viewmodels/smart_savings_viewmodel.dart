import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/goals/data/repositories/goal_repository.dart';
import 'package:migoalpilot/features/goals/presentation/viewmodels/goals_viewmodel.dart';
import 'package:migoalpilot/features/smart_savings/domain/services/smart_savings_planner.dart';

class SmartSavingsPlanState {
  final List<Goal> goals;
  final Map<String, double> allocations;
  final double totalCapacity;
  final Map<String, DateTime?> projectedCompletionDates;
  final Map<String, int> simulatedHealthScores;
  final String recommendationText;
  final bool isLoading;
  final String? error;

  SmartSavingsPlanState({
    this.goals = const [],
    this.allocations = const {},
    this.totalCapacity = 0.0,
    this.projectedCompletionDates = const {},
    this.simulatedHealthScores = const {},
    this.recommendationText = '',
    this.isLoading = false,
    this.error,
  });

  SmartSavingsPlanState copyWith({
    List<Goal>? goals,
    Map<String, double>? allocations,
    double? totalCapacity,
    Map<String, DateTime?>? projectedCompletionDates,
    Map<String, int>? simulatedHealthScores,
    String? recommendationText,
    bool? isLoading,
    String? error,
  }) {
    return SmartSavingsPlanState(
      goals: goals ?? this.goals,
      allocations: allocations ?? this.allocations,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      projectedCompletionDates:
          projectedCompletionDates ?? this.projectedCompletionDates,
      simulatedHealthScores:
          simulatedHealthScores ?? this.simulatedHealthScores,
      recommendationText: recommendationText ?? this.recommendationText,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SmartSavingsPlanViewModel extends StateNotifier<SmartSavingsPlanState> {
  final GoalRepository _repo;

  SmartSavingsPlanViewModel(this._repo) : super(SmartSavingsPlanState()) {
    initPlan();
  }

  Future<void> initPlan() async {
    state = state.copyWith(isLoading: true);
    try {
      final goals = await _repo.getGoals();
      final transactionsMap = <String, List<SavingsTransaction>>{};
      for (final g in goals) {
        transactionsMap[g.id] = await _repo.getTransactions(g.id);
      }

      final defaultPlan = SmartSavingsPlanner.calculateDefaultPlan(goals);
      final allocations = defaultPlan.defaultAllocations;
      final totalCapacity = defaultPlan.recommendedTotalMonthly;

      final projections = SmartSavingsPlanner.recalculateProjections(
        goals: goals,
        allocations: allocations,
      );

      final healthScores = SmartSavingsPlanner.recalculateHealthScores(
        goals: goals,
        allocations: allocations,
        transactionsMap: transactionsMap,
      );

      final recText = _generateRecommendation(goals, allocations, projections);

      state = SmartSavingsPlanState(
        goals: goals,
        allocations: allocations,
        totalCapacity: totalCapacity,
        projectedCompletionDates: projections,
        simulatedHealthScores: healthScores,
        recommendationText: recText,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateAllocation(String goalId, double newValue) {
    final updatedAllocations = SmartSavingsPlanner.rebalanceAllocations(
      currentAllocations: state.allocations,
      changedGoalId: goalId,
      newValue: newValue,
      totalCapacity: state.totalCapacity,
    );

    _recalculate(updatedAllocations);
  }

  Future<void> _recalculate(Map<String, double> updatedAllocations) async {
    final goals = state.goals;
    final transactionsMap = <String, List<SavingsTransaction>>{};
    for (final g in goals) {
      transactionsMap[g.id] = await _repo.getTransactions(g.id);
    }

    final projections = SmartSavingsPlanner.recalculateProjections(
      goals: goals,
      allocations: updatedAllocations,
    );

    final healthScores = SmartSavingsPlanner.recalculateHealthScores(
      goals: goals,
      allocations: updatedAllocations,
      transactionsMap: transactionsMap,
    );

    final recText = _generateRecommendation(
      goals,
      updatedAllocations,
      projections,
    );

    state = state.copyWith(
      allocations: updatedAllocations,
      projectedCompletionDates: projections,
      simulatedHealthScores: healthScores,
      recommendationText: recText,
    );
  }

  String _generateRecommendation(
    List<Goal> goals,
    Map<String, double> allocations,
    Map<String, DateTime?> projections,
  ) {
    if (goals.isEmpty) return "No active goals found.";

    final List<String> issues = [];
    for (final g in goals) {
      final alloc = allocations[g.id] ?? 0.0;
      final proj = projections[g.id];
      if (alloc <= 0) {
        issues.add("${g.name} is currently paused.");
      } else if (proj != null && proj.isAfter(g.targetDate)) {
        issues.add("The deadline for ${g.name} may be difficult to reach.");
      }
    }

    if (issues.isNotEmpty) {
      return "⚠️ Plan Warning: ${issues.join(' ')} Try adjusting allocations to prioritize closer deadlines.";
    }

    return "✓ On track! Your allocations cover the recommended required rates. You're set to reach your dreams.";
  }

  Future<void> savePlan() async {
    state = state.copyWith(isLoading: true);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final smartSavingsPlanViewModelProvider =
    StateNotifierProvider<SmartSavingsPlanViewModel, SmartSavingsPlanState>((
      ref,
    ) {
      return SmartSavingsPlanViewModel(ref.watch(goalRepositoryProvider));
    });
