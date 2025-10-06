import 'dart:developer' as developer;

import '../services/diagnosticos_data_loader.dart';
import '../services/fitossanitarios_data_loader.dart';
import '../services/pragas_data_loader.dart';
import '../services/receituagro_hive_service_stub.dart'; // Stub service for compatibility

/// Configuração e inicialização dos dados estáticos do ReceitaAgro
class ReceitaAgroDataSetup {
  
  /// Inicializa o sistema de dados estáticos do ReceitaAgro
  static Future<void> initialize() async {
    try {
      developer.log('🔧 [SETUP] Verificando se Hive já está inicializado...', name: 'ReceitaAgroDataSetup');
      bool hiveReady = false;
      try {
        final testBox = ReceitaAgroHiveService.getCulturas();
        hiveReady = testBox.isNotEmpty;
        developer.log('✅ [SETUP] Hive já inicializado pelo AppDataManager com ${testBox.length} culturas', name: 'ReceitaAgroDataSetup');
      } catch (e) {
        developer.log('⚠️ [SETUP] Hive não inicializado ainda, procedendo com inicialização...', name: 'ReceitaAgroDataSetup');
      }
      
      if (!hiveReady) {
        await ReceitaAgroHiveService.initialize();
        await ReceitaAgroHiveService.openBoxes();
      }
      await _loadTestData();
      
      developer.log('✅ [SETUP] ReceitaAgro data setup concluído', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('❌ [SETUP] Erro durante setup: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }

  /// Carrega dados reais dos JSON assets
  static Future<void> _loadTestData() async {
    try {
      developer.log('🔄 [SETUP] Verificando se dados adicionais precisam ser carregados...', name: 'ReceitaAgroDataSetup');
      bool fitossanitariosLoaded = await FitossanitariosDataLoader.isDataLoaded();
      bool pragasLoaded = await PragasDataLoader.isDataLoaded();
      bool diagnosticosLoaded = await DiagnosticosDataLoader.isDataLoaded();
      
      developer.log('📊 [SETUP] Status: Fitossanitários=$fitossanitariosLoaded, Pragas=$pragasLoaded, Diagnósticos=$diagnosticosLoaded', name: 'ReceitaAgroDataSetup');
      if (!fitossanitariosLoaded) {
        developer.log('🛡️ [SETUP] Carregando fitossanitários...', name: 'ReceitaAgroDataSetup');
        await FitossanitariosDataLoader.loadFitossanitariosData();
      } else {
        developer.log('✅ [SETUP] Fitossanitários já carregados, pulando...', name: 'ReceitaAgroDataSetup');
      }
      
      if (!pragasLoaded) {
        developer.log('🐛 [SETUP] Carregando pragas...', name: 'ReceitaAgroDataSetup');
        await PragasDataLoader.loadPragasData();
      } else {
        developer.log('✅ [SETUP] Pragas já carregadas, pulando...', name: 'ReceitaAgroDataSetup');
      }
      
      if (!diagnosticosLoaded) {
        developer.log('🩺 [SETUP] Carregando diagnósticos...', name: 'ReceitaAgroDataSetup');
        await DiagnosticosDataLoader.loadDiagnosticosData();
      } else {
        developer.log('✅ [SETUP] Diagnósticos já carregados, pulando...', name: 'ReceitaAgroDataSetup');
      }
      
      developer.log('✅ [SETUP] Verificação de dados complementares concluída!', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('⚠️ [SETUP] Erro ao carregar dados complementares (AppDataManager já carregou dados principais): $e', name: 'ReceitaAgroDataSetup');
    }
  }


  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload() async {
    try {
      developer.log('🔄 Forçando recarregamento dos dados...', name: 'ReceitaAgroDataSetup');
      await ReceitaAgroHiveService.closeBoxes();
      await ReceitaAgroHiveService.openBoxes();
      await FitossanitariosDataLoader.forceReload();
      await PragasDataLoader.forceReload();
      await DiagnosticosDataLoader.forceReload();
      
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
      
      developer.log('✅ Dados limpos!', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('❌ Erro ao limpar dados: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }

  /// Obtém estatísticas dos dados carregados
  static Future<Map<String, dynamic>> getDataStats() async {
    try {
      final pragasStats = await PragasDataLoader.getStats();
      final fitossanitariosStats = await FitossanitariosDataLoader.getStats();
      final diagnosticosStats = await DiagnosticosDataLoader.getStats();
      
      final int pragasCount = (pragasStats['total_pragas'] as int?) ?? 0;
      final int fitossanitariosCount = (fitossanitariosStats['total_fitossanitarios'] as int?) ?? 0;
      final int diagnosticosCount = (diagnosticosStats['total_diagnosticos'] as int?) ?? 0;
      final culturas = ReceitaAgroHiveService.getCulturas();

      return {
        'pragas_count': pragasCount,
        'culturas_count': culturas.length,
        'fitossanitarios_count': fitossanitariosCount,
        'diagnosticos_count': diagnosticosCount,
        'total_items': pragasCount + culturas.length + fitossanitariosCount + diagnosticosCount,
        'last_updated': DateTime.now().toIso8601String(),
        'pragas_loaded': pragasStats['is_loaded'] ?? false,
        'fitossanitarios_loaded': fitossanitariosStats['is_loaded'] ?? false,
        'diagnosticos_loaded': diagnosticosStats['is_loaded'] ?? false,
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
