import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/providers/dependency_providers.dart';
import 'core/config/environment_config.dart';
import 'core/config/dev_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific handling
  await _initializeFirebase();

  // 🧪 AUTO-LOGIN para desenvolvimento (apenas em debug mode)
  if (kDebugMode && !kIsWeb && DevConfig.enableAutoLogin) {
    await _performAutoLogin();
  }

  // Set environment (change for production)
  EnvironmentConfig.setEnvironment(Environment.development);

  // Initialize SharedPreferences for provider override
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run app with Riverpod
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AppNebulalistApp(),
    ),
  );
}

/// Initialize Firebase with platform-specific configuration
Future<void> _initializeFirebase() async {
  try {
    if (kIsWeb) {
      // For web, Firebase needs to be configured via index.html
      // or we can skip Firebase initialization if not configured
      debugPrint('Running on Web - Firebase initialization skipped');
      debugPrint('Configure Firebase in web/index.html for full functionality');
      // Uncomment below when firebase_options.dart is generated:
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
    } else {
      // For mobile platforms
      await Firebase.initializeApp();
      if (DevConfig.verboseLogs) {
        debugPrint('✅ Firebase initialized for mobile platform');
      }
    }
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    debugPrint('⚠️ App will continue without Firebase features');
    // App continues without Firebase - local-first approach
  }
}

/// Auto-login para desenvolvimento (apenas em kDebugMode)
/// Facilita testes sem precisar digitar credenciais manualmente
Future<void> _performAutoLogin() async {
  try {
    final auth = FirebaseAuth.instance;

    // Se já está logado, não faz nada
    if (auth.currentUser != null) {
      if (DevConfig.verboseLogs) {
        debugPrint(
          '🧪 [NEBULALIST-AUTO-LOGIN] Já autenticado como: ${auth.currentUser!.email ?? "anônimo"}',
        );
      }
      return;
    }

    if (DevConfig.verboseLogs) {
      debugPrint('🧪 [NEBULALIST-AUTO-LOGIN] Iniciando auto-login...');
    }

    final userCredential = await auth.signInWithEmailAndPassword(
      email: DevConfig.testEmail,
      password: DevConfig.testPassword,
    );

    if (userCredential.user != null) {
      debugPrint(
        '✅ [NEBULALIST-AUTO-LOGIN] Login automático bem-sucedido! '
        'Usuário: ${userCredential.user!.email}',
      );
    }
  } catch (e, stackTrace) {
    debugPrint('❌ [NEBULALIST-AUTO-LOGIN] Falha no auto-login: $e');
    if (DevConfig.verboseLogs) {
      debugPrint('Stack: $stackTrace');
    }
    
    // Em caso de erro, tenta login anônimo como fallback
    if (DevConfig.useAnonymousFallback) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint('⚠️ [NEBULALIST-AUTO-LOGIN] Fallback para login anônimo');
      } catch (e2) {
        debugPrint('❌ [NEBULALIST-AUTO-LOGIN] Falha no fallback anônimo: $e2');
      }
    }
  }
}
