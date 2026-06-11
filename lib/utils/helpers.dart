/// ═══════════════════════════════════════════════════════════════
/// Helpers - AZAMOV Second Me
/// Utility functions used across the application
/// ═══════════════════════════════════════════════════════════════

import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  /// Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'uz').format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'uz').format(date);
  }

  /// Format time only
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Get greeting based on time of day (Uzbek)
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Xayrli ertalab ☀️';
    if (hour < 17) return 'Xayrli kun 🌤️';
    if (hour < 21) return 'Xayrli kech 🌅';
    return 'Xayrli tun 🌙';
  }

  /// Format XP number with K suffix
  static String formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    }
    return xp.toString();
  }

  /// Get level title based on level number
  static String getLevelTitle(int level) {
    if (level >= 50) return 'Ustoz';
    if (level >= 40) return 'Kasbiy';
    if (level >= 30) return 'Tajribali';
    if (level >= 20) return 'Rivojlangan';
    if (level >= 10) return 'O\'rganuvchi';
    if (level >= 5) return 'Boshlang\'ich';
    return 'Yangi boshlovchi';
  }

  /// Get streak message in Uzbek
  static String getStreakMessage(int streak) {
    if (streak >= 30) return 'Ajoyib! 30+ kunlik streak! 🔥';
    if (streak >= 14) return 'Zo\'r! 2 haftalik streak! 💪';
    if (streak >= 7) return 'Yaxshi! 1 haftalik streak! ⭐';
    if (streak >= 3) return 'Davom eting! 🔥';
    if (streak >= 1) return 'Yaxshi boshladiz! 👍';
    return 'Bugun boshlang! 🚀';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Calculate time ago string
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yil oldin';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} oy oldin';
    if (diff.inDays > 0) return '${diff.inDays} kun oldin';
    if (diff.inHours > 0) return '${diff.inHours} soat oldin';
    if (diff.inMinutes > 0) return '${diff.inMinutes} daqiqa oldin';
    return 'Hozirgina';
  }
}
