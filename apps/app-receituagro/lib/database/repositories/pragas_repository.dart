import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Pragas usando Drift
///
/// Gerencia todas as operações de leitura dos dados estáticos de pragas
///
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
      ..where((tbl) => tbl.nome.like('%$nome%'));
    return await query.get();
  }

  /// Busca pragas por tipo
  Future<List<Praga>> findByTipo(String tipo) async {
    final query = _db.select(_db.pragas)..where((tbl) => tbl.tipo.equals(tipo));
    return await query.get();
  }

  /// Conta o total de pragas
  Future<int> count() async {
    final countColumn = _db.pragas.id.count();
    final query = _db.selectOnly(_db.pragas)
      ..addColumns([countColumn]);
    final result = await query.getSingle();
    return result.read(countColumn)!;
  }

  /// Carrega dados do JSON e salva no banco Drift
  ///
  /// Recebe uma lista de Maps do JSON e insere no banco de dados.
  /// Limpa os dados existentes antes de inserir.
  Future<void> loadFromJson(
    List<Map<String, dynamic>> jsonData,
    String version,
  ) async {
    await _db.transaction(() async {
      // Limpar dados existentes
      await _db.delete(_db.pragas).go();

      // Inserir novos dados
      for (final item in jsonData) {
        final companion = PragasCompanion.insert(
          idPraga: item['idReg']?.toString() ?? '',
          nome: item['nomeComum']?.toString() ?? '',
          nomeLatino: Value(item['nomeCientifico']?.toString()),
          tipo: Value(item['tipoPraga']?.toString()),
          imagemUrl: Value(item['imagemUrl']?.toString()),
          descricao: Value(item['descricao']?.toString()),
        );
        await _db.into(_db.pragas).insert(companion);
      }
    });
  }

  // ============================================================================
  // MÉTODOS DE COMPATIBILIDADE LEGACY
  // ============================================================================

  /// @Deprecated("Deprecated - use alternative") Use findByIdPraga instead
  /// Legacy alias for findByIdPraga
  Future<Praga?> getById(String idPraga) async {
    return await findByIdPraga(idPraga);
  }
}
