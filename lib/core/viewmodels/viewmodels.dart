import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

// --- PROVIDERS DECLARATIONS ---
final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());
final goalRepositoryProvider = Provider<GoalRepository>((ref) => MockGoalRepository());
final marriageRepositoryProvider = Provider<MarriageRepository>((ref) => MockMarriageRepository());
final goldRepositoryProvider = Provider<GoldRepository>((ref) => MockGoldRepository());
final aiRepositoryProvider = Provider<AiRepository>((ref) => MockAiRepository());
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => MockNotificationRepository());

// --- VIEWMODEL STATES & NOTIFIERS ---

// Auth State
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
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
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
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});

// Goals State
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
      state = GoalsState(goals: list);
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

final goalsViewModelProvider = StateNotifierProvider<GoalsViewModel, GoalsState>((ref) {
  return GoalsViewModel(ref.watch(goalRepositoryProvider));
});

// Goal Detail State
class GoalDetailState {
  final Goal? goal;
  final List<SavingsTransaction> transactions;
  final bool isLoading;
  final String? error;

  GoalDetailState({this.goal, this.transactions = const [], this.isLoading = false, this.error});

  GoalDetailState copyWith({Goal? goal, List<SavingsTransaction>? transactions, bool? isLoading, String? error}) {
    return GoalDetailState(
      goal: goal ?? this.goal,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GoalDetailViewModel extends StateNotifier<GoalDetailState> {
  final GoalRepository _repo;
  final String _goalId;

  GoalDetailViewModel(this._repo, this._goalId) : super(GoalDetailState()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = state.copyWith(isLoading: true);
    try {
      final g = await _repo.getGoal(_goalId);
      final txs = await _repo.getTransactions(_goalId);
      state = GoalDetailState(goal: g, transactions: txs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addSavingContribution(double amount, String? note, {double? grams}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.addSaving(_goalId, amount, note: note, grams: grams);
      await loadDetails();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final goalDetailViewModelProvider = StateNotifierProvider.family<GoalDetailViewModel, GoalDetailState, String>((ref, id) {
  return GoalDetailViewModel(ref.watch(goalRepositoryProvider), id);
});

// Marriage Planner State
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
      simulatedMonthlyIncrease: simulatedMonthlyIncrease ?? this.simulatedMonthlyIncrease,
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
      // parse result: {"difference": d, "newBudget": nb, "monthlyAdd": ma}
      final diff = double.parse(RegExp(r'"difference":\s*([0-9\.-]+)').firstMatch(res)?.group(1) ?? '0');
      final newB = double.parse(RegExp(r'"newBudget":\s*([0-9\.-]+)').firstMatch(res)?.group(1) ?? '0');
      final monA = double.parse(RegExp(r'"monthlyAdd":\s*([0-9\.-]+)').firstMatch(res)?.group(1) ?? '0');
      
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

final marriageViewModelProvider = StateNotifierProvider<MarriageViewModel, MarriageState>((ref) {
  return MarriageViewModel(
    ref.watch(marriageRepositoryProvider),
    ref.watch(aiRepositoryProvider),
  );
});

// Gold Module State
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
      state = state.copyWith(isLoading: false, livePrice: price, history: points);
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

final goldViewModelProvider = StateNotifierProvider<GoldViewModel, GoldState>((ref) {
  return GoldViewModel(ref.watch(goldRepositoryProvider));
});

// AI Conversation Chat State
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class AiState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final AiInsight? dashboardInsight;

  AiState({this.messages = const [], this.isTyping = false, this.dashboardInsight});

  AiState copyWith({List<ChatMessage>? messages, bool? isTyping, AiInsight? dashboardInsight}) {
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
    final newMsg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, newMsg],
      isTyping: true,
    );

    try {
      final reply = await _repo.sendChatMessage(text);
      final replyMsg = ChatMessage(text: reply, isUser: false, timestamp: DateTime.now());
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

// Notifications ViewModel State
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

  void clearAll() {
    state = NotificationState(items: const []);
  }
}

final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  return NotificationViewModel(ref.watch(notificationRepositoryProvider));
});

// Theme/Preferences Model & Provider
class ProfileState {
  final ThemeMode themeMode;
  final String currency;
  final bool hideBalance;
  final bool appLockEnabled;

  ProfileState({
    this.themeMode = ThemeMode.system,
    this.currency = 'INR',
    this.hideBalance = false,
    this.appLockEnabled = false,
  });

  ProfileState copyWith({
    ThemeMode? themeMode,
    String? currency,
    bool? hideBalance,
    bool? appLockEnabled,
  }) {
    return ProfileState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      hideBalance: hideBalance ?? this.hideBalance,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
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

  void setCurrency(String cur) {
    state = state.copyWith(currency: cur);
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel();
});
