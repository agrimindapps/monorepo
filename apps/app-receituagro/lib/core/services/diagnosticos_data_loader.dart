import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../di/injection_container.dart' as di;
import '../repositories/diagnostico_hive_repository.dart';

/// Serviço para carregar dados de diagnósticos dos assets JSON
class DiagnosticosDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de diagnósticos do JSON dos assets usando repositório
  static Future<void> loadDiagnosticosData() async {
    if (_isLoaded) {
      developer.log('Diagnósticos já carregados, pulando...',
          name: 'DiagnosticosDataLoader');
      return;
    }

    try {
      developer.log('🩺 [DIAGNOSTICOS] Iniciando carregamento de diagnósticos...',
          name: 'DiagnosticosDataLoader');
      print('🩺 [DIAGNOSTICOS] Iniciando carregamento de diagnósticos...');

      final List<Map<String, dynamic>> allDiagnosticos = [];

      // Carrega todos os arquivos JSON de diagnósticos (0 a 64)
      for (int i = 0; i <= 64; i++) {
        try {
          // Use path without 'assets/' prefix for web compatibility
          final String assetPath = kIsWeb 
              ? 'database/json/tbdiagnostico/TBDIAGNOSTICO$i.json'
              : 'assets/database/json/tbdiagnostico/TBDIAGNOSTICO$i.json';
          
          final String jsonString = await rootBundle.loadString(assetPath);

          final dynamic decodedJson = json.decode(jsonString);
          final List<dynamic> jsonData = decodedJson is List ? decodedJson : [];
          final List<Map<String, dynamic>> diagnosticos =
              jsonData.cast<Map<String, dynamic>>().toList();

          allDiagnosticos.addAll(diagnosticos);

          developer.log(
              '🩺 [DIAGNOSTICOS] Arquivo TBDIAGNOSTICO$i.json carregado: ${diagnosticos.length} registros',
              name: 'DiagnosticosDataLoader');
        } catch (e) {
          developer.log(
              '⚠️ [DIAGNOSTICOS] Arquivo TBDIAGNOSTICO$i.json não encontrado ou erro: $e',
              name: 'DiagnosticosDataLoader');
        }
      }

      // Filtra apenas registros válidos - correção: usar 'IdReg' (maiúsculo) como no JSON
      final List<Map<String, dynamic>> diagnosticos = allDiagnosticos
          .where((item) =>
              item['IdReg'] != null &&
              item['IdReg'].toString().trim().isNotEmpty &&
              item['fkIdDefensivo'] != null &&
              item['fkIdCultura'] != null &&
              item['fkIdPraga'] != null)
          .toList();

      developer.log(
          '🩺 [DIAGNOSTICOS] JSON carregado: ${allDiagnosticos.length} registros totais, ${diagnosticos.length} diagnósticos válidos',
          name: 'DiagnosticosDataLoader');
      print('🩺 [DIAGNOSTICOS] JSON carregado: ${allDiagnosticos.length} registros totais, ${diagnosticos.length} diagnósticos válidos');

      // 2. Salva no repositório Hive usando injeção de dependência
      final repository = di.sl<DiagnosticoHiveRepository>();

      // Usa o método loadFromJson do base repository que já limpa e carrega os dados
      final result = await repository.loadFromJson(diagnosticos, 'static_diagnosticos_v1');
      
      result.fold(
        (error) {
          developer.log(
              '⚠️ [DIAGNOSTICOS] Erro ao carregar diagnósticos: $error',
              name: 'DiagnosticosDataLoader');
          throw error;
        },
        (_) {
          developer.log('✅ [DIAGNOSTICOS] Diagnósticos carregados com sucesso',
              name: 'DiagnosticosDataLoader');
        },
      );

      final countAfter = repository.getAll().length;
      developer.log('Diagnósticos carregados com sucesso!',
          name: 'DiagnosticosDataLoader');
      developer.log('Verificação: $countAfter diagnósticos disponíveis',
          name: 'DiagnosticosDataLoader');
      print('Diagnósticos carregados com sucesso!');
      print('Verificação: $countAfter diagnósticos disponíveis');

      _isLoaded = true;
    } catch (e, stackTrace) {
      developer.log('❌ [DIAGNOSTICOS] Erro durante carregamento de diagnósticos: $e',
          name: 'DiagnosticosDataLoader');
      developer.log('❌ [DIAGNOSTICOS] Stack trace: $stackTrace',
          name: 'DiagnosticosDataLoader');
      print('❌ [DIAGNOSTICOS] Erro durante carregamento de diagnósticos: $e');
      print('❌ [DIAGNOSTICOS] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload() async {
    _isLoaded = false;
    await loadDiagnosticosData();
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded() async {
    try {
      final repository = di.sl<DiagnosticoHiveRepository>();
      final diagnosticos = repository.getAll();
      final hasData = diagnosticos.isNotEmpty;
      
      developer.log('🔍 [DIAGNOSTICOS] isDataLoaded() - Repository has ${diagnosticos.length} items: $hasData', 
          name: 'DiagnosticosDataLoader');
      
      return hasData;
    } catch (e) {
      developer.log('❌ [DIAGNOSTICOS] Error checking isDataLoaded: $e', 
          name: 'DiagnosticosDataLoader');
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final repository = di.sl<DiagnosticoHiveRepository>();
      final diagnosticos = repository.getAll();

      return {
        'total_diagnosticos': diagnosticos.length,
        'is_loaded': _isLoaded,
        'sample_diagnosticos': diagnosticos.take(5).map((d) => d.idReg).toList(),
      };
    } catch (e) {
      return {
        'total_diagnosticos': 0,
        'is_loaded': false,
        'error': e.toString(),
      };
    }
  }

  /// Verifica se os dados já foram carregados
  static bool get isLoaded => _isLoaded;

  /// Força recarregamento dos dados
  static void reset() {
    _isLoaded = false;
  }
}