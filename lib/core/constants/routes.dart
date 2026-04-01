import 'package:flutter/material.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/subjects/subjects_screen.dart';
import '../../features/subjects/chapter_screen.dart';
import '../../features/lesson/lesson_screen.dart';
import '../../features/lesson/lesson_complete_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../core/navigation/main_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String shell = '/shell';
  static const String home = '/home';
  static const String subjects = '/subjects';
  static const String chapter = '/chapter';
  static const String lesson = '/lesson';
  static const String lessonComplete = '/lesson/complete';
  static const String profile = '/profile';
}

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen(), settings);

      case AppRoutes.shell:
        return _fade(const MainShell(), settings);

      case AppRoutes.chapter:
        final args = settings.arguments as Map<String, String>;
        return _slide(ChapterScreen(
          moduleId: args['moduleId']!,
          chapterId: args['chapterId']!,
        ), settings);

      case AppRoutes.lesson:
        final lessonId = settings.arguments as String;
        return _slideUp(LessonScreen(lessonId: lessonId), settings);

      case AppRoutes.lessonComplete:
        final args = settings.arguments as Map<String, dynamic>;
        return _slideUp(LessonCompleteScreen(
          lessonId: args['lessonId'] as String,
          result: args['result'],
        ), settings);

      case AppRoutes.profile:
        return _slide(const ProfileScreen(), settings);

      default:
        return _fade(const MainShell(), settings);
    }
  }

  static PageRoute _fade(Widget page, RouteSettings settings) => PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      );

  static PageRoute _slide(Widget page, RouteSettings settings) => PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      );

  static PageRoute _slideUp(Widget page, RouteSettings settings) => PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
        fullscreenDialog: true,
      );
}
