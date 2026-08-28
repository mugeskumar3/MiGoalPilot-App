import 'dart:async';
import 'package:migoalpilot/core/models/models.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> addNotification(NotificationItem item);
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

  @override
  Future<void> addNotification(NotificationItem item) async {
    _list.insert(0, item);
  }
}
