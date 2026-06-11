/// ═══════════════════════════════════════════════════════════════
/// Extensions - AZAMOV Second Me
/// Extension methods for commonly used types
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// ─── String Extensions ───
extension StringExtension on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Get initials from name
  String get initials {
    final parts = trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (isNotEmpty) return this[0].toUpperCase();
    return '';
  }
}

/// ─── DateTime Extensions ───
extension DateTimeExtension on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}

/// ─── Color Extensions ───
extension ColorExtension on Color {
  /// Create material color swatch
  MaterialColor get materialColor {
    final hsl = HSLColor.fromColor(this);
    final lightness = hsl.lightness;

    // Create lighter and darker shades
    return MaterialColor(
      value,
      <int, Color>{
        50: _withLightness(0.95),
        100: _withLightness(0.90),
        200: _withLightness(0.80),
        300: _withLightness(0.70),
        400: _withLightness(0.60),
        500: _withLightness(0.50),
        600: _withLightness(0.40),
        700: _withLightness(0.30),
        800: _withLightness(0.20),
        900: _withLightness(0.10),
      },
    );
  }

  Color _withLightness(double targetLightness) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness(targetLightness).toColor();
  }
}

/// ─── BuildContext Extensions ───
extension BuildContextExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Show a snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
