// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/hive_service.dart';
import '../models/medicoes_models.dart';
import '../models/pluviometros_models.dart';

// Adapters específicos do módulo app-agrihurbi

/// Serviço de inicialização do Hive específico para o módulo app-agrihurbi
class AgrihurbiHiveService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Hive para o módulo app-agrihurbi
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🌾 Inicializando Hive para módulo app-agrihurbi...');

      // Garantir que o HiveService global está inicializado
      await HiveService().init();

      // Registrar adapters específicos do módulo app-agrihurbi
      _registerAgrihurbiAdapters();

      _isInitialized = true;
      debugPrint('✅ Hive inicializado com sucesso para app-agrihurbi');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Hive para app-agrihurbi: $e');
      rethrow;
    }
  }

  /// Registra todos os adapters do módulo app-agrihurbi
  static void _registerAgrihurbiAdapters() {
    debugPrint('📦 Registrando adapters do app-agrihurbi...');

    // Registrar adapters com typeIds específicos (30-31)
    HiveService.safeRegisterAdapter(MedicoesAdapter()); // typeId: 30
    HiveService.safeRegisterAdapter(PluviometroAdapter()); // typeId: 31

    debugPrint('✅ Todos os adapters do app-agrihurbi registrados');
  }

  /// Informações de debug específicas do módulo
  static Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'app-agrihurbi',
      'isInitialized': _isInitialized,
      'adapters': [
        'MedicoesAdapter (30)',
        'PluviometroAdapter (31)',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
