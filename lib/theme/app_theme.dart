//this file actually sets the colors for the app
//and assigns those colors to actual UI components
import 'package:flutter/material.dart';
import 'app_colors_extension.dart';
import 'app_corners.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const appColors = AppColors(
      brand: Color(0xFF2563EB),
      focus: Color(0xFF2563EB),
      group: Color(0xFF2563EB),
      task: Color(0xFF2563EB),
      studyRoom: Color(0xFF7C3AED),
      planner: Color(0xFFF59E0B),
      success: Color(0xFF10B981),
      warning: Color(0xFFF97316),
      danger: Color(0xFFEF4444),

      surfaceSoft: Color(0xFFF8FAFC),
      surfaceMuted: Color(0xFFF1F5F9),
      surfaceStrong: Color(0xFFE2E8F0),

      cardBorder: Color(0xFFE2E8F0),
      navBorder: Color(0xFFE2E8F0),
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: appColors.brand,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: appColors.surfaceSoft,
      extensions: <ThemeExtension<dynamic>>[
        appColors,
      ],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.lg),
          side: BorderSide(color: appColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          borderSide: BorderSide(color: appColors.brand, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: appColors.surfaceMuted,
        selectedColor: appColors.brand,
        disabledColor: appColors.surfaceStrong,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.pill),
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.xl),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: appColors.surfaceMuted,
        selectedItemColor: appColors.brand,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerColor: appColors.cardBorder,
    );
  } //end lightTheme

  static ThemeData get darkTheme {
    const appColors = AppColors(
      brand: Color(0xFF60A5FA),
      focus: Color(0xFF60A5FA),
      group: Color(0xFF60A5FA),
      task: Color(0xFF60A5FA),
      studyRoom: Color(0xFFA78BFA),
      planner: Color(0xFFFBBF24),
      success: Color(0xFF34D399),
      warning: Color(0xFFFB923C),
      danger: Color(0xFFF87171),

      surfaceSoft: Color(0xFF020617),
      surfaceMuted: Color(0xFF0F172A),
      surfaceStrong: Color(0xFF1E293B),

      cardBorder: Color(0xFF1E293B),
      navBorder: Color(0xFF1E293B),
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: appColors.brand,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: appColors.surfaceSoft,
      extensions: <ThemeExtension<dynamic>>[
        appColors,
      ],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: appColors.surfaceMuted,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.lg),
          side: BorderSide(color: appColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          borderSide: BorderSide(color: appColors.brand, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: appColors.surfaceStrong,
        selectedColor: appColors.brand,
        disabledColor: appColors.surfaceStrong,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.pill),
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.xl),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: appColors.surfaceMuted,
        selectedItemColor: appColors.brand,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerColor: appColors.cardBorder,
    );
  } //end darkTheme
}
