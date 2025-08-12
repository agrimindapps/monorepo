// Package imports:
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// Project imports:
import '../services/firebase_config_manager.dart';

/// Firebase Options usando configuração segura
/// Configurações movidas para environment variables para segurança
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final configManager = FirebaseConfigManager();
    return configManager.currentPlatformOptions;
  }

  /// Validar se configuração está válida
  static bool get isConfigurationValid {
    final configManager = FirebaseConfigManager();
    return configManager.validateConfiguration();
  }

  /// Obter informações de configuração (sanitizadas)
  static Map<String, dynamic> get configInfo {
    final configManager = FirebaseConfigManager();
    return configManager.getConfigInfo();
  }

  /// Gerar template de environment variables
  static String get environmentTemplate {
    final configManager = FirebaseConfigManager();
    return configManager.generateEnvironmentTemplate();
  }

  // Manter configurações antigas comentadas para referência durante migração
  /*
  CONFIGURAÇÕES ANTIGAS REMOVIDAS POR SEGURANÇA
  
  API keys e configurações sensíveis foram movidas para environment variables.
  
  Para configurar:
  1. Use --dart-define na build: flutter build --dart-define=WEB_API_KEY_PROD=your-key
  2. Ou configure no CI/CD pipeline
  3. Para desenvolvimento, use valores padrão de desenvolvimento
  
  Exemplo:
  flutter run --dart-define=FLUTTER_ENV=dev
  flutter build web --dart-define=FLUTTER_ENV=prod --dart-define=WEB_API_KEY_PROD=your-prod-key
  
  Para gerar template completo de configuração:
  print(DefaultFirebaseOptions.environmentTemplate);
  */
}
