import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Configuração base para bancos de dados Drift
///
/// Esta classe fornece métodos utilitários para configurar e inicializar
/// bancos de dados Drift de forma consistente em todo o monorepo.
class DriftDatabaseConfig {
  /// Cria um QueryExecutor para o banco de dados
  ///
  /// [databaseName] - Nome do arquivo do banco de dados
  /// [logStatements] - Se deve logar as queries SQL (útil para debug)
  static QueryExecutor createExecutor({
    required String databaseName,
    bool logStatements = false,
  }) {
    return driftDatabase(
      name: databaseName,
      native: DriftNativeOptions(shareAcrossIsolates: true),
    );
  }

  /// Cria um executor customizado para casos especiais
  ///
  /// Útil para testes ou quando precisar de controle total sobre o local do banco
  static LazyDatabase createCustomExecutor({
    required String databaseName,
    String? customPath,
    bool logStatements = false,
  }) {
    return LazyDatabase(() async {
      final dbFolder = customPath != null
          ? Directory(customPath)
          : await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, databaseName));

      return NativeDatabase.createInBackground(
        file,
        logStatements: logStatements,
      );
    });
  }

  /// Cria um executor em memória (útil para testes)
  static QueryExecutor createInMemoryExecutor({bool logStatements = false}) {
    return NativeDatabase.memory(logStatements: logStatements);
  }

  /// Obtém o caminho do banco de dados
  static Future<String> getDatabasePath(String databaseName) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, databaseName);
  }

  /// Deleta o banco de dados (útil para reset ou testes)
  static Future<void> deleteDatabase(String databaseName) async {
    final path = await getDatabasePath(databaseName);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Verifica se o banco de dados existe
  static Future<bool> databaseExists(String databaseName) async {
    final path = await getDatabasePath(databaseName);
    final file = File(path);
    return await file.exists();
  }

  /// Obtém o tamanho do banco de dados em bytes
  static Future<int> getDatabaseSize(String databaseName) async {
    final path = await getDatabasePath(databaseName);
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Cria um backup do banco de dados
  static Future<String> backupDatabase(String databaseName) async {
    final path = await getDatabasePath(databaseName);
    final file = File(path);

    if (!await file.exists()) {
      throw Exception('Database does not exist: $databaseName');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '$path.backup.$timestamp';
    await file.copy(backupPath);

    return backupPath;
  }

  /// Restaura o banco de dados de um backup
  static Future<void> restoreDatabase({
    required String databaseName,
    required String backupPath,
  }) async {
    final backupFile = File(backupPath);

    if (!await backupFile.exists()) {
      throw Exception('Backup file does not exist: $backupPath');
    }

    final path = await getDatabasePath(databaseName);
    await backupFile.copy(path);
  }
}
