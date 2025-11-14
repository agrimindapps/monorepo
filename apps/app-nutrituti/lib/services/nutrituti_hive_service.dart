// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/hive_service.dart';

// Adapters específicos do módulo app-nutrituti

/// DEPRECATED: Este serviço está sendo migrado para Drift ORM
/// Serviço de inicialização do Hive específico para o módulo app-nutrituti
@Deprecated('Migrating to Drift ORM. Use Drift database instead.')
class NutriTutiHiveService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Hive para o módulo app-nutrituti
  @Deprecated('Use Drift database initialization instead')
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🥗 Inicializando Hive para módulo app-nutrituti...');

      // Garantir que o HiveService global está inicializado
      await HiveService().init();

      // REMOVED: Adapters migrados para Drift
      // _registerNutriTutiAdapters();

      _isInitialized = true;
      debugPrint(
        '✅ Hive inicializado com sucesso para app-nutrituti (DEPRECATED)',
      );
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Hive para app-nutrituti: $e');
      rethrow;
    }
  }

  /// Informações de debug específicas do módulo
  static Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'app-nutrituti',
      'isInitialized': _isInitialized,
      'adapters': [
        'ComentariosAdapter (50) - MIGRATED TO DRIFT',
        'BeberAguaAdapter (51) - MIGRATED TO DRIFT',
        'PerfilModelAdapter (52) - MIGRATED TO DRIFT',
        'PesoModelAdapter (53) - MIGRATED TO DRIFT',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
