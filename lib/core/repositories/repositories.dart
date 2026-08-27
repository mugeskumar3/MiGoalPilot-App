import 'dart:async';
import 'dart:math';
import 'package:migoalpilot_app/core/models/models.dart';
import 'package:migoalpilot_app/shared/enums/enums.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<User> updateProfile({required String name, required String email, String? phone, String? country});
}

class MockAuthRepository implements AuthRepository {
  User? _currentUser = User(
    id: 'usr_1',
    name: 'Mugesh R',
    email: 'mugesh@example.com',
    partnerId: 'partner_1',
    phone: '+91 98765 43210',
    country: 'India',
  );

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.contains('error')) {
      throw Exception('Invalid credentials or account does not exist.');
    }
    _currentUser = User(
      id: 'usr_1',
      name: email.split('@')[0].toUpperCase(),
      email: email,
      partnerId: 'partner_1',
      phone: '+91 98765 43210',
      country: 'India',
    );
    return _currentUser!;
  }

  @override
  Future<User> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = User(
      id: 'usr_${Random().nextInt(1000)}',
      name: name,
      email: email,
      phone: '',
      country: 'India',
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User> updateProfile({required String name, required String email, String? phone, String? country}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_currentUser == null) {
      throw Exception('Not authenticated');
    }
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      country: country,
    );
    return _currentUser!;
  }
}

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

abstract class MarriageRepository {
  Future<MarriagePlan> getPlan();
  Future<MarriagePlan> updateBudget(double total);
  Future<MarriagePlan> updateBudgetItem(BudgetItem item);
  Future<MarriagePlan> toggleTimelineTask(String taskId, bool isCompleted);
}

class MockMarriageRepository implements MarriageRepository {
  MarriagePlan? _plan;

  MarriagePlan _initPlan() {
    _plan ??= MarriagePlan(
      totalBudget: 1050000,
      budgetItems: [
        BudgetItem(id: 'b1', category: 'Venue', estimatedCost: 300000, actualSpent: 50000),
        BudgetItem(id: 'b2', category: 'Food & Catering', estimatedCost: 250000, actualSpent: 0),
        BudgetItem(id: 'b3', category: 'Jewellery', estimatedCost: 200000, actualSpent: 75000),
        BudgetItem(id: 'b4', category: 'Photography', estimatedCost: 80000, actualSpent: 10000),
        BudgetItem(id: 'b5', category: 'Clothing & Attire', estimatedCost: 70000, actualSpent: 15000),
        BudgetItem(id: 'b6', category: 'Decoration & Stage', estimatedCost: 60000, actualSpent: 0),
        BudgetItem(id: 'b7', category: 'Travel & Honeymoon', estimatedCost: 50000, actualSpent: 0),
        BudgetItem(id: 'b8', category: 'Accommodation', estimatedCost: 20000, actualSpent: 0),
        BudgetItem(id: 'b9', category: 'Invitations & Gift Cards', estimatedCost: 10000, actualSpent: 2000),
        BudgetItem(id: 'b10', category: 'Emergency Buffer', estimatedCost: 10000, actualSpent: 0),
      ],
      timelineTasks: [
        TimelineTask(id: 'task1', title: 'Book Venue', deadline: DateTime.now().add(const Duration(days: 30)), isCompleted: true, category: 'Venue'),
        TimelineTask(id: 'task2', title: 'Confirm Catering Menu', deadline: DateTime.now().add(const Duration(days: 60)), category: 'Food & Catering'),
        TimelineTask(id: 'task3', title: 'Finalize Jewellery Purchases', deadline: DateTime.now().add(const Duration(days: 90)), isCompleted: false, category: 'Jewellery'),
        TimelineTask(id: 'task4', title: 'Hire Photographer/Videographer', deadline: DateTime.now().add(const Duration(days: 120)), category: 'Photography'),
      ],
    );
    return _plan!;
  }

  @override
  Future<MarriagePlan> getPlan() async {
    return _initPlan();
  }

  @override
  Future<MarriagePlan> updateBudget(double total) async {
    final p = _initPlan();
    _plan = p.copyWith(totalBudget: total);
    return _plan!;
  }

  @override
  Future<MarriagePlan> updateBudgetItem(BudgetItem item) async {
    final p = _initPlan();
    final items = List<BudgetItem>.from(p.budgetItems);
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      items[idx] = item;
    }
    _plan = p.copyWith(budgetItems: items);
    return _plan!;
  }

  @override
  Future<MarriagePlan> toggleTimelineTask(String taskId, bool isCompleted) async {
    final p = _initPlan();
    final tasks = List<TimelineTask>.from(p.timelineTasks);
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      tasks[idx] = tasks[idx].copyWith(isCompleted: isCompleted);
    }
    _plan = p.copyWith(timelineTasks: tasks);
    return _plan!;
  }
}

