import 'package:core/core.dart';
import '../receituagro_database.dart';

/// Repositório de Fitossanitários usando Drift
///
/// Gerencia todas as operações de leitura dos dados estáticos de fitossanitários
/// usando o banco de dados Drift ao invés do Hive.
@lazySingleton
class FitossanitariosRepository {
  FitossanitariosRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todos os fitossanitários
  Future<List<Fitossanitario>> findAll() async {
    final query = _db.select(_db.fitossanitarios);
    return await query.get();
  }

  /// Busca fitossanitário por ID
  Future<Fitossanitario?> findById(int id) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Busca fitossanitário por ID do defensivo (idDefensivo)
  Future<Fitossanitario?> findByIdDefensivo(String idDefensivo) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.idDefensivo.equals(idDefensivo));
    return await query.getSingleOrNull();
  }

  /// Busca fitossanitários por nome (busca parcial)
  Future<List<Fitossanitario>> findByNome(String nome) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.nome.contains(nome));
    return await query.get();
  }

  /// Busca fitossanitários por classe
  Future<List<Fitossanitario>> findByClasse(String classe) async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.classe.equals(classe));
    return await query.get();
  }

  /// Busca fitossanitários elegíveis (status = true e elegivel = true)
  Future<List<Fitossanitario>> findElegiveis() async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.status.equals(true) & tbl.elegivel.equals(true));
    return await query.get();
  }

  /// Busca fitossanitários comercializados
  Future<List<Fitossanitario>> findComercializados() async {
    final query = _db.select(_db.fitossanitarios)
      ..where((tbl) => tbl.comercializado.equals(1));
    return await query.get();
  }

  /// Conta o total de fitossanitários
  Future<int> count() async {
    final count = _db.fitossanitarios.id.count();
    final query = _db.selectOnly(_db.fitossanitarios)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count)!;
  }
}
