/// ═══════════════════════════════════════════════════════════════
/// Progress Provider - AZAMOV Second Me
/// Riverpod provider for progress tracking and achievements
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Weekly progress data
final weeklyProgressProvider = FutureProvider<List<DailyProgress>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Future.value([]);
  return firestore.getWeeklyProgress(userId);
});

/// User achievements stream
final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  if (userId == null) return Stream.value([]);
  return firestore.getUserAchievements(userId);
});

/// Streak management
final streakProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.currentStreak ?? 0;
});

/// Level info
final levelProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user.valueOrNull == null) {
    return {'level': 1, 'xp': 0, 'progress': 0.0};
  }
  final u = user.valueOrNull!;
  return {
    'level': u.level,
    'xp': u.xp,
    'progress': u.levelProgress,
  };
});
