import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import '../services/receituagro_hive_service.dart';

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

  /// Carrega dados de teste temporários
  static Future<void> _loadTestData() async {
    try {
      // TODO: Substituir por carregamento real dos JSONs quando disponíveis
      await ReceitaAgroHiveService.saveTestData();
      
      developer.log('Dados de teste carregados', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('Erro ao carregar dados de teste: $e', name: 'ReceitaAgroDataSetup');
    }
  }

  /// Carrega dados dos assets JSON (versão futura)
  static Future<void> _loadDataFromAssets() async {
    const currentAppVersion = '1.0.0'; // Versão atual do app
    
    try {
      developer.log('📦 Carregando dados estáticos versão $currentAppVersion...', name: 'ReceitaAgroDataSetup');

      // TODO: Implementar carregamento real dos JSONs
      // final futures = await Future.wait([
      //   _loadJsonAsset('assets/data/pragas.json'),
      //   _loadJsonAsset('assets/data/culturas.json'),
      //   _loadJsonAsset('assets/data/diagnosticos.json'),
      //   _loadJsonAsset('assets/data/fitossanitarios.json'),
      // ]);
      
      // final pragasJson = futures[0];
      // final culturasJson = futures[1];
      // final diagnosticosJson = futures[2];
      // final fitossanitariosJson = futures[3];

      // await ReceitaAgroHiveService.loadAllStaticData(
      //   pragasJson: pragasJson,
      //   culturasJson: culturasJson,
      //   diagnosticosJson: diagnosticosJson,
      //   fitossanitariosJson: fitossanitariosJson,
      //   appVersion: currentAppVersion,
      // );

      developer.log('✅ Dados carregados com sucesso!', name: 'ReceitaAgroDataSetup');
    } catch (e) {
      developer.log('❌ Erro ao carregar dados: $e', name: 'ReceitaAgroDataSetup');
      rethrow;
    }
  }

  /// Carrega um JSON dos assets
  static Future<Map<String, dynamic>> _loadJsonAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Erro ao carregar asset $assetPath: $e', name: 'ReceitaAgroDataSetup');
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
      
      // Recarrega dados
      await _loadTestData();
      
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
      final pragas = ReceitaAgroHiveService.getPragas();
      final culturas = ReceitaAgroHiveService.getCulturas();
      final fitossanitarios = ReceitaAgroHiveService.getFitossanitarios();
      final diagnosticos = ReceitaAgroHiveService.getDiagnosticos();

      return {
        'pragas_count': pragas.length,
        'culturas_count': culturas.length,
        'fitossanitarios_count': fitossanitarios.length,
        'diagnosticos_count': diagnosticos.length,
        'total_items': pragas.length + culturas.length + fitossanitarios.length + diagnosticos.length,
        'last_updated': DateTime.now().toIso8601String(),
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
      };
    }
  }
}