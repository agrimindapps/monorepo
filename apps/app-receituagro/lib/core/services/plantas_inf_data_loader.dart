import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../database/providers/database_providers.dart';
import '../../database/receituagro_database.dart';

/// Loader para carregar dados de informações de plantas daninhas do JSON para o SQLite
///
/// NOTA: PlantasInf contém informações sobre plantas daninhas (pragas tipo 3),
/// não informações sobre culturas agrícolas. O campo `culturaId` na tabela
/// referencia a tabela `pragas` (por legado do schema original).
class PlantasInfDataLoader {
  static bool _isLoaded = false;

  /// Carrega os dados de PlantasInf do JSON para o banco
  static Future<void> loadPlantasInfData(dynamic ref) async {
    if (_isLoaded) {
      developer.log(
        '⚠️ [PLANTAS_INF] Já carregado, pulando...',
        name: 'PlantasInfDataLoader',
      );
      return;
    }

    try {
      final db = ref.read(databaseProvider) as ReceituagroDatabase;

      developer.log(
        '🌿 [PLANTAS_INF] Iniciando carregamento de informações de plantas...',
        name: 'PlantasInfDataLoader',
      );

      // Limpar dados existentes
      await db.delete(db.plantasInf).go();
      developer.log(
        '🗑️ [PLANTAS_INF] Dados existentes removidos',
        name: 'PlantasInfDataLoader',
      );

      // Carregar arquivos JSON
      final List<Map<String, dynamic>> allRecords = [];

      // Carrega todos os arquivos TBPLANTASINF*.json
      for (int i = 0; i < 10; i++) {
        try {
          final String assetPath = kIsWeb
              ? 'database/json/tbplantasinf/TBPLANTASINF$i.json'
              : 'assets/database/json/tbplantasinf/TBPLANTASINF$i.json';

          final jsonString = await rootBundle.loadString(assetPath);
          final jsonList = json.decode(jsonString) as List<dynamic>;
          allRecords.addAll(jsonList.cast<Map<String, dynamic>>());
          developer.log(
            '🌿 [PLANTAS_INF] Arquivo TBPLANTASINF$i.json carregado: ${jsonList.length} registros',
            name: 'PlantasInfDataLoader',
          );
        } catch (e) {
          // Arquivo não existe, parar de tentar
          break;
        }
      }

      if (allRecords.isEmpty) {
        developer.log(
          '⚠️ [PLANTAS_INF] Nenhum registro encontrado',
          name: 'PlantasInfDataLoader',
        );
        return;
      }

      developer.log(
        '🌿 [PLANTAS_INF] Total de registros JSON: ${allRecords.length}',
        name: 'PlantasInfDataLoader',
      );

      // Buscar mapeamento de idPraga -> id
      // PlantasInf referencia pragas do tipo 3 (plantas daninhas)
      final pragasQuery = db.select(db.pragas);
      final allPragas = await pragasQuery.get();
      final pragaIdMap = <String, int>{};
      for (final praga in allPragas) {
        pragaIdMap[praga.idPraga] = praga.id;
      }
      developer.log(
        '🌿 [PLANTAS_INF] Mapeamento de pragas criado: ${pragaIdMap.length} pragas',
        name: 'PlantasInfDataLoader',
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
          // O fkIdPraga no JSON corresponde ao idPraga na tabela Pragas
          final pragaId = pragaIdMap[fkIdPraga ?? idReg];
          if (pragaId == null) {
            skippedCount++;
            continue;
          }

          batch.insert(
            db.plantasInf,
            PlantasInfCompanion.insert(
              idReg: idReg,
              culturaId: pragaId, // Usa pragaId como culturaId (legado do schema)
              ciclo: Value(record['ciclo'] as String?),
              reproducao: Value(record['reproducao'] as String?),
              habitat: Value(record['habitat'] as String?),
              adaptacoes: Value(record['adaptacoes'] as String?),
              altura: Value(record['altura'] as String?),
              filotaxia: Value(record['filotaxia'] as String?),
              formaLimbo: Value(record['formaLimbo'] as String?),
              superficie: Value(record['superficie'] as String?),
              consistencia: Value(record['consistencia'] as String?),
              nervacao: Value(record['nervacao'] as String?),
              nervacaoComprimento: Value(record['nervacaoComprimento'] as String?),
              margemFolha: Value(record['margemFolha'] as String?),
              folha: Value(record['folha'] as String?),
              base: Value(record['base'] as String?),
              formaBase: Value(record['formaBase'] as String?),
              apice: Value(record['apice'] as String?),
              formaApice: Value(record['formaApice'] as String?),
              tipoFlor: Value(record['tipoFlor'] as String?),
              corFlor: Value(record['corFlor'] as String?),
              tipoFruto: Value(record['tipoFruto'] as String?),
              corFruto: Value(record['corFruto'] as String?),
              tipoSemente: Value(record['tipoSemente'] as String?),
              corSemente: Value(record['corSemente'] as String?),
            ),
          );
          insertedCount++;
        }
      });

      _isLoaded = true;

      developer.log(
        '✅ [PLANTAS_INF] Carregamento concluído: $insertedCount inseridos, $skippedCount ignorados',
        name: 'PlantasInfDataLoader',
      );
    } catch (e, stack) {
      developer.log(
        '❌ [PLANTAS_INF] Erro ao carregar: $e',
        name: 'PlantasInfDataLoader',
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
      final repo = ref.read(plantasInfRepositoryProvider);
      final all = await repo.findAll() as List<dynamic>;
      return all.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
