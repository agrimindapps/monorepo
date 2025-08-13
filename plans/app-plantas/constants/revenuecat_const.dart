// ESTRUTURA CENTRALIZADA - App Plantas
// Este arquivo usa a configuração centralizada em core/constants/subscription_constants.dart

// Project imports:
import '../../core/services/subscription_factory_service.dart';

const String _appId = 'plantas';

// Getters que retornam as configurações da estrutura centralizada
String get entitlementID =>
    SubscriptionFactoryService.getEntitlementIdForApp(_appId);

String get appleApiKey =>
    SubscriptionFactoryService.getAppleApiKeyForApp(_appId);

String get googleApiKey =>
    SubscriptionFactoryService.getGoogleApiKeyForApp(_appId);

// Métodos de conveniência para validação das API keys
bool get hasValidApiKeys => SubscriptionFactoryService.hasValidApiKeys(_appId);

bool get isConfigurationReady =>
    SubscriptionFactoryService.validateAppConfig(_appId);

// Informações específicas do RevenueCat para o app Plantas
class PlantasRevenueCatConfig {
  static const String appId = 'plantas';
  static const String displayName = 'Plantas - Grow Premium';

  // Configurações de desenvolvimento/produção
  static const bool isDevelopment = true; // Alterar para false em produção

  // Configurações de log
  static const bool enableDebugLogs = true;

  // Configurações de ofertas
  static const Duration offerTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // Método para verificar se o ambiente está configurado
  static bool get isEnvironmentReady {
    try {
      final config = SubscriptionFactoryService.createConfig(_appId);
      return config.appleApiKey.isNotEmpty && config.googleApiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Método para obter informações de debug
  static Map<String, dynamic> get debugInfo {
    try {
      return {
        'appId': _appId,
        'hasValidKeys': hasValidApiKeys,
        'isConfigured': isConfigurationReady,
        'isDevelopment': isDevelopment,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

// Nota: As API keys para o app Plantas ainda precisam ser configuradas no RevenueCat
// e adicionadas ao arquivo core/constants/subscription_constants.dart
//
// Passos para configuração:
// 1. Criar projeto no RevenueCat para o app Plantas
// 2. Obter as API keys (Apple e Google)
// 3. Atualizar o arquivo subscription_constants.dart com as chaves
// 4. Testar a integração
