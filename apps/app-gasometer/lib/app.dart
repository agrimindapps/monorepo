import 'package:core/core.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/gasometer_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'GasOMeter - Controle de Veículos',
      theme: GasometerTheme.lightTheme,
      darkTheme: GasometerTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
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
