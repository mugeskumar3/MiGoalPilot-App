import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/repositories/repositories.dart';
import 'package:migoalpilot/core/services/goal_health_calculator.dart';
import 'package:migoalpilot/core/services/smart_savings_planner.dart';
import 'package:migoalpilot/core/services/goal_milestone_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';
import 'package:migoalpilot/core/services/smart_reminder_engine.dart';
import 'package:migoalpilot/core/services/monthly_snapshot_calculator.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);
final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => MockGoalRepository(),
);
final marriageRepositoryProvider = Provider<MarriageRepository>(
  (ref) => MockMarriageRepository(),
);
final goldRepositoryProvider = Provider<GoldRepository>(
  (ref) => MockGoldRepository(),
);
final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => MockAiRepository(),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => MockNotificationRepository(),
);

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthViewModel(this._repo) : super(AuthState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await _repo.getCurrentUser();
    state = AuthState(user: u);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final u = await _repo.login(email, password);
      state = AuthState(user: u);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final u = await _repo.register(name, email, password);
      state = AuthState(user: u);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AuthState();
  }

  Future<void> forgotPassword(String email) async {
    await _repo.forgotPassword(email);
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? country,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final u = await _repo.updateProfile(
        name: name,
        email: email,
        phone: phone,
        country: country,
      );
      state = AuthState(user: u);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});

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

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final AiInsight? dashboardInsight;

  AiState({
    this.messages = const [],
    this.isTyping = false,
    this.dashboardInsight,
  });

  AiState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    AiInsight? dashboardInsight,
  }) {
    return AiState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      dashboardInsight: dashboardInsight ?? this.dashboardInsight,
    );
  }
}

class AiViewModel extends StateNotifier<AiState> {
  final AiRepository _repo;

  AiViewModel(this._repo) : super(AiState()) {
    _loadDashboardInsight();
  }

  Future<void> _loadDashboardInsight() async {
    final ins = await _repo.getDashboardInsight();
    state = state.copyWith(dashboardInsight: ins);
  }

  Future<void> sendMessage(String text) async {
    final newMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, newMsg],
      isTyping: true,
    );

    try {
      final reply = await _repo.sendChatMessage(text);
      final replyMsg = ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, replyMsg],
        isTyping: false,
      );
    } catch (e) {
      final err = ChatMessage(
        text: 'GoalPilot AI is temporarily unavailable. Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, err],
        isTyping: false,
      );
    }
  }

  Future<Map<String, dynamic>> parseGoalCreationQuery(String query) async {
    return await _repo.parseGoalCreationQuery(query);
  }
}

extension on AiRepository {
  Future<Map<String, dynamic>> parseGoalCreationQuery(String query) async {
    return await parseGoalIntent(query);
  }
}

final aiViewModelProvider = StateNotifierProvider<AiViewModel, AiState>((ref) {
  return AiViewModel(ref.watch(aiRepositoryProvider));
});

class NotificationState {
  final List<NotificationItem> items;
  final bool isLoading;

  NotificationState({this.items = const [], this.isLoading = false});

  NotificationState copyWith({List<NotificationItem>? items, bool? isLoading}) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repo;

  NotificationViewModel(this._repo) : super(NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    final list = await _repo.getNotifications();
    state = NotificationState(items: list);
  }

  void markAsRead(String id) {
    final updated = state.items.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(items: updated);
  }

  Future<void> addNotification(NotificationItem item) async {
    await _repo.addNotification(item);
    await loadNotifications();
  }

  void clearAll() {
    state = NotificationState(items: const []);
  }
}

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      return NotificationViewModel(ref.watch(notificationRepositoryProvider));
    });

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
