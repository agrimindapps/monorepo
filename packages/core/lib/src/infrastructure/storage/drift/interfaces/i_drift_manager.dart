import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';

import '../../../../shared/utils/failure.dart';

/// Interface para gerenciamento centralizado do Drift
/// Define contratos para inicialização, abertura e fechamento de databases
///
/// Equivalente Drift do IHiveManager
abstract class IDriftManager {
  /// Inicializa o Drift com configurações específicas do app
  /// [appName] usado para criar path único de armazenamento
  Future<Either<Failure, void>> initialize(String appName);

  /// Obtém uma database do Drift, criando se necessário
  /// Retorna a database tipada ou erro se houver falha
  Future<Either<Failure, GeneratedDatabase>> getDatabase(String databaseName);

  /// Fecha uma database específica e remove do cache
  /// Libera recursos de memória
  Future<Either<Failure, void>> closeDatabase(String databaseName);

  /// Fecha todas as databases abertas
  /// Útil para cleanup durante logout ou reset
  Future<Either<Failure, void>> closeAllDatabases();

  /// Verifica se uma database está aberta
  bool isDatabaseOpen(String databaseName);

  /// Verifica se o Drift foi inicializado
  bool get isInitialized;

  /// Lista todas as databases abertas
  List<String> get openDatabaseNames;

  /// Limpa completamente todos os dados do Drift
  /// CUIDADO: Operação destrutiva
  Future<Either<Failure, void>> clearAllData();

  /// Obtém estatísticas de uso das databases
  Map<String, int> getDatabaseStatistics();

  /// Executa VACUUM em uma database específica (otimização SQLite)
  Future<Either<Failure, void>> vacuumDatabase(String databaseName);

  /// Executa VACUUM em todas as databases abertas
  Future<Either<Failure, void>> vacuumAllDatabases();

  /// Obtém informações detalhadas de uma database
  Future<Either<Failure, Map<String, dynamic>>> getDatabaseInfo(
    String databaseName,
  );
}
