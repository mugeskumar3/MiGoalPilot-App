import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/models/models.dart';
import 'package:migoalpilot/features/ai/data/repositories/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => MockAiRepository(),
);

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final AiInsight? dashboardInsight;

  AiState({
    this.messages = const [],
    this.isTyping = false,
    this.dashboardInsight,
  });

  AiState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    AiInsight? dashboardInsight,
  }) {
    return AiState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      dashboardInsight: dashboardInsight ?? this.dashboardInsight,
    );
  }
}

class AiViewModel extends StateNotifier<AiState> {
  final AiRepository _repo;

  AiViewModel(this._repo) : super(AiState()) {
    _loadDashboardInsight();
  }

  Future<void> _loadDashboardInsight() async {
    final ins = await _repo.getDashboardInsight();
    state = state.copyWith(dashboardInsight: ins);
  }

  Future<void> sendMessage(String text) async {
    final newMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, newMsg],
      isTyping: true,
    );

    try {
      final reply = await _repo.sendChatMessage(text);
      final replyMsg = ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, replyMsg],
        isTyping: false,
      );
    } catch (e) {
      final err = ChatMessage(
        text: 'GoalPilot AI is temporarily unavailable. Error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, err],
        isTyping: false,
      );
    }
  }

  Future<Map<String, dynamic>> parseGoalCreationQuery(String query) async {
    return await _repo.parseGoalCreationQuery(query);
  }
}

extension on AiRepository {
  Future<Map<String, dynamic>> parseGoalCreationQuery(String query) async {
    return await parseGoalIntent(query);
  }
}

final aiViewModelProvider = StateNotifierProvider<AiViewModel, AiState>((ref) {
  return AiViewModel(ref.watch(aiRepositoryProvider));
});
