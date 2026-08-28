import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/goals/domain/services/goal_milestone_calculator.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

enum ReminderPriority { high, medium, low }

class ReminderResult {
  final String type;
  final ReminderPriority priority;
  final String title;
  final String message;
  final String? goalId;
  final String actionLabel;
  final String actionRoute;
  final DateTime createdAt;

  ReminderResult({
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.goalId,
    required this.actionLabel,
    required this.actionRoute,
    required this.createdAt,
  });
}

class SmartReminderEngine {
  static ReminderResult? evaluate({
    required List<Goal> goals,
    required Map<String, List<SavingsTransaction>> transactionsMap,
    required Map<String, bool>
    settings, // remindersEnabled, milestonesEnabled, deadlinesEnabled, goldAlertsEnabled
    required List<NotificationItem> notificationHistory,
    double? currentGold22KPrice,
    double? recentGold22KTrackedPrice,
  }) {
    final now = DateTime.now();
    final List<ReminderResult> candidates = [];

    // Check if category is enabled in settings
    bool isEnabled(String type) {
      if (type == 'GOLD_PRICE_DROP' || type == 'GOLD_PRICE_TARGET') {
        return settings['goldAlertsEnabled'] ?? true;
      }
      if (type == 'MILESTONE_NEAR' || type == 'MILESTONE_REACHED') {
        return settings['milestonesEnabled'] ?? true;
      }
      if (type == 'DEADLINE_APPROACHING') {
        return settings['deadlinesEnabled'] ?? true;
      }
      return settings['remindersEnabled'] ?? true;
    }

    // Check if the reminder type & goalId has a cooldown (already sent within 24 hours)
    bool hasCooldown(String type, String? goalId) {
      final cutoff = now.subtract(const Duration(hours: 24));
      return notificationHistory.any((n) {
        final matchesType = n.id.startsWith('r_${type}_');
        final matchesGoal = goalId != null && n.deepLink != null && n.deepLink!.endsWith(goalId);
        return matchesType && matchesGoal && n.timestamp.isAfter(cutoff);
      });
    }

    // 1. Gold Price Drop Reminder (Global check)
    if (isEnabled('GOLD_PRICE_DROP') &&
        currentGold22KPrice != null &&
        recentGold22KTrackedPrice != null &&
        currentGold22KPrice > 0 &&
        recentGold22KTrackedPrice > 0) {
      final double change =
          ((currentGold22KPrice - recentGold22KTrackedPrice) /
          recentGold22KTrackedPrice);
      if (change <= -0.01) {
        // 1.0% or more price drop
        final double pct = change.abs() * 100.0;
        final String message =
            '22K gold is ${pct.toStringAsFixed(1)}% lower than your recent tracked average. Consider reviewing your plan.';
        if (!hasCooldown('GOLD_PRICE_DROP', 'gold')) {
          candidates.add(
            ReminderResult(
              type: 'GOLD_PRICE_DROP',
              priority: ReminderPriority.medium,
              title: 'Gold Price Movement Detected',
              message: message,
              goalId: 'gold',
              actionLabel: 'Review Gold Goal',
              actionRoute: '/gold',
              createdAt: now,
            ),
          );
        }
      }
    }

    // 2. Goal-Specific Reminders
    for (final g in goals) {
      final bool isCompleted = g.type == GoalType.gold
          ? (g.targetGrams > 0 && g.purchasedGrams >= g.targetGrams)
          : (g.targetAmount > 0 && g.currentSavings >= g.targetAmount);

      if (isCompleted) continue;

      final txs = transactionsMap[g.id] ?? [];

      // A. Deadline Proximity Check
      final bool hasNoDeadline = g.targetDate.year <= 1970;
      if (!hasNoDeadline && isEnabled('DEADLINE_APPROACHING')) {
        final daysRemaining = g.targetDate.difference(now).inDays;
        if (daysRemaining > 0 && daysRemaining <= 90) {
          ReminderPriority priority = ReminderPriority.low;
          String msg =
              'Your ${g.name} deadline is $daysRemaining days away. Consider updating your target date.';
          if (daysRemaining <= 7) {
            priority = ReminderPriority.high;
            msg =
                'Your ${g.name} deadline is next week! Review your final savings.';
          } else if (daysRemaining <= 30) {
            priority = ReminderPriority.medium;
            msg =
                'Your target date is approaching in $daysRemaining days. Review your savings plan.';
          }

          if (!hasCooldown('DEADLINE_APPROACHING', g.id)) {
            candidates.add(
              ReminderResult(
                type: 'DEADLINE_APPROACHING',
                priority: priority,
                title: 'Deadline Approaching',
                message: msg,
                goalId: g.id,
                actionLabel: 'Review Goal',
                actionRoute: g.type == GoalType.gold ? '/gold-goals/${g.id}' : '/goals/${g.id}',
                createdAt: now,
              ),
            );
          }
        }
      }

      // B. Goal Health & Pace Alerts
      // We check simulated score or healthScore
      if (g.healthScore < 40 && isEnabled('GOAL_AT_RISK')) {
        if (!hasCooldown('GOAL_AT_RISK', g.id)) {
          candidates.add(
            ReminderResult(
              type: 'GOAL_AT_RISK',
              priority: ReminderPriority.high,
              title: 'Goal At Risk',
              message:
                  'Your savings pace for ${g.name} may miss your target date. Review allocations.',
              goalId: g.id,
              actionLabel: 'Adjust Savings Plan',
              actionRoute: '/multi-goal',
              createdAt: now,
            ),
          );
        }
      } else if (g.healthScore >= 40 &&
          g.healthScore < 60 &&
          isEnabled('GOAL_BEHIND')) {
        if (!hasCooldown('GOAL_BEHIND', g.id)) {
          candidates.add(
            ReminderResult(
              type: 'GOAL_BEHIND',
              priority: ReminderPriority.high,
              title: 'Goal Needs Attention',
              message:
                  'Your ${g.name} is slightly behind. Adjust savings to stay on track.',
              goalId: g.id,
              actionLabel: 'Adjust Savings Plan',
              actionRoute: '/multi-goal',
              createdAt: now,
            ),
          );
        }
      }

      // C. Milestone Proximity Check
      if (isEnabled('MILESTONE_NEAR')) {
        final milestones = GoalMilestoneCalculator.calculateMilestones(g, txs);
        final nextUpcoming = milestones.firstWhere(
          (m) => !m.completed,
          orElse: () => milestones.last,
        );

        if (!nextUpcoming.completed) {
          final double totalTarget = g.type == GoalType.gold
              ? g.targetGrams
              : g.targetAmount;
          final double currentTotal = g.type == GoalType.gold
              ? g.purchasedGrams
              : g.currentSavings;
          final double diff = nextUpcoming.targetAmount - currentTotal;
          final double threshold = totalTarget * 0.10; // within 10%

          if (diff > 0 && diff <= threshold) {
            final String formattedDiff = g.type == GoalType.gold
                ? '${diff.toStringAsFixed(2)}g'
                : '₹${diff.toStringAsFixed(0)}';
            if (!hasCooldown('MILESTONE_NEAR', g.id)) {
              candidates.add(
                ReminderResult(
                  type: 'MILESTONE_NEAR',
                  priority: ReminderPriority.medium,
                  title: 'Milestone within Reach!',
                  message:
                      'You are only $formattedDiff away from unlocking the ${nextUpcoming.percentage}% milestone for ${g.name}.',
                  goalId: g.id,
                  actionLabel: 'Milestone Details',
                  actionRoute: g.type == GoalType.gold ? '/gold-goals/${g.id}' : '/goals/${g.id}',
                  createdAt: now,
                ),
              );
            }
          }
        }
      }

      // D. User Saving Patterns (Historical check)
      if (isEnabled('SAVING_DUE') && txs.isNotEmpty) {
        // Calculate average contribution size
        final double totalAmount = txs.fold(
          0.0,
          (sum, t) =>
              sum + (g.type == GoalType.gold ? (t.goldGrams ?? 0.0) : t.amount),
        );
        final double averageSavings = totalAmount / txs.length;

        // Check if no transactions recorded in last 30 days
        final bool hasNoRecentTx = txs.every(
          (t) => now.difference(t.date).inDays > 30,
        );
        if (hasNoRecentTx && averageSavings > 0) {
          final String formattedAvg = g.type == GoalType.gold
              ? '${averageSavings.toStringAsFixed(2)}g'
              : '₹${averageSavings.toStringAsFixed(0)}';
          if (!hasCooldown('SAVING_DUE', g.id)) {
            candidates.add(
              ReminderResult(
                type: 'SAVING_DUE',
                priority: ReminderPriority.low,
                title: 'Savings Reminder',
                message:
                    'You haven\'t added to your ${g.name} this month. A $formattedAvg contribution would keep your plan healthy.',
                goalId: g.id,
                actionLabel: 'Save Now',
                actionRoute: '/add-saving/${g.id}',
                createdAt: now,
              ),
            );
          }
        }
      }
    }

    if (candidates.isEmpty) return null;

    // Prioritize candidates: high first, then medium, then low.
    candidates.sort((a, b) {
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return priorityCompare;
    });

    return candidates.first;
  }
}
