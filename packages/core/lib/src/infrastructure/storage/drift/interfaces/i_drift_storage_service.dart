import 'package:dartz/dartz.dart';
import '../../../../shared/utils/failure.dart';

/// Interface base para serviços de storage Drift
/// Define contratos básicos que qualquer implementação Drift deve seguir
///
/// Equivalente Drift do IStorageService (Hive)
abstract class IDriftStorageService {
  /// Nome do serviço de storage
  String get serviceName;

  /// Verifica se o serviço foi inicializado
  bool get isInitialized;

  /// Inicializa o serviço de storage
  /// [config] configurações específicas do serviço (deve conter 'appName')
  Future<Either<Failure, void>> initialize(Map<String, dynamic>? config);

  /// Verifica a saúde/integridade do serviço
  /// Retorna informações sobre status das databases abertas
  Future<Either<Failure, Map<String, dynamic>>> healthCheck();

  /// Obtém estatísticas gerais do storage
  /// Informações sobre todas as databases gerenciadas
  Future<Either<Failure, Map<String, dynamic>>> getStatistics();

  /// Limpa todos os dados (operação destrutiva)
  /// [confirm] confirmação obrigatória para evitar acidentes
  Future<Either<Failure, void>> clearAllData({required bool confirm});

  /// Faz backup dos dados
  /// Retorna informações sobre o backup criado
  Future<Either<Failure, Map<String, dynamic>>> backup();

  /// Restaura dados de um backup
  /// [backupData] dados do backup a serem restaurados
  Future<Either<Failure, void>> restore(Map<String, dynamic> backupData);

  /// Executa limpeza/manutenção do storage
  /// No Drift, isso inclui VACUUM em todas as databases
  Future<Either<Failure, void>> performMaintenance();

  /// Fecha/destrói o serviço liberando recursos
  Future<Either<Failure, void>> dispose();
}

/// Interface específica para storage baseado em database (Drift)
/// Equivalente ao IBoxStorageService mas para databases SQL
abstract class IDatabaseStorageService extends IDriftStorageService {
  /// Lista todas as databases disponíveis
  Future<Either<Failure, List<String>>> listDatabases();

  /// Verifica se uma database específica existe
  Future<Either<Failure, bool>> databaseExists(String databaseName);

  /// Obtém estatísticas de uma database específica
  Future<Either<Failure, Map<String, dynamic>>> getDatabaseStatistics(
    String databaseName,
  );

  /// Executa VACUUM em uma database específica
  /// Otimiza o arquivo SQLite removendo espaço não utilizado
  Future<Either<Failure, void>> vacuumDatabase(String databaseName);

  /// Remove uma database específica
  /// CUIDADO: Operação destrutiva
  Future<Either<Failure, void>> deleteDatabase(String databaseName);

  /// Faz backup de uma database específica
  Future<Either<Failure, Map<String, dynamic>>> backupDatabase(
    String databaseName,
  );

  /// Restaura uma database específica
  Future<Either<Failure, void>> restoreDatabase(
    String databaseName,
    Map<String, dynamic> databaseData,
  );

  /// Obtém informações detalhadas de uma database
  /// Inclui versão, tabelas, índices, etc.
  Future<Either<Failure, Map<String, dynamic>>> getDatabaseInfo(
    String databaseName,
  );

  /// Executa VACUUM em todas as databases abertas
  Future<Either<Failure, void>> vacuumAllDatabases();
}

/// Interface para configuração de storage Drift
abstract class IDriftStorageConfig {
  /// Nome da aplicação
  String get appName;

  /// Configurações específicas do Drift
  Map<String, dynamic> get driftConfig;

  /// Configurações de backup
  Map<String, dynamic>? get backupConfig;

  /// Configurações de cache
  Map<String, dynamic>? get cacheConfig;

  /// Configurações de sincronização
  Map<String, dynamic>? get syncConfig;

  /// Configurações de migrations
  Map<String, dynamic>? get migrationConfig;

  /// Valida se a configuração é válida
  Either<Failure, void> validate();
}
