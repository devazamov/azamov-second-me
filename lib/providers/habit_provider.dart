/// ═══════════════════════════════════════════════════════════════
/// Habit Provider - AZAMOV Second Me
/// Riverpod provider for habit tracking
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// User's habits stream
final userHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Stream.value([]);
  return firestore.getUserHabits(userId);
});

/// Today's habit logs
final todayHabitLogsProvider = FutureProvider<List<HabitLog>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value([]);
  return firestore.getTodayHabitLogs(userId);
});

/// Combined habits with today's completion status
final habitsWithStatusProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final habitsAsync = ref.watch(userHabitsProvider);
  final logsAsync = ref.watch(todayHabitLogsProvider);

  final habits = habitsAsync.valueOrNull ?? [];
  final logs = logsAsync.valueOrNull ?? [];

  return habits.map((habit) {
    final todayLog = logs.where((l) => l.habitId == habit.id).toList();
    final totalDone = todayLog.fold<int>(0, (sum, l) => sum + l.count);
    final isDone = totalDone >= habit.targetCount;

    return {
      'habit': habit,
      'isDone': isDone,
      'doneCount': totalDone,
      'targetCount': habit.targetCount,
    };
  }).toList();
});

/// Habit notifier
class HabitNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  HabitNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createHabit(Habit habit) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.createHabit(habit);
    ref.invalidate(userHabitsProvider);
  }

  Future<void> toggleHabit(Habit habit) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    final todayLogs = await firestore.getTodayHabitLogs(userId);
    final existingLogs = todayLogs.where((l) => l.habitId == habit.id).toList();
    final totalDone = existingLogs.fold<int>(0, (sum, l) => sum + l.count);

    if (totalDone >= habit.targetCount) {
      // Already completed - show snackbar or just return
      return;
    }

    final log = HabitLog(
      id: _uuid.v4(),
      userId: userId,
      habitId: habit.id,
      date: DateTime.now(),
      count: 1,
    );
    await firestore.logHabitCompletion(log);

    // Award small XP for habit completion
    await firestore.addXp(userId, 2);

    ref.invalidate(todayHabitLogsProvider);
    ref.invalidate(currentUserProvider);
  }

  Future<void> deleteHabit(String habitId) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.deactivateHabit(habitId);
    ref.invalidate(userHabitsProvider);
  }
}

final habitNotifierProvider = StateNotifierProvider<HabitNotifier, AsyncValue<void>>((ref) {
  return HabitNotifier(ref);
});
