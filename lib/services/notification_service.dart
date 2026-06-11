/// ═══════════════════════════════════════════════════════════════
/// Notification Service - AZAMOV Second Me
/// Firebase Cloud Messaging + Local Notifications
/// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize push notifications
  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveFcmToken);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    }
  }

  /// Save FCM token to user's document
  Future<void> _saveFcmToken(String token) async {
    // TODO: Get current user ID from auth provider
    // await _firestore.collection('users').doc(userId).update({
    //   'fcmToken': token,
    //   'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    // });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification or in-app banner
    final notification = message.notification;
    if (notification != null) {
      // TODO: Show local notification
      print('Foreground notification: ${notification.title}');
    }
  }

  /// Handle background messages (must be top-level function)
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Process background message
    print('Background message: ${message.messageId}');
  }

  /// Subscribe to daily reminder topic
  Future<void> subscribeToDailyReminders() async {
    await _messaging.subscribeToTopic('daily_reminders');
  }

  /// Subscribe to motivation quotes topic
  Future<void> subscribeToMotivationQuotes() async {
    await _messaging.subscribeToTopic('motivation_quotes');
  }

  /// Unsubscribe from topics
  Future<void> unsubscribeFromAll() async {
    await _messaging.unsubscribeFromTopic('daily_reminders');
    await _messaging.unsubscribeFromTopic('motivation_quotes');
    await _messaging.unsubscribeFromTopic('mission_reminders');
  }

  /// Send broadcast notification (admin use)
  static Future<void> sendBroadcast({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'type': 'broadcast',
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }
}
