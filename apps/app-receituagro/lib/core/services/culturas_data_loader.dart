import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../di/injection_container.dart' as di;
import '../repositories/cultura_hive_repository.dart';

/// Serviço para carregar dados de culturas dos assets JSON
class CulturasDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de culturas do JSON dos assets usando repositório Hive
  static Future<void> loadCulturasData() async {
    if (_isLoaded) {
      developer.log('Culturas já carregadas, pulando...',
          name: 'CulturasDataLoader');
      return;
    }

    try {
      developer.log('🌱 [CULTURAS] Iniciando carregamento de culturas...',
          name: 'CulturasDataLoader');
      print('🌱 [CULTURAS] Iniciando carregamento de culturas...');

      // 1. Carrega JSON do asset - use path without 'assets/' prefix for web compatibility
      final String assetPath = kIsWeb 
          ? 'database/json/tbculturas/TBCULTURAS0.json'
          : 'assets/database/json/tbculturas/TBCULTURAS0.json';
      
      final String jsonString = await rootBundle.loadString(assetPath);

      final dynamic decodedJson = json.decode(jsonString);
      final List<dynamic> jsonData = decodedJson is List ? decodedJson : [];
      final List<Map<String, dynamic>> allCulturas =
          jsonData.cast<Map<String, dynamic>>().toList();

      // Filtra apenas registros válidos
      final List<Map<String, dynamic>> culturas = allCulturas
          .where((item) =>
              item['cultura'] != null &&
              item['cultura'].toString().trim().isNotEmpty &&
              item['idReg'] != null &&
              item['idReg'].toString().trim().isNotEmpty)
          .toList();

      developer.log(
          '🌱 [CULTURAS] JSON carregado: ${allCulturas.length} registros totais, ${culturas.length} culturas válidas',
          name: 'CulturasDataLoader');
      print(
          '🌱 [CULTURAS] JSON carregado: ${allCulturas.length} registros totais, ${culturas.length} culturas válidas');

      // 2. Obtém repositório do DI
      final repository = di.sl<CulturaHiveRepository>();

      // 3. Carrega dados no repositório
      final result = await repository.loadFromJson(culturas, '1.0.0');

      result.fold(
        (error) {
          developer.log('Erro ao carregar culturas: $error',
              name: 'CulturasDataLoader');
          throw error;
        },
        (_) {
          developer.log('Culturas carregadas com sucesso!',
              name: 'CulturasDataLoader');
          _isLoaded = true;
        },
      );

      // 4. Verifica se dados foram realmente salvos
      final loadedCulturas = repository.getAll();
      developer.log(
          'Verificação: ${loadedCulturas.length} culturas disponíveis',
          name: 'CulturasDataLoader');

      if (loadedCulturas.isNotEmpty) {
        developer.log(
            'Primeiras 3 culturas: ${loadedCulturas.take(3).map((c) => c.cultura).join(', ')}',
            name: 'CulturasDataLoader');
      }
    } catch (e) {
      developer.log('❌ [CULTURAS] Erro durante carregamento de culturas: $e',
          name: 'CulturasDataLoader');
      print('❌ [CULTURAS] Erro durante carregamento de culturas: $e');
      print('❌ [CULTURAS] Stack trace: ${StackTrace.current}');
      // Não bloqueia o app, apenas registra o erro
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
      final repository = di.sl<CulturaHiveRepository>();
      final culturas = repository.getAll();
      return culturas.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final repository = di.sl<CulturaHiveRepository>();
      final culturas = repository.getAll();

      return {
        'total_culturas': culturas.length,
        'is_loaded': _isLoaded,
        'sample_culturas': culturas.take(5).map((c) => c.cultura).toList(),
      };
    } catch (e) {
      return {
        'total_culturas': 0,
        'is_loaded': false,
        'error': e.toString(),
      };
    }
  }
}
