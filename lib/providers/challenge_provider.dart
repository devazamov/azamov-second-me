/// ═══════════════════════════════════════════════════════════════
/// Challenge Provider - AZAMOV Second Me
/// Riverpod provider for challenge system
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/challenge_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

const _uuid = Uuid();

/// Active challenges stream
final activeChallengesProvider = StreamProvider<List<Challenge>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.getActiveChallenges();
});

/// User's challenges
final userChallengesProvider = StreamProvider<List<UserChallenge>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Stream.value([]);
  return firestore.getUserChallenges(userId);
});

/// Active user challenges (not completed)
final activeUserChallengesProvider = Provider<List<UserChallenge>>((ref) {
  final challenges = ref.watch(userChallengesProvider).valueOrNull ?? [];
  return challenges.where((c) => c.status == ChallengeStatus.active).toList();
});

/// Completed user challenges
final completedUserChallengesProvider = Provider<List<UserChallenge>>((ref) {
  final challenges = ref.watch(userChallengesProvider).valueOrNull ?? [];
  return challenges.where((c) => c.status == ChallengeStatus.completed).toList();
});

/// Challenge notifier
class ChallengeNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ChallengeNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> joinChallenge(Challenge challenge) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null) return;

    final userChallenge = UserChallenge(
      id: _uuid.v4(),
      userId: userId,
      challengeId: challenge.id,
      challengeTitle: challenge.title,
      challengeEmoji: challenge.emoji,
      period: challenge.period,
      totalDays: challenge.totalDays,
      xpReward: challenge.xpReward,
      bonusXp: challenge.bonusXp,
      status: ChallengeStatus.active,
      joinedAt: DateTime.now(),
      currentDay: 1,
    );

    await firestore.joinChallenge(userChallenge);
    ref.invalidate(userChallengesProvider);
  }

  Future<void> completeDay(UserChallenge userChallenge) async {
    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    if (userId == null || userChallenge.completedDays.contains(userChallenge.currentDay)) return;

    await firestore.completeChallengeDay(userChallenge.id, userChallenge.currentDay);

    // Award XP for each day
    final dailyXp = (userChallenge.xpReward / userChallenge.totalDays).round();
    await firestore.addXp(userId, dailyXp);

    ref.invalidate(userChallengesProvider);
    ref.invalidate(activeUserChallengesProvider);
    ref.invalidate(currentUserProvider);
  }
}

final challengeNotifierProvider = StateNotifierProvider<ChallengeNotifier, AsyncValue<void>>((ref) {
  return ChallengeNotifier(ref);
});
