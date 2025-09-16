import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../di/injection_container.dart' as di;
import '../repositories/pragas_hive_repository.dart';

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
      print('🐛 [PRAGAS] Iniciando carregamento de pragas...');

      // Carrega JSON do asset principal - use path without 'assets/' prefix for web compatibility
      final String assetPath = kIsWeb 
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
      print(
          '🐛 [PRAGAS] JSON carregado: ${allPragas.length} registros totais, ${pragas.length} pragas válidas');

      // Obtém repositório do DI
      final repository = di.sl<PragasHiveRepository>();

      // Carrega dados no repositório
      final result = await repository.loadFromJson(pragas, '1.0.0');

      result.fold(
        (error) {
          developer.log('Erro ao carregar pragas: $error',
              name: 'PragasDataLoader');
          throw error;
        },
        (_) {
          developer.log('Pragas carregadas com sucesso!',
              name: 'PragasDataLoader');
          _isLoaded = true;
        },
      );

      // Verifica se dados foram realmente salvos
      final loadedPragas = repository.getAll();
      developer.log(
          'Verificação: ${loadedPragas.length} pragas disponíveis',
          name: 'PragasDataLoader');

      if (loadedPragas.isNotEmpty) {
        developer.log(
            'Primeiras 3 pragas: ${loadedPragas.take(3).map((p) => p.nomeCientifico).join(', ')}',
            name: 'PragasDataLoader');
      }
    } catch (e) {
      developer.log('❌ [PRAGAS] Erro durante carregamento de pragas: $e',
          name: 'PragasDataLoader');
      print('❌ [PRAGAS] Erro durante carregamento de pragas: $e');
      print('❌ [PRAGAS] Stack trace: ${StackTrace.current}');
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
    if (!_isLoaded) return false;

    try {
      final repository = di.sl<PragasHiveRepository>();
      final pragas = repository.getAll();
      return pragas.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final repository = di.sl<PragasHiveRepository>();
      final pragas = repository.getAll();

      return {
        'total_pragas': pragas.length,
        'is_loaded': _isLoaded,
        'sample_pragas': pragas.take(5).map((p) => p.nomeCientifico).toList(),
      };
    } catch (e) {
      return {
        'total_pragas': 0,
        'is_loaded': false,
        'error': e.toString(),
      };
    }
  }
}