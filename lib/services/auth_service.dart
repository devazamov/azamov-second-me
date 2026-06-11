/// ═══════════════════════════════════════════════════════════════
/// Auth Service - AZAMOV Second Me
/// Firebase Authentication with Email/Password and Google Sign-In
/// ═══════════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ─── Email & Password Sign Up ───
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!, name, email);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// ─── Email & Password Sign In ───
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// ─── Google Sign-In ───
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      // Create user document if new user
      if (userCredential.additionalUserInfo?.isNewUser == true &&
          userCredential.user != null) {
        await _createUserDocument(
          userCredential.user!,
          userCredential.user!.displayName ?? 'User',
          userCredential.user!.email ?? '',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// ─── Password Reset ───
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// ─── Sign Out ───
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// ─── Create User Document in Firestore ───
  Future<void> _createUserDocument(User user, String name, String email) {
    return _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'photoUrl': user.photoURL,
      'age': 0,
      'gender': '',
      'goals': [],
      'dreams': [],
      'interests': [],
      'preferredLanguage': 'uz',
      'isPremium': false,
      'xp': 0,
      'level': 1,
      'currentStreak': 0,
      'longestStreak': 0,
      'dailyChatsUsed': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastActiveDate': FieldValue.serverTimestamp(),
      'onboardingCompleted': false,
      'notificationsEnabled': true,
    });
  }

  /// ─── Handle Firebase Auth Errors ───
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
