// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/hive_service.dart';
import '../database/comentarios_models.dart';
import '../database/perfil_model.dart';
import '../pages/agua/models/beber_agua_model.dart';
import '../pages/peso/models/peso_model.dart';

// Adapters específicos do módulo app-nutrituti

/// Serviço de inicialização do Hive específico para o módulo app-nutrituti
class NutriTutiHiveService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Hive para o módulo app-nutrituti
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🥗 Inicializando Hive para módulo app-nutrituti...');

      // Garantir que o HiveService global está inicializado
      await HiveService().init();

      // Registrar adapters específicos do módulo app-nutrituti
      _registerNutriTutiAdapters();

      _isInitialized = true;
      debugPrint('✅ Hive inicializado com sucesso para app-nutrituti');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Hive para app-nutrituti: $e');
      rethrow;
    }
  }

  /// Registra todos os adapters do módulo app-nutrituti
  static void _registerNutriTutiAdapters() {
    debugPrint('📦 Registrando adapters do app-nutrituti...');

    // Registrar adapters com typeIds específicos (50-53)
    HiveService.safeRegisterAdapter(ComentariosAdapter()); // typeId: 50
    HiveService.safeRegisterAdapter(BeberAguaAdapter()); // typeId: 51
    HiveService.safeRegisterAdapter(PerfilModelAdapter()); // typeId: 52
    HiveService.safeRegisterAdapter(PesoModelAdapter()); // typeId: 53

    debugPrint('✅ Todos os adapters do app-nutrituti registrados');
  }

  /// Informações de debug específicas do módulo
  static Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'app-nutrituti',
      'isInitialized': _isInitialized,
      'adapters': [
        'ComentariosAdapter (50)',
        'BeberAguaAdapter (51)',
        'PerfilModelAdapter (52)',
        'PesoModelAdapter (53)',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
