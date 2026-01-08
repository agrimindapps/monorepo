import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../database/providers/database_providers.dart';
import '../../database/receituagro_database.dart';
import '../../database/repositories/diagnostico_repository.dart';

/// Serviço para carregar dados de diagnósticos dos assets JSON
class DiagnosticosDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de diagnósticos do JSON dos assets usando repositório
  static Future<void> loadDiagnosticosData(dynamic ref) async {
    if (_isLoaded) {
      return;
    }

    try {
      final List<Map<String, dynamic>> allDiagnosticos = [];
      for (int i = 0; i <= 64; i++) {
        try {
          final String assetPath = kIsWeb
              ? 'database/json/tbdiagnostico/TBDIAGNOSTICO$i.json'
              : 'assets/database/json/tbdiagnostico/TBDIAGNOSTICO$i.json';

          final String jsonString = await rootBundle.loadString(assetPath);

          final dynamic decodedJson = json.decode(jsonString);
          final List<dynamic> jsonData = decodedJson is List ? decodedJson : [];
          final List<Map<String, dynamic>> diagnosticos =
              jsonData.cast<Map<String, dynamic>>().toList();

          allDiagnosticos.addAll(diagnosticos);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ DiagnosticosDataLoader: Error loading file TBDIAGNOSTICO$i.json - $e',
            );
          }
        }
      }
      final List<Map<String, dynamic>> diagnosticos = allDiagnosticos
          .where(
            (item) =>
                item['IdReg'] != null &&
                item['IdReg'].toString().trim().isNotEmpty &&
                item['fkIdDefensivo'] != null &&
                item['fkIdCultura'] != null &&
                item['fkIdPraga'] != null,
          )
          .toList();

      if (diagnosticos.isNotEmpty) {
        final repository = ref.read(diagnosticoRepositoryProvider);

        // LIMPAR DADOS EXISTENTES antes de inserir novos
        // Isso garante que registros removidos do JSON sejam removidos do SQLite
        if (kDebugMode) {
          debugPrint('🗑️ DiagnosticosDataLoader: Limpando dados existentes...');
        }
        await repository.deleteAll();

        // Convert JSON to Companions - direct string FK insertion (no lookup needed)
        final List<DiagnosticosCompanion> batch = [];

        for (final d in diagnosticos) {
          final fkIdDefensivo = d['fkIdDefensivo'].toString();
          final fkIdCultura = d['fkIdCultura'].toString();
          final fkIdPraga = d['fkIdPraga'].toString();

          batch.add(DiagnosticosCompanion(
            idReg: Value(d['IdReg'].toString()),
            fkIdDefensivo: Value(fkIdDefensivo),
            fkIdCultura: Value(fkIdCultura),
            fkIdPraga: Value(fkIdPraga),
            // Chaves em camelCase conforme JSON original
            dsMin: Value(d['dsMin']?.toString()),
            dsMax: Value(d['dsMax']?.toString() ?? ''),
            um: Value(d['um']?.toString() ?? ''),
            minAplicacaoT: Value(d['minAplicacaoT']?.toString()),
            maxAplicacaoT: Value(d['maxAplicacaoT']?.toString()),
            umT: Value(d['umT']?.toString()),
            minAplicacaoA: Value(d['minAplicacaoA']?.toString()),
            maxAplicacaoA: Value(d['maxAplicacaoA']?.toString()),
            umA: Value(d['umA']?.toString()),
            intervalo: Value(d['intervalo']?.toString()),
            intervalo2: Value(d['intervalo2']?.toString()),
            epocaAplicacao: Value(d['epocaAplicacao']?.toString()),
          ));
        }

        if (batch.isNotEmpty) {
          // Usar insertBatch pois já limpamos a tabela antes
          await repository.insertBatch(batch);

          if (kDebugMode) {
            debugPrint(
                '✓ DiagnosticosDataLoader: Inserted ${batch.length} items into database');
          }
        } else {
          if (kDebugMode) {
            debugPrint(
                '⚠️ DiagnosticosDataLoader: No items found to insert');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              '⚠️ DiagnosticosDataLoader: No valid items found to insert');
        }
      }

      _isLoaded = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Força recarregamento dos dados (reseta flag para permitir novo carregamento)
  static void forceReload(dynamic ref) {
    _isLoaded = false;
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded(dynamic ref) async {
    try {
      final repository =
          ref.read(diagnosticoRepositoryProvider) as DiagnosticoRepository;
      final List<Diagnostico> diagnosticos = await repository.getAll();
      final hasData = diagnosticos.isNotEmpty;

      return hasData;
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats(dynamic ref) async {
    try {
      final repository =
          ref.read(diagnosticoRepositoryProvider) as DiagnosticoRepository;
      final List<Diagnostico> diagnosticos = await repository.getAll();

      return {
        'total_diagnosticos': diagnosticos.length,
        'is_loaded': _isLoaded,
        'sample_diagnosticos':
            diagnosticos.take(5).map((Diagnostico d) => d.idReg).toList(),
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
