// MIGRADO PARA SISTEMA CENTRALIZADO
// Este arquivo foi migrado para o sistema centralizado de assinaturas.
// Agora todas as configurações estão em: lib/core/constants/subscription_constants.dart
// E são acessadas via: SubscriptionFactoryService.createConfig('todoist')

// Project imports:
import '../../core/services/subscription_factory_service.dart';

// Mantendo getters para compatibilidade com código existente
const String _appId = 'todoist';

List<Map<String, dynamic>> get inappProductIds =>
    SubscriptionFactoryService.getProductsForApp(_appId);

String get regexAssinatura =>
    SubscriptionFactoryService.getRegexPatternForApp(_appId);

List<Map<String, dynamic>> get inappVantagens =>
    SubscriptionFactoryService.getAdvantagesForApp(_appId);

Map<String, String> get inappTermosUso =>
    SubscriptionFactoryService.getTermsForApp(_appId);

Map<String, dynamic> get infoAssinatura =>
    SubscriptionFactoryService.getInitialSubscriptionInfoForApp(_appId);
