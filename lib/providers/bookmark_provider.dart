/// ═══════════════════════════════════════════════════════════════
/// Bookmark Provider - AZAMOV Academy
/// Riverpod provider for chat bookmarks
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/bookmark_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// User's bookmarks
final bookmarksProvider = StreamProvider<List<Bookmark>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Stream.value([]);
  return firestore.getBookmarks(userId);
});

/// Bookmark notifier
class BookmarkNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  BookmarkNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addBookmark({
    required String content,
    String? aiResponse,
    String? chatId,
    String? messageId,
    String? tag,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    final bookmark = Bookmark(
      id: _uuid.v4(),
      userId: userId,
      content: content,
      aiResponse: aiResponse,
      chatId: chatId,
      messageId: messageId,
      tag: tag,
      createdAt: DateTime.now(),
    );

    await firestore.saveBookmark(bookmark);
    ref.invalidate(bookmarksProvider);
  }

  Future<void> deleteBookmark(String id) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.deleteBookmark(id);
    ref.invalidate(bookmarksProvider);
  }
}

final bookmarkNotifierProvider = StateNotifierProvider<BookmarkNotifier, AsyncValue<void>>((ref) {
  return BookmarkNotifier(ref);
});
