import 'package:drift/drift.dart';
import '../../../../shared/utils/result.dart';

/// Interface para gerenciamento centralizado do Drift
/// Define contratos para inicialização, abertura e fechamento de databases
/// 
/// Equivalente Drift do IHiveManager
abstract class IDriftManager {
  /// Inicializa o Drift com configurações específicas do app
  /// [appName] usado para criar path único de armazenamento
  Future<Result<void>> initialize(String appName);

  /// Obtém uma database do Drift, criando se necessário
  /// Retorna a database tipada ou erro se houver falha
  Future<Result<GeneratedDatabase>> getDatabase(String databaseName);

  /// Fecha uma database específica e remove do cache
  /// Libera recursos de memória
  Future<Result<void>> closeDatabase(String databaseName);

  /// Fecha todas as databases abertas
  /// Útil para cleanup durante logout ou reset
  Future<Result<void>> closeAllDatabases();

  /// Verifica se uma database está aberta
  bool isDatabaseOpen(String databaseName);

  /// Verifica se o Drift foi inicializado
  bool get isInitialized;

  /// Lista todas as databases abertas
  List<String> get openDatabaseNames;

  /// Limpa completamente todos os dados do Drift
  /// CUIDADO: Operação destrutiva
  Future<Result<void>> clearAllData();

  /// Obtém estatísticas de uso das databases
  Map<String, int> getDatabaseStatistics();

  /// Executa VACUUM em uma database específica (otimização SQLite)
  Future<Result<void>> vacuumDatabase(String databaseName);

  /// Executa VACUUM em todas as databases abertas
  Future<Result<void>> vacuumAllDatabases();

  /// Obtém informações detalhadas de uma database
  Future<Result<Map<String, dynamic>>> getDatabaseInfo(String databaseName);
}
