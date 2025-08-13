// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/services/hive_service.dart';
import '../../database/comentario_model.dart';
import '../../database/espaco_model.dart';
import '../../database/planta_config_model.dart';
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';

// Adapters específicos do módulo app-plantas

/// Serviço de inicialização do Hive específico para o módulo app-plantas
class PlantasHiveService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Hive para o módulo app-plantas
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🌱 Inicializando Hive para módulo app-plantas...');

      // Garantir que o HiveService global está inicializado
      await HiveService().init();

      // Registrar adapters específicos do módulo app-plantas
      _registerPlantasAdapters();

      _isInitialized = true;
      debugPrint('✅ Hive inicializado com sucesso para app-plantas');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Hive para app-plantas: $e');
      rethrow;
    }
  }

  /// Registra todos os adapters do módulo app-plantas
  static void _registerPlantasAdapters() {
    debugPrint('📦 Registrando adapters do app-plantas...');

    // Registrar adapters com typeIds específicos (80-85)
    HiveService.safeRegisterAdapter(ComentarioModelAdapter()); // typeId: 80
    HiveService.safeRegisterAdapter(EspacoModelAdapter()); // typeId: 81
    HiveService.safeRegisterAdapter(PlantaModelAdapter()); // typeId: 82
    // typeId: 83 - reservado
    HiveService.safeRegisterAdapter(TarefaModelAdapter()); // typeId: 84
    HiveService.safeRegisterAdapter(PlantaConfigModelAdapter()); // typeId: 85
    // TarefaConcluidaModel removido - usando novo sistema de tarefas
    // LoginModelAdapter removido - substituído pelo sistema centralizado

    debugPrint('✅ Todos os adapters do app-plantas registrados');
  }

  /// Informações de debug específicas do módulo
  static Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'app-plantas',
      'isInitialized': _isInitialized,
      'adapters': [
        'ComentarioModelAdapter (80)',
        'EspacoModelAdapter (81)',
        'PlantaModelAdapter (82)',
        'TarefaModelAdapter (84)',
        'PlantaConfigModelAdapter (85)',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
