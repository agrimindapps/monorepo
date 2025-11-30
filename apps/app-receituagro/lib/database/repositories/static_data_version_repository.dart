import 'package:drift/drift.dart';

import '../receituagro_database.dart';

/// Repositório para controle de versão dos dados estáticos
///
/// Gerencia o registro de quando cada tabela de dados estáticos foi carregada,
/// permitindo evitar recarregamentos desnecessários e forçar atualização
/// quando necessário.
class StaticDataVersionRepository {
  StaticDataVersionRepository(this._db);

  final ReceituagroDatabase _db;

  /// Verifica se os dados de uma tabela precisam ser carregados
  ///
  /// Retorna true se:
  /// - A tabela nunca foi carregada
  /// - A versão do app mudou desde o último carregamento
  /// - A versão dos dados mudou
  Future<bool> needsLoading({
    required String tableName,
    required String appVersion,
    required String dataVersion,
  }) async {
    final query = _db.select(_db.staticDataVersion)
      ..where((tbl) => tbl.dataTableName.equals(tableName));
    
    final existing = await query.getSingleOrNull();
    
    if (existing == null) {
      // Nunca foi carregado
      return true;
    }
    
    // Verifica se a versão do app ou dos dados mudou
    if (existing.appVersion != appVersion || existing.dataVersion != dataVersion) {
      return true;
    }
    
    return false;
  }

  /// Verifica se uma tabela específica foi carregada (independente da versão)
  Future<bool> isTableLoaded(String tableName) async {
    final query = _db.select(_db.staticDataVersion)
      ..where((tbl) => tbl.dataTableName.equals(tableName));
    
    final existing = await query.getSingleOrNull();
    return existing != null && existing.recordCount > 0;
  }

  /// Registra que os dados de uma tabela foram carregados
  Future<void> markAsLoaded({
    required String tableName,
    required String appVersion,
    required String dataVersion,
    required int recordCount,
    String? checksum,
  }) async {
    final existing = await (_db.select(_db.staticDataVersion)
      ..where((tbl) => tbl.dataTableName.equals(tableName)))
      .getSingleOrNull();

    if (existing != null) {
      // Atualiza o registro existente
      await (_db.update(_db.staticDataVersion)
        ..where((tbl) => tbl.dataTableName.equals(tableName)))
        .write(StaticDataVersionCompanion(
          dataVersion: Value(dataVersion),
          appVersion: Value(appVersion),
          loadedAt: Value(DateTime.now()),
          recordCount: Value(recordCount),
          checksum: Value(checksum),
        ));
    } else {
      // Cria novo registro
      await _db.into(_db.staticDataVersion).insert(
        StaticDataVersionCompanion.insert(
          dataTableName: tableName,
          dataVersion: dataVersion,
          appVersion: appVersion,
          recordCount: Value(recordCount),
          checksum: Value(checksum),
        ),
      );
    }
  }

  /// Obtém informações de versão de uma tabela
  Future<StaticDataVersionData?> getVersionInfo(String tableName) async {
    final query = _db.select(_db.staticDataVersion)
      ..where((tbl) => tbl.dataTableName.equals(tableName));
    
    return await query.getSingleOrNull();
  }

  /// Obtém informações de todas as tabelas carregadas
  Future<List<StaticDataVersionData>> getAllVersionInfo() async {
    return await _db.select(_db.staticDataVersion).get();
  }

  /// Remove registro de versão de uma tabela (força recarregamento)
  Future<void> invalidate(String tableName) async {
    await (_db.delete(_db.staticDataVersion)
      ..where((tbl) => tbl.dataTableName.equals(tableName)))
      .go();
  }

  /// Remove todos os registros de versão (força recarregamento completo)
  Future<void> invalidateAll() async {
    await _db.delete(_db.staticDataVersion).go();
  }

  /// Obtém estatísticas de carregamento
  Future<Map<String, dynamic>> getStats() async {
    final all = await getAllVersionInfo();
    
    return {
      'tables_loaded': all.length,
      'total_records': all.fold<int>(0, (sum, v) => sum + v.recordCount),
      'tables': all.map((v) => {
        'name': v.dataTableName,
        'data_version': v.dataVersion,
        'app_version': v.appVersion,
        'record_count': v.recordCount,
        'loaded_at': v.loadedAt.toIso8601String(),
      }).toList(),
    };
  }
}
