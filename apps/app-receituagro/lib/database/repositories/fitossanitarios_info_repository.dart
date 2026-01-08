import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Informações de Fitossanitários usando Drift
///
/// NOTA: FitossanitariosInfo contém dados detalhados: embalagens, tecnologia, precauções
/// Os campos de formulação, modoAcao, toxicidade agora estão em Fitossanitarios
/// 

class FitossanitariosInfoRepository {
  FitossanitariosInfoRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as informações de fitossanitários
  Future<List<FitossanitariosInfoData>> findAll() async {
    final query = _db.select(_db.fitossanitariosInfo);
    return await query.get();
  }

  /// Busca informação de fitossanitário por idReg (PRIMARY KEY)
  Future<FitossanitariosInfoData?> findByIdReg(String idReg) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.idReg.equals(idReg));
    return await query.getSingleOrNull();
  }

  /// Busca informações por fkIdDefensivo (string FK)
  Future<FitossanitariosInfoData?> findByFkIdDefensivo(String fkIdDefensivo) async {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.fkIdDefensivo.equals(fkIdDefensivo));
    return await query.getSingleOrNull();
  }

  /// Busca informações pelo idDefensivo do Fitossanitarios relacionado
  /// Alias para findByFkIdDefensivo
  Future<FitossanitariosInfoData?> findByFitossanitarioIdDefensivo(
    String idDefensivo,
  ) async {
    return await findByFkIdDefensivo(idDefensivo);
  }

  /// Busca informações com join do fitossanitário
  Future<List<FitossanitarioInfoWithDefensivo>> findAllWithDefensivo() async {
    final query = _db.select(_db.fitossanitariosInfo).join([
      leftOuterJoin(
        _db.fitossanitarios,
        _db.fitossanitarios.idDefensivo.equalsExp(_db.fitossanitariosInfo.fkIdDefensivo),
      ),
    ]);

    final results = await query.get();
    return results.map((row) {
      return FitossanitarioInfoWithDefensivo(
        fitossanitarioInfo: row.readTable(_db.fitossanitariosInfo),
        fitossanitario: row.readTableOrNull(_db.fitossanitarios),
      );
    }).toList();
  }

  /// Conta o total de informações de fitossanitários
  Future<int> count() async {
    final countColumn = _db.fitossanitariosInfo.idReg.count();
    final query = _db.selectOnly(_db.fitossanitariosInfo)
      ..addColumns([countColumn]);
    final result = await query.getSingle();
    return result.read(countColumn)!;
  }

  /// Observa mudanças em todas as informações de fitossanitários
  Stream<List<FitossanitariosInfoData>> watchAll() {
    return _db.select(_db.fitossanitariosInfo).watch();
  }

  /// Observa mudanças em uma informação específica por idReg
  Stream<FitossanitariosInfoData?> watchByIdReg(String idReg) {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.idReg.equals(idReg));
    return query.watchSingleOrNull();
  }

  /// Observa mudanças por fkIdDefensivo
  Stream<FitossanitariosInfoData?> watchByFkIdDefensivo(String fkIdDefensivo) {
    final query = _db.select(_db.fitossanitariosInfo)
      ..where((tbl) => tbl.fkIdDefensivo.equals(fkIdDefensivo));
    return query.watchSingleOrNull();
  }
}

/// Classe auxiliar para join de FitossanitariosInfo com Fitossanitario
class FitossanitarioInfoWithDefensivo {
  final FitossanitariosInfoData fitossanitarioInfo;
  final Fitossanitario? fitossanitario;

  FitossanitarioInfoWithDefensivo({
    required this.fitossanitarioInfo,
    this.fitossanitario,
  });
}
