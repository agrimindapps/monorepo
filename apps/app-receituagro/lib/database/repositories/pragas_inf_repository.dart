import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Informações de Pragas usando Drift
///
/// Gerencia todas as operações de leitura dos dados complementares de pragas
/// 

class PragasInfRepository {
  PragasInfRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as informações de pragas
  Future<List<PragasInfData>> findAll() async {
    final query = _db.select(_db.pragasInf);
    return await query.get();
  }

  /// Busca informação de praga por ID de registro (idReg)
  Future<PragasInfData?> findByIdReg(String idReg) async {
    final query = _db.select(_db.pragasInf)
      ..where((tbl) => tbl.idReg.equals(idReg));
    return await query.getSingleOrNull();
  }

  /// Busca informações por ID da praga (fkIdPraga)
  Future<PragasInfData?> findByPragaId(String pragaId) async {
    final query = _db.select(_db.pragasInf)
      ..where((tbl) => tbl.fkIdPraga.equals(pragaId));
    return await query.getSingleOrNull();
  }

  /// Busca informações com join da praga
  Future<List<PragaInfoWithPraga>> findAllWithPraga() async {
    final query = _db.select(_db.pragasInf).join([
      leftOuterJoin(_db.pragas, _db.pragas.idPraga.equalsExp(_db.pragasInf.fkIdPraga)),
    ]);

    final results = await query.get();
    return results.map((row) {
      return PragaInfoWithPraga(
        pragaInfo: row.readTable(_db.pragasInf),
        praga: row.readTableOrNull(_db.pragas),
      );
    }).toList();
  }

  /// Busca informações por sintomas (busca parcial)
  Future<List<PragasInfData>> findBySintomas(String sintomas) async {
    final query = _db.select(_db.pragasInf)
      ..where((tbl) => tbl.sintomas.like('%$sintomas%'));
    return await query.get();
  }

  /// Busca informações por controle (busca parcial)
  Future<List<PragasInfData>> findByControle(String controle) async {
    final query = _db.select(_db.pragasInf)
      ..where((tbl) => tbl.controle.like('%$controle%'));
    return await query.get();
  }

  /// Busca informações por descrição (busca parcial)
  Future<List<PragasInfData>> findByDescricao(String descricao) async {
    final query = _db.select(_db.pragasInf)
      ..where((tbl) => tbl.descricao.like('%$descricao%'));
    return await query.get();
  }

  /// Conta o total de informações de pragas
  Future<int> count() async {
    final countColumn = _db.pragasInf.idReg.count();
    final query = _db.selectOnly(_db.pragasInf)
      ..addColumns([countColumn]);
    final result = await query.getSingle();
    return result.read(countColumn)!;
  }

  /// Observa mudanças em todas as informações de pragas
  Stream<List<PragasInfData>> watchAll() {
    return _db.select(_db.pragasInf).watch();
  }

  /// Observa mudanças em uma informação específica
  Stream<PragasInfData?> watchByIdReg(String idReg) {
    final query = _db.select(_db.pragasInf)..where((tbl) => tbl.idReg.equals(idReg));
    return query.watchSingleOrNull();
  }

  /// Observa mudanças por praga
  Stream<PragasInfData?> watchByPragaId(String pragaId) {
    final query = _db.select(_db.pragasInf)
      ..where((tbl) => tbl.fkIdPraga.equals(pragaId));
    return query.watchSingleOrNull();
  }
}

/// Classe auxiliar para join de PragasInf com Praga
class PragaInfoWithPraga {
  final PragasInfData pragaInfo;
  final Praga? praga;

  PragaInfoWithPraga({required this.pragaInfo, this.praga});
}
