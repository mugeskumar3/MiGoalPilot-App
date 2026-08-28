import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final ThemeMode themeMode;
  final String currency;
  final bool hideBalance;
  final bool appLockEnabled;
  final bool remindersEnabled;
  final bool milestonesEnabled;
  final bool deadlinesEnabled;
  final bool goldAlertsEnabled;

  ProfileState({
    this.themeMode = ThemeMode.system,
    this.currency = 'INR',
    this.hideBalance = false,
    this.appLockEnabled = false,
    this.remindersEnabled = true,
    this.milestonesEnabled = true,
    this.deadlinesEnabled = true,
    this.goldAlertsEnabled = true,
  });

  ProfileState copyWith({
    ThemeMode? themeMode,
    String? currency,
    bool? hideBalance,
    bool? appLockEnabled,
    bool? remindersEnabled,
    bool? milestonesEnabled,
    bool? deadlinesEnabled,
    bool? goldAlertsEnabled,
  }) {
    return ProfileState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      hideBalance: hideBalance ?? this.hideBalance,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      milestonesEnabled: milestonesEnabled ?? this.milestonesEnabled,
      deadlinesEnabled: deadlinesEnabled ?? this.deadlinesEnabled,
      goldAlertsEnabled: goldAlertsEnabled ?? this.goldAlertsEnabled,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel() : super(ProfileState());

  void toggleTheme(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void toggleHideBalance(bool val) {
    state = state.copyWith(hideBalance: val);
  }

  void toggleAppLock(bool val) {
    state = state.copyWith(appLockEnabled: val);
  }

  void toggleReminders(bool val) {
    state = state.copyWith(remindersEnabled: val);
  }

  void toggleMilestones(bool val) {
    state = state.copyWith(milestonesEnabled: val);
  }

  void toggleDeadlines(bool val) {
    state = state.copyWith(deadlinesEnabled: val);
  }

  void toggleGoldAlerts(bool val) {
    state = state.copyWith(goldAlertsEnabled: val);
  }

  void setCurrency(String cur) {
    state = state.copyWith(currency: cur);
  }
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      return ProfileViewModel();
    });
