// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../core/services/hive_service.dart';
import '../database/20_odometro_model.dart';
import '../database/21_veiculos_model.dart';
import '../database/22_despesas_model.dart';
import '../database/23_abastecimento_model.dart';
import '../database/25_manutencao_model.dart';
import '../database/26_categorias_model.dart';

// Adapters específicos do módulo app-gasometer

/// Serviço de inicialização do Hive específico para o módulo app-gasometer
class GasometerHiveService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Hive para o módulo app-gasometer
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚗 Inicializando Hive para módulo app-gasometer...');

      // Garantir que o HiveService global está inicializado
      await HiveService().init();

      // Registrar adapters específicos do módulo app-gasometer
      _registerGasometerAdapters();

      _isInitialized = true;
      debugPrint('✅ Hive inicializado com sucesso para app-gasometer');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Hive para app-gasometer: $e');
      rethrow;
    }
  }

  /// Registra todos os adapters do módulo app-gasometer
  static void _registerGasometerAdapters() {
    debugPrint('📦 Registrando adapters do app-gasometer...');

    // Registrar adapters com typeIds específicos (20-26)
    HiveService.safeRegisterAdapter(OdometroCarAdapter()); // typeId: 20
    HiveService.safeRegisterAdapter(VeiculoCarAdapter()); // typeId: 21
    HiveService.safeRegisterAdapter(DespesaCarAdapter()); // typeId: 22
    HiveService.safeRegisterAdapter(AbastecimentoCarAdapter()); // typeId: 23
    HiveService.safeRegisterAdapter(ManutencaoCarAdapter()); // typeId: 25
    HiveService.safeRegisterAdapter(CategoriaCarAdapter()); // typeId: 26

    debugPrint('✅ Todos os adapters do app-gasometer registrados');
  }

  /// Informações de debug específicas do módulo
  static Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'app-gasometer',
      'isInitialized': _isInitialized,
      'adapters': [
        'OdometroCarAdapter (20)',
        'VeiculoCarAdapter (21)',
        'DespesaCarAdapter (22)',
        'AbastecimentoCarAdapter (23)',
        'ManutencaoCarAdapter (25)',
        'CategoriaCarAdapter (26)',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
