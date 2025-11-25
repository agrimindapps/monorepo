import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../database/providers/database_providers.dart';
import '../../database/receituagro_database.dart';

class CulturasDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de culturas do JSON dos assets
  static Future<void> loadCulturasData(dynamic ref) async {
    if (_isLoaded) {
      developer.log(
        'Culturas já carregadas, pulando...',
        name: 'CulturasDataLoader',
      );
      return;
    }

    try {
      developer.log(
        '🌱 [CULTURAS] Iniciando carregamento de culturas...',
        name: 'CulturasDataLoader',
      );
      print('🌱 [CULTURAS] Iniciando carregamento de culturas...');
      const String assetPath = kIsWeb
          ? 'database/json/tbculturas/TBCULTURAS0.json'
          : 'assets/database/json/tbculturas/TBCULTURAS0.json';

      final String jsonString = await rootBundle.loadString(assetPath);

      final dynamic decodedJson = json.decode(jsonString);
      final List<dynamic> jsonData = decodedJson is List ? decodedJson : [];
      final List<Map<String, dynamic>> allCulturas =
          jsonData.cast<Map<String, dynamic>>().toList();
      final List<Map<String, dynamic>> culturas = allCulturas
          .where(
            (item) =>
                item['cultura'] != null &&
                item['cultura'].toString().trim().isNotEmpty &&
                item['idReg'] != null &&
                item['idReg'].toString().trim().isNotEmpty,
          )
          .toList();

      developer.log(
        '🌱 [CULTURAS] JSON carregado: ${allCulturas.length} registros totais, ${culturas.length} culturas válidas',
        name: 'CulturasDataLoader',
      );
      print(
        '🌱 [CULTURAS] JSON carregado: ${allCulturas.length} registros totais, ${culturas.length} culturas válidas',
      );

      final repository = ref.watch(culturasRepositoryProvider);

      try {
        await repository.loadFromJson(culturas, '1.0.0');

        developer.log(
          'Culturas carregadas com sucesso!',
          name: 'CulturasDataLoader',
        );
        _isLoaded = true;

        // Verificação
        final List<Cultura> loadedCulturas =
            (await repository.findAll()) as List<Cultura>;
        developer.log(
          'Verificação: ${loadedCulturas.length} culturas disponíveis',
          name: 'CulturasDataLoader',
        );

        if (loadedCulturas.isNotEmpty) {
          developer.log(
            'Primeiras 3 culturas: ${loadedCulturas.take(3).map<Cultura>((c) => c).map((c) => c.nome).join(', ')}',
            name: 'CulturasDataLoader',
          );
        }
      } catch (e) {
        developer.log(
          'Erro ao carregar culturas: $e',
          name: 'CulturasDataLoader',
        );
        throw Exception('Erro ao carregar culturas: $e');
      }
    } catch (e) {
      developer.log(
        '❌ [CULTURAS] Erro durante carregamento de culturas: $e',
        name: 'CulturasDataLoader',
      );
      print('❌ [CULTURAS] Erro durante carregamento de culturas: $e');
      print('❌ [CULTURAS] Stack trace: ${StackTrace.current}');
    }
  }

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload(dynamic ref) async {
    _isLoaded = false;
    await loadCulturasData(ref);
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded(dynamic ref) async {
    if (!_isLoaded) return false;

    try {
      final repository = ref.watch(culturasRepositoryProvider);
      final List<Cultura> culturas =
          (await repository.findAll()) as List<Cultura>;
      return culturas.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats(dynamic ref) async {
    try {
      final repository = ref.read(culturasRepositoryProvider);
      final List<Cultura> culturas =
          (await repository.findAll()) as List<Cultura>;

      return {
        'total_culturas': culturas.length,
        'is_loaded': _isLoaded,
        'sample_culturas': culturas.take(5).map((c) => c.nome).toList(),
      };
    } catch (e) {
      return {'total_culturas': 0, 'is_loaded': false, 'error': e.toString()};
    }
  }
}
