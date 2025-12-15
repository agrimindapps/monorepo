import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/providers/realtime_sync_providers.dart';
import 'core/providers/sync_completion_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/plantis_theme.dart';
import 'features/settings/presentation/providers/notifiers/plantis_theme_notifier.dart';
import 'shared/widgets/desktop_keyboard_shortcuts.dart';

class PlantisApp extends ConsumerStatefulWidget {
  const PlantisApp({super.key});

  @override
  ConsumerState<PlantisApp> createState() => _PlantisAppState();
}

class _PlantisAppState extends ConsumerState<PlantisApp> {
  @override
  void initState() {
    super.initState();

    // Mark first frame rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final performance = PerformanceService();
      performance.markFirstFrame();

      // Mark app as interactive after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        performance.markAppInteractive();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa o listener de sincronização
    ref.watch(syncCompletionListenerInitializerProvider);

    // Inicializa o serviço de sincronização em tempo real
    ref.watch(realtimeSyncServiceProvider);

    final router = AppRouter.router(ref);
    final currentThemeMode = ref.watch(plantisThemeProvider);

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
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        locale: const Locale('pt', 'BR'),
      ),
    );
  }
}
