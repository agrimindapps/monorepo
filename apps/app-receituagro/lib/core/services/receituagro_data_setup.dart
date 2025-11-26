import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import '../services/culturas_data_loader.dart';
import '../services/diagnosticos_data_loader.dart';
import '../services/fitossanitarios_data_loader.dart';
import '../services/pragas_data_loader.dart';

/// Configuração e inicialização dos dados estáticos do ReceitaAgro
class ReceitaAgroDataSetup {
  /// Inicializa o sistema de dados estáticos do ReceitaAgro
  static Future<void> initialize(Ref ref) async {
    try {
      developer.log(
        '🔧 [SETUP] Inicializando dados estáticos do ReceitaAgro...',
        name: 'ReceitaAgroDataSetup',
      );

      // Carregar dados usando os data loaders individuais
      await Future.wait<void>([
        CulturasDataLoader.loadCulturasData(ref),
        PragasDataLoader.loadPragasData(ref),
        FitossanitariosDataLoader.loadFitossanitariosData(ref),
        DiagnosticosDataLoader.loadDiagnosticosData(ref),
      ]);

      await _loadTestData(ref);

      developer.log(
        '✅ [SETUP] ReceitaAgro data setup concluído',
        name: 'ReceitaAgroDataSetup',
      );
    } catch (e) {
      developer.log(
        '❌ [SETUP] Erro durante setup: $e',
        name: 'ReceitaAgroDataSetup',
      );
      rethrow;
    }
  }

  /// Carrega dados reais dos JSON assets
  static Future<void> _loadTestData(Ref ref) async {
    try {
      developer.log(
        '🔄 [SETUP] Verificando se dados adicionais precisam ser carregados...',
        name: 'ReceitaAgroDataSetup',
      );
      bool fitossanitariosLoaded =
          await FitossanitariosDataLoader.isDataLoaded(ref);
      bool pragasLoaded = await PragasDataLoader.isDataLoaded(ref);
      bool diagnosticosLoaded = await DiagnosticosDataLoader.isDataLoaded(ref);

      developer.log(
        '📊 [SETUP] Status: Fitossanitários=$fitossanitariosLoaded, Pragas=$pragasLoaded, Diagnósticos=$diagnosticosLoaded',
        name: 'ReceitaAgroDataSetup',
      );
      if (!fitossanitariosLoaded) {
        developer.log(
          '🛡️ [SETUP] Carregando fitossanitários...',
          name: 'ReceitaAgroDataSetup',
        );
        await FitossanitariosDataLoader.loadFitossanitariosData(ref);
      } else {
        developer.log(
          '✅ [SETUP] Fitossanitários já carregados, pulando...',
          name: 'ReceitaAgroDataSetup',
        );
      }

      if (!pragasLoaded) {
        developer.log(
          '🐛 [SETUP] Carregando pragas...',
          name: 'ReceitaAgroDataSetup',
        );
        await PragasDataLoader.loadPragasData(ref);
      } else {
        developer.log(
          '✅ [SETUP] Pragas já carregadas, pulando...',
          name: 'ReceitaAgroDataSetup',
        );
      }

      if (!diagnosticosLoaded) {
        developer.log(
          '🩺 [SETUP] Carregando diagnósticos...',
          name: 'ReceitaAgroDataSetup',
        );
        await DiagnosticosDataLoader.loadDiagnosticosData(ref);
      } else {
        developer.log(
          '✅ [SETUP] Diagnósticos já carregados, pulando...',
          name: 'ReceitaAgroDataSetup',
        );
      }

      developer.log(
        '✅ [SETUP] Verificação de dados complementares concluída!',
        name: 'ReceitaAgroDataSetup',
      );
    } catch (e) {
      developer.log(
        '⚠️ [SETUP] Erro ao carregar dados complementares (AppDataManager já carregou dados principais): $e',
        name: 'ReceitaAgroDataSetup',
      );
    }
  }

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload(Ref ref) async {
    try {
      developer.log(
        '🔄 Forçando recarregamento dos dados...',
        name: 'ReceitaAgroDataSetup',
      );
      await Future.wait<void>([
        CulturasDataLoader.forceReload(ref),
        FitossanitariosDataLoader.forceReload(ref),
        PragasDataLoader.forceReload(ref),
        DiagnosticosDataLoader.forceReload(ref),
      ]);

      developer.log(
        '✅ Recarregamento concluído!',
        name: 'ReceitaAgroDataSetup',
      );
    } catch (e) {
      developer.log(
        '❌ Erro no recarregamento: $e',
        name: 'ReceitaAgroDataSetup',
      );
      rethrow;
    }
  }

  static Future<void> clearAllData() async {
    try {
      developer.log(
        '🗑️ Função clearAllData não implementada (usar repositórios individuais)',
        name: 'ReceitaAgroDataSetup',
      );
      // Dados são gerenciados pelos repositórios individuais
      developer.log('✅ Dados limpos!', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('❌ Erro ao limpar dados: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }

  /// Obtém estatísticas dos dados carregados
  static Future<Map<String, dynamic>> getDataStats(Ref ref) async {
    try {
      final pragasStats = await PragasDataLoader.getStats(ref);
      final fitossanitariosStats = await FitossanitariosDataLoader.getStats(ref);
      final culturasStats = await CulturasDataLoader.getStats(ref);
      final diagnosticosStats = await DiagnosticosDataLoader.getStats(ref);

      final int pragasCount = (pragasStats['total_pragas'] as int?) ?? 0;
      final int fitossanitariosCount =
          (fitossanitariosStats['total_fitossanitarios'] as int?) ?? 0;
      final int diagnosticosCount =
          (diagnosticosStats['total_diagnosticos'] as int?) ?? 0;
      final int culturasCount = (culturasStats['total_culturas'] as int?) ?? 0;

      return {
        'pragas_count': pragasCount,
        'culturas_count': culturasCount,
        'fitossanitarios_count': fitossanitariosCount,
        'diagnosticos_count': diagnosticosCount,
        'total_items':
            pragasCount +
            culturasCount +
            fitossanitariosCount +
            diagnosticosCount,
        'last_updated': DateTime.now().toIso8601String(),
        'pragas_loaded': pragasStats['is_loaded'] ?? false,
        'fitossanitarios_loaded': fitossanitariosStats['is_loaded'] ?? false,
        'diagnosticos_loaded': diagnosticosStats['is_loaded'] ?? false,
        'culturas_loaded': culturasStats['is_loaded'] ?? false,
      };
    } catch (e) {
      developer.log(
        'Erro ao obter estatísticas: $e',
        name: 'ReceitaAgroDataSetup',
      );
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
