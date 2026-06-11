/// ═══════════════════════════════════════════════════════════════
/// Chat Provider - AZAMOV Second Me
/// Riverpod provider for Future Self AI chat
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// AI Service provider
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// UUID generator
final _uuid = const Uuid();

/// Current chat session ID
final currentChatIdProvider = StateProvider<String?>((ref) => null);

/// Chat messages stream for current session
final chatMessagesProvider =
    StreamProvider.autoDispose<List<ChatMessage>>((ref) {
  final chatId = ref.watch(currentChatIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);

  if (chatId == null) return Stream.value([]);
  return firestore.getChatMessages(chatId);
});

/// User's chat sessions list
final chatSessionsProvider = StreamProvider<List<ChatSession>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);

  if (userId == null) return Stream.value([]);
  return firestore.getUserChatSessions(userId);
});

/// Chat state - tracks typing, sending, errors
class ChatState {
  final bool isTyping;
  final bool isSending;
  final String? error;
  final String? streamingContent;

  const ChatState({
    this.isTyping = false,
    this.isSending = false,
    this.error,
    this.streamingContent,
  });

  ChatState copyWith({
    bool? isTyping,
    bool? isSending,
    String? error,
    String? streamingContent,
    bool clearError = false,
  }) {
    return ChatState(
      isTyping: isTyping ?? this.isTyping,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      streamingContent: streamingContent ?? this.streamingContent,
    );
  }
}

/// Chat notifier - manages chat interactions
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref ref;

  ChatNotifier(this.ref) : super(const ChatState());

  /// Start a new chat session
  Future<void> startNewChat() async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    final chatId = await firestore.createChatSession(userId);
    ref.read(currentChatIdProvider.notifier).state = chatId;
  }

  /// Send a message and get AI response
  Future<void> sendMessage(String content) async {
    final userId = ref.read(currentUserIdProvider);
    final user = ref.read(currentUserProvider).valueOrNull;
    final chatId = ref.read(currentChatIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    final aiService = ref.read(aiServiceProvider);

    if (userId == null || user == null || chatId == null) return;
    if (content.trim().isEmpty) return;

    state = state.copyWith(isSending: true, clearError: true);

    try {
      // Check chat limit for free users
      if (!user.canStartChat) {
        state = state.copyWith(
          isSending: false,
          error: 'Bugungi chat limit tugadi. Premiumga o\'ting!',
        );
        return;
      }

      // Save user message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        chatId: chatId,
        userId: userId,
        content: content.trim(),
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );
      await firestore.sendMessage(userMessage);

      // Update daily chat count
      await firestore.incrementDailyChats(userId);

      // Get recent messages for AI context
      final recentMessages = await firestore.getRecentMessages(chatId);

      state = state.copyWith(isTyping: true);

      // Get AI response
      final aiResponse = await aiService.sendMessage(
        userMessage: content.trim(),
        user: user,
        chatHistory: recentMessages,
      );

      // Save AI response
      final assistantMessage = ChatMessage(
        id: _uuid.v4(),
        chatId: chatId,
        userId: userId,
        content: aiResponse,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );
      await firestore.sendMessage(assistantMessage);

      state = state.copyWith(isTyping: false, isSending: false);
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        isSending: false,
        error: e.toString(),
      );
    }
  }
}

/// Chat notifier provider
final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
