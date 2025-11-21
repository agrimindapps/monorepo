import 'package:core/core.dart';
import 'package:drift/drift.dart';

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

  /// Busca diagnóstico por ID local
  Future<Diagnostico?> findById(int id) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Busca diagnóstico por Firebase ID (idReg)
  Future<Diagnostico?> findByFirebaseId(String firebaseId) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.firebaseId.equals(firebaseId)))
        .getSingleOrNull();
  }

  /// Busca diagnóstico por idReg único
  Future<Diagnostico?> findByIdReg(String idReg) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.idReg.equals(idReg)))
        .getSingleOrNull();
  }

  /// Busca diagnósticos por defensivo
  Future<List<Diagnostico>> findByDefensivo(int defensivoId) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.defensivoId.equals(defensivoId)))
        .get();
  }

  /// Busca diagnósticos por cultura
  Future<List<Diagnostico>> findByCultura(int culturaId) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.culturaId.equals(culturaId)))
        .get();
  }

  /// Busca diagnósticos por praga
  Future<List<Diagnostico>> findByPraga(int pragaId) async {
    return await (_db.select(_db.diagnosticos)
          ..where((tbl) => tbl.pragaId.equals(pragaId)))
        .get();
  }

  /// Busca diagnósticos com join completo (defensivo + cultura + praga)
  Future<List<DiagnosticoEnriched>> findAllWithRelations() async {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(
        _db.fitossanitarios,
        _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defensivoId),
      ),
      leftOuterJoin(
        _db.culturas,
        _db.culturas.id.equalsExp(_db.diagnosticos.culturaId),
      ),
      leftOuterJoin(
        _db.pragas,
        _db.pragas.id.equalsExp(_db.diagnosticos.pragaId),
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
        _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defensivoId),
      ),
      leftOuterJoin(
        _db.culturas,
        _db.culturas.id.equalsExp(_db.diagnosticos.culturaId),
      ),
      leftOuterJoin(
        _db.pragas,
        _db.pragas.id.equalsExp(_db.diagnosticos.pragaId),
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
    int defensivoId,
  ) async {
    final query = _db.select(_db.diagnosticos).join([
      leftOuterJoin(
        _db.fitossanitarios,
        _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defensivoId),
      ),
      leftOuterJoin(
        _db.culturas,
        _db.culturas.id.equalsExp(_db.diagnosticos.culturaId),
      ),
      leftOuterJoin(
        _db.pragas,
        _db.pragas.id.equalsExp(_db.diagnosticos.pragaId),
      ),
    ])
      ..where(_db.diagnosticos.defensivoId.equals(defensivoId));

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
    final count = _db.diagnosticos.id.count();
    final query = _db.selectOnly(_db.diagnosticos)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
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
    // Tenta primeiro como Firebase ID
    final byFirebase = await findByFirebaseId(id);
    if (byFirebase != null) return byFirebase;
    
    // Tenta como ID local
    final localId = int.tryParse(id);
    if (localId != null) {
      final byLocal = await findById(localId);
      if (byLocal != null) return byLocal;
    }
    
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
