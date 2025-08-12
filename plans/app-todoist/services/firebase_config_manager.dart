// Flutter imports:
// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Gerenciador seguro de configurações Firebase
/// Remove configurações hardcoded e usa environment variables
class FirebaseConfigManager {
  static final FirebaseConfigManager _instance = FirebaseConfigManager._internal();
  factory FirebaseConfigManager() => _instance;
  FirebaseConfigManager._internal();

  /// Environment configurations
  static const String _devEnvironment = 'dev';
  static const String _stagingEnvironment = 'staging';
  static const String _prodEnvironment = 'prod';

  /// Obter configuração atual baseada no ambiente
  FirebaseOptions get currentPlatformOptions {
    final environment = _getCurrentEnvironment();
    
    if (kIsWeb) {
      return _getWebOptions(environment);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _getAndroidOptions(environment);
      case TargetPlatform.iOS:
        return _getIosOptions(environment);
      case TargetPlatform.macOS:
        return _getMacosOptions(environment);
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase not configured for Windows. Please configure via environment variables.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase not configured for Linux. Please configure via environment variables.',
        );
      default:
        throw UnsupportedError(
          'Firebase not supported for this platform.',
        );
    }
  }

  /// Determinar ambiente atual
  String _getCurrentEnvironment() {
    // Tentar obter do environment variable primeiro
    const environment = String.fromEnvironment('FLUTTER_ENV');
    if (environment.isNotEmpty) {
      return environment;
    }

    // Fallback baseado em debug/release mode
    if (kDebugMode) {
      return _devEnvironment;
    } else {
      return _prodEnvironment;
    }
  }

  /// Configuração Web por ambiente
  FirebaseOptions _getWebOptions(String environment) {
    switch (environment) {
      case _devEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('WEB_API_KEY_DEV', 'development-web-key'),
          appId: _getConfigValue('WEB_APP_ID_DEV', 'development-web-app-id'),
          messagingSenderId: _getConfigValue('WEB_MESSAGING_SENDER_ID_DEV', 'dev-sender-id'),
          projectId: _getConfigValue('WEB_PROJECT_ID_DEV', 'dev-project-id'),
          authDomain: _getConfigValue('WEB_AUTH_DOMAIN_DEV', 'dev-project.firebaseapp.com'),
          storageBucket: _getConfigValue('WEB_STORAGE_BUCKET_DEV', 'dev-project.firebasestorage.app'),
          measurementId: _getConfigValue('WEB_MEASUREMENT_ID_DEV', 'G-DEVMEASURE'),
        );
      
      case _stagingEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('WEB_API_KEY_STAGING', 'staging-web-key'),
          appId: _getConfigValue('WEB_APP_ID_STAGING', 'staging-web-app-id'),
          messagingSenderId: _getConfigValue('WEB_MESSAGING_SENDER_ID_STAGING', 'staging-sender-id'),
          projectId: _getConfigValue('WEB_PROJECT_ID_STAGING', 'staging-project-id'),
          authDomain: _getConfigValue('WEB_AUTH_DOMAIN_STAGING', 'staging-project.firebaseapp.com'),
          storageBucket: _getConfigValue('WEB_STORAGE_BUCKET_STAGING', 'staging-project.firebasestorage.app'),
          measurementId: _getConfigValue('WEB_MEASUREMENT_ID_STAGING', 'G-STAGINGMEASURE'),
        );
      
      case _prodEnvironment:
      default:
        return FirebaseOptions(
          apiKey: _getConfigValue('WEB_API_KEY_PROD', ''),
          appId: _getConfigValue('WEB_APP_ID_PROD', ''),
          messagingSenderId: _getConfigValue('WEB_MESSAGING_SENDER_ID_PROD', ''),
          projectId: _getConfigValue('WEB_PROJECT_ID_PROD', ''),
          authDomain: _getConfigValue('WEB_AUTH_DOMAIN_PROD', ''),
          storageBucket: _getConfigValue('WEB_STORAGE_BUCKET_PROD', ''),
          measurementId: _getConfigValue('WEB_MEASUREMENT_ID_PROD', ''),
        );
    }
  }

  /// Configuração Android por ambiente
  FirebaseOptions _getAndroidOptions(String environment) {
    switch (environment) {
      case _devEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('ANDROID_API_KEY_DEV', 'development-android-key'),
          appId: _getConfigValue('ANDROID_APP_ID_DEV', 'development-android-app-id'),
          messagingSenderId: _getConfigValue('ANDROID_MESSAGING_SENDER_ID_DEV', 'dev-sender-id'),
          projectId: _getConfigValue('ANDROID_PROJECT_ID_DEV', 'dev-project-id'),
          storageBucket: _getConfigValue('ANDROID_STORAGE_BUCKET_DEV', 'dev-project.firebasestorage.app'),
        );
      
      case _stagingEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('ANDROID_API_KEY_STAGING', 'staging-android-key'),
          appId: _getConfigValue('ANDROID_APP_ID_STAGING', 'staging-android-app-id'),
          messagingSenderId: _getConfigValue('ANDROID_MESSAGING_SENDER_ID_STAGING', 'staging-sender-id'),
          projectId: _getConfigValue('ANDROID_PROJECT_ID_STAGING', 'staging-project-id'),
          storageBucket: _getConfigValue('ANDROID_STORAGE_BUCKET_STAGING', 'staging-project.firebasestorage.app'),
        );
      
      case _prodEnvironment:
      default:
        return FirebaseOptions(
          apiKey: _getConfigValue('ANDROID_API_KEY_PROD', ''),
          appId: _getConfigValue('ANDROID_APP_ID_PROD', ''),
          messagingSenderId: _getConfigValue('ANDROID_MESSAGING_SENDER_ID_PROD', ''),
          projectId: _getConfigValue('ANDROID_PROJECT_ID_PROD', ''),
          storageBucket: _getConfigValue('ANDROID_STORAGE_BUCKET_PROD', ''),
        );
    }
  }

  /// Configuração iOS por ambiente
  FirebaseOptions _getIosOptions(String environment) {
    switch (environment) {
      case _devEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('IOS_API_KEY_DEV', 'development-ios-key'),
          appId: _getConfigValue('IOS_APP_ID_DEV', 'development-ios-app-id'),
          messagingSenderId: _getConfigValue('IOS_MESSAGING_SENDER_ID_DEV', 'dev-sender-id'),
          projectId: _getConfigValue('IOS_PROJECT_ID_DEV', 'dev-project-id'),
          storageBucket: _getConfigValue('IOS_STORAGE_BUCKET_DEV', 'dev-project.firebasestorage.app'),
          iosBundleId: _getConfigValue('IOS_BUNDLE_ID_DEV', 'br.com.agrimind.winfinancas.dev'),
        );
      
      case _stagingEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('IOS_API_KEY_STAGING', 'staging-ios-key'),
          appId: _getConfigValue('IOS_APP_ID_STAGING', 'staging-ios-app-id'),
          messagingSenderId: _getConfigValue('IOS_MESSAGING_SENDER_ID_STAGING', 'staging-sender-id'),
          projectId: _getConfigValue('IOS_PROJECT_ID_STAGING', 'staging-project-id'),
          storageBucket: _getConfigValue('IOS_STORAGE_BUCKET_STAGING', 'staging-project.firebasestorage.app'),
          iosBundleId: _getConfigValue('IOS_BUNDLE_ID_STAGING', 'br.com.agrimind.winfinancas.staging'),
        );
      
      case _prodEnvironment:
      default:
        return FirebaseOptions(
          apiKey: _getConfigValue('IOS_API_KEY_PROD', ''),
          appId: _getConfigValue('IOS_APP_ID_PROD', ''),
          messagingSenderId: _getConfigValue('IOS_MESSAGING_SENDER_ID_PROD', ''),
          projectId: _getConfigValue('IOS_PROJECT_ID_PROD', ''),
          storageBucket: _getConfigValue('IOS_STORAGE_BUCKET_PROD', ''),
          iosBundleId: _getConfigValue('IOS_BUNDLE_ID_PROD', 'br.com.agrimind.winfinancas'),
        );
    }
  }

  /// Configuração macOS por ambiente
  FirebaseOptions _getMacosOptions(String environment) {
    switch (environment) {
      case _devEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('MACOS_API_KEY_DEV', 'development-macos-key'),
          appId: _getConfigValue('MACOS_APP_ID_DEV', 'development-macos-app-id'),
          messagingSenderId: _getConfigValue('MACOS_MESSAGING_SENDER_ID_DEV', 'dev-sender-id'),
          projectId: _getConfigValue('MACOS_PROJECT_ID_DEV', 'dev-project-id'),
          storageBucket: _getConfigValue('MACOS_STORAGE_BUCKET_DEV', 'dev-project.firebasestorage.app'),
          iosBundleId: _getConfigValue('MACOS_BUNDLE_ID_DEV', 'br.com.agrimind.winfinancas.dev'),
        );
      
      case _stagingEnvironment:
        return FirebaseOptions(
          apiKey: _getConfigValue('MACOS_API_KEY_STAGING', 'staging-macos-key'),
          appId: _getConfigValue('MACOS_APP_ID_STAGING', 'staging-macos-app-id'),
          messagingSenderId: _getConfigValue('MACOS_MESSAGING_SENDER_ID_STAGING', 'staging-sender-id'),
          projectId: _getConfigValue('MACOS_PROJECT_ID_STAGING', 'staging-project-id'),
          storageBucket: _getConfigValue('MACOS_STORAGE_BUCKET_STAGING', 'staging-project.firebasestorage.app'),
          iosBundleId: _getConfigValue('MACOS_BUNDLE_ID_STAGING', 'br.com.agrimind.winfinancas.staging'),
        );
      
      case _prodEnvironment:
      default:
        return FirebaseOptions(
          apiKey: _getConfigValue('MACOS_API_KEY_PROD', ''),
          appId: _getConfigValue('MACOS_APP_ID_PROD', ''),
          messagingSenderId: _getConfigValue('MACOS_MESSAGING_SENDER_ID_PROD', ''),
          projectId: _getConfigValue('MACOS_PROJECT_ID_PROD', ''),
          storageBucket: _getConfigValue('MACOS_STORAGE_BUCKET_PROD', ''),
          iosBundleId: _getConfigValue('MACOS_BUNDLE_ID_PROD', 'br.com.agrimind.winfinancas'),
        );
    }
  }

  /// Obter valor de configuração com fallback
  String _getConfigValue(String key, String fallback) {
    final actualConfig = String.fromEnvironment(key);
    if (actualConfig.isNotEmpty) {
      return actualConfig;
    }

    // Em modo de desenvolvimento, usar fallback
    if (kDebugMode && fallback.isNotEmpty) {
      return fallback;
    }

    // Em produção sem configuração, falhar explicitamente
    if (!kDebugMode) {
      throw Exception(
        'Firebase configuration missing: $key. '
        'Please set environment variable for production build.',
      );
    }

    return fallback;
  }

  /// Validar se configuração está completa
  bool validateConfiguration() {
    try {
      final options = currentPlatformOptions;
      
      // Verificar campos obrigatórios
      if (options.apiKey.isEmpty) return false;
      if (options.appId.isEmpty) return false;
      if (options.projectId.isEmpty) return false;
      if (options.messagingSenderId.isEmpty) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obter informações de configuração (sanitizadas)
  Map<String, dynamic> getConfigInfo() {
    final environment = _getCurrentEnvironment();
    final isValid = validateConfiguration();
    
    return {
      'environment': environment,
      'platform': defaultTargetPlatform.name,
      'is_web': kIsWeb,
      'is_valid': isValid,
      'debug_mode': kDebugMode,
      'config_source': kDebugMode ? 'fallback_values' : 'environment_variables',
    };
  }

  /// Exemplo de arquivo de configuração para environment variables
  String generateEnvironmentTemplate() {
    return '''
# Firebase Configuration Template
# Copy this to your environment configuration

# Development Environment
WEB_API_KEY_DEV=your-dev-web-api-key
WEB_APP_ID_DEV=your-dev-web-app-id
WEB_PROJECT_ID_DEV=your-dev-project-id
WEB_MESSAGING_SENDER_ID_DEV=your-dev-sender-id
WEB_AUTH_DOMAIN_DEV=your-dev-project.firebaseapp.com
WEB_STORAGE_BUCKET_DEV=your-dev-project.firebasestorage.app
WEB_MEASUREMENT_ID_DEV=G-DEVMEASUREMENT

ANDROID_API_KEY_DEV=your-dev-android-api-key
ANDROID_APP_ID_DEV=your-dev-android-app-id
ANDROID_PROJECT_ID_DEV=your-dev-project-id
ANDROID_MESSAGING_SENDER_ID_DEV=your-dev-sender-id
ANDROID_STORAGE_BUCKET_DEV=your-dev-project.firebasestorage.app

IOS_API_KEY_DEV=your-dev-ios-api-key
IOS_APP_ID_DEV=your-dev-ios-app-id
IOS_PROJECT_ID_DEV=your-dev-project-id
IOS_MESSAGING_SENDER_ID_DEV=your-dev-sender-id
IOS_STORAGE_BUCKET_DEV=your-dev-project.firebasestorage.app
IOS_BUNDLE_ID_DEV=br.com.agrimind.winfinancas.dev

# Production Environment (required for release builds)
WEB_API_KEY_PROD=your-prod-web-api-key
WEB_APP_ID_PROD=your-prod-web-app-id
WEB_PROJECT_ID_PROD=your-prod-project-id
WEB_MESSAGING_SENDER_ID_PROD=your-prod-sender-id
WEB_AUTH_DOMAIN_PROD=your-prod-project.firebaseapp.com
WEB_STORAGE_BUCKET_PROD=your-prod-project.firebasestorage.app
WEB_MEASUREMENT_ID_PROD=G-PRODMEASUREMENT

ANDROID_API_KEY_PROD=your-prod-android-api-key
ANDROID_APP_ID_PROD=your-prod-android-app-id
ANDROID_PROJECT_ID_PROD=your-prod-project-id
ANDROID_MESSAGING_SENDER_ID_PROD=your-prod-sender-id
ANDROID_STORAGE_BUCKET_PROD=your-prod-project.firebasestorage.app

IOS_API_KEY_PROD=your-prod-ios-api-key
IOS_APP_ID_PROD=your-prod-ios-app-id
IOS_PROJECT_ID_PROD=your-prod-project-id
IOS_MESSAGING_SENDER_ID_PROD=your-prod-sender-id
IOS_STORAGE_BUCKET_PROD=your-prod-project.firebasestorage.app
IOS_BUNDLE_ID_PROD=br.com.agrimind.winfinancas
''';
  }
}