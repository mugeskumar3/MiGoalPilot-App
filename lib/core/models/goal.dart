import 'package:migoalpilot/shared/enums/enums.dart';

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
