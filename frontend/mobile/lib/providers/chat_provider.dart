import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chatbot_log_model.dart';
import '../services/requests/chat_request.dart';
import 'auth_provider.dart';

final chatRequestsProvider = Provider<ChatRequests>((_) => ChatRequests());

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.pendingPrompt,
  });

  final List<ChatbotLogModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final String? pendingPrompt;

  ChatState copyWith({
    List<ChatbotLogModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    String? pendingPrompt,
    bool clearPendingPrompt = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingPrompt:
          clearPendingPrompt ? null : (pendingPrompt ?? this.pendingPrompt),
    );
  }
}

class ChatController extends Notifier<ChatState> {
  ChatRequests? _chatRequests;

  @override
  ChatState build() {
    _chatRequests = ref.watch(chatRequestsProvider);

    // Auto-fetch history when the user is authenticated
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated && authState.profile != null) {
      Future.microtask(() => fetchHistory());
    }

    return const ChatState();
  }

  String? get _userId => ref.read(authProvider).authUser?.id;

  void _setState({
    List<ChatbotLogModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    String? pendingPrompt,
    bool clearPendingPrompt = false,
  }) {
    state = state.copyWith(
      messages: messages,
      isLoading: isLoading,
      isSending: isSending,
      errorMessage: errorMessage,
      clearError: clearError,
      pendingPrompt: pendingPrompt,
      clearPendingPrompt: clearPendingPrompt,
    );
  }

  Future<void> fetchHistory() async {
    final userId = _userId;
    if (userId == null) return;

    _setState(isLoading: true, clearError: true);
    try {
      final history = await _chatRequests?.getChatHistory(userId);
      _setState(
        messages: history?..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        isLoading: false,
      );
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> sendMessage(String prompt) async {
    final userId = _userId;
    final trimmedPrompt = prompt.trim();
    if (userId == null || trimmedPrompt.isEmpty) return;

    _setState(isSending: true, clearError: true, pendingPrompt: trimmedPrompt);

    try {
      final request = ChatPromptRequest(userId: userId, prompt: trimmedPrompt);
      final newChat = await _chatRequests?.generateNewChat(request);

      _setState(
        messages: [
          ...state.messages,
          if (newChat != null) newChat,
        ],
        isSending: false,
        clearPendingPrompt: true,
      );
    } catch (e) {
      _setState(
        isSending: false,
        errorMessage: e.toString(),
        clearPendingPrompt: true,
      );
    }
  }

  Future<void> deleteMessage(String chatId) async {
    try {
      await _chatRequests?.deleteChat(chatId);
      _setState(
        messages: state.messages.where((m) => m.chatId != chatId).toList(),
      );
    } catch (e) {
      _setState(errorMessage: e.toString());
    }
  }

  void clearError() {
    _setState(clearError: true);
  }
}

final chatProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);
