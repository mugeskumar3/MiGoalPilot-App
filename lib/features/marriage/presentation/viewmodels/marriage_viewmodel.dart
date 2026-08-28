import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/marriage/data/repositories/marriage_repository.dart';
import 'package:migoalpilot/features/ai/data/repositories/ai_repository.dart';
import 'package:migoalpilot/features/ai/presentation/viewmodels/ai_viewmodel.dart';

final marriageRepositoryProvider = Provider<MarriageRepository>(
  (ref) => MockMarriageRepository(),
);


class MarriageState {
  final MarriagePlan? plan;
  final bool isLoading;
  final String? error;
  final double simulatedDiff;
  final double simulatedBudget;
  final double simulatedMonthlyIncrease;

  MarriageState({
    this.plan,
    this.isLoading = false,
    this.error,
    this.simulatedDiff = 0,
    this.simulatedBudget = 0,
    this.simulatedMonthlyIncrease = 0,
  });

  MarriageState copyWith({
    MarriagePlan? plan,
    bool? isLoading,
    String? error,
    double? simulatedDiff,
    double? simulatedBudget,
    double? simulatedMonthlyIncrease,
  }) {
    return MarriageState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      simulatedDiff: simulatedDiff ?? this.simulatedDiff,
      simulatedBudget: simulatedBudget ?? this.simulatedBudget,
      simulatedMonthlyIncrease:
          simulatedMonthlyIncrease ?? this.simulatedMonthlyIncrease,
    );
  }
}

class MarriageViewModel extends StateNotifier<MarriageState> {
  final MarriageRepository _repo;
  final AiRepository _aiRepo;

  MarriageViewModel(this._repo, this._aiRepo) : super(MarriageState()) {
    loadMarriagePlan();
  }

  Future<void> loadMarriagePlan() async {
    state = state.copyWith(isLoading: true);
    try {
      final p = await _repo.getPlan();
      state = MarriageState(plan: p);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateBudget(double amount) async {
    final p = await _repo.updateBudget(amount);
    state = state.copyWith(plan: p);
  }

  Future<void> updateItem(BudgetItem item) async {
    final p = await _repo.updateBudgetItem(item);
    state = state.copyWith(plan: p);
  }

  Future<void> toggleTask(String id, bool val) async {
    final p = await _repo.toggleTimelineTask(id, val);
    state = state.copyWith(plan: p);
  }

  Future<void> runGuestWhatIfSimulator(int guests) async {
    state = state.copyWith(isLoading: true);
    try {
      final currentBudget = state.plan?.totalBudget ?? 1050000;
      final res = await _aiRepo.simulateWhatIf(guests, currentBudget);
      final diff = double.parse(
        RegExp(r'"difference":\s*([0-9\.-]+)').firstMatch(res)?.group(1) ?? '0',
      );
      final newB = double.parse(
        RegExp(r'"newBudget":\s*([0-9\.-]+)').firstMatch(res)?.group(1) ?? '0',
      );
      final monA = double.parse(
        RegExp(r'"monthlyAdd":\s*([0-9\.-]+)').firstMatch(res)?.group(1) ?? '0',
      );

      state = state.copyWith(
        isLoading: false,
        simulatedDiff: diff,
        simulatedBudget: newB,
        simulatedMonthlyIncrease: monA,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final marriageViewModelProvider =
    StateNotifierProvider<MarriageViewModel, MarriageState>((ref) {
      return MarriageViewModel(
        ref.watch(marriageRepositoryProvider),
        ref.watch(aiRepositoryProvider),
      );
    });
