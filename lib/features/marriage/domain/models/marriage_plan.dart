import 'package:migoalpilot/features/marriage/domain/models/budget_item.dart';
import 'package:migoalpilot/features/marriage/domain/models/timeline_task.dart';

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
