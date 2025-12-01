import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../database/providers/database_providers.dart';
import '../../database/receituagro_database.dart';

/// Loader para carregar dados de informações de pragas do JSON para o SQLite
class PragasInfDataLoader {
  static bool _isLoaded = false;

  /// Carrega os dados de PragasInf do JSON para o banco
  static Future<void> loadPragasInfData(dynamic ref) async {
    if (_isLoaded) {
      developer.log(
        '⚠️ [PRAGAS_INF] Já carregado, pulando...',
        name: 'PragasInfDataLoader',
      );
      return;
    }

    try {
      final db = ref.read(databaseProvider) as ReceituagroDatabase;

      developer.log(
        '🔬 [PRAGAS_INF] Iniciando carregamento de informações de pragas...',
        name: 'PragasInfDataLoader',
      );

      // Limpar dados existentes
      await db.delete(db.pragasInf).go();
      developer.log(
        '🗑️ [PRAGAS_INF] Dados existentes removidos',
        name: 'PragasInfDataLoader',
      );

      // Carregar arquivos JSON
      final List<Map<String, dynamic>> allRecords = [];

      // Carrega todos os arquivos TBPRAGASINF*.json
      for (int i = 0; i < 10; i++) {
        try {
          final String assetPath = kIsWeb
              ? 'database/json/tbpragasinf/TBPRAGASINF$i.json'
              : 'assets/database/json/tbpragasinf/TBPRAGASINF$i.json';

          final jsonString = await rootBundle.loadString(assetPath);
          final jsonList = json.decode(jsonString) as List<dynamic>;
          allRecords.addAll(jsonList.cast<Map<String, dynamic>>());
          developer.log(
            '🔬 [PRAGAS_INF] Arquivo TBPRAGASINF$i.json carregado: ${jsonList.length} registros',
            name: 'PragasInfDataLoader',
          );
        } catch (e) {
          // Arquivo não existe, parar de tentar
          break;
        }
      }

      if (allRecords.isEmpty) {
        developer.log(
          '⚠️ [PRAGAS_INF] Nenhum registro encontrado',
          name: 'PragasInfDataLoader',
        );
        return;
      }

      developer.log(
        '🔬 [PRAGAS_INF] Total de registros JSON: ${allRecords.length}',
        name: 'PragasInfDataLoader',
      );

      // Buscar mapeamento de idPraga -> id
      final pragasQuery = db.select(db.pragas);
      final allPragas = await pragasQuery.get();
      final pragaIdMap = <String, int>{};
      for (final praga in allPragas) {
        pragaIdMap[praga.idPraga] = praga.id;
      }
      developer.log(
        '🔬 [PRAGAS_INF] Mapeamento de pragas criado: ${pragaIdMap.length} pragas',
        name: 'PragasInfDataLoader',
      );

      // Inserir em batch
      int insertedCount = 0;
      int skippedCount = 0;

      await db.batch((batch) {
        for (final record in allRecords) {
          final idReg = record['idReg'] as String?;
          final fkIdPraga = record['fkIdPraga'] as String?;

          if (idReg == null || idReg.isEmpty) {
            skippedCount++;
            continue;
          }

          // Obter ID da praga (FK) - usar fkIdPraga ou idReg como fallback
          final pragaId = pragaIdMap[fkIdPraga ?? idReg];
          if (pragaId == null) {
            skippedCount++;
            continue;
          }

          batch.insert(
            db.pragasInf,
            PragasInfCompanion.insert(
              idReg: idReg,
              pragaId: pragaId,
              sintomas: Value(record['sintomas'] as String?),
              controle: Value(record['controle'] as String?),
              danos: Value(record['descrisao'] as String?), // descrisao -> danos
              condicoesFavoraveis: Value(record['bioecologia'] as String?),
            ),
          );
          insertedCount++;
        }
      });

      _isLoaded = true;

      developer.log(
        '✅ [PRAGAS_INF] Carregamento concluído: $insertedCount inseridos, $skippedCount ignorados',
        name: 'PragasInfDataLoader',
      );
    } catch (e, stack) {
      developer.log(
        '❌ [PRAGAS_INF] Erro ao carregar: $e',
        name: 'PragasInfDataLoader',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Força recarregamento na próxima chamada
  static void forceReload(dynamic ref) {
    _isLoaded = false;
  }

  /// Verifica se dados estão carregados
  static Future<bool> isDataLoaded(dynamic ref) async {
    if (!_isLoaded) return false;

    try {
      final repo = ref.read(pragasInfRepositoryProvider);
      final all = await repo.findAll() as List<dynamic>;
      return all.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
