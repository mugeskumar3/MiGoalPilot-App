import 'package:flutter_test/flutter_test.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/core/services/smart_reminder_engine.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

void main() {
  group('SmartReminderEngine Unit Tests', () {
    final now = DateTime.now();

    test('At risk goal triggers high priority reminder', () {
      final goal = Goal(
        id: 'at_risk_1',
        name: 'Marriage ceremony',
        type: GoalType.marriage,
        targetAmount: 100000,
        currentSavings: 10000,
        targetDate: now.add(const Duration(days: 30)),
        priority: GoalPriority.high,
        health: GoalHealth.atRisk,
        healthScore: 30, // at risk threshold is < 40
      );

      final result = SmartReminderEngine.evaluate(
        goals: [goal],
        transactionsMap: {},
        settings: {
          'remindersEnabled': true,
          'milestonesEnabled': true,
          'deadlinesEnabled': true,
          'goldAlertsEnabled': true,
        },
        notificationHistory: [],
      );

      expect(result, isNotNull);
      expect(result!.type, equals('GOAL_AT_RISK'));
      expect(result.priority, equals(ReminderPriority.high));
      expect(result.actionLabel, equals('Adjust Savings Plan'));
    });

    test('Behind goal triggers high priority reminder', () {
      final goal = Goal(
        id: 'behind_1',
        name: 'Custom study',
        type: GoalType.education,
        targetAmount: 100000,
        currentSavings: 40000,
        targetDate: now.add(const Duration(days: 30)),
        priority: GoalPriority.medium,
        health: GoalHealth.needsAttention,
        healthScore: 50, // behind threshold is 40-59
      );

      final result = SmartReminderEngine.evaluate(
        goals: [goal],
        transactionsMap: {},
        settings: {
          'remindersEnabled': true,
          'milestonesEnabled': true,
          'deadlinesEnabled': true,
          'goldAlertsEnabled': true,
        },
        notificationHistory: [],
      );

      expect(result, isNotNull);
      expect(result!.type, equals('GOAL_BEHIND'));
      expect(result.priority, equals(ReminderPriority.high));
    });

    test('Disabled notification settings returns null for corresponding alerts', () {
      final goal = Goal(
        id: 'behind_1',
        name: 'Custom study',
        type: GoalType.education,
        targetAmount: 100000,
        currentSavings: 40000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.medium,
        health: GoalHealth.needsAttention,
        healthScore: 50,
      );

      final result = SmartReminderEngine.evaluate(
        goals: [goal],
        transactionsMap: {},
        settings: {
          'remindersEnabled': false,
          'milestonesEnabled': false,
          'deadlinesEnabled': false,
          'goldAlertsEnabled': false,
        },
        notificationHistory: [],
      );

      expect(result, isNull);
    });

    test('Deduplication / Cooldown logic prevents duplicate reminders within 24 hours', () {
      final goal = Goal(
        id: 'at_risk_1',
        name: 'Marriage ceremony',
        type: GoalType.marriage,
        targetAmount: 100000,
        currentSavings: 10000,
        targetDate: now.add(const Duration(days: 300)),
        priority: GoalPriority.high,
        health: GoalHealth.atRisk,
        healthScore: 30,
      );

      final history = [
        NotificationItem(
          id: 'r_GOAL_AT_RISK_at_risk_1',
          title: 'Goal At Risk',
          message: 'Already sent recently',
          timestamp: now.subtract(const Duration(hours: 4)),
          deepLink: '/goals/at_risk_1',
        ),
      ];

      final result = SmartReminderEngine.evaluate(
        goals: [goal],
        transactionsMap: {},
        settings: {
          'remindersEnabled': true,
          'milestonesEnabled': true,
          'deadlinesEnabled': true,
          'goldAlertsEnabled': true,
        },
        notificationHistory: history,
      );

      expect(result, isNull);
    });

    test('Priority ranking selects High over Medium and Low', () {
      final behindGoal = Goal(
        id: 'behind_1',
        name: 'Custom study',
        type: GoalType.education,
        targetAmount: 100000,
        currentSavings: 40000,
        targetDate: now.add(const Duration(days: 90)),
        priority: GoalPriority.medium,
        health: GoalHealth.needsAttention,
        healthScore: 50, // GOAL_BEHIND -> Priority HIGH
      );

      // We simulate a gold price drop drop of 1.4% (Priority MEDIUM)
      final result = SmartReminderEngine.evaluate(
        goals: [behindGoal],
        transactionsMap: {},
        settings: {
          'remindersEnabled': true,
          'milestonesEnabled': true,
          'deadlinesEnabled': true,
          'goldAlertsEnabled': true,
        },
        notificationHistory: [],
        currentGold22KPrice: 5000.0,
        recentGold22KTrackedPrice: 5071.0, // (5000 - 5071)/5071 = -1.4% drop
      );

      expect(result, isNotNull);
      expect(result!.type, equals('GOAL_BEHIND')); // selected over GOLD_PRICE_DROP
    });
  });
}
