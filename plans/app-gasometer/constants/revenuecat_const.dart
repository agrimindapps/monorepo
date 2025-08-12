// MIGRADO PARA ESTRUTURA CENTRALIZADA
// Este arquivo agora usa a configuração centralizada em core/constants/subscription_constants.dart

// Project imports:
import '../../core/services/subscription_factory_service.dart';

const String _appId = 'gasometer';

// Getters que retornam as configurações da estrutura centralizada
String get entitlementID =>
    SubscriptionFactoryService.getEntitlementIdForApp(_appId);

String get appleApiKey =>
    SubscriptionFactoryService.getAppleApiKeyForApp(_appId);

String get googleApiKey =>
    SubscriptionFactoryService.getGoogleApiKeyForApp(_appId);

// Métodos de conveniência para validação das API keys
bool get hasValidApiKeys => SubscriptionFactoryService.hasValidApiKeys(_appId);

// Nota: As API keys para o Gasometer ainda precisam ser configuradas no RevenueCat
// e adicionadas ao arquivo core/constants/subscription_constants.dart
