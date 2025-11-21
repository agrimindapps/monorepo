import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:drift/drift.dart';
import '../../database/receituagro_database.dart';
import '../../database/repositories/diagnostico_repository.dart';
import '../../database/repositories/fitossanitarios_repository.dart';
import '../../database/repositories/culturas_repository.dart';
import '../../database/repositories/pragas_repository.dart';
import '../di/injection_container.dart' as di;

/// Serviço para carregar dados de diagnósticos dos assets JSON
class DiagnosticosDataLoader {
  static bool _isLoaded = false;

  /// Carrega dados de diagnósticos do JSON dos assets usando repositório
  static Future<void> loadDiagnosticosData() async {
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
        final repository = di.sl<DiagnosticoRepository>();
        final fitossanitariosRepo = di.sl<FitossanitariosRepository>();
        final culturasRepo = di.sl<CulturasRepository>();
        final pragasRepo = di.sl<PragasRepository>();

        // Load lookup maps
        final fitossanitarios = await fitossanitariosRepo.findAll();
        final culturas = await culturasRepo.findAll();
        final pragas = await pragasRepo.findAll();

        final defensivoMap = {
          for (var f in fitossanitarios) f.idDefensivo: f.id
        };
        final culturaMap = {for (var c in culturas) c.idCultura: c.id};
        final pragaMap = {for (var p in pragas) p.idPraga: p.id};

        // Convert JSON to Companions with ID resolution
        final List<DiagnosticosCompanion> batch = [];

        for (final d in diagnosticos) {
          final defensivoIdStr = d['fkIdDefensivo'].toString();
          final culturaIdStr = d['fkIdCultura'].toString();
          final pragaIdStr = d['fkIdPraga'].toString();

          final defensivoId = defensivoMap[defensivoIdStr];
          final culturaId = culturaMap[culturaIdStr];
          final pragaId = pragaMap[pragaIdStr];

          if (defensivoId != null && culturaId != null && pragaId != null) {
            batch.add(DiagnosticosCompanion(
              idReg: Value(d['IdReg'].toString()),
              defensivoId: Value(defensivoId),
              culturaId: Value(culturaId),
              pragaId: Value(pragaId),
              dsMin: Value(d['DsMin']?.toString()),
              dsMax: Value(d['DsMax']?.toString() ?? ''),
              um: Value(d['Um']?.toString() ?? ''),
              minAplicacaoT: Value(d['MinAplicacaoT']?.toString()),
              maxAplicacaoT: Value(d['MaxAplicacaoT']?.toString()),
              umT: Value(d['UmT']?.toString()),
              minAplicacaoA: Value(d['MinAplicacaoA']?.toString()),
              maxAplicacaoA: Value(d['MaxAplicacaoA']?.toString()),
              umA: Value(d['UmA']?.toString()),
              intervalo: Value(d['Intervalo']?.toString()),
              intervalo2: Value(d['Intervalo2']?.toString()),
              epocaAplicacao: Value(d['EpocaAplicacao']?.toString()),
            ));
          }
        }

        if (batch.isNotEmpty) {
          // Insert into database
          await repository.insertBatch(batch);

          if (kDebugMode) {
            debugPrint(
                '✓ DiagnosticosDataLoader: Inserted ${batch.length} items into database (skipped ${diagnosticos.length - batch.length} invalid references)');
          }
        } else {
          if (kDebugMode) {
            debugPrint(
                '⚠️ DiagnosticosDataLoader: No items with valid references found to insert');
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

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload() async {
    _isLoaded = false;
    await loadDiagnosticosData();
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded() async {
    try {
      final repository = di.sl<DiagnosticoRepository>();
      final diagnosticos = await repository.getAll();
      final hasData = diagnosticos.isNotEmpty;

      return hasData;
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas de carregamento
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final repository = di.sl<DiagnosticoRepository>();
      final diagnosticos = await repository.getAll();

      return {
        'total_diagnosticos': diagnosticos.length,
        'is_loaded': _isLoaded,
        'sample_diagnosticos':
            diagnosticos.take(5).map((d) => d.idReg).toList(),
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
