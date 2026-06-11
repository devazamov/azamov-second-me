import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ═══════════════════════════════════════════════════════════════
/// AZAMOV Academy - Premium Liquid Glass Design System
/// White/Silver + Deep Blue/Purple + Dark Mode
/// ═══════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ─── Azamov Academy Brand Colors ───
  static const Color academyBlue = Color(0xFF1A56DB);
  static const Color academyPurple = Color(0xFF7C3AED);
  static const Color academyGold = Color(0xFFF59E0B);

  // ─── Light Theme ───
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // ─── Dark Theme ───
  static const Color darkBackground = Color(0xFF0F1118);
  static const Color darkSurface = Color(0xFF1A1D28);
  static const Color darkSurfaceElevated = Color(0xFF242736);
  static const Color darkCardBg = Color(0xFF1E2130);

  // ─── Liquid Glass Colors ───
  static const Color glassWhite = Color(0xE6FFFFFF);
  static const Color glassDark = Color(0xCC1A1D28);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x0D000000);

  // ─── Accent Colors ───
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryLight = Color(0xFFE8EFFD);
  static const Color primaryDark = Color(0xFF143E9E);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFFF0EAFF);
  static const Color accentSoft = Color(0xFFF0F7FF);

  // ─── Silver Palette ───
  static const Color silver = Color(0xFFC0C4CC);
  static const Color silverLight = Color(0xFFE8EAEE);
  static const Color silverDark = Color(0xFF8E9299);
  static const Color darkSilver = Color(0xFF3A3D4A);

  // ─── Text Colors (Light) ───
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Text Colors (Dark) ───
  static const Color darkTextPrimary = Color(0xFFF1F3F7);
  static const Color darkTextSecondary = Color(0xFFB0B5C4);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkTextOnPrimary = Color(0xFFFFFFFF);

  // ─── Status Colors ───
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFE8F9ED);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFDECEC);
  static const Color info = Color(0xFF1A56DB);
  static const Color infoLight = Color(0xFFE8EFFD);

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A56DB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silverGradient = LinearGradient(
    colors: [Color(0xFFE8EAEE), Color(0xFFC0C4CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xE6FFFFFF), Color(0xE6F8F9FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1A56DB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [Color(0xCC1A1D28), Color(0xCC1E2130)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Chart Colors ───
  static const List<Color> chartColors = [
    Color(0xFF1A56DB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF7C3AED),
  ];
}

/// ═══════════════════════════════════════════════════════════════
/// App Theme Configuration
/// ═══════════════════════════════════════════════════════════════

class AppTheme {
  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.academyBlue,
        secondary: AppColors.academyPurple,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      textTheme: _buildTextTheme(false),
      appBarTheme: _buildAppBarTheme(false),
      cardTheme: _buildCardTheme(false),
      inputDecorationTheme: _buildInputDecorationTheme(false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      chipTheme: _buildChipTheme(false),
      bottomNavigationBarTheme: _buildBottomNavTheme(false),
      dialogTheme: _buildDialogTheme(false),
      snackBarTheme: _buildSnackBarTheme(),
      bottomSheetTheme: _buildBottomSheetTheme(false),
      floatingActionButtonTheme: _buildFabTheme(),
      dividerTheme: _buildDividerTheme(false),
      switchTheme: _buildSwitchTheme(),
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.academyBlue,
        secondary: AppColors.academyPurple,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.textOnPrimary,
      ),
      textTheme: _buildTextTheme(true),
      appBarTheme: _buildAppBarTheme(true),
      cardTheme: _buildCardTheme(true),
      inputDecorationTheme: _buildInputDecorationTheme(true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      chipTheme: _buildChipTheme(true),
      bottomNavigationBarTheme: _buildBottomNavTheme(true),
      dialogTheme: _buildDialogTheme(true),
      snackBarTheme: _buildSnackBarTheme(),
      bottomSheetTheme: _buildBottomSheetTheme(true),
      floatingActionButtonTheme: _buildFabTheme(),
      dividerTheme: _buildDividerTheme(true),
      switchTheme: _buildSwitchTheme(),
    );
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(color: textColor, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
      displayMedium: GoogleFonts.inter(color: textColor, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2),
      displaySmall: GoogleFonts.inter(color: textColor, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.3),
      headlineLarge: GoogleFonts.inter(color: textColor, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.3),
      headlineMedium: GoogleFonts.inter(color: textColor, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3),
      headlineSmall: GoogleFonts.inter(color: textColor, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.1, height: 1.4),
      titleLarge: GoogleFonts.inter(color: textColor, fontSize: 17, fontWeight: FontWeight.w600, height: 1.4),
      titleMedium: GoogleFonts.inter(color: textColor, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      titleSmall: GoogleFonts.inter(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
      bodyLarge: GoogleFonts.inter(color: textColor, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: GoogleFonts.inter(color: secondaryColor, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: GoogleFonts.inter(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3, height: 1.4),
      labelMedium: GoogleFonts.inter(color: secondaryColor, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2, height: 1.3),
      labelSmall: GoogleFonts.inter(color: mutedColor, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2, height: 1.3),
    );
  }

  static AppBarTheme _buildAppBarTheme(bool isDark) {
    return AppBarTheme(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, size: 22,
      ),
      surfaceTintColor: Colors.transparent,
    );
  }

  static CardThemeData _buildCardTheme(bool isDark) {
    return CardThemeData(
      color: isDark ? AppColors.darkCardBg : AppColors.cardBg,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? AppColors.darkSilver : AppColors.silverLight, width: 1),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? AppColors.darkSilver : AppColors.silverLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? AppColors.darkSilver : AppColors.silverLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(
        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted, fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.academyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.2),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.academyBlue,
        side: const BorderSide(color: AppColors.academyBlue, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.2),
      ),
    );
  }

  static ChipThemeData _buildChipTheme(bool isDark) {
    return ChipThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.background,
      selectedColor: AppColors.primaryLight,
      labelStyle: GoogleFonts.inter(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 13,
      ),
      side: BorderSide(color: isDark ? AppColors.darkSilver : AppColors.silverLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      showCheckmark: false,
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme(bool isDark) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      selectedItemColor: AppColors.academyBlue,
      unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  static DialogThemeData _buildDialogTheme(bool isDark) {
    return DialogThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: 20,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.inter(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontSize: 18, fontWeight: FontWeight.w600,
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: GoogleFonts.inter(color: AppColors.surface, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    );
  }

  static BottomSheetThemeData _buildBottomSheetTheme(bool isDark) {
    return BottomSheetThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  static FloatingActionButtonThemeData _buildFabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.academyBlue,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4, shape: CircleBorder(),
    );
  }

  static DividerThemeData _buildDividerTheme(bool isDark) {
    return DividerThemeData(
      color: isDark ? AppColors.darkSilver : AppColors.silverLight,
      thickness: 1, space: 1,
    );
  }

  static SwitchThemeData _buildSwitchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.academyBlue;
        return AppColors.silver;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
        return AppColors.silverLight;
      }),
    );
  }
}
