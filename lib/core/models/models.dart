import 'package:migoalpilot/shared/enums/enums.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? partnerId;
  final String? phone;
  final String? country;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.partnerId,
    this.phone,
    this.country,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? partnerId,
    String? phone,
    String? country,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      partnerId: partnerId ?? this.partnerId,
      phone: phone ?? this.phone,
      country: country ?? this.country,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      partnerId: json['partnerId'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'partnerId': partnerId,
        'phone': phone,
        'country': country,
      };
}

class Goal {
  final String id;
  final String name;
  final GoalType type;
  final double targetAmount;
  final double currentSavings;
  final DateTime targetDate;
  final GoalPriority priority;
  final GoalHealth health;
  final double targetGrams;
  final double purchasedGrams;
  final bool isShared;
  final int healthScore;
  final List<int> completedMilestones;

  Goal({
    required this.id,
    required this.name,
    required this.type,
    required this.targetAmount,
    required this.currentSavings,
    required this.targetDate,
    required this.priority,
    required this.health,
    this.targetGrams = 0.0,
    this.purchasedGrams = 0.0,
    this.isShared = false,
    this.healthScore = 100,
    this.completedMilestones = const [],
  });

  double get progressPercentage {
    if (type == GoalType.gold) {
      if (targetGrams <= 0) return 0.0;
      return (purchasedGrams / targetGrams).clamp(0.0, 1.0);
    }
    if (targetAmount <= 0) return 0.0;
    return (currentSavings / targetAmount).clamp(0.0, 1.0);
  }

  Goal copyWith({
    String? id,
    String? name,
    GoalType? type,
    double? targetAmount,
    double? currentSavings,
    DateTime? targetDate,
    GoalPriority? priority,
    GoalHealth? health,
    double? targetGrams,
    double? purchasedGrams,
     bool? isShared,
    int? healthScore,
    List<int>? completedMilestones,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSavings: currentSavings ?? this.currentSavings,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      health: health ?? this.health,
      targetGrams: targetGrams ?? this.targetGrams,
      purchasedGrams: purchasedGrams ?? this.purchasedGrams,
      isShared: isShared ?? this.isShared,
      healthScore: healthScore ?? this.healthScore,
      completedMilestones: completedMilestones ?? this.completedMilestones,
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentSavings: (json['currentSavings'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      priority: GoalPriority.values.firstWhere((e) => e.name == json['priority']),
      health: GoalHealth.values.firstWhere((e) => e.name == json['health']),
      targetGrams: (json['targetGrams'] ?? 0.0 as num).toDouble(),
      purchasedGrams: (json['purchasedGrams'] ?? 0.0 as num).toDouble(),
      isShared: json['isShared'] ?? false,
      healthScore: json['healthScore'] != null ? json['healthScore'] as int : 100,
      completedMilestones: json['completedMilestones'] != null
          ? List<int>.from(json['completedMilestones'] as List)
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'targetAmount': targetAmount,
        'currentSavings': currentSavings,
        'targetDate': targetDate.toIso8601String(),
        'priority': priority.name,
        'health': health.name,
        'targetGrams': targetGrams,
        'purchasedGrams': purchasedGrams,
        'isShared': isShared,
        'healthScore': healthScore,
        'completedMilestones': completedMilestones,
      };
}

class SavingsTransaction {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;
  final double? goldGrams;

  SavingsTransaction({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
    this.goldGrams,
  });

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) {
    return SavingsTransaction(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      goldGrams: json['goldGrams'] != null ? (json['goldGrams'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
        'goldGrams': goldGrams,
      };
}

class BudgetItem {
  final String id;
  final String category;
  final double estimatedCost;
  final double actualSpent;

  BudgetItem({
    required this.id,
    required this.category,
    required this.estimatedCost,
    required this.actualSpent,
  });

  BudgetItem copyWith({
    String? id,
    String? category,
    double? estimatedCost,
    double? actualSpent,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualSpent: actualSpent ?? this.actualSpent,
    );
  }

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as String,
      category: json['category'] as String,
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      actualSpent: (json['actualSpent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'estimatedCost': estimatedCost,
        'actualSpent': actualSpent,
      };
}

class TimelineTask {
  final String id;
  final String title;
  final DateTime deadline;
  final bool isCompleted;
  final String category;

  TimelineTask({
    required this.id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    required this.category,
  });

  TimelineTask copyWith({
    String? id,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    String? category,
  }) {
    return TimelineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }

  factory TimelineTask.fromJson(Map<String, dynamic> json) {
    return TimelineTask(
      id: json['id'] as String,
      title: json['title'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'deadline': deadline.toIso8601String(),
        'isCompleted': isCompleted,
        'category': category,
      };
}

class MarriagePlan {
  final double totalBudget;
  final List<BudgetItem> budgetItems;
  final List<TimelineTask> timelineTasks;

  MarriagePlan({
    required this.totalBudget,
    required this.budgetItems,
    required this.timelineTasks,
  });

  MarriagePlan copyWith({
    double? totalBudget,
    List<BudgetItem>? budgetItems,
    List<TimelineTask>? timelineTasks,
  }) {
    return MarriagePlan(
      totalBudget: totalBudget ?? this.totalBudget,
      budgetItems: budgetItems ?? this.budgetItems,
      timelineTasks: timelineTasks ?? this.timelineTasks,
    );
  }
}

class GoldPrice {
  final double rate22K;
  final double rate24K;
  final double dailyChangePercentage;
  final DateTime lastUpdated;

  GoldPrice({
    required this.rate22K,
    required this.rate24K,
    required this.dailyChangePercentage,
    required this.lastUpdated,
  });
}

class Reminder {
  final String id;
  final String title;
  final DateTime triggerTime;
  final String goalId;
  final bool isEnabled;

  Reminder({
    required this.id,
    required this.title,
    required this.triggerTime,
    required this.goalId,
    this.isEnabled = true,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? deepLink;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.deepLink,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? deepLink,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink ?? this.deepLink,
    );
  }
}

class Couple {
  final String id;
  final String user1Id;
  final String user2Id;
  final String partnerName;
  final Map<String, double> contributions;

  Couple({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.partnerName,
    required this.contributions,
  });
}

class AiInsight {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AiInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });
}
