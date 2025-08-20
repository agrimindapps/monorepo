// MIGRADO PARA ESTRUTURA CENTRALIZADA
// Este arquivo agora usa a configuração centralizada em core/constants/subscription_constants.dart

// Project imports:
import '../../core/services/subscription_factory_service.dart';

const String _appId = 'petiveti';

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

bool get hasValidApiKeys => 
    SubscriptionFactoryService.hasValidApiKeys(_appId);

// Método para obter configuração completa como Map (útil para debugging)
Map<String, dynamic> get fullConfiguration => 
    SubscriptionFactoryService.getFullConfigAsMap(_appId);
