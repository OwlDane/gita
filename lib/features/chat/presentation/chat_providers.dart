import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/features/chat/data/chat_repository.dart';

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

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier(this._repository) : super(ChatState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    final response = await _repository.sendMessage(text);

    final aiMessage = ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      isLoading: false,
    );
  }

  void reset() {
    _repository.resetChat();
    state = ChatState();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});
