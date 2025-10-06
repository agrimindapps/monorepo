import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/repositories/fitossanitario_hive_repository.dart';
import '../di/injection_container.dart' as di;

/// Serviço para carregar dados de fitossanitários dos assets JSON
class FitossanitariosDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de fitossanitários do JSON dos assets usando repositório
  static Future<void> loadFitossanitariosData() async {
    if (_isLoaded) {
      developer.log(
        'Fitossanitários já carregados, pulando...',
        name: 'FitossanitariosDataLoader',
      );
      return;
    }

    try {
      developer.log(
        '🛡️ [FITOSSANITARIOS] Iniciando carregamento de fitossanitários...',
        name: 'FitossanitariosDataLoader',
      );
      print(
        '🛡️ [FITOSSANITARIOS] Iniciando carregamento de fitossanitários...',
      );

      final List<Map<String, dynamic>> allFitossanitarios = [];

      // Carrega todos os arquivos JSON de fitossanitários
      for (int i = 0; i <= 2; i++) {
        try {
          // Use path without 'assets/' prefix for web compatibility
          final String assetPath =
              kIsWeb
                  ? 'database/json/tbfitossanitarios/TBFITOSSANITARIOS$i.json'
                  : 'assets/database/json/tbfitossanitarios/TBFITOSSANITARIOS$i.json';

          final String jsonString = await rootBundle.loadString(assetPath);

          final dynamic decodedJson = json.decode(jsonString);
          final List<dynamic> jsonData = decodedJson is List ? decodedJson : [];
          final List<Map<String, dynamic>> fitossanitarios =
              jsonData.cast<Map<String, dynamic>>().toList();

          allFitossanitarios.addAll(fitossanitarios);

          developer.log(
            '🛡️ [FITOSSANITARIOS] Arquivo TBFITOSSANITARIOS$i.json carregado: ${fitossanitarios.length} registros',
            name: 'FitossanitariosDataLoader',
          );
        } catch (e) {
          developer.log(
            '⚠️ [FITOSSANITARIOS] Arquivo TBFITOSSANITARIOS$i.json não encontrado ou erro: $e',
            name: 'FitossanitariosDataLoader',
          );
        }
      }

      // Filtra apenas registros válidos
      final List<Map<String, dynamic>> fitossanitarios =
          allFitossanitarios
              .where(
                (item) =>
                    item['nomeComum'] != null &&
                    item['nomeComum'].toString().trim().isNotEmpty &&
                    item['idReg'] != null &&
                    item['idReg'].toString().trim().isNotEmpty,
              )
              .toList();

      developer.log(
        '🛡️ [FITOSSANITARIOS] JSON carregado: ${allFitossanitarios.length} registros totais, ${fitossanitarios.length} fitossanitários válidos',
        name: 'FitossanitariosDataLoader',
      );
      print(
        '🛡️ [FITOSSANITARIOS] JSON carregado: ${allFitossanitarios.length} registros totais, ${fitossanitarios.length} fitossanitários válidos',
      );

      // Obtém repositório do DI
      final repository = di.sl<FitossanitarioHiveRepository>();

      // Carrega dados no repositório
      final result = await repository.loadFromJson(fitossanitarios, '1.0.0');

      result.fold(
        (error) {
          developer.log(
            'Erro ao carregar fitossanitários: $error',
            name: 'FitossanitariosDataLoader',
          );
          throw Exception('Erro ao carregar fitossanitários: $error');
        },
        (_) {
          developer.log(
            'Fitossanitários carregados com sucesso!',
            name: 'FitossanitariosDataLoader',
          );
          _isLoaded = true;
        },
      );

      // Verifica se dados foram realmente salvos
      final loadedResult = await repository.getAll();
      if (loadedResult.isSuccess) {
        final loadedFitossanitarios = loadedResult.data!;
        developer.log(
          'Verificação: ${loadedFitossanitarios.length} fitossanitários disponíveis',
          name: 'FitossanitariosDataLoader',
        );

        if (loadedFitossanitarios.isNotEmpty) {
          developer.log(
            'Primeiros 3 fitossanitários: ${loadedFitossanitarios.take(3).map((f) => f.nomeComum).join(', ')}',
            name: 'FitossanitariosDataLoader',
          );
        }
      }
    } catch (e) {
      developer.log(
        '❌ [FITOSSANITARIOS] Erro durante carregamento de fitossanitários: $e',
        name: 'FitossanitariosDataLoader',
      );
      print(
        '❌ [FITOSSANITARIOS] Erro durante carregamento de fitossanitários: $e',
      );
      print('❌ [FITOSSANITARIOS] Stack trace: ${StackTrace.current}');
      // Não bloqueia o app, apenas registra o erro
    }
  }

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload() async {
    _isLoaded = false;
    await loadFitossanitariosData();
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded() async {
    try {
      final repository = di.sl<FitossanitarioHiveRepository>();
      final result = await repository.getAll();

      if (result.isSuccess) {
        final fitossanitarios = result.data!;
        final hasData = fitossanitarios.isNotEmpty;

        developer.log(
          '🔍 [FITOSSANITARIOS] isDataLoaded() - Repository has ${fitossanitarios.length} items: $hasData',
          name: 'FitossanitariosDataLoader',
        );

        return hasData;
      } else {
        developer.log(
          '❌ [FITOSSANITARIOS] Error getting all items: ${result.error}',
          name: 'FitossanitariosDataLoader',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '❌ [FITOSSANITARIOS] Error checking isDataLoaded: $e',
        name: 'FitossanitariosDataLoader',
      );
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final repository = di.sl<FitossanitarioHiveRepository>();
      final result = await repository.getAll();

      if (result.isSuccess) {
        final fitossanitarios = result.data!;
        return {
          'total_fitossanitarios': fitossanitarios.length,
          'is_loaded': _isLoaded,
          'sample_fitossanitarios':
              fitossanitarios.take(5).map((f) => f.nomeComum).toList(),
        };
      } else {
        return {
          'total_fitossanitarios': 0,
          'is_loaded': false,
          'error': result.error.toString(),
        };
      }
    } catch (e) {
      return {
        'total_fitossanitarios': 0,
        'is_loaded': false,
        'error': e.toString(),
      };
    }
  }
}
