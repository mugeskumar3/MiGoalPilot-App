import 'dart:async';
import 'package:migoalpilot/core/models/models.dart';

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
