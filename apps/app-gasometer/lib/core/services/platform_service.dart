import 'package:flutter/foundation.dart';

/// Serviço para detectar a plataforma e fornecer configurações específicas
class PlatformService {
  static const PlatformService _instance = PlatformService._internal();
  factory PlatformService() => _instance;
  const PlatformService._internal();

  /// Verifica se está executando em plataforma mobile (Android ou iOS)
  bool get isMobile => defaultTargetPlatform == TargetPlatform.android || 
                      defaultTargetPlatform == TargetPlatform.iOS;

  /// Verifica se está executando em plataforma web
  bool get isWeb => kIsWeb;

  /// Verifica se está executando em plataforma desktop
  bool get isDesktop => defaultTargetPlatform == TargetPlatform.windows ||
                       defaultTargetPlatform == TargetPlatform.macOS ||
                       defaultTargetPlatform == TargetPlatform.linux;

  /// Retorna a plataforma atual como string
  String get platformName {
    if (kIsWeb) return 'web';
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  /// Determina se deve usar modo anônimo por padrão
  bool get shouldUseAnonymousByDefault => isMobile;

  /// Determina se deve mostrar página de promoção por padrão
  bool get shouldShowPromoByDefault => isWeb;
}