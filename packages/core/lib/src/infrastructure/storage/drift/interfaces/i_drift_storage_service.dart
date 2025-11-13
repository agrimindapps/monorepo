import '../../../../shared/utils/result.dart';

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
  Future<Result<void>> initialize(Map<String, dynamic>? config);

  /// Verifica a saúde/integridade do serviço
  /// Retorna informações sobre status das databases abertas
  Future<Result<Map<String, dynamic>>> healthCheck();

  /// Obtém estatísticas gerais do storage
  /// Informações sobre todas as databases gerenciadas
  Future<Result<Map<String, dynamic>>> getStatistics();

  /// Limpa todos os dados (operação destrutiva)
  /// [confirm] confirmação obrigatória para evitar acidentes
  Future<Result<void>> clearAllData({required bool confirm});

  /// Faz backup dos dados
  /// Retorna informações sobre o backup criado
  Future<Result<Map<String, dynamic>>> backup();

  /// Restaura dados de um backup
  /// [backupData] dados do backup a serem restaurados
  Future<Result<void>> restore(Map<String, dynamic> backupData);

  /// Executa limpeza/manutenção do storage
  /// No Drift, isso inclui VACUUM em todas as databases
  Future<Result<void>> performMaintenance();

  /// Fecha/destrói o serviço liberando recursos
  Future<Result<void>> dispose();
}

/// Interface específica para storage baseado em database (Drift)
/// Equivalente ao IBoxStorageService mas para databases SQL
abstract class IDatabaseStorageService extends IDriftStorageService {
  /// Lista todas as databases disponíveis
  Future<Result<List<String>>> listDatabases();

  /// Verifica se uma database específica existe
  Future<Result<bool>> databaseExists(String databaseName);

  /// Obtém estatísticas de uma database específica
  Future<Result<Map<String, dynamic>>> getDatabaseStatistics(String databaseName);

  /// Executa VACUUM em uma database específica
  /// Otimiza o arquivo SQLite removendo espaço não utilizado
  Future<Result<void>> vacuumDatabase(String databaseName);

  /// Remove uma database específica
  /// CUIDADO: Operação destrutiva
  Future<Result<void>> deleteDatabase(String databaseName);

  /// Faz backup de uma database específica
  Future<Result<Map<String, dynamic>>> backupDatabase(String databaseName);

  /// Restaura uma database específica
  Future<Result<void>> restoreDatabase(
    String databaseName,
    Map<String, dynamic> databaseData,
  );

  /// Obtém informações detalhadas de uma database
  /// Inclui versão, tabelas, índices, etc.
  Future<Result<Map<String, dynamic>>> getDatabaseInfo(String databaseName);

  /// Executa VACUUM em todas as databases abertas
  Future<Result<void>> vacuumAllDatabases();
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
  Result<void> validate();
}
