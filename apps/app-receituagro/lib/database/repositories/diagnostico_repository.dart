import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../receituagro_database.dart';

/// Repositório SIMPLIFICADO de Diagnósticos usando Drift
///
/// ⚠️ IMPORTANTE: Tabela Diagnosticos é ESTÁTICA (dados de lookup)
/// - Não possui campos de audit (userId, createdAt, isDirty, etc)
/// - Dados carregados do Firebase apenas para consulta
/// - Não há operações de create/update/delete por usuário
///
/// Para diagnósticos do usuário, criar tabela separada "UserDiagnosticos"
class DiagnosticoRepository {
  DiagnosticoRepository(this._db);

  final ReceituagroDatabase _db;

  // ========== READ-ONLY QUERIES ==========

  Future<List<Diagnostico>> findAll() async {
    return await _db.select(_db.diagnosticos).get();
  }

  /// Stream de todos os diagnósticos
  Stream<List<Diagnostico>> watchAll() {
    return _db.select(_db.diagnosticos).watch();
  }

  /// Busca diagnóstico por idReg único (PRIMARY KEY)
  Future<Diagnostico?> findByIdReg(String idReg) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.idReg.equals(idReg)))
        .getSingleOrNull();
  }

  /// Busca diagnósticos por defensivo (string FK)
  Future<List<Diagnostico>> findByDefensivoId(String fkIdDefensivo) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.fkIdDefensivo.equals(fkIdDefensivo)))
        .get();
  }

  /// Busca diagnósticos por cultura (string FK)
  Future<List<Diagnostico>> findByCulturaId(String fkIdCultura) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.fkIdCultura.equals(fkIdCultura)))
        .get();
  }

  /// Busca diagnósticos por praga (string FK)
  Future<List<Diagnostico>> findByPragaId(String fkIdPraga) async {
    debugPrint('🔍 [DiagnosticoRepository] findByPragaId chamado com fkIdPraga: $fkIdPraga');
    final results = await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.fkIdPraga.equals(fkIdPraga)))
        .get();
    debugPrint('🔍 [DiagnosticoRepository] findByPragaId retornou ${results.length} resultados');
    return results;
  }

  /// Busca diagnósticos com join completo (defensivo + cultura + praga)
  /// NOTA: Joins agora usam string FKs
  Future<List<DiagnosticoEnriched>> findAllWithRelations() async {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(
        _db.fitossanitarios,
        _db.fitossanitarios.idDefensivo.equalsExp(_db.diagnosticos.fkIdDefensivo),
      ),
      leftOuterJoin(
        _db.culturas,
        _db.culturas.idCultura.equalsExp(_db.diagnosticos.fkIdCultura),
      ),
      leftOuterJoin(
        _db.pragas,
        _db.pragas.idPraga.equalsExp(_db.diagnosticos.fkIdPraga),
      ),
    ]);

    final results = await query.get();

    return results.map((row) {
      return DiagnosticoEnriched(
        diagnostico: row.readTable(_db.diagnosticos),
        defensivo: row.readTableOrNull(_db.fitossanitarios),
        cultura: row.readTableOrNull(_db.culturas),
        praga: row.readTableOrNull(_db.pragas),
      );
    }).toList();
  }

  /// Stream de diagnósticos com relações
  Stream<List<DiagnosticoEnriched>> watchAllWithRelations() {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(
        _db.fitossanitarios,
        _db.fitossanitarios.idDefensivo.equalsExp(_db.diagnosticos.fkIdDefensivo),
      ),
      leftOuterJoin(
        _db.culturas,
        _db.culturas.idCultura.equalsExp(_db.diagnosticos.fkIdCultura),
      ),
      leftOuterJoin(
        _db.pragas,
        _db.pragas.idPraga.equalsExp(_db.diagnosticos.fkIdPraga),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DiagnosticoEnriched(
          diagnostico: row.readTable(_db.diagnosticos),
          defensivo: row.readTableOrNull(_db.fitossanitarios),
          cultura: row.readTableOrNull(_db.culturas),
          praga: row.readTableOrNull(_db.pragas),
        );
      }).toList();
    });
  }

  /// Busca diagnósticos enriquecidos por defensivo
  Future<List<DiagnosticoEnriched>> findByDefensivoWithRelations(
    String fkIdDefensivo,
  ) async {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(
        _db.fitossanitarios,
        _db.fitossanitarios.idDefensivo.equalsExp(_db.diagnosticos.fkIdDefensivo),
      ),
      leftOuterJoin(
        _db.culturas,
        _db.culturas.idCultura.equalsExp(_db.diagnosticos.fkIdCultura),
      ),
      leftOuterJoin(
        _db.pragas,
        _db.pragas.idPraga.equalsExp(_db.diagnosticos.fkIdPraga),
      ),
    ])
      ..where(_db.diagnosticos.fkIdDefensivo.equals(fkIdDefensivo));

    final results = await query.get();

    return results.map((row) {
      return DiagnosticoEnriched(
        diagnostico: row.readTable(_db.diagnosticos),
        defensivo: row.readTableOrNull(_db.fitossanitarios),
        cultura: row.readTableOrNull(_db.culturas),
        praga: row.readTableOrNull(_db.pragas),
      );
    }).toList();
  }

  /// Conta total de diagnósticos
  Future<int> count() async {
    final cnt = _db.diagnosticos.idReg.count();
    final query = _db.selectOnly(_db.diagnosticos)..addColumns([cnt]);
    final result = await query.getSingle();
    return result.read(cnt) ?? 0;
  }

  // ========== BULK INSERT (Para carga inicial de dados) ==========

  /// Insere diagnósticos em lote (para carga inicial do Firebase)
  Future<void> insertBatch(List<DiagnosticosCompanion> diagnosticos) async {
    await _db.batch((batch) {
      batch.insertAll(_db.diagnosticos, diagnosticos);
    });
  }

  Future<void> deleteAll() async {
    await _db.delete(_db.diagnosticos).go();
  }

  /// Insere ou atualiza diagnóstico (upsert por idReg)
  Future<void> upsert(DiagnosticosCompanion companion) async {
    await _db.into(_db.diagnosticos).insertOnConflictUpdate(companion);
  }

  /// Insere ou atualiza em lote
  Future<void> upsertBatch(List<DiagnosticosCompanion> diagnosticos) async {
    await _db.batch((batch) {
      for (final diagnostico in diagnosticos) {
        batch.insert(
          _db.diagnosticos,
          diagnostico,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ========== COMPATIBILITY METHODS (for legacy code) ==========

  /// Alias for findAll - compatibility method
  Future<List<Diagnostico>> getAll() async {
    return await findAll();
  }

  /// Busca por ID ou ObjectId (Firebase) - compatibility method
  Future<Diagnostico?> getByIdOrObjectId(String id) async {
    return await findByIdOrObjectId(id);
  }

  /// Alias compatibility
  Future<Diagnostico?> getDiagnosticoByIdOrObjectId(String id) async {
    return await findByIdOrObjectId(id);
  }

  /// Busca por ID ou ObjectId com múltiplos formatos
  Future<Diagnostico?> findByIdOrObjectId(String id) async {
    // Tenta como idReg
    return await findByIdReg(id);
  }
}

/// Classe auxiliar para retornar diagnóstico com dados relacionados
class DiagnosticoEnriched {
  final Diagnostico diagnostico;
  final Fitossanitario? defensivo;
  final Cultura? cultura;
  final Praga? praga;

  DiagnosticoEnriched({
    required this.diagnostico,
    this.defensivo,
    this.cultura,
    this.praga,
  });

  String get nomeDefensivo => defensivo?.nome ?? 'Desconhecido';
  String get nomeCultura => cultura?.nome ?? 'Desconhecida';
  String get nomePraga => praga?.nome ?? 'Desconhecida';
}
