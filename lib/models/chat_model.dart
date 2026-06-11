/// ═══════════════════════════════════════════════════════════════
/// Chat Message Model - AZAMOV Second Me
/// Represents a single message in the Future Self AI chat
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final String chatId;
  final String userId;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isStreaming;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isStreaming = false,
  });

  /// Create from Firestore
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      role: MessageRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isStreaming: data['isStreaming'] ?? false,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'userId': userId,
      'content': content,
      'role': role.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isStreaming': isStreaming,
    };
  }

  /// Whether this message is from the user
  bool get isUser => role == MessageRole.user;

  /// Whether this message is from the AI
  bool get isAssistant => role == MessageRole.assistant;

  ChatMessage copyWith({String? content, bool? isStreaming}) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      userId: userId,
      content: content ?? this.content,
      role: role,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// Chat Session Model - AZAMOV Second Me
/// Represents a complete chat session with the Future Self
/// ═══════════════════════════════════════════════════════════════

class ChatSession {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final bool isActive;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.isActive = true,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'New Chat',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messageCount: data['messageCount'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'messageCount': messageCount,
      'isActive': isActive,
    };
  }
}
