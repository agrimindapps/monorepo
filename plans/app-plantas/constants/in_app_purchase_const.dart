// ESTRUTURA CENTRALIZADA - App Plantas
// Este arquivo usa a configuração centralizada em core/constants/subscription_constants.dart

// Project imports:
import '../../core/services/subscription_factory_service.dart';

const String _appId = 'plantas';

// Getters que retornam as configurações da estrutura centralizada
List<Map<String, dynamic>> get inappProductIds =>
    SubscriptionFactoryService.getProductsForApp(_appId);

String get regexAssinatura =>
    SubscriptionFactoryService.getRegexPatternForApp(_appId);

List<Map<String, dynamic>> get inappVantagens =>
    SubscriptionFactoryService.getAdvantagesForApp(_appId);

Map<String, String> get inappTermosUso =>
    SubscriptionFactoryService.getTermsForApp(_appId);

Map<String, dynamic> get infoAssinatura =>
    SubscriptionFactoryService.getDefaultSubscriptionInfoForApp(_appId);

// Getters para as chaves do RevenueCat
String get entitlementID =>
    SubscriptionFactoryService.getEntitlementIdForApp(_appId);

String get appleApiKey =>
    SubscriptionFactoryService.getAppleApiKeyForApp(_appId);

String get googleApiKey =>
    SubscriptionFactoryService.getGoogleApiKeyForApp(_appId);

// Métodos de conveniência para validação
bool get isConfigurationValid =>
    SubscriptionFactoryService.validateAppConfig(_appId);

List<String> get configurationErrors =>
    SubscriptionFactoryService.getValidationErrors(_appId);

bool get hasValidApiKeys => SubscriptionFactoryService.hasValidApiKeys(_appId);

// Método para obter configuração completa como Map (útil para debugging)
Map<String, dynamic> get fullConfiguration =>
    SubscriptionFactoryService.getFullConfigAsMap(_appId);

// Constantes específicas do app Plantas
class PlantasPremiumConstants {
  static const String appName = 'Plantas';
  static const String premiumName = 'Grow Premium';

  // Cores específicas do tema plantas
  static const int primaryColorValue = 0xFF4CAF50; // Verde plantas
  static const int accentColorValue = 0xFF8BC34A; // Verde claro
  static const int premiumColorValue = 0xFFFFD700; // Dourado premium

  // Recursos premium específicos do app plantas
  static const List<String> premiumFeatures = [
    'Plantas ilimitadas',
    'Lembretes avançados',
    'Sincronização entre dispositivos',
    'Insights detalhados',
    'Suporte prioritário',
    'Sem anúncios',
  ];

  // Limites da versão gratuita
  static const int maxPlantsFreeTier = 5;
  static const int maxRemindersFreeTier = 10;

  // URLs específicas (quando disponíveis)
  static const String helpUrl = 'https://plantas-app.com/help';
  static const String feedbackUrl = 'https://plantas-app.com/feedback';
}
