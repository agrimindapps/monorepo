import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../di/injection_container.dart' as di;
import '../data/repositories/pragas_hive_repository.dart';

/// Serviço para carregar dados de pragas dos assets JSON
class PragasDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de pragas do JSON dos assets usando repositório
  static Future<void> loadPragasData() async {
    if (_isLoaded) {
      developer.log('Pragas já carregadas, pulando...',
          name: 'PragasDataLoader');
      return;
    }

    try {
      developer.log('🐛 [PRAGAS] Iniciando carregamento de pragas...',
          name: 'PragasDataLoader');

      // Carrega JSON do asset principal - use path without 'assets/' prefix for web compatibility
      const String assetPath = kIsWeb 
          ? 'database/json/tbpragas/TBPRAGAS0.json'
          : 'assets/database/json/tbpragas/TBPRAGAS0.json';
      
      final String jsonString = await rootBundle.loadString(assetPath);

      final dynamic decodedJson = json.decode(jsonString);
      final List<dynamic> jsonData = decodedJson is List ? decodedJson : [];
      final List<Map<String, dynamic>> allPragas =
          jsonData.cast<Map<String, dynamic>>().toList();

      // Filtra apenas registros válidos
      final List<Map<String, dynamic>> pragas = allPragas
          .where((item) =>
              item['nomeCientifico'] != null &&
              item['nomeCientifico'].toString().trim().isNotEmpty &&
              item['idReg'] != null &&
              item['idReg'].toString().trim().isNotEmpty)
          .toList();

      developer.log(
          '🐛 [PRAGAS] JSON carregado: ${allPragas.length} registros totais, ${pragas.length} pragas válidas',
          name: 'PragasDataLoader');

      // Obtém repositório do DI
      final repository = di.sl<PragasHiveRepository>();

      // Carrega dados no repositório
      final result = await repository.loadFromJson(pragas, '1.0.0');

      result.fold(
        (error) {
          developer.log('Erro ao carregar pragas: $error',
              name: 'PragasDataLoader');
          throw Exception('Erro ao carregar pragas: $error');
        },
        (_) {
          developer.log('Pragas carregadas com sucesso!',
              name: 'PragasDataLoader');
          _isLoaded = true;
        },
      );

      // Verifica se dados foram realmente salvos
      final loadedPragasResult = await repository.getAll();
      loadedPragasResult.fold(
        (error) {
          developer.log('Erro ao verificar pragas carregadas: $error', name: 'PragasDataLoader');
        },
        (loadedPragas) {
          developer.log(
              'Verificação: ${loadedPragas.length} pragas disponíveis',
              name: 'PragasDataLoader');
          
          if (loadedPragas.isNotEmpty) {
            developer.log(
                'Primeiras 3 pragas: ${loadedPragas.take(3).map((p) => p.nomeComum).join(', ')}',
                name: 'PragasDataLoader');
          }
        },
      );
    } catch (e) {
      developer.log('❌ [PRAGAS] Erro durante carregamento de pragas: $e',
          name: 'PragasDataLoader', stackTrace: StackTrace.current);
      // Não bloqueia o app, apenas registra o erro
    }
  }

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload() async {
    _isLoaded = false;
    await loadPragasData();
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded() async {
    try {
      final repository = di.sl<PragasHiveRepository>();
      final pragasResult = await repository.getAll();
      
      return pragasResult.fold(
        (error) {
          developer.log('❌ [PRAGAS] Error checking isDataLoaded: $error', 
              name: 'PragasDataLoader');
          return false;
        },
        (pragas) {
          final hasData = pragas.isNotEmpty;
          developer.log('🔍 [PRAGAS] isDataLoaded() - Repository has ${pragas.length} items: $hasData', 
              name: 'PragasDataLoader');
          return hasData;
        },
      );
    } catch (e) {
      developer.log('❌ [PRAGAS] Error checking isDataLoaded: $e', 
          name: 'PragasDataLoader');
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final repository = di.sl<PragasHiveRepository>();
      final pragasResult = await repository.getAll();

      return pragasResult.fold(
        (error) => {
          'total_pragas': 0,
          'is_loaded': false,
          'error': error.toString(),
        },
        (pragas) => {
          'total_pragas': pragas.length,
          'is_loaded': _isLoaded,
          'sample_pragas': pragas.take(5).map((p) => p.nomeComum).toList(),
        },
      );
    } catch (e) {
      return {
        'total_pragas': 0,
        'is_loaded': false,
        'error': e.toString(),
      };
    }
  }
}