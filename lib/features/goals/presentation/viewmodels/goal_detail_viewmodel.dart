import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:migoalpilot/features/goals/data/repositories/goal_repository.dart';
import 'package:migoalpilot/features/goals/presentation/viewmodels/goals_viewmodel.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_health_calculator.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_milestone_calculator.dart';
import 'package:migoalpilot/features/profile/data/repositories/notification_repository.dart';
import 'package:migoalpilot/features/profile/presentation/viewmodels/notification_viewmodel.dart';

class GoalDetailState {
  final Goal? goal;
  final List<SavingsTransaction> transactions;
  final bool isLoading;
  final String? error;
  final GoalMilestone? newlyUnlockedMilestone;

  GoalDetailState({
    this.goal,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.newlyUnlockedMilestone,
  });

  GoalDetailState copyWith({
    Goal? goal,
    List<SavingsTransaction>? transactions,
    bool? isLoading,
    String? error,
    GoalMilestone? newlyUnlockedMilestone,
    bool clearCelebration = false,
  }) {
    return GoalDetailState(
      goal: goal ?? this.goal,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      newlyUnlockedMilestone: clearCelebration
          ? null
          : (newlyUnlockedMilestone ?? this.newlyUnlockedMilestone),
    );
  }
}

class GoalDetailViewModel extends StateNotifier<GoalDetailState> {
  final GoalRepository _repo;
  final NotificationRepository _notifRepo;
  final String _goalId;

  GoalDetailViewModel(this._repo, this._notifRepo, this._goalId)
    : super(GoalDetailState()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = state.copyWith(isLoading: true);
    try {
      final g = await _repo.getGoal(_goalId);
      final txs = await _repo.getTransactions(_goalId);
      final healthResult = GoalHealthCalculator.calculate(g, txs);

      // Dynamic milestone calculation
      final milestones = GoalMilestoneCalculator.calculateMilestones(g, txs);

      // Check for newly achieved milestones
      GoalMilestone? newlyUnlocked;
      final List<int> newlyCompletedList = List.from(g.completedMilestones);

      for (final m in milestones) {
        if (m.completed && !g.completedMilestones.contains(m.percentage)) {
          newlyCompletedList.add(m.percentage);
          newlyUnlocked = m;

          final notif = NotificationItem(
            id: 'm_${g.id}_${m.percentage}',
            title: 'Milestone Reached!',
            message:
                '🎉 You\'ve reached ${m.percentage}% of your ${g.name}! ${g.type == GoalType.gold ? "${m.targetAmount.toStringAsFixed(2)}g" : "₹${m.targetAmount.toStringAsFixed(0)}"} saved.',
            timestamp: DateTime.now(),
            deepLink: g.type == GoalType.gold ? '/gold-goals/${g.id}' : '/goals/${g.id}',
          );
          await _notifRepo.addNotification(notif);
        }
      }

      final updatedGoal = g.copyWith(
        health: healthResult.status,
        healthScore: healthResult.score,
        completedMilestones: newlyCompletedList,
      );

      if (newlyUnlocked != null) {
        await _repo.updateGoal(updatedGoal);
      }

      state = GoalDetailState(
        goal: updatedGoal,
        transactions: txs,
        newlyUnlockedMilestone: newlyUnlocked,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearCelebration() {
    state = state.copyWith(clearCelebration: true);
  }

  Future<void> addSavingContribution(
    double amount,
    String? note, {
    double? grams,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.addSaving(_goalId, amount, note: note, grams: grams);
      await loadDetails();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final goalDetailViewModelProvider =
    StateNotifierProvider.family<GoalDetailViewModel, GoalDetailState, String>((
      ref,
      id,
    ) {
      return GoalDetailViewModel(
        ref.watch(goalRepositoryProvider),
        ref.watch(notificationRepositoryProvider),
        id,
      );
    });
