
import 'package:core/core.dart';

import '../data/models/comentario_hive.dart';
import '../data/models/cultura_hive.dart';
import '../data/models/diagnostico_hive.dart';
import '../data/models/favorito_item_hive.dart';
import '../data/models/fitossanitario_hive.dart';
import '../data/models/fitossanitario_info_hive.dart';
import '../data/models/plantas_inf_hive.dart';
import '../data/models/pragas_hive.dart';
import '../data/models/pragas_inf_hive.dart';
import '../data/models/premium_status_hive.dart';
import '../data/models/sync_queue_item.dart';

/// Registry centralizado para registro de todos os adapters Hive
/// ✅ PADRÃO APP-PLANTIS: Apenas registra adapters, NÃO abre boxes
/// BoxRegistryService é responsável por abrir/fechar boxes
class HiveAdapterRegistry {
  // Private constructor para classe utilitária (apenas métodos estáticos)
  HiveAdapterRegistry._();

  static bool _isRegistered = false;

  /// Registra todos os adapters Hive necessários
  /// ✅ PADRÃO APP-PLANTIS: Hive.initFlutter() já foi chamado no main.dart
  static Future<void> registerAdapters() async {
    if (_isRegistered) {
      return;
    }

    try {
      // ✅ Hive.initFlutter() já foi executado no main.dart
      Hive.registerAdapter(CulturaHiveAdapter());
      Hive.registerAdapter(PragasHiveAdapter());
      Hive.registerAdapter(FitossanitarioHiveAdapter());
      Hive.registerAdapter(DiagnosticoHiveAdapter());
      Hive.registerAdapter(FitossanitarioInfoHiveAdapter());
      Hive.registerAdapter(PlantasInfHiveAdapter());
      Hive.registerAdapter(PragasInfHiveAdapter());
      Hive.registerAdapter(PremiumStatusHiveAdapter());
      Hive.registerAdapter(ComentarioHiveAdapter());
      Hive.registerAdapter(FavoritoItemHiveAdapter());

      // P1.3 - Sync infrastructure
      Hive.registerAdapter(SyncQueueItemAdapter());

      _isRegistered = true;

    } catch (e) {
      throw Exception('Erro ao registrar adapters Hive: $e');
    }
  }

  /// Verifica se os adapters já foram registrados
  static bool get isRegistered => _isRegistered;

  /// Lista de boxes para referência (não mais usado para abrir boxes)
  static const Map<String, String> boxNames = {
    'culturas': 'receituagro_culturas',
    'pragas': 'receituagro_pragas',
    'fitossanitarios': 'receituagro_fitossanitarios',
    'diagnosticos': 'receituagro_diagnosticos',
    'fitossanitarios_info': 'receituagro_fitossanitarios_info',
    'plantas_inf': 'receituagro_plantas_inf',
    'pragas_inf': 'receituagro_pragas_inf',
    'premium_status': 'receituagro_premium_status',
    'comentarios': 'comentarios',
    'favoritos': 'receituagro_user_favorites',
  };

  // ❌ REMOVIDO: openBoxes() - BoxRegistryService gerencia abertura
  // ❌ REMOVIDO: closeBoxes() - BoxRegistryService gerencia fechamento
  // ❌ REMOVIDO: clearAllBoxes() - Use BoxRegistryService para operações de box
}
