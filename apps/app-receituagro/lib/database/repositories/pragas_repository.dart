import 'package:core/core.dart';
import '../receituagro_database.dart';

/// Repositório de Pragas usando Drift
///
/// Gerencia todas as operações de leitura dos dados estáticos de pragas
/// usando o banco de dados Drift ao invés do Hive.
@lazySingleton
class PragasRepository {
  PragasRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as pragas
  Future<List<Praga>> findAll() async {
    final query = _db.select(_db.pragas);
    return await query.get();
  }

  /// Busca praga por ID
  Future<Praga?> findById(int id) async {
    final query = _db.select(_db.pragas)..where((tbl) => tbl.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Busca praga por ID da praga (idPraga)
  Future<Praga?> findByIdPraga(String idPraga) async {
    final query = _db.select(_db.pragas)
      ..where((tbl) => tbl.idPraga.equals(idPraga));
    return await query.getSingleOrNull();
  }

  /// Busca pragas por nome (busca parcial)
  Future<List<Praga>> findByNome(String nome) async {
    final query = _db.select(_db.pragas)
      ..where((tbl) => tbl.nome.contains(nome));
    return await query.get();
  }

  /// Busca pragas por tipo
  Future<List<Praga>> findByTipo(String tipo) async {
    final query = _db.select(_db.pragas)..where((tbl) => tbl.tipo.equals(tipo));
    return await query.get();
  }

  /// Conta o total de pragas
  Future<int> count() async {
    final count = _db.pragas.id.count();
    final query = _db.selectOnly(_db.pragas)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count)!;
  }
}
