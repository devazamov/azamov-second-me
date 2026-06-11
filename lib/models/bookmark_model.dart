/// ═══════════════════════════════════════════════════════════════
/// Bookmark Model - AZAMOV Academy
/// Save important AI chat responses
/// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String id;
  final String userId;
  final String content;
  final String? aiResponse;
  final String? chatId;
  final String? messageId;
  final String? tag;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.userId,
    required this.content,
    this.aiResponse,
    this.chatId,
    this.messageId,
    this.tag,
    required this.createdAt,
  });

  factory Bookmark.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Bookmark(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      aiResponse: data['aiResponse'],
      chatId: data['chatId'],
      messageId: data['messageId'],
      tag: data['tag'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'content': content,
      'aiResponse': aiResponse,
      'chatId': chatId,
      'messageId': messageId,
      'tag': tag,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
