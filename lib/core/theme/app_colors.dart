import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand core ───────────────────────────────────────────
  static const Color bgBase = Color(0xFF000000);
  static const Color bgPinkOverlay = Color(0xFFA40869); // 20% opacity overlay

  static const Color cardGoldStart = Color(0xFFFDC333);
  static const Color cardOrangeEnd = Color(0xFFF67D2D);

  static const Color buttonPurpleStart = Color(0xFF8C48CD);
  static const Color buttonDeepVioletEnd = Color(0xFF230A3E);

  // ─── Gradients ────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.0409, 1.0],
    colors: [bgBase, bgBase, Color(0x33A40869)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cardGoldStart, cardOrangeEnd],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [buttonPurpleStart, buttonDeepVioletEnd],
  );

  // ─── Subject card gradients ────────────────────────────────
  static const LinearGradient mathGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8C48CD), Color(0xFF5A1F9E)],
  );

  static const LinearGradient physicsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDC333), Color(0xFFF67D2D)],
  );

  // ─── Semantic colors ──────────────────────────────────────
  static const Color success = Color(0xFF1D9E75);
  static const Color successLight = Color(0xFFE1F5EE);
  static const Color error = Color(0xFFE24B4A);
  static const Color errorLight = Color(0xFFFCEBEB);
  static const Color warning = Color(0xFFEF9F27);
  static const Color warningLight = Color(0xFFFAEEDA);
  static const Color info = Color(0xFF378ADD);
  static const Color infoLight = Color(0xFFE6F1FB);

  // ─── Star color ───────────────────────────────────────────
  static const Color starGold = Color(0xFFFDC333);
  static const Color starEmpty = Color(0xFF3A3A3A);

  // ─── Light theme surfaces ─────────────────────────────────
  static const Color lightBg = Color(0xFFF5F4F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF0EFE9);
  static const Color lightBorder = Color(0xFFE2E0D8);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6966);
  static const Color lightTextTertiary = Color(0xFF9E9B96);

  // ─── Dark theme surfaces ──────────────────────────────────
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF161616);
  static const Color darkSurface2 = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFF0EFE9);
  static const Color darkTextSecondary = Color(0xFF9E9B96);
  static const Color darkTextTertiary = Color(0xFF5F5E5A);
}
