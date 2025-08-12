// ATUALIZADO PARA USAR CONSTANTES ESPECÍFICAS DO GASOMETER
// Este arquivo agora usa a nova estrutura de constantes do Gasometer

// Project imports:
import '../../core/services/subscription_factory_service.dart';
import 'subscription_constants.dart';

const String _appId = 'gasometer';

// Produtos específicos do Gasometer
List<Map<String, dynamic>> get inappProductIds =>
    GasometerSubscriptionConstants.productIds;

// Benefícios premium específicos do Gasometer  
List<Map<String, dynamic>> get inappVantagens =>
    GasometerSubscriptionConstants.premiumBenefits;

// Getters da estrutura centralizada (mantidos para compatibilidade)
String get regexAssinatura =>
    SubscriptionFactoryService.getRegexPatternForApp(_appId);

Map<String, String> get inappTermosUso =>
    SubscriptionFactoryService.getTermsForApp(_appId);

Map<String, dynamic> get infoAssinatura =>
    SubscriptionFactoryService.getDefaultSubscriptionInfoForApp(_appId);

// Chaves do RevenueCat específicas do Gasometer
String get entitlementID =>
    GasometerSubscriptionConstants.entitlementId;

String get appleApiKey =>
    GasometerSubscriptionConstants.revenueCatApiKeyApple;

String get googleApiKey =>
    GasometerSubscriptionConstants.revenueCatApiKeyGoogle;

// Validação específica do Gasometer
bool get hasValidApiKeys => GasometerSubscriptionConstants.hasValidApiKeys;

bool get isConfigurationValid =>
    SubscriptionFactoryService.validateAppConfig(_appId) && hasValidApiKeys;

List<String> get configurationErrors {
  final errors = SubscriptionFactoryService.getValidationErrors(_appId);
  if (!hasValidApiKeys) {
    errors.add('API Keys do Gasometer não configuradas ou são placeholders');
  }
  return errors;
}

// Configuração completa para debugging
Map<String, dynamic> get fullConfiguration {
  final baseConfig = SubscriptionFactoryService.getFullConfigAsMap(_appId);
  baseConfig.addAll(GasometerSubscriptionConstants.debugInfo);
  return baseConfig;
}

// Métodos específicos do Gasometer
String getFormattedPrice(String productId) =>
    GasometerSubscriptionConstants.getFormattedPrice(productId);

String getProductDescription(String productId) =>
    GasometerSubscriptionConstants.getProductDescription(productId);

Map<String, dynamic>? getProductById(String productId) =>
    GasometerSubscriptionConstants.getProductById(productId);
