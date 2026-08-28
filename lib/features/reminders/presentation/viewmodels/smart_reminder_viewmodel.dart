import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/goals/data/repositories/goal_repository.dart';
import 'package:migoalpilot/features/goals/presentation/viewmodels/goals_viewmodel.dart';
import 'package:migoalpilot/features/profile/presentation/viewmodels/notification_viewmodel.dart';
import 'package:migoalpilot/features/gold/presentation/viewmodels/gold_viewmodel.dart';
import 'package:migoalpilot/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:migoalpilot/features/reminders/domain/services/smart_reminder_engine.dart';

class SmartReminderState {
  final ReminderResult? activeReminder;
  final bool isLoading;

  SmartReminderState({
    this.activeReminder,
    this.isLoading = false,
  });
}

class SmartReminderViewModel extends StateNotifier<SmartReminderState> {
  final GoalRepository _goalRepo;
  final Ref _ref;

  SmartReminderViewModel(this._goalRepo, this._ref) : super(SmartReminderState()) {
    _ref.listen(goalsViewModelProvider, (previous, next) {
      evaluateReminders();
    });
    _ref.listen(notificationViewModelProvider, (previous, next) {
      evaluateReminders();
    });
    _ref.listen(goldViewModelProvider, (previous, next) {
      evaluateReminders();
    });
    _ref.listen(profileViewModelProvider, (previous, next) {
      evaluateReminders();
    });

    evaluateReminders();
  }

  Future<void> evaluateReminders() async {
    final goals = _ref.read(goalsViewModelProvider).goals;
    if (goals.isEmpty) {
      state = SmartReminderState(activeReminder: null);
      return;
    }

    final notifs = _ref.read(notificationViewModelProvider).items;
    final goldState = _ref.read(goldViewModelProvider);
    final profileState = _ref.read(profileViewModelProvider);

    final Map<String, List<SavingsTransaction>> transactionsMap = {};
    for (final g in goals) {
      transactionsMap[g.id] = await _goalRepo.getTransactions(g.id);
    }

    final settings = {
      'remindersEnabled': profileState.remindersEnabled,
      'milestonesEnabled': profileState.milestonesEnabled,
      'deadlinesEnabled': profileState.deadlinesEnabled,
      'goldAlertsEnabled': profileState.goldAlertsEnabled,
    };

    final reminder = SmartReminderEngine.evaluate(
      goals: goals,
      transactionsMap: transactionsMap,
      settings: settings,
      notificationHistory: notifs,
      currentGold22KPrice: goldState.livePrice?.rate22K,
      recentGold22KTrackedPrice: goldState.livePrice != null ? goldState.livePrice!.rate22K * 1.014 : null,
    );

    state = SmartReminderState(activeReminder: reminder);
  }
}

final smartReminderViewModelProvider =
    StateNotifierProvider<SmartReminderViewModel, SmartReminderState>((ref) {
  return SmartReminderViewModel(
    ref.watch(goalRepositoryProvider),
    ref,
  );
});
