import 'package:drift/drift.dart';

/// Configuração base para bancos de dados Drift (Stub - não deve ser usado diretamente)
///
/// Este arquivo é um stub que nunca deve ser importado diretamente.
/// Use conditional imports para mobile ou web.
class DriftDatabaseConfig {
  static QueryExecutor createExecutor({
    required String databaseName,
    bool logStatements = false,
  }) {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static QueryExecutor createCustomExecutor({
    required String databaseName,
    String? customPath,
    bool logStatements = false,
  }) {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static QueryExecutor createInMemoryExecutor({bool logStatements = false}) {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static Future<String> getDatabasePath(String databaseName) async {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static Future<void> deleteDatabase(String databaseName) async {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static Future<bool> databaseExists(String databaseName) async {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static Future<int> getDatabaseSize(String databaseName) async {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static Future<String> backupDatabase(String databaseName) async {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }

  static Future<void> restoreDatabase({
    required String databaseName,
    required String backupPath,
  }) async {
    throw UnsupportedError(
      'No suitable platform implementation found. '
      'This stub should never be called directly.',
    );
  }
}
