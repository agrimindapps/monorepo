// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/hive_service.dart';
import '../models/11_animal_model.dart';
import '../models/12_consulta_model.dart';
import '../models/13_despesa_model.dart';
import '../models/14_lembrete_model.dart';
import '../models/15_medicamento_model.dart';
import '../models/16_vacina_model.dart';
import '../models/17_peso_model.dart';

// Adapters específicos do módulo app-petiveti

/// Serviço de inicialização do Hive específico para o módulo app-petiveti
class PetivetiHiveService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Hive para o módulo app-petiveti
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🐾 Inicializando Hive para módulo app-petiveti...');
      
      // Garantir que o HiveService global está inicializado
      await HiveService().init();
      
      // Registrar adapters específicos do módulo app-petiveti
      _registerPetivetiAdapters();
      
      _isInitialized = true;
      debugPrint('✅ Hive inicializado com sucesso para app-petiveti');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Hive para app-petiveti: $e');
      rethrow;
    }
  }

  /// Registra todos os adapters do módulo app-petiveti
  static void _registerPetivetiAdapters() {
    debugPrint('📦 Registrando adapters do app-petiveti...');
    
    // Registrar adapters com typeIds específicos (11-17)
    HiveService.safeRegisterAdapter(AnimalAdapter());               // typeId: 11
    HiveService.safeRegisterAdapter(ConsultaAdapter());             // typeId: 12
    HiveService.safeRegisterAdapter(DespesaVetAdapter());           // typeId: 13
    HiveService.safeRegisterAdapter(LembreteVetAdapter());          // typeId: 14
    HiveService.safeRegisterAdapter(MedicamentoVetAdapter());       // typeId: 15
    HiveService.safeRegisterAdapter(VacinaVetAdapter());            // typeId: 16
    HiveService.safeRegisterAdapter(PesoAnimalAdapter());           // typeId: 17
    
    debugPrint('✅ Todos os adapters do app-petiveti registrados');
  }

  /// Informações de debug específicas do módulo
  static Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'app-petiveti',
      'isInitialized': _isInitialized,
      'adapters': [
        'AnimalAdapter (11)',
        'ConsultaAdapter (12)',
        'DespesaVetAdapter (13)',
        'LembreteVetAdapter (14)',
        'MedicamentoVetAdapter (15)',
        'VacinaVetAdapter (16)',
        'PesoAnimalAdapter (17)',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
