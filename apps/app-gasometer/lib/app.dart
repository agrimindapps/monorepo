import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/providers/dependency_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/gasometer_theme.dart';
import 'features/settings/presentation/providers/theme_notifier.dart';
import 'main.dart' as main;
import 'shared/widgets/connectivity_banner.dart';

class GasOMeterApp extends ConsumerStatefulWidget {
  const GasOMeterApp({super.key});

  @override
  ConsumerState<GasOMeterApp> createState() => _GasOMeterAppState();
}

class _GasOMeterAppState extends ConsumerState<GasOMeterApp>
    with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize router once, cache it to prevent rebuilds
    _router = ref.read(appRouterProvider);

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

    // 🧪 AUTO-LOGIN PARA TESTES (APENAS LOCALHOST)
    if (kDebugMode && _isLocalhost()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performTestAutoLogin();
      });
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

    // 🔒 Verificação de segurança: apenas processa se o widget ainda está montado
    if (!mounted) return;

    try {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          // App going to background - pause auto-sync
          if (mounted) {
            main.autoSyncService.pause();
          }
          break;
        case AppLifecycleState.resumed:
          // App returning to foreground - resume auto-sync
          if (mounted) {
            main.autoSyncService.resume();
            // ✅ NOVO: Sincronizar imagens pendentes ao voltar ao app
            _syncPendingImages();
          }
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
    // 🔒 Verificação de segurança: apenas executa se o widget ainda está montado
    if (!mounted) return;

    try {
      final imageSyncService = ref.read(imageSyncServiceProvider);
      final result = await imageSyncService.syncPendingImages();

      if (!mounted) return; // Verifica novamente após operação async

      if (result.hasSuccess && kDebugMode) {
        SecureLogger.info('📤 Synced ${result.successful} pending images');
      }

      if (result.hasErrors && kDebugMode) {
        SecureLogger.warning('⚠️ Failed to sync ${result.failed} images');
      }
    } catch (e) {
      if (kDebugMode && mounted) {
        SecureLogger.warning('Failed to sync pending images', error: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = ref.watch(gasometerThemeProvider);

    return MaterialApp.router(
      title: 'GasOMeter - Controle de Veículos',
      theme: GasometerTheme.lightTheme,
      darkTheme: GasometerTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
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

  /// Verifica se está rodando em localhost (Web apenas)
  bool _isLocalhost() {
    if (!kIsWeb) return true; // Mobile/Desktop sempre permite em debug

    try {
      // No Web, verifica se está em localhost
      final uri = Uri.base;
      final host = uri.host.toLowerCase();
      return host == 'localhost' || host == '127.0.0.1' || host == '::1';
    } catch (e) {
      if (kDebugMode) {
        SecureLogger.warning('Failed to check localhost status', error: e);
      }
      return false; // Em caso de erro, não permite auto-login
    }
  }

  /// 🧪 AUTO-LOGIN PARA TESTES
  /// Remove this method in production!
  void _performTestAutoLogin() async {
    // 🔒 Verificação de segurança: apenas executa se o widget ainda está montado
    if (!mounted) return;

    try {
      SecureLogger.info('🧪 [GASOMETER-TEST] Attempting auto-login...');

      final auth = FirebaseAuth.instance;

      // Se já está logado, não faz nada
      if (auth.currentUser != null) {
        SecureLogger.info(
          '🧪 [GASOMETER-TEST] Already logged in as: ${auth.currentUser!.email}',
        );
        return;
      }

      const testEmail = 'lucineiy@hotmail.com';
      const testPassword = 'QWEqwe@123';

      final result = await auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      if (!mounted) return; // Verifica novamente após operação async

      if (result.user != null) {
        SecureLogger.info(
          '🧪 [GASOMETER-TEST] Auto-login successful! User: ${result.user!.email}',
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        SecureLogger.error(
          '🧪 [GASOMETER-TEST] Auto-login error',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }
}
