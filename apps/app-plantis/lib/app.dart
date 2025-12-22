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

class _PlantisAppState extends ConsumerState<PlantisApp> {
  @override
  void initState() {
    super.initState();

    // 🧪 AUTO-LOGIN PARA TESTES (APENAS LOCALHOST)
    if (kDebugMode && _isLocalhost()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performTestAutoLogin();
      });
    }

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
