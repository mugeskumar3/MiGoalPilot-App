import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/profile/data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => MockNotificationRepository(),
);

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

  Future<void> addNotification(NotificationItem item) async {
    await _repo.addNotification(item);
    await loadNotifications();
  }

  void clearAll() {
    state = NotificationState(items: const []);
  }
}

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      return NotificationViewModel(ref.watch(notificationRepositoryProvider));
    });
