/// ═══════════════════════════════════════════════════════════════
/// Journal Provider - AZAMOV Second Me
/// Riverpod provider for daily journal entries
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// User's journal entries stream
final userJournalProvider = StreamProvider<List<JournalEntry>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Stream.value([]);
  return firestore.getUserJournal(userId);
});

/// Today's journal entry
final todayJournalProvider = FutureProvider<JournalEntry?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value(null);
  return firestore.getTodayJournal(userId);
});

/// Journal notifier
class JournalNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  JournalNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> saveEntry({
    required String id,
    required String content,
    required JournalMood mood,
    List<String> gratitudes = const [],
    String? todayWin,
    String? tomorrowGoal,
    List<String> tags = const [],
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    final entry = JournalEntry(
      id: id,
      userId: userId,
      date: DateTime.now(),
      content: content,
      mood: mood,
      gratitudes: gratitudes,
      todayWin: todayWin,
      tomorrowGoal: tomorrowGoal,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await firestore.saveJournalEntry(entry);
    await firestore.addXp(userId, 5); // XP for journaling

    ref.invalidate(todayJournalProvider);
    ref.invalidate(userJournalProvider);
    ref.invalidate(currentUserProvider);
  }

  Future<String> createNewEntry() async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) throw Exception('User not logged in');

    // Check if today's entry already exists
    final existing = await firestore.getTodayJournal(userId);
    if (existing != null) return existing.id;

    return _uuid.v4();
  }
}

final journalNotifierProvider = StateNotifierProvider<JournalNotifier, AsyncValue<void>>((ref) {
  return JournalNotifier(ref);
});
