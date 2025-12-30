import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/providers/realtime_sync_providers.dart';
import 'core/providers/sync_completion_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/plantis_theme.dart';
import 'features/settings/presentation/providers/notifiers/plantis_theme_notifier.dart';
import 'shared/widgets/desktop_keyboard_shortcuts.dart';

/// Verifica se está rodando em localhost (Web apenas)
bool _isLocalhost() {
  if (!kIsWeb) return true; // Mobile/Desktop sempre permite em debug

  try {
    final uri = Uri.base;
    final host = uri.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Failed to check localhost status: $e');
    }
    return false; // Fail-safe: bloqueia em caso de erro
  }
}

class PlantisApp extends ConsumerStatefulWidget {
  const PlantisApp({super.key});

  @override
  ConsumerState<PlantisApp> createState() => _PlantisAppState();
}

class _PlantisAppState extends ConsumerState<PlantisApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🧪 AUTO-LOGIN PARA TESTES (APENAS LOCALHOST)
    if (kDebugMode && _isLocalhost()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performTestAutoLogin();
      });
    }

    // 📊 Analytics: Start initial session tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSessionTracking();
    });

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
  void dispose() {
    // 📊 Analytics: End session on dispose
    _endSessionTracking();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    try {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          // 📊 Analytics: End session tracking
          _endSessionTracking();
          break;
        case AppLifecycleState.resumed:
          // 📊 Analytics: Start session tracking
          _startSessionTracking();
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

  /// 📊 Inicia tracking de sessão para analytics
  void _startSessionTracking() {
    try {
      ref.read(sessionTrackingProvider.notifier).startSession();
      ref.read(engagementMetricsProvider.notifier).startNewSession();
      if (kDebugMode) {
        SecureLogger.info('📊 [Analytics] Session started');
      }
    } catch (e) {
      if (kDebugMode) {
        SecureLogger.warning('Failed to start session tracking', error: e);
      }
    }
  }

  /// 📊 Finaliza tracking de sessão para analytics
  void _endSessionTracking() {
    try {
      final sessionDuration = ref.read(currentSessionDurationProvider);
      ref.read(sessionTrackingProvider.notifier).endSession();
      ref.read(engagementMetricsProvider.notifier).addSessionTime(sessionDuration);
      if (kDebugMode) {
        SecureLogger.info('📊 [Analytics] Session ended (${sessionDuration.inSeconds}s)');
      }
    } catch (e) {
      if (kDebugMode) {
        SecureLogger.warning('Failed to end session tracking', error: e);
      }
    }
  }

  /// 🧪 AUTO-LOGIN PARA TESTES
  /// Remove this method in production!
  void _performTestAutoLogin() async {
    try {
      SecureLogger.info('🧪 [PLANTIS-TEST] Attempting auto-login...');

      final auth = FirebaseAuth.instance;

      // Se já está logado, não faz nada
      if (auth.currentUser != null) {
        SecureLogger.info(
          '🧪 [PLANTIS-TEST] Already logged in as: ${auth.currentUser!.email}',
        );
        return;
      }

      const testEmail = 'lucineiy@hotmail.com';
      const testPassword = 'QWEqwe@123';

      final result = await auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      if (result.user != null) {
        SecureLogger.info(
          '🧪 [PLANTIS-TEST] Auto-login successful! User: ${result.user!.email}',
        );
      }
    } catch (e, stackTrace) {
      SecureLogger.error(
        '🧪 [PLANTIS-TEST] Auto-login error',
        error: e,
        stackTrace: stackTrace,
      );
    }
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
        title: 'CantinhoVerde - Seu Jardim de Apartamento',
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
