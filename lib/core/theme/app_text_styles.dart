import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Display ──────────────────────────────────────────────
  static const TextStyle display = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );

  // ─── Body ─────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'CinzelDecorative',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Labels ───────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  // ─── Lesson-specific ──────────────────────────────────────
  static const TextStyle lessonConceptTitle = TextStyle(
    fontFamily: 'CinzelDecorative',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle lessonBody = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  // monospace kept for equations — Cinzel won't render math symbols correctly
  static const TextStyle lessonEquation = TextStyle(
    fontFamily: 'monospace',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}