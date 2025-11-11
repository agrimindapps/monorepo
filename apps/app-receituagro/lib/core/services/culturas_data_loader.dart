import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../database/repositories/culturas_repository.dart';
import '../di/injection_container.dart' as di;

class CulturasDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de culturas do JSON dos assets usando repositório Hive
  static Future<void> loadCulturasData() async {
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
      final List<Map<String, dynamic>> allCulturas = jsonData
          .cast<Map<String, dynamic>>()
          .toList();
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

      final repository = di.sl<CulturasRepository>();

      try {
        await repository.loadFromJson(culturas, '1.0.0');

        developer.log(
          'Culturas carregadas com sucesso!',
          name: 'CulturasDataLoader',
        );
        _isLoaded = true;

        // Verificação
        final loadedCulturas = await repository.findAll();
        developer.log(
          'Verificação: ${loadedCulturas.length} culturas disponíveis',
          name: 'CulturasDataLoader',
        );

        if (loadedCulturas.isNotEmpty) {
          developer.log(
            'Primeiras 3 culturas: ${loadedCulturas.take(3).map((c) => c.nome).join(', ')}',
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
  static Future<void> forceReload() async {
    _isLoaded = false;
    await loadCulturasData();
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded() async {
    if (!_isLoaded) return false;

    try {
      final repository = di.sl<CulturasRepository>();
      final culturas = await repository.findAll();
      return culturas.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final repository = di.sl<CulturasRepository>();
      final culturas = await repository.findAll();

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
