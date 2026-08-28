import 'dart:async';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/shared/enums/enums.dart';

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
