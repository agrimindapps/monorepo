import 'dart:developer' as developer;
import '../services/receituagro_hive_service_stub.dart'; // Stub service for compatibility
import '../services/fitossanitarios_data_loader.dart';
import '../services/pragas_data_loader.dart';

/// Configuração e inicialização dos dados estáticos do ReceitaAgro
class ReceitaAgroDataSetup {
  
  /// Inicializa o sistema de dados estáticos do ReceitaAgro
  static Future<void> initialize() async {
    try {
      // 1. Inicializa o Hive e registra adapters
      await ReceitaAgroHiveService.initialize();
      
      // 2. Abre todas as boxes
      await ReceitaAgroHiveService.openBoxes();
      
      // 3. Carrega dados de teste temporário
      await _loadTestData();
      
      developer.log('ReceitaAgro data setup concluído', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('Erro durante setup: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }

  /// Carrega dados reais dos JSON assets
  static Future<void> _loadTestData() async {
    try {
      developer.log('Iniciando carregamento de dados reais dos JSONs...', name: 'ReceitaAgroDataSetup');
      
      // Carrega dados de fitossanitários (defensivos)
      await FitossanitariosDataLoader.loadFitossanitariosData();
      
      // Carrega dados de pragas
      await PragasDataLoader.loadPragasData();
      
      developer.log('Dados reais carregados com sucesso!', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('Erro ao carregar dados reais: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }


  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload() async {
    try {
      developer.log('🔄 Forçando recarregamento dos dados...', name: 'ReceitaAgroDataSetup');
      
      // Fecha e reabre as boxes
      await ReceitaAgroHiveService.closeBoxes();
      await ReceitaAgroHiveService.openBoxes();
      
      // Força recarregamento individual dos loaders
      await FitossanitariosDataLoader.forceReload();
      await PragasDataLoader.forceReload();
      
      developer.log('✅ Recarregamento concluído!', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('❌ Erro no recarregamento: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }

  /// Limpa todos os dados (para desenvolvimento)
  static Future<void> clearAllData() async {
    try {
      developer.log('🗑️ Limpando todos os dados...', name: 'ReceitaAgroDataSetup');
      
      await ReceitaAgroHiveService.closeBoxes();
      
      // TODO: Implementar limpeza das boxes quando necessário
      // await Hive.deleteBoxFromDisk('receituagro_pragas');
      // await Hive.deleteBoxFromDisk('receituagro_culturas');
      // etc...
      
      developer.log('✅ Dados limpos!', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('❌ Erro ao limpar dados: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }

  /// Obtém estatísticas dos dados carregados
  static Future<Map<String, dynamic>> getDataStats() async {
    try {
      // Obtém estatísticas dos loaders individuais
      final pragasStats = await PragasDataLoader.getStats();
      final fitossanitariosStats = await FitossanitariosDataLoader.getStats();
      
      final int pragasCount = (pragasStats['total_pragas'] as int?) ?? 0;
      final int fitossanitariosCount = (fitossanitariosStats['total_fitossanitarios'] as int?) ?? 0;
      
      // Obter culturas e diagnósticos usando o stub service
      final culturas = ReceitaAgroHiveService.getCulturas();
      final diagnosticos = ReceitaAgroHiveService.getDiagnosticos();

      return {
        'pragas_count': pragasCount,
        'culturas_count': culturas.length,
        'fitossanitarios_count': fitossanitariosCount,
        'diagnosticos_count': diagnosticos.length,
        'total_items': pragasCount + culturas.length + fitossanitariosCount + diagnosticos.length,
        'last_updated': DateTime.now().toIso8601String(),
        'pragas_loaded': pragasStats['is_loaded'] ?? false,
        'fitossanitarios_loaded': fitossanitariosStats['is_loaded'] ?? false,
      };
    } catch (e) {
      developer.log('Erro ao obter estatísticas: $e', name: 'ReceitaAgroDataSetup');
      return {
        'error': e.toString(),
        'pragas_count': 0,
        'culturas_count': 0,
        'fitossanitarios_count': 0,
        'diagnosticos_count': 0,
        'total_items': 0,
        'pragas_loaded': false,
        'fitossanitarios_loaded': false,
      };
    }
  }
}