import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/providers/sync_completion_listener.dart';
import 'core/router/app_router.dart';
import 'core/theme/plantis_theme.dart';
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
    
    // 🧪 AUTO-LOGIN PARA TESTES (remover em produção)
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performTestAutoLogin();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa o listener de sincronização
    ref.watch(syncCompletionListenerInitializerProvider);

    final router = AppRouter.router(ref);
    const currentThemeMode = ThemeMode.system;

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
}
