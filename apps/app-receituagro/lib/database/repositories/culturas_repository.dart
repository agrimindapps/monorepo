import 'package:core/core.dart';
import '../receituagro_database.dart';

/// Repositório de Culturas usando Drift
///
/// Gerencia todas as operações de leitura dos dados estáticos de culturas
/// usando o banco de dados Drift ao invés do Hive.
@lazySingleton
class CulturasRepository {
  CulturasRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as culturas
  Future<List<Cultura>> findAll() async {
    final query = _db.select(_db.culturas);
    return await query.get();
  }

  /// Busca cultura por ID
  Future<Cultura?> findById(int id) async {
    final query = _db.select(_db.culturas)..where((tbl) => tbl.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Busca cultura por ID da cultura (idCultura)
  Future<Cultura?> findByIdCultura(String idCultura) async {
    final query = _db.select(_db.culturas)
      ..where((tbl) => tbl.idCultura.equals(idCultura));
    return await query.getSingleOrNull();
  }

  /// Busca culturas por nome (busca parcial)
  Future<List<Cultura>> findByNome(String nome) async {
    final query = _db.select(_db.culturas)
      ..where((tbl) => tbl.nome.contains(nome));
    return await query.get();
  }

  /// Busca culturas por família botânica
  Future<List<Cultura>> findByFamilia(String familia) async {
    final query = _db.select(_db.culturas)
      ..where((tbl) => tbl.familia.equals(familia));
    return await query.get();
  }

  /// Conta o total de culturas
  Future<int> count() async {
    final count = _db.culturas.id.count();
    final query = _db.selectOnly(_db.culturas)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count)!;
  }
}
