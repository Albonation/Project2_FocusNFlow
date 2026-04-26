//this file actually sets the colors for the app
//and assigns those colors to actual UI components
import 'package:flutter/material.dart';
import 'app_colors_extension.dart';
import 'app_corners.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const appColors = AppColors(
      brand: Color(0xFF2563EB),
      focus: Color(0xFF2563EB),
      group: Color(0xFF8B5CF6),
      task: Color(0xFF0EA5E9),
      studyRoom: Color(0xFF7C3AED),
      planner: Color(0xFFF59E0B),
      success: Color(0xFF10B981),
      warning: Color(0xFFF97316),
      danger: Color(0xFFEF4444),

      surfaceSoft: Color(0xFFF8F6F6),//0xFFF8FAFC
      surfaceMuted: Color(0xFFB4B6BC),
      surfaceStrong: Color(0xFFE2E8F0),

      cardBorder: Color(0xFFE2E8F0),
      navBorder: Color(0xFFCBD5E1),
    );

    return _buildTheme(
      appColors: appColors,
      brightness: Brightness.light,
      cardColor: appColors.surfaceMuted,
    );
  }

  static ThemeData get darkTheme {
    const appColors = AppColors(
      brand: Color(0xFF60A5FA),
      focus: Color(0xFF599BEE),
      group: Color(0xFFA78BFA),
      task: Color(0xFF38BDF8),
      studyRoom: Color(0xFFC084FC),
      planner: Color(0xFFFBBF24),
      success: Color(0xFF34D399),
      warning: Color(0xFFFB923C),
      danger: Color(0xFFF87171),

      surfaceSoft: Color(0xFF020617),
      surfaceMuted: Color(0xFF0F172A),
      surfaceStrong: Color(0xFF1E293B),

      cardBorder: Color(0xFF334155),
      navBorder: Color(0xFF334155),
    );

    return _buildTheme(
      appColors: appColors,
      brightness: Brightness.dark,
      cardColor: appColors.surfaceMuted,
    );
  }

  static ThemeData _buildTheme({
    required AppColors appColors,
    required Brightness brightness,
    required Color cardColor,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: appColors.brand,
      brightness: brightness,
    );

    final inputTheme = _inputDecorationTheme(
      appColors: appColors,
      scheme: scheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: appColors.surfaceSoft,
      dividerColor: appColors.cardBorder,
      extensions: <ThemeExtension<dynamic>>[appColors],

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.lg),
          side: BorderSide(color: appColors.cardBorder, width: 1),
        ),
      ),
      //set the input decoration theme globally to ensure consistent styling across all input fields
      //including those in dialogs and dropdowns
      inputDecorationTheme: inputTheme,

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.xl),
          side: BorderSide(color: appColors.cardBorder, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        modalBackgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.onSurfaceVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppCorners.xl),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: AppSpacing.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppCorners.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: appColors.brand,
          foregroundColor: Colors.white,
          padding: AppSpacing.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppCorners.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appColors.brand,
          side: BorderSide(color: appColors.focus, width: 1),
          padding: AppSpacing.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppCorners.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appColors.brand,
          padding: AppSpacing.smallButton,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurfaceVariant),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listTilePadding,
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        subtitleTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
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

      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.md),
          side: BorderSide(color: appColors.cardBorder, width: 1),
        ),
        textStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        inputDecorationTheme: inputTheme,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(cardColor),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppCorners.md),
              side: BorderSide(color: appColors.cardBorder, width: 1),
            ),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCorners.xl),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: appColors.surfaceMuted,
        selectedItemColor: appColors.focus,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        showUnselectedLabels: true,
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(
        color: appColors.cardBorder,
        thickness: 1,
        space: AppSpacing.lg,
      ),
    );
  }

  //helper method to create a consistent input decoration theme
  //for all text fields and dropdowns in the app
  //ensuring a cohesive look and feel across all form elements
  static InputDecorationTheme _inputDecorationTheme({
    required AppColors appColors,
    required ColorScheme scheme,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: appColors.surfaceMuted,
      contentPadding: AppSpacing.inputContent,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(
        color: appColors.brand,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppCorners.md),
        borderSide: BorderSide(color: appColors.cardBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppCorners.md),
        borderSide: BorderSide(color: appColors.cardBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppCorners.md),
        borderSide: BorderSide(color: appColors.focus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppCorners.md),
        borderSide: BorderSide(color: appColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppCorners.md),
        borderSide: BorderSide(color: appColors.danger, width: 2),
      ),
    );
  }
}
