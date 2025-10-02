import 'package:core/core.dart';

/// Serviço para detectar a plataforma e fornecer configurações específicas do Gasometer
/// Wrapper around PlatformCapabilitiesService from core package
@lazySingleton
class PlatformService {
  const PlatformService();

  // Use core's PlatformCapabilitiesService
  static const _coreService = PlatformCapabilitiesService();

  /// Verifica se está executando em plataforma mobile (Android ou iOS)
  bool get isMobile => _coreService.isMobile;

  /// Verifica se está executando em plataforma web
  bool get isWeb => _coreService.isWeb;

  /// Verifica se está executando em plataforma desktop
  bool get isDesktop => _coreService.isDesktop;

  /// Retorna a plataforma atual como string
  String get platformName => _coreService.platformName;

  /// Determina se deve usar modo anônimo por padrão
  /// Web NÃO deve usar modo anônimo automaticamente
  bool get shouldUseAnonymousByDefault => isMobile && !isWeb;

  /// Determina se deve mostrar página de promoção por padrão
  bool get shouldShowPromoByDefault => isWeb;
}