abstract class GoldRepository {
  Future<GoldPrice> getLivePrice();
  Future<List<double>> getPriceHistory(String range);
}

class MockGoldRepository implements GoldRepository {
  @override
  Future<GoldPrice> getLivePrice() async {
    return GoldPrice(
      rate22K: 12500,
      rate24K: 13640,
      dailyChangePercentage: -1.2,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<List<double>> getPriceHistory(String range) async {
    const basePrice = 12500.0;
    final points = range == '7D' ? 7 : range == '30D' ? 30 : 60;
    final rand = Random();
    return List.generate(points, (idx) {
      final change = (rand.nextDouble() - 0.52) * 300;
      return basePrice + (idx * change);
    });
  }
}

abstract class AiRepository {
  Future<AiInsight> getDashboardInsight();
  Future<Map<String, dynamic>> parseGoalIntent(String query);
  Future<String> simulateWhatIf(int newGuestCount, double previousBudget);
  Future<String> sendChatMessage(String message);
}

class MockAiRepository implements AiRepository {
  @override
  Future<AiInsight> getDashboardInsight() async {
    return AiInsight(
      id: 'insight_1',
      title: 'Savings Pace Alert',
      description: 'You\'re ₹2,500 ahead of your monthly savings target. Keep your current pace and you may reach your goal earlier.',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>> parseGoalIntent(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    final q = query.toLowerCase();
    if (q.contains('car')) {
      return {
        'name': 'New SUV Car',
        'type': GoalType.car.name,
        'targetAmount': 800000.0,
        'months': 24,
        'monthlySavingsNeeded': 33333.0,
      };
    } else if (q.contains('laptop')) {
      return {
        'name': 'MacBook Pro',
        'type': GoalType.laptop.name,
        'targetAmount': 150000.0,
        'months': 6,
        'monthlySavingsNeeded': 25000.0,
      };
    } else {
      return {
        'name': 'Custom Plan',
        'type': GoalType.custom.name,
        'targetAmount': 500000.0,
        'months': 12,
        'monthlySavingsNeeded': 41666.0,
      };
    }
  }

  @override
  Future<String> simulateWhatIf(int newGuestCount, double previousBudget) async {
    await Future.delayed(const Duration(milliseconds: 500));
    const costPerGuest = 600.0;
    final difference = (newGuestCount - 300) * costPerGuest;
    final total = previousBudget + difference;
    final monthlyAdd = difference / 18.0;
    return '{"difference": $difference, "newBudget": $total, "monthlyAdd": $monthlyAdd}';
  }

  @override
  Future<String> sendChatMessage(String message) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final m = message.toLowerCase();
    if (m.contains('afford') || m.contains('multiple')) {
      return 'Your current plan uses ₹40,000/month across Marriage, Gold, and House. Adding another goal right now exceeds your estimated available budget of ₹45,000/month. Recommending: Extend the Laptop deadline from 6 to 12 months, or reduce travel allocation.';
    }
    if (m.contains('marriage') || m.contains('wedding')) {
      return 'To optimize your Marriage Plan, consider reducing the decoration budget by 10% and prioritizing the catering booking now as food costs tend to inflate closer to winter dates.';
    }
    return 'GoalPilot AI: I recommend looking at your gold purchases today. Gold is down 1.2%, giving you a potential opportunity to buy 2.5g cheaper than last week.';
  }
}

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotifications();
}

class MockNotificationRepository implements NotificationRepository {
  final List<NotificationItem> _list = [
    NotificationItem(
      id: 'n1',
      title: 'Gold Price Alert',
      message: 'Gold fell 1.4% today. Potential opportunity detected.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      deepLink: '/gold',
    ),
    NotificationItem(
      id: 'n2',
      title: 'Savings Reminder',
      message: '₹2,500 is due this week for your Europe flight goal.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      deepLink: '/goals/g_travel',
    ),
    NotificationItem(
      id: 'n3',
      title: 'AI Insight',
      message: 'Your House Downpayment goal needs attention. Savings are behind schedule.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      deepLink: '/goals/g_house',
    ),
    NotificationItem(
      id: 'n4',
      title: 'Milestone Reached!',
      message: 'Wedding Ceremony reached 40% of its target. Keep flying high! ✈️',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      deepLink: '/goals/g_marriage',
    ),
  ];

  @override
  Future<List<NotificationItem>> getNotifications() async {
    return _list;
  }
}
