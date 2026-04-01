import 'package:eazyconcepts/shared/widgets/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/routes.dart';
// import 'core/widgets/app_background.dart'; // <-- add this
import 'data/local/hive_service.dart';
import 'data/local/providers.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: EazyConceptsApp()));
}

class EazyConceptsApp extends ConsumerWidget {
  const EazyConceptsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'EazyConcepts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generate,
      // ── Wraps every screen, dialog & bottom sheet with the bg image ──
      builder: (context, child) => AppBackground(child: child!),
    );
  }
}