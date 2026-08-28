import 'dart:async';
import 'dart:math';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<Goal> getGoal(String id);
  Future<Goal> createGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<List<SavingsTransaction>> getTransactions(String goalId);
  Future<SavingsTransaction> addSaving(String goalId, double amount, {String? note, double? grams});
}

class MockGoalRepository implements GoalRepository {
  final List<Goal> _goals = [
    Goal(
      id: 'g_marriage',
      name: 'Wedding Ceremony',
      type: GoalType.marriage,
      targetAmount: 1050000,
      currentSavings: 450000,
      targetDate: DateTime.now().add(const Duration(days: 540)),
      priority: GoalPriority.critical,
      health: GoalHealth.onTrack,
      isShared: true,
    ),
    Goal(
      id: 'g_gold',
      name: 'Marriage Jewellery',
      type: GoalType.gold,
      targetAmount: 250000,
      currentSavings: 93750,
      targetDate: DateTime.now().add(const Duration(days: 365)),
      priority: GoalPriority.high,
      health: GoalHealth.onTrack,
      targetGrams: 20.0,
      purchasedGrams: 7.5,
    ),
    Goal(
      id: 'g_house',
      name: 'House Downpayment',
      type: GoalType.house,
      targetAmount: 1000000,
      currentSavings: 210000,
      targetDate: DateTime.now().add(const Duration(days: 730)),
      priority: GoalPriority.high,
      health: GoalHealth.needsAttention,
    ),
    Goal(
      id: 'g_travel',
      name: 'Europe Flight & Trip',
      type: GoalType.travel,
      targetAmount: 150000,
      currentSavings: 450000 / 10,
      targetDate: DateTime.now().add(const Duration(days: 90)),
      priority: GoalPriority.low,
      health: GoalHealth.atRisk,
    ),
  ];

  final List<SavingsTransaction> _transactions = [
    SavingsTransaction(
      id: 't_1',
      goalId: 'g_marriage',
      amount: 10000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      note: 'Monthly savings salary deposit',
    ),
    SavingsTransaction(
      id: 't_2',
      goalId: 'g_gold',
      amount: 5000,
      date: DateTime.now().subtract(const Duration(days: 4)),
      note: 'Bought 0.4g gold',
      goldGrams: 0.4,
    ),
    SavingsTransaction(
      id: 't_3',
      goalId: 'g_house',
      amount: 15000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: 'Bonus savings allocation',
    ),
  ];

  @override
  Future<List<Goal>> getGoals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_goals);
  }

  @override
  Future<Goal> getGoal(String id) async {
    return _goals.firstWhere((g) => g.id == id);
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    _goals.add(goal);
    return goal;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _goals[idx] = goal;
    }
    return goal;
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
  }

  @override
  Future<List<SavingsTransaction>> getTransactions(String goalId) async {
    return _transactions.where((t) => t.goalId == goalId).toList();
  }

  @override
  Future<SavingsTransaction> addSaving(String goalId, double amount, {String? note, double? grams}) async {
    final tx = SavingsTransaction(
      id: 't_${Random().nextInt(10000)}',
      goalId: goalId,
      amount: amount,
      date: DateTime.now(),
      note: note,
      goldGrams: grams,
    );
    _transactions.add(tx);

    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final old = _goals[idx];
      _goals[idx] = old.copyWith(
        currentSavings: old.currentSavings + amount,
        purchasedGrams: grams != null ? old.purchasedGrams + grams : old.purchasedGrams,
      );
    }
    return tx;
  }
}
