import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório de Culturas usando Drift
///
/// Gerencia todas as operações de leitura dos dados estáticos de culturas
/// 

class CulturasRepository {
  CulturasRepository(this._db);

  final ReceituagroDatabase _db;

  /// Busca todas as culturas
  Future<List<Cultura>> findAll() async {
    final query = _db.select(_db.culturas);
    return await query.get();
  }

  /// Busca cultura por idCultura (PRIMARY KEY)
  Future<Cultura?> findByIdCultura(String idCultura) async {
    final query = _db.select(_db.culturas)
      ..where((tbl) => tbl.idCultura.equals(idCultura));
    return await query.getSingleOrNull();
  }

  /// Busca culturas por nome (busca parcial)
  Future<List<Cultura>> findByNome(String nome) async {
    final query = _db.select(_db.culturas)
      ..where((tbl) => tbl.nome.like('%$nome%'));
    return await query.get();
  }

  /// Conta o total de culturas
  Future<int> count() async {
    final query = _db.selectOnly(_db.culturas)
      ..addColumns([_db.culturas.idCultura.count()]);
    final result = await query.getSingle();
    return result.read(_db.culturas.idCultura.count())!;
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
      await _db.delete(_db.culturas).go();

      // Inserir novos dados
      for (final item in jsonData) {
        final companion = CulturasCompanion.insert(
          idCultura: item['idReg']?.toString() ?? '',
          nome: item['cultura']?.toString() ?? '',
        );
        await _db.into(_db.culturas).insert(companion);
      }
    });
  }
}
