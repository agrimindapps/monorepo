import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../database/providers/database_providers.dart';
import '../../database/receituagro_database.dart';
import '../../database/repositories/pragas_repository.dart';

/// Serviço para carregar dados de pragas dos assets JSON
class PragasDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de pragas do JSON dos assets usando repositório
  static Future<void> loadPragasData(dynamic ref) async {
    if (_isLoaded) {
      developer.log(
        'Pragas já carregadas, pulando...',
        name: 'PragasDataLoader',
      );
      return;
    }

    try {
      developer.log(
        '🐛 [PRAGAS] Iniciando carregamento de pragas...',
        name: 'PragasDataLoader',
      );
      const String assetPath = kIsWeb
          ? 'database/json/tbpragas/TBPRAGAS0.json'
          : 'assets/database/json/tbpragas/TBPRAGAS0.json';

      final String jsonString = await rootBundle.loadString(assetPath);

      final dynamic decodedJson = json.decode(jsonString);
      final List<dynamic> jsonData = decodedJson is List ? decodedJson : [];
      final List<Map<String, dynamic>> allPragas =
          jsonData.cast<Map<String, dynamic>>().toList();
      final List<Map<String, dynamic>> pragas = allPragas
          .where(
            (item) =>
                item['nomeCientifico'] != null &&
                item['nomeCientifico'].toString().trim().isNotEmpty &&
                item['idReg'] != null &&
                item['idReg'].toString().trim().isNotEmpty,
          )
          .toList();

      developer.log(
        '🐛 [PRAGAS] JSON carregado: ${allPragas.length} registros totais, ${pragas.length} pragas válidas',
        name: 'PragasDataLoader',
      );
      final repository = ref.read(pragasRepositoryProvider);
      await repository.loadFromJson(pragas, '1.0.0');

      developer.log('Pragas carregadas com sucesso!', name: 'PragasDataLoader');
      _isLoaded = true;

      final List<Praga> loadedPragas =
          await (repository.findAll() as Future<List<Praga>>);
      developer.log(
        'Verificação: ${loadedPragas.length} pragas disponíveis',
        name: 'PragasDataLoader',
      );

      if (loadedPragas.isNotEmpty) {
        developer.log(
          'Primeiras 3 pragas: ${loadedPragas.take(3).map((Praga p) => p.nome).join(', ')}',
          name: 'PragasDataLoader',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [PRAGAS] Erro durante carregamento de pragas: $e',
        name: 'PragasDataLoader',
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload(dynamic ref) async {
    _isLoaded = false;
    await loadPragasData(ref);
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded(dynamic ref) async {
    try {
      final repository = ref.read(pragasRepositoryProvider) as PragasRepository;
      final List<Praga> pragas = await repository.findAll();

      final hasData = pragas.isNotEmpty;
      developer.log(
        '🔍 [PRAGAS] isDataLoaded() - Repository has ${pragas.length} items: $hasData',
        name: 'PragasDataLoader',
      );
      return hasData;
    } catch (e) {
      developer.log(
        '❌ [PRAGAS] Error checking isDataLoaded: $e',
        name: 'PragasDataLoader',
      );
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats(dynamic ref) async {
    try {
      final repository = ref.read(pragasRepositoryProvider) as PragasRepository;
      final List<Praga> pragas = await repository.findAll();

      return {
        'total_pragas': pragas.length,
        'is_loaded': _isLoaded,
        'sample_pragas': pragas.take(5).map((Praga p) => p.nome).toList(),
      };
    } catch (e) {
      return {'total_pragas': 0, 'is_loaded': false, 'error': e.toString()};
    }
  }
}
