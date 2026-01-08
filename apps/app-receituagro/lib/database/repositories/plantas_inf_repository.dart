import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Informações de Plantas Daninhas usando Drift
///
/// Gerencia todas as operações de leitura dos dados complementares de plantas daninhas
/// NOTA: PlantasInf referencia Pragas (plantas daninhas são pragas tipo 3), não Culturas
/// 

class PlantasInfRepository {
  PlantasInfRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as informações de plantas
  Future<List<PlantasInfData>> findAll() async {
    final query = _db.select(_db.plantasInf);
    return await query.get();
  }

  /// Busca informação de planta por ID de registro (idReg)
  Future<PlantasInfData?> findByIdReg(String idReg) async {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.idReg.equals(idReg));
    return await query.getSingleOrNull();
  }

  /// Busca informações por ID da praga (fkIdPraga)
  /// NOTA: PlantasInf referencia pragas (plantas daninhas são pragas tipo 3)
  Future<PlantasInfData?> findByPragaId(String pragaId) async {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.fkIdPraga.equals(pragaId));
    return await query.getSingleOrNull();
  }

  /// Busca informações com join da praga
  Future<List<PlantaInfoWithPraga>> findAllWithPraga() async {
    final query = _db.select(_db.plantasInf).join([
      leftOuterJoin(
        _db.pragas,
        _db.pragas.idPraga.equalsExp(_db.plantasInf.fkIdPraga),
      ),
    ]);

    final results = await query.get();
    return results.map((row) {
      return PlantaInfoWithPraga(
        plantaInfo: row.readTable(_db.plantasInf),
        praga: row.readTableOrNull(_db.pragas),
      );
    }).toList();
  }

  /// Busca informações por ciclo da planta
  Future<List<PlantasInfData>> findByCiclo(String ciclo) async {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.ciclo.equals(ciclo));
    return await query.get();
  }

  /// Busca informações por tipo de reprodução
  Future<List<PlantasInfData>> findByReproducao(String reproducao) async {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.reproducao.equals(reproducao));
    return await query.get();
  }

  /// Busca informações por habitat
  Future<List<PlantasInfData>> findByHabitat(String habitat) async {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.habitat.equals(habitat));
    return await query.get();
  }

  /// Conta o total de informações de plantas
  Future<int> count() async {
    final countColumn = _db.plantasInf.idReg.count();
    final query = _db.selectOnly(_db.plantasInf)
      ..addColumns([countColumn]);
    final result = await query.getSingle();
    return result.read(countColumn)!;
  }

  /// Observa mudanças em todas as informações de plantas
  Stream<List<PlantasInfData>> watchAll() {
    return _db.select(_db.plantasInf).watch();
  }

  /// Observa mudanças em uma informação específica
  Stream<PlantasInfData?> watchByIdReg(String idReg) {
    final query = _db.select(_db.plantasInf)..where((tbl) => tbl.idReg.equals(idReg));
    return query.watchSingleOrNull();
  }

  /// Observa mudanças por praga
  Stream<PlantasInfData?> watchByPragaId(String pragaId) {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.fkIdPraga.equals(pragaId));
    return query.watchSingleOrNull();
  }
}

/// Classe auxiliar para join de PlantasInf com Praga
class PlantaInfoWithPraga {
  final PlantasInfData plantaInfo;
  final Praga? praga;

  PlantaInfoWithPraga({required this.plantaInfo, this.praga});
}
