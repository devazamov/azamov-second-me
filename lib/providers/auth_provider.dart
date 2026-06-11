/// ═══════════════════════════════════════════════════════════════
/// Auth Provider - AZAMOV Second Me
/// Riverpod provider for Firebase Authentication state
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Auth service provider (singleton)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Current Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current user UID (convenience provider)
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});
