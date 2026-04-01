import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';


class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.buttonPurpleStart,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.buttonDeepVioletEnd : const Color(0xFFEEEDFE),
      onPrimaryContainer: isDark ? Colors.white : AppColors.buttonDeepVioletEnd,
      secondary: AppColors.cardGoldStart,
      onSecondary: AppColors.lightTextPrimary,
      secondaryContainer: isDark ? const Color(0xFF2A1F00) : AppColors.warningLight,
      onSecondaryContainer: isDark ? AppColors.cardGoldStart : AppColors.lightTextPrimary,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      surfaceContainerHighest: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // ── Background image via scaffoldBackgroundColor is not enough;
      //    use a transparent color so the Stack/Container bg shows through.
      scaffoldBackgroundColor: Colors.transparent,

      // ── Cinzel as the default font family across the whole app ──
      fontFamily: 'Cinzel',

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headline3.copyWith(
          fontFamily: 'Cinzel',
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedItemColor: AppColors.buttonPurpleStart,
        unselectedItemColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontFamily: 'Cinzel'),
        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontFamily: 'Cinzel'),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.buttonPurpleStart,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          fontFamily: 'Cinzel',
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        thickness: 0.5,
        space: 0,
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(fontFamily: 'Cinzel'),
        headlineLarge: AppTextStyles.headline1.copyWith(fontFamily: 'Cinzel'),
        headlineMedium: AppTextStyles.headline2.copyWith(fontFamily: 'Cinzel'),
        headlineSmall: AppTextStyles.headline3.copyWith(fontFamily: 'Cinzel'),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(fontFamily: 'Cinzel'),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(fontFamily: 'Cinzel'),
        bodySmall: AppTextStyles.bodySmall.copyWith(fontFamily: 'Cinzel'),
        labelLarge: AppTextStyles.labelLarge.copyWith(fontFamily: 'Cinzel'),
        labelMedium: AppTextStyles.labelMedium.copyWith(fontFamily: 'Cinzel'),
        labelSmall: AppTextStyles.labelSmall.copyWith(fontFamily: 'Cinzel'),
      ).apply(
        fontFamily: 'Cinzel',
        bodyColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        displayColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }
}