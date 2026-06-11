/// ═══════════════════════════════════════════════════════════════
/// Mood Provider - AZAMOV Second Me
/// Riverpod provider for mood tracking
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// Today's mood entry
final todayMoodProvider = FutureProvider<MoodEntry?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value(null);
  return firestore.getTodayMood(userId);
});

/// Mood history (last 30 days)
final moodHistoryProvider = FutureProvider<List<MoodEntry>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value([]);
  return firestore.getMoodHistory(userId);
});

/// Weekly mood average
final weeklyMoodAverageProvider = Provider<double>((ref) {
  final history = ref.watch(moodHistoryProvider).valueOrNull ?? [];
  if (history.isEmpty) return 0.5;

  final weekEntries = history.where((e) =>
      e.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();
  if (weekEntries.isEmpty) return 0.5;

  final avg = weekEntries.fold<double>(0, (sum, e) => sum + e.moodLevel.value) / weekEntries.length;
  return avg;
});

/// Mood notifier
class MoodNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  MoodNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> logMood({
    required MoodLevel moodLevel,
    List<EmotionTag> emotions = const [],
    String? note,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    // Check if already logged today
    final existing = await firestore.getTodayMood(userId);
    final id = existing?.id ?? _uuid.v4();

    final entry = MoodEntry(
      id: id,
      userId: userId,
      date: DateTime.now(),
      moodLevel: moodLevel,
      emotions: emotions,
      note: note,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    await firestore.logMood(entry);
    await firestore.addXp(userId, 3); // XP for mood tracking

    ref.invalidate(todayMoodProvider);
    ref.invalidate(moodHistoryProvider);
    ref.invalidate(currentUserProvider);
  }
}

final moodNotifierProvider = StateNotifierProvider<MoodNotifier, AsyncValue<void>>((ref) {
  return MoodNotifier(ref);
});
