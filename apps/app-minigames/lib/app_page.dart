import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(currentThemeModeProvider);
    final lightThemeData = ref.watch(lightThemeProvider);
    final darkThemeData = ref.watch(darkThemeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MiniGames',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
