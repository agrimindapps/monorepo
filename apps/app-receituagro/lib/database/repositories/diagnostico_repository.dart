import 'package:core/core.dart';

import '../receituagro_database.dart';
import '../tables/receituagro_tables.dart';

/// Repositório de Diagnósticos usando Drift
///
/// Gerencia todas as operações de CRUD e queries relacionadas a diagnósticos
/// usando o banco de dados Drift ao invés do Hive.
@lazySingleton
class DiagnosticoRepository
    extends BaseDriftRepositoryImpl<DiagnosticoData, Diagnostico> {
  DiagnosticoRepository(this._db);

  final ReceituagroDatabase _db;

  @override
  TableInfo<Diagnosticos, Diagnostico> get table => _db.diagnosticos;

  @override
  GeneratedDatabase get database => _db;

  @override
  DiagnosticoData fromData(Diagnostico data) {
    return DiagnosticoData(
      id: data.id,
      firebaseId: data.firebaseId,
      userId: data.userId,
      moduleName: data.moduleName,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      defenisivoId: data.defenisivoId,
      culturaId: data.culturaId,
      pragaId: data.pragaId,
      idReg: data.idReg,
      dsMin: data.dsMin,
      dsMax: data.dsMax,
      um: data.um,
      minAplicacaoT: data.minAplicacaoT,
      maxAplicacaoT: data.maxAplicacaoT,
      umT: data.umT,
      minAplicacaoA: data.minAplicacaoA,
      maxAplicacaoA: data.maxAplicacaoA,
      umA: data.umA,
      intervalo: data.intervalo,
      intervalo2: data.intervalo2,
      epocaAplicacao: data.epocaAplicacao,
    );
  }

  @override
  Insertable<Diagnostico> toCompanion(DiagnosticoData entity) {
    return DiagnosticosCompanion(
      id: entity.id > 0 ? Value(entity.id) : const Value.absent(),
      firebaseId: Value(entity.firebaseId),
      userId: Value(entity.userId),
      moduleName: Value(entity.moduleName),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      defenisivoId: Value(entity.defenisivoId),
      culturaId: Value(entity.culturaId),
      pragaId: Value(entity.pragaId),
      idReg: Value(entity.idReg),
      dsMin: Value(entity.dsMin),
      dsMax: Value(entity.dsMax),
      um: Value(entity.um),
      minAplicacaoT: Value(entity.minAplicacaoT),
      maxAplicacaoT: Value(entity.maxAplicacaoT),
      umT: Value(entity.umT),
      minAplicacaoA: Value(entity.minAplicacaoA),
      maxAplicacaoA: Value(entity.maxAplicacaoA),
      umA: Value(entity.umA),
      intervalo: Value(entity.intervalo),
      intervalo2: Value(entity.intervalo2),
      epocaAplicacao: Value(entity.epocaAplicacao),
    );
  }

  @override
  Expression<int> idColumn(Diagnosticos tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca diagnósticos do usuário que não foram deletados
  Future<List<DiagnosticoData>> findByUserId(String userId) async {
    final query = _db.select(_db.diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca diagnóstico por firebaseId ou ID local
  ///
  /// Este método tenta primeiro buscar por firebaseId (String).
  /// Se não encontrar, tenta converter o ID para int e buscar por id local.
  Future<DiagnosticoData?> findByFirebaseIdOrId(String idString) async {
    // Primeiro tenta buscar por firebaseId
    var query = _db.select(_db.diagnosticos)
      ..where((tbl) => tbl.firebaseId.equals(idString))
      ..limit(1);

    var results = await query.get();
    if (results.isNotEmpty) {
      return fromData(results.first);
    }

    // Se não encontrar, tenta converter para int e buscar por id
    final intId = int.tryParse(idString);
    if (intId != null) {
      query = _db.select(_db.diagnosticos)
        ..where((tbl) => tbl.id.equals(intId))
        ..limit(1);

      results = await query.get();
      if (results.isNotEmpty) {
        return fromData(results.first);
      }
    }

    return null;
  }

  /// Stream de diagnósticos do usuário
  Stream<List<DiagnosticoData>> watchByUserId(String userId) {
    final query = _db.select(_db.diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca diagnósticos com dados relacionados (JOIN)
  ///
  /// Retorna diagnósticos com informações de defensivo, cultura e praga
  Future<List<DiagnosticoEnriched>> findAllWithRelations(String userId) async {
    final query =
        _db.select(_db.diagnosticos).join([
            leftOuterJoin(
              _db.fitossanitarios,
              _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defenisivoId),
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
          ..where(
            _db.diagnosticos.userId.equals(userId) &
                _db.diagnosticos.isDeleted.equals(false),
          )
          ..orderBy([OrderingTerm.desc(_db.diagnosticos.createdAt)]);

    final results = await query.get();
    return results.map(_mapJoinedRow).toList();
  }

  /// Stream de diagnósticos com dados relacionados
  Stream<List<DiagnosticoEnriched>> watchAllWithRelations(String userId) {
    final query =
        _db.select(_db.diagnosticos).join([
            leftOuterJoin(
              _db.fitossanitarios,
              _db.fitossanitarios.id.equalsExp(_db.diagnosticos.defenisivoId),
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
          ..where(
            _db.diagnosticos.userId.equals(userId) &
                _db.diagnosticos.isDeleted.equals(false),
          )
          ..orderBy([OrderingTerm.desc(_db.diagnosticos.createdAt)]);

    return query.watch().map((rows) => rows.map(_mapJoinedRow).toList());
  }

  /// Mapeia resultado do JOIN para DiagnosticoEnriched
  DiagnosticoEnriched _mapJoinedRow(TypedResult row) {
    final diagnostico = row.readTable(_db.diagnosticos);
    final defensivo = row.readTableOrNull(_db.fitossanitarios);
    final cultura = row.readTableOrNull(_db.culturas);
    final praga = row.readTableOrNull(_db.pragas);

    return DiagnosticoEnriched(
      diagnostico: fromData(diagnostico),
      defensivo: defensivo != null ? DefensivoData.fromDrift(defensivo) : null,
      cultura: cultura != null ? CulturaData.fromDrift(cultura) : null,
      praga: praga != null ? PragaData.fromDrift(praga) : null,
    );
  }

  /// Busca diagnóstico por idReg
  Future<DiagnosticoData?> findByIdReg(String userId, String idReg) async {
    final query = _db.select(_db.diagnosticos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.idReg.equals(idReg) &
            tbl.isDeleted.equals(false),
      )
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }

  /// Busca diagnósticos por cultura
  Future<List<DiagnosticoData>> findByCultura(
    String userId,
    int culturaId,
  ) async {
    final query = _db.select(_db.diagnosticos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.culturaId.equals(culturaId) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca diagnósticos por praga
  Future<List<DiagnosticoData>> findByPraga(String userId, int pragaId) async {
    final query = _db.select(_db.diagnosticos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.pragaId.equals(pragaId) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca diagnósticos por defensivo
  Future<List<DiagnosticoData>> findByDefensivo(
    String userId,
    int defensivoId,
  ) async {
    final query = _db.select(_db.diagnosticos)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.defenisivoId.equals(defensivoId) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Conta diagnósticos do usuário
  Future<int> countByUserId(String userId) async {
    final query = _db.selectOnly(_db.diagnosticos)
      ..addColumns([_db.diagnosticos.id.count()])
      ..where(
        _db.diagnosticos.userId.equals(userId) &
            _db.diagnosticos.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.diagnosticos.id.count()) ?? 0;
  }

  /// Busca todos os diagnósticos (sem filtro de usuário)
  ///
  /// Retorna todos os diagnósticos não deletados
  Future<List<DiagnosticoData>> getAllData() async {
    final query = _db.select(_db.diagnosticos)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca diagnóstico por firebaseId ou ID local (Legacy compatibility)
  ///
  /// Este método tenta primeiro buscar por firebaseId (String).
  /// Se não encontrar, tenta converter o ID para int e buscar por id local.
  Future<DiagnosticoData?> getByIdOrObjectId(String idString) async {
    final data = await findByFirebaseIdOrId(idString);
    return data;
  }

  /// Busca todos os diagnósticos como lista (Legacy compatibility)
  ///
  /// Wrapper para getAllData() mantendo compatibilidade
  Future<List<DiagnosticoData>> getAll() async {
    return await getAllData();
  }

  /// Soft delete de um diagnóstico
  Future<bool> softDelete(int diagnosticoId) async {
    final rowsAffected =
        await (_db.update(
          _db.diagnosticos,
        )..where((tbl) => tbl.id.equals(diagnosticoId))).write(
          DiagnosticosCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// Busca registros que precisam ser sincronizados
  Future<List<DiagnosticoData>> findDirtyRecords() async {
    final query = _db.select(_db.diagnosticos)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> diagnosticoIds) async {
    await _db.executeTransaction(() async {
      for (final id in diagnosticoIds) {
        await (_db.update(
          _db.diagnosticos,
        )..where((tbl) => tbl.id.equals(id))).write(
          DiagnosticosCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark diagnosticos as synced');
  }

  /// Busca diagnósticos recentes (últimos N)
  Future<List<DiagnosticoData>> findRecent(
    String userId, {
    int limit = 10,
  }) async {
    final query = _db.select(_db.diagnosticos)
      ..where((tbl) => tbl.userId.equals(userId) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }
}

/// Classe para transferência de dados de diagnósticos
///
/// Esta classe serve como intermediária entre o Drift e a camada de domínio
class DiagnosticoData {
  const DiagnosticoData({
    required this.id,
    this.firebaseId,
    required this.userId,
    required this.moduleName,
    required this.createdAt,
    this.updatedAt,
    this.lastSyncAt,
    required this.isDirty,
    required this.isDeleted,
    required this.version,
    required this.defenisivoId,
    required this.culturaId,
    required this.pragaId,
    required this.idReg,
    this.dsMin,
    required this.dsMax,
    required this.um,
    this.minAplicacaoT,
    this.maxAplicacaoT,
    this.umT,
    this.minAplicacaoA,
    this.maxAplicacaoA,
    this.umA,
    this.intervalo,
    this.intervalo2,
    this.epocaAplicacao,
  });

  final int id;
  final String? firebaseId;
  final String userId;
  final String moduleName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final bool isDeleted;
  final int version;
  final int defenisivoId;
  final int culturaId;
  final int pragaId;
  final String idReg;
  final String? dsMin;
  final String dsMax;
  final String um;
  final String? minAplicacaoT;
  final String? maxAplicacaoT;
  final String? umT;
  final String? minAplicacaoA;
  final String? maxAplicacaoA;
  final String? umA;
  final String? intervalo;
  final String? intervalo2;
  final String? epocaAplicacao;

  /// Cria uma cópia com campos modificados
  DiagnosticoData copyWith({
    int? id,
    String? firebaseId,
    String? userId,
    String? moduleName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    int? defenisivoId,
    int? culturaId,
    int? pragaId,
    String? idReg,
    String? dsMin,
    String? dsMax,
    String? um,
    String? minAplicacaoT,
    String? maxAplicacaoT,
    String? umT,
    String? minAplicacaoA,
    String? maxAplicacaoA,
    String? umA,
    String? intervalo,
    String? intervalo2,
    String? epocaAplicacao,
  }) {
    return DiagnosticoData(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      defenisivoId: defenisivoId ?? this.defenisivoId,
      culturaId: culturaId ?? this.culturaId,
      pragaId: pragaId ?? this.pragaId,
      idReg: idReg ?? this.idReg,
      dsMin: dsMin ?? this.dsMin,
      dsMax: dsMax ?? this.dsMax,
      um: um ?? this.um,
      minAplicacaoT: minAplicacaoT ?? this.minAplicacaoT,
      maxAplicacaoT: maxAplicacaoT ?? this.maxAplicacaoT,
      umT: umT ?? this.umT,
      minAplicacaoA: minAplicacaoA ?? this.minAplicacaoA,
      maxAplicacaoA: maxAplicacaoA ?? this.maxAplicacaoA,
      umA: umA ?? this.umA,
      intervalo: intervalo ?? this.intervalo,
      intervalo2: intervalo2 ?? this.intervalo2,
      epocaAplicacao: epocaAplicacao ?? this.epocaAplicacao,
    );
  }
}

/// Classe para diagnóstico com dados relacionados (JOIN result)
class DiagnosticoEnriched {
  const DiagnosticoEnriched({
    required this.diagnostico,
    this.defensivo,
    this.cultura,
    this.praga,
  });

  final DiagnosticoData diagnostico;
  final DefensivoData? defensivo;
  final CulturaData? cultura;
  final PragaData? praga;
}

/// Classe auxiliar para dados de defensivo
class DefensivoData {
  const DefensivoData({
    required this.id,
    required this.idDefensivo,
    required this.nome,
    this.fabricante,
    this.classe,
    this.ingredienteAtivo,
    this.registroMapa,
  });

  final int id;
  final String idDefensivo;
  final String nome;
  final String? fabricante;
  final String? classe;
  final String? ingredienteAtivo;
  final String? registroMapa;

  factory DefensivoData.fromDrift(Fitossanitario data) {
    return DefensivoData(
      id: data.id,
      idDefensivo: data.idDefensivo,
      nome: data.nome,
      fabricante: data.fabricante,
      classe: data.classe,
      ingredienteAtivo: data.ingredienteAtivo,
      registroMapa: data.registroMapa,
    );
  }
}

/// Classe auxiliar para dados de cultura
class CulturaData {
  const CulturaData({
    required this.id,
    required this.idCultura,
    required this.nome,
    this.nomeLatino,
    this.familia,
    this.imagemUrl,
    this.descricao,
  });

  final int id;
  final String idCultura;
  final String nome;
  final String? nomeLatino;
  final String? familia;
  final String? imagemUrl;
  final String? descricao;

  factory CulturaData.fromDrift(Cultura data) {
    return CulturaData(
      id: data.id,
      idCultura: data.idCultura,
      nome: data.nome,
      nomeLatino: data.nomeLatino,
      familia: data.familia,
      imagemUrl: data.imagemUrl,
      descricao: data.descricao,
    );
  }
}

/// Classe auxiliar para dados de praga
class PragaData {
  const PragaData({
    required this.id,
    required this.idPraga,
    required this.nome,
    this.nomeLatino,
    this.tipo,
    this.imagemUrl,
    this.descricao,
  });

  final int id;
  final String idPraga;
  final String nome;
  final String? nomeLatino;
  final String? tipo;
  final String? imagemUrl;
  final String? descricao;

  factory PragaData.fromDrift(Praga data) {
    return PragaData(
      id: data.id,
      idPraga: data.idPraga,
      nome: data.nome,
      nomeLatino: data.nomeLatino,
      tipo: data.tipo,
      imagemUrl: data.imagemUrl,
      descricao: data.descricao,
    );
  }
}

// ============================================================================
// MÉTODOS DE COMPATIBILIDADE LEGACY (Hive → Drift Migration)
// ============================================================================
// Estes métodos fornecem compatibilidade temporária com código antigo que
// esperava Diagnostico. DEPRECATE após migração completa.

extension DiagnosticoRepositoryLegacyCompat on DiagnosticoRepository {
  /// @deprecated Use findByFirebaseIdOrId instead
  ///
  /// Compatibilidade com código antigo que chamava getByIdOrObjectId
  Future<Diagnostico?> getByIdOrObjectId(String idString) async {
    final data = await findByFirebaseIdOrId(idString);
    return data != null ? _diagnosticoDataToHive(data) : null;
  }

  /// Busca Diagnostico (Drift) por firebaseId ou ID local
  ///
  /// Retorna o row Drift diretamente (não DiagnosticoData)
  Future<Diagnostico?> getDiagnosticoByIdOrObjectId(String idString) async {
    // Primeiro tenta buscar por firebaseId
    var query = _db.select(_db.diagnosticos)
      ..where((tbl) => tbl.firebaseId.equals(idString))
      ..limit(1);

    var results = await query.get();
    if (results.isNotEmpty) {
      return results.first;
    }

    // Se não encontrar, tenta converter para int e buscar por id
    final intId = int.tryParse(idString);
    if (intId != null) {
      query = _db.select(_db.diagnosticos)
        ..where((tbl) => tbl.id.equals(intId))
        ..limit(1);

      results = await query.get();
      if (results.isNotEmpty) {
        return results.first;
      }
    }

    return null;
  }

  /// @deprecated Use getAllData instead
  ///
  /// Compatibilidade com código antigo que chamava getAll
  Future<List<Diagnostico>> getAll() async {
    final dataList = await getAllData();
    return dataList.map(_diagnosticoDataToHive).toList();
  }

  /// Converte DiagnosticoData (Drift) → Diagnostico (Legacy)
  Diagnostico _diagnosticoDataToHive(DiagnosticoData data) {
    return Diagnostico(
      objectId: data.firebaseId ?? data.id.toString(),
      createdAt: data.createdAt.millisecondsSinceEpoch,
      updatedAt: data.updatedAt?.millisecondsSinceEpoch ?? 0,
      idReg: data.idReg,
      fkIdDefensivo: data.defenisivoId.toString(),
      fkIdCultura: data.culturaId.toString(),
      fkIdPraga: data.pragaId.toString(),
      dsMin: data.dsMin,
      dsMax: data.dsMax,
      um: data.um,
      minAplicacaoT: data.minAplicacaoT,
      maxAplicacaoT: data.maxAplicacaoT,
      umT: data.umT,
      minAplicacaoA: data.minAplicacaoA,
      maxAplicacaoA: data.maxAplicacaoA,
      umA: data.umA,
      intervalo: data.intervalo,
      intervalo2: data.intervalo2,
      epocaAplicacao: data.epocaAplicacao,
    );
  }
}
