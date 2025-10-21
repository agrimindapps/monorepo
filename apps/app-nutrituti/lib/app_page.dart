import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // TODO: Initialize app-specific services
  }

  @override
  void dispose() {
    // TODO: Dispose resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(currentThemeModeProvider);
    final lightThemeData = ref.watch(lightThemeProvider);
    final darkThemeData = ref.watch(darkThemeProvider);

    return MaterialApp.router(
      title: 'NutriTuti',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
