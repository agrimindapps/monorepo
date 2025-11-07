import 'package:drift/drift.dart';

/// Classe base abstrata para todos os bancos de dados Drift
///
/// Esta classe fornece funcionalidades comuns que podem ser compartilhadas
/// entre diferentes implementações de banco de dados no monorepo.
///
/// Exemplo de uso:
/// ```dart
/// @DriftDatabase(tables: [Users, Posts])
/// class MyAppDatabase extends _$MyAppDatabase with BaseDriftDatabase {
///   MyAppDatabase(QueryExecutor e) : super(e);
///
///   @override
///   int get schemaVersion => 1;
/// }
/// ```
mixin BaseDriftDatabase on GeneratedDatabase {
  /// Executa uma transação de forma segura
  ///
  /// Wrapper sobre o método transaction() nativo do Drift para adicionar
  /// tratamento de erros e logging consistente.
  Future<T> executeTransaction<T>(
    Future<T> Function() action, {
    String? operationName,
  }) async {
    try {
      return await transaction(() async {
        return await action();
      });
    } catch (e, stackTrace) {
      // Log do erro (pode ser integrado com Firebase Crashlytics)
      print(
        'Transaction error${operationName != null ? " in $operationName" : ""}: $e',
      );
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Executa uma operação batch de forma otimizada
  ///
  /// [operations] - Lista de operações a serem executadas
  Future<void> executeBatch(void Function(Batch batch) operations) async {
    try {
      await batch(operations);
    } catch (e, stackTrace) {
      print('Batch operation error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Limpa todas as tabelas do banco de dados
  ///
  /// ATENÇÃO: Esta operação é irreversível!
  Future<void> clearAllTables() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  /// Conta o número total de registros em uma tabela
  Future<int> countRecords<T extends Table>(TableInfo<T, dynamic> table) async {
    final query = selectOnly(table)
      ..addColumns([table.primaryKey.first.count()]);
    final result = await query.getSingle();
    return result.read(table.primaryKey.first.count()) ?? 0;
  }

  /// Verifica se uma tabela está vazia
  Future<bool> isTableEmpty<T extends Table>(
    TableInfo<T, dynamic> table,
  ) async {
    final count = await countRecords(table);
    return count == 0;
  }

  /// Obtém estatísticas do banco de dados
  Future<Map<String, int>> getDatabaseStats() async {
    final stats = <String, int>{};

    for (final table in allTables) {
      final tableName = table.actualTableName;
      stats[tableName] = await countRecords(table);
    }

    return stats;
  }

  /// Executa VACUUM para otimizar o banco de dados
  ///
  /// Esta operação pode demorar e deve ser executada em momentos apropriados
  /// (por exemplo, quando o app está em background ou durante manutenção)
  Future<void> vacuum() async {
    try {
      await customStatement('VACUUM');
    } catch (e) {
      print('Vacuum error: $e');
      rethrow;
    }
  }

  /// Verifica a integridade do banco de dados
  ///
  /// Retorna true se o banco está íntegro, false caso contrário
  Future<bool> checkIntegrity() async {
    try {
      final result = await customSelect(
        'PRAGMA integrity_check',
        readsFrom: {},
      ).getSingle();

      return result.data['integrity_check'] == 'ok';
    } catch (e) {
      print('Integrity check error: $e');
      return false;
    }
  }

  /// Obtém informações sobre o banco de dados
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final info = <String, dynamic>{};

    // Versão do schema
    info['schemaVersion'] = schemaVersion;

    // Número de tabelas
    info['tableCount'] = allTables.length;

    // Nome das tabelas
    info['tables'] = allTables.map((t) => t.actualTableName).toList();

    // Estatísticas
    info['stats'] = await getDatabaseStats();

    return info;
  }
}
