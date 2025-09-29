import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/plantis_theme.dart';
import 'shared/widgets/desktop_keyboard_shortcuts.dart';

class PlantisApp extends ConsumerWidget {
  const PlantisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Migrado para Riverpod puro - sem mais dependências do Provider package
    final router = AppRouter.router(ref);
    
    // Tema simplificado - será migrado para Riverpod posteriormente
    final currentThemeMode = ThemeMode.system;

    return DesktopKeyboardShortcuts(
      child: MaterialApp.router(
        title: 'Plantis - Cuidado de Plantas',
        theme: PlantisTheme.lightTheme,
        darkTheme: PlantisTheme.darkTheme,
        themeMode: currentThemeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('pt', 'BR'),
      ),
    );
  }
}
