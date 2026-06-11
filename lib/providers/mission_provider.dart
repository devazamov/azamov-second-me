/// ═══════════════════════════════════════════════════════════════
/// Mission Provider - AZAMOV Second Me
/// Riverpod provider for daily missions
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/mission_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// Active missions list
final missionsProvider = StreamProvider<List<Mission>>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.getDailyMissions(isPremium);
});

/// Today's completed missions
final todayCompletedMissionsProvider =
    FutureProvider<List<CompletedMission>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value([]);
  return firestore.getTodayCompletedMissions(userId);
});

/// Mission completion state
class MissionState {
  final bool isCompleting;
  final Mission? justCompleted;
  final String? error;

  const MissionState({
    this.isCompleting = false,
    this.justCompleted,
    this.error,
  });

  MissionState copyWith({
    bool? isCompleting,
    Mission? justCompleted,
    String? error,
    bool clearJustCompleted = false,
  }) {
    return MissionState(
      isCompleting: isCompleting ?? this.isCompleting,
      justCompleted:
          clearJustCompleted ? null : (justCompleted ?? this.justCompleted),
      error: error ?? this.error,
    );
  }
}

/// Mission notifier - handles mission completion and XP rewards
class MissionNotifier extends StateNotifier<MissionState> {
  final Ref ref;

  MissionNotifier(this.ref) : super(const MissionState());

  /// Complete a mission and award XP
  Future<void> completeMission(Mission mission) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);

    if (userId == null) return;

    state = state.copyWith(isCompleting: true);

    try {
      // Record completed mission
      final completed = CompletedMission(
        id: _uuid.v4(),
        userId: userId,
        missionId: mission.id,
        missionTitle: mission.title,
        missionEmoji: mission.emoji,
        xpEarned: mission.totalXp,
        completedAt: DateTime.now(),
      );
      await firestore.completeMission(completed);

      // Award XP
      await firestore.addXp(userId, mission.totalXp);

      // Update daily progress
      await firestore.updateDailyProgress(
        userId,
        xpEarned: mission.totalXp,
        missionsCompleted: 1,
      );

      // Invalidate providers to refresh UI
      ref.invalidate(todayCompletedMissionsProvider);
      ref.invalidate(currentUserProvider);

      state = state.copyWith(
        isCompleting: false,
        justCompleted: mission,
      );
    } catch (e) {
      state = state.copyWith(
        isCompleting: false,
        error: 'Missiyani tugatishda xatolik: $e',
      );
    }
  }

  /// Clear just completed notification
  void clearJustCompleted() {
    state = state.copyWith(clearJustCompleted: true);
  }
}

/// Mission notifier provider
final missionNotifierProvider =
    StateNotifierProvider<MissionNotifier, MissionState>((ref) {
  return MissionNotifier(ref);
});
