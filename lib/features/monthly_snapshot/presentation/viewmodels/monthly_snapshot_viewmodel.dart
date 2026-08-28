import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/goals/data/repositories/goal_repository.dart';
import 'package:migoalpilot/features/goals/presentation/viewmodels/goals_viewmodel.dart';
import 'package:migoalpilot/features/monthly_snapshot/domain/services/monthly_snapshot_calculator.dart';

class MonthlySnapshotState {
  final DateTime selectedMonth;
  final MonthlySnapshotResult? snapshot;
  final bool isLoading;

  MonthlySnapshotState({
    required this.selectedMonth,
    this.snapshot,
    this.isLoading = false,
  });

  MonthlySnapshotState copyWith({
    DateTime? selectedMonth,
    MonthlySnapshotResult? snapshot,
    bool? isLoading,
  }) {
    return MonthlySnapshotState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MonthlySnapshotViewModel extends StateNotifier<MonthlySnapshotState> {
  final GoalRepository _goalRepo;
  final Ref _ref;

  MonthlySnapshotViewModel(this._goalRepo, this._ref)
      : super(MonthlySnapshotState(selectedMonth: DateTime.now())) {
    _ref.listen(goalsViewModelProvider, (previous, next) {
      loadSnapshot(state.selectedMonth);
    });
    loadSnapshot(state.selectedMonth);
  }

  Future<void> loadSnapshot(DateTime month) async {
    state = state.copyWith(isLoading: true, selectedMonth: month);
    try {
      final goals = _ref.read(goalsViewModelProvider).goals;
      final List<SavingsTransaction> allTransactions = [];
      for (final g in goals) {
        final txs = await _goalRepo.getTransactions(g.id);
        allTransactions.addAll(txs);
      }
      final snapshot = MonthlySnapshotCalculator.calculate(
        goals: goals,
        allTransactions: allTransactions,
        selectedMonth: month,
      );
      state = state.copyWith(snapshot: snapshot, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void changeMonth(int monthsToAdd) {
    final newMonth = DateTime(state.selectedMonth.year, state.selectedMonth.month + monthsToAdd, 1);
    loadSnapshot(newMonth);
  }
}

final monthlySnapshotViewModelProvider =
    StateNotifierProvider<MonthlySnapshotViewModel, MonthlySnapshotState>((ref) {
  return MonthlySnapshotViewModel(
    ref.watch(goalRepositoryProvider),
    ref,
  );
});
