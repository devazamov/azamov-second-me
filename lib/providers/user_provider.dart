/// ═══════════════════════════════════════════════════════════════
/// User Provider - AZAMOV Second Me
/// Riverpod provider for Firestore user data
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

/// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Current user's Firestore document (real-time stream)
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestore = ref.watch(firestoreServiceProvider);

  if (userId == null) return Stream.value(null);
  return firestore.userStream(userId);
});

/// Check if user has completed onboarding
final onboardingCompletedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.onboardingCompleted ?? false;
});

/// Check if user is premium
final isPremiumProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.isPremium ?? false;
});
