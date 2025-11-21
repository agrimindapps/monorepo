import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Informações de Plantas/Culturas usando Drift
///
/// Gerencia todas as operações de leitura dos dados complementares de plantas
/// 
@lazySingleton
class PlantasInfRepository {
  PlantasInfRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as informações de plantas
  Future<List<PlantasInfData>> findAll() async {
    final query = _db.select(_db.plantasInf);
    return await query.get();
  }

  /// Busca informação de planta por ID
  Future<PlantasInfData?> findById(int id) async {
    final query = _db.select(_db.plantasInf)..where((tbl) => tbl.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Busca informação de planta por ID de registro (idReg)
  Future<PlantasInfData?> findByIdReg(String idReg) async {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.idReg.equals(idReg));
    return await query.getSingleOrNull();
  }

  /// Busca informações por ID da cultura
  Future<PlantasInfData?> findByCulturaId(int culturaId) async {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.culturaId.equals(culturaId));
    return await query.getSingleOrNull();
  }

  /// Busca informações com join da cultura
  Future<List<PlantaInfoWithCultura>> findAllWithCultura() async {
    final query = _db.select(_db.plantasInf).join([
      leftOuterJoin(
        _db.culturas,
        _db.culturas.id.equalsExp(_db.plantasInf.culturaId),
      ),
    ]);

    final results = await query.get();
    return results.map((row) {
      return PlantaInfoWithCultura(
        plantaInfo: row.readTable(_db.plantasInf),
        cultura: row.readTableOrNull(_db.culturas),
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
    final countColumn = _db.plantasInf.id.count();
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
  Stream<PlantasInfData?> watchById(int id) {
    final query = _db.select(_db.plantasInf)..where((tbl) => tbl.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Observa mudanças por cultura
  Stream<PlantasInfData?> watchByCulturaId(int culturaId) {
    final query = _db.select(_db.plantasInf)
      ..where((tbl) => tbl.culturaId.equals(culturaId));
    return query.watchSingleOrNull();
  }
}

/// Classe auxiliar para join de PlantasInf com Cultura
class PlantaInfoWithCultura {
  final PlantasInfData plantaInfo;
  final Cultura? cultura;

  PlantaInfoWithCultura({required this.plantaInfo, this.cultura});
}
