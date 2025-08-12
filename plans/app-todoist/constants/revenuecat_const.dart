// MIGRADO PARA SISTEMA CENTRALIZADO
// Este arquivo foi migrado para o sistema centralizado de assinaturas.
// Agora todas as configurações estão em: lib/core/constants/subscription_constants.dart
// E são acessadas via: SubscriptionFactoryService.createConfig('todoist')

// Project imports:
import '../../core/services/subscription_factory_service.dart';

// Mantendo constantes para compatibilidade com código existente
const String _appId = 'todoist';

String get entitlementID =>
    SubscriptionFactoryService.getEntitlementIdForApp(_appId);

String get appleApiKey =>
    SubscriptionFactoryService.getAppleApiKeyForApp(_appId);

String get googleApiKey =>
    SubscriptionFactoryService.getGoogleApiKeyForApp(_appId);
