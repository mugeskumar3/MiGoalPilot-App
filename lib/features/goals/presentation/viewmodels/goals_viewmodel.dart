import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/goals/data/repositories/goal_repository.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_health_calculator.dart';

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => MockGoalRepository(),
);

class GoalsState {
  final List<Goal> goals;
  final bool isLoading;
  final String? error;

  GoalsState({this.goals = const [], this.isLoading = false, this.error});

  GoalsState copyWith({List<Goal>? goals, bool? isLoading, String? error}) {
    return GoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GoalsViewModel extends StateNotifier<GoalsState> {
  final GoalRepository _repo;

  GoalsViewModel(this._repo) : super(GoalsState()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repo.getGoals();
      final updatedGoals = <Goal>[];
      for (final g in list) {
        final txs = await _repo.getTransactions(g.id);
        final healthResult = GoalHealthCalculator.calculate(g, txs);
        updatedGoals.add(
          g.copyWith(
            health: healthResult.status,
            healthScore: healthResult.score,
          ),
        );
      }
      state = GoalsState(goals: updatedGoals);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addGoal(Goal g) async {
    await _repo.createGoal(g);
    await loadGoals();
  }

  Future<void> updateGoal(Goal g) async {
    await _repo.updateGoal(g);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _repo.deleteGoal(id);
    await loadGoals();
  }
}

final goalsViewModelProvider =
    StateNotifierProvider<GoalsViewModel, GoalsState>((ref) {
      return GoalsViewModel(ref.watch(goalRepositoryProvider));
    });
