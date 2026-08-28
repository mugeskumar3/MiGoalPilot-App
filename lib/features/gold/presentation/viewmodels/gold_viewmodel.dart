import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/gold/data/repositories/gold_repository.dart';

final goldRepositoryProvider = Provider<GoldRepository>(
  (ref) => MockGoldRepository(),
);

class GoldState {
  final GoldPrice? livePrice;
  final List<double> history;
  final bool isLoading;
  final String? error;
  final double alertThreshold;
  final bool dailyUpdatesEnabled;

  GoldState({
    this.livePrice,
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.alertThreshold = 1.0,
    this.dailyUpdatesEnabled = true,
  });

  GoldState copyWith({
    GoldPrice? livePrice,
    List<double>? history,
    bool? isLoading,
    String? error,
    double? alertThreshold,
    bool? dailyUpdatesEnabled,
  }) {
    return GoldState(
      livePrice: livePrice ?? this.livePrice,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      dailyUpdatesEnabled: dailyUpdatesEnabled ?? this.dailyUpdatesEnabled,
    );
  }
}

class GoldViewModel extends StateNotifier<GoldState> {
  final GoldRepository _repo;

  GoldViewModel(this._repo) : super(GoldState()) {
    loadGoldData();
  }

  Future<void> loadGoldData() async {
    state = state.copyWith(isLoading: true);
    try {
      final price = await _repo.getLivePrice();
      final points = await _repo.getPriceHistory('30D');
      state = state.copyWith(
        isLoading: false,
        livePrice: price,
        history: points,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> changeHistoryRange(String range) async {
    final points = await _repo.getPriceHistory(range);
    state = state.copyWith(history: points);
  }

  void saveAlertSettings(double pct, bool enabled) {
    state = state.copyWith(alertThreshold: pct, dailyUpdatesEnabled: enabled);
  }
}

final goldViewModelProvider = StateNotifierProvider<GoldViewModel, GoldState>((
  ref,
) {
  return GoldViewModel(ref.watch(goldRepositoryProvider));
});
