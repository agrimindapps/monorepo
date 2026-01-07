import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../database/providers/database_providers.dart';
import '../../database/receituagro_database.dart';
import '../../database/repositories/fitossanitarios_repository.dart';

/// Serviço para carregar dados de fitossanitários dos assets JSON
class FitossanitariosDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de fitossanitários do JSON dos assets usando repositório
  static Future<void> loadFitossanitariosData(dynamic ref) async {
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
      debugPrint(
        '🛡️ [FITOSSANITARIOS] Iniciando carregamento de fitossanitários...',
      );

      final List<Map<String, dynamic>> allFitossanitarios = [];
      for (int i = 0; i <= 2; i++) {
        try {
          final String assetPath = kIsWeb
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
      final List<Map<String, dynamic>> fitossanitarios = allFitossanitarios
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
      debugPrint(
        '🛡️ [FITOSSANITARIOS] JSON carregado: ${allFitossanitarios.length} registros totais, ${fitossanitarios.length} fitossanitários válidos',
      );
      final repository = ref.read(fitossanitariosRepositoryProvider);
      await repository.loadFromJson(fitossanitarios, '1.0.0');

      developer.log(
        'Fitossanitários carregados com sucesso!',
        name: 'FitossanitariosDataLoader',
      );
      _isLoaded = true;

      final List<Fitossanitario> loadedFitossanitarios =
          await (repository.findAll() as Future<List<Fitossanitario>>);
      developer.log(
        'Verificação: ${loadedFitossanitarios.length} fitossanitários disponíveis',
        name: 'FitossanitariosDataLoader',
      );

      if (loadedFitossanitarios.isNotEmpty) {
        developer.log(
          'Primeiros 3 fitossanitários: ${loadedFitossanitarios.take(3).map((Fitossanitario f) => f.nome).join(', ')}',
          name: 'FitossanitariosDataLoader',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [FITOSSANITARIOS] Erro durante carregamento de fitossanitários: $e',
        name: 'FitossanitariosDataLoader',
      );
      debugPrint(
        '❌ [FITOSSANITARIOS] Erro durante carregamento de fitossanitários: $e',
      );
      debugPrint('❌ [FITOSSANITARIOS] Stack trace: ${StackTrace.current}');
    }
  }

  /// Força recarregamento dos dados (reseta flag para permitir novo carregamento)
  static void forceReload(dynamic ref) {
    _isLoaded = false;
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded(dynamic ref) async {
    try {
      final repository = ref.read(fitossanitariosRepositoryProvider)
          as FitossanitariosRepository;
      final List<Fitossanitario> fitossanitarios = await repository.findAll();
      final hasData = fitossanitarios.isNotEmpty;

      developer.log(
        '🔍 [FITOSSANITARIOS] isDataLoaded() - Repository has ${fitossanitarios.length} items: $hasData',
        name: 'FitossanitariosDataLoader',
      );

      return hasData;
    } catch (e) {
      developer.log(
        '❌ [FITOSSANITARIOS] Error checking isDataLoaded: $e',
        name: 'FitossanitariosDataLoader',
      );
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats(dynamic ref) async {
    try {
      final repository = ref.read(fitossanitariosRepositoryProvider)
          as FitossanitariosRepository;
      final List<Fitossanitario> fitossanitarios = await repository.findAll();

      return {
        'total_fitossanitarios': fitossanitarios.length,
        'is_loaded': _isLoaded,
        'sample_fitossanitarios':
            fitossanitarios.take(5).map((Fitossanitario f) => f.nome).toList(),
      };
    } catch (e) {
      return {
        'total_fitossanitarios': 0,
        'is_loaded': false,
        'error': e.toString(),
      };
    }
  }
}
