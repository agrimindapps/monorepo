import 'package:core/core.dart' hide AuthProvider, Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/providers/dependency_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/gasometer_theme.dart';
import 'features/settings/presentation/providers/settings_notifier.dart';
import 'main.dart' as main;
import 'shared/widgets/connectivity_banner.dart';

class GasOMeterApp extends ConsumerStatefulWidget {
  const GasOMeterApp({super.key});

  @override
  ConsumerState<GasOMeterApp> createState() => _GasOMeterAppState();
}

class _GasOMeterAppState extends ConsumerState<GasOMeterApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start auto-sync when app initializes
    try {
      main.autoSyncService.start();
    } catch (e) {
      if (kDebugMode) {
        SecureLogger.warning('Failed to start auto-sync service', error: e);
      }
    }

    // ✅ NOVO: Sincronizar imagens pendentes ao abrir o app
    _syncPendingImages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    try {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          // App going to background - pause auto-sync
          main.autoSyncService.pause();
          break;
        case AppLifecycleState.resumed:
          // App returning to foreground - resume auto-sync
          main.autoSyncService.resume();
          // ✅ NOVO: Sincronizar imagens pendentes ao voltar ao app
          _syncPendingImages();
          break;
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          // No action needed
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        SecureLogger.warning('Error handling lifecycle state change', error: e);
      }
    }
  }

  /// Sincroniza imagens pendentes de upload (offline → online)
  Future<void> _syncPendingImages() async {
    try {
      final imageSyncService = ref.read(imageSyncServiceProvider);
      final result = await imageSyncService.syncPendingImages();

      if (result.hasSuccess && kDebugMode) {
        SecureLogger.info('📤 Synced ${result.successful} pending images');
      }

      if (result.hasErrors && kDebugMode) {
        SecureLogger.warning('⚠️ Failed to sync ${result.failed} images');
      }
    } catch (e) {
      if (kDebugMode) {
        SecureLogger.warning('Failed to sync pending images', error: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(appRouterProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'GasOMeter - Controle de Veículos',
      theme: GasometerTheme.lightTheme,
      darkTheme: GasometerTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      builder: (context, child) {
        return Column(
          children: [
            const ConnectivityBanner(),
            Expanded(child: child ?? const SizedBox()),
          ],
        );
      },
    );
  }
}
