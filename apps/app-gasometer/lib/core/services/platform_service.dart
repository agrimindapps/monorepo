import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Serviço para detectar a plataforma e fornecer configurações específicas
@lazySingleton
class PlatformService {
  const PlatformService();

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
  /// Web NÃO deve usar modo anônimo automaticamente
  bool get shouldUseAnonymousByDefault => isMobile && !isWeb;

  /// Determina se deve mostrar página de promoção por padrão
  bool get shouldShowPromoByDefault => isWeb;
}