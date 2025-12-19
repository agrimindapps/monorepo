import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/config/app_config.dart';

/// Main application widget
/// Configures MaterialApp with routing, theming, and localization
class AppNebulalistApp extends ConsumerWidget {
  const AppNebulalistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme provider for dynamic theme changes
    final themeMode = ref.watch(themeProvider);
    // Watch router provider
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration with dynamic theme mode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router configuration with auth protection
      routerConfig: router,

      // Localization (if needed)
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('pt', 'BR'),
      //   Locale('en', 'US'),
      // ],
    );
  }
}
