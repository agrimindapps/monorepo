import '../../../../shared/utils/result.dart';

/// Interface genérica para serviços de storage
/// Define contratos básicos que qualquer implementação de storage deve seguir
abstract class IStorageService {
  /// Nome do serviço de storage
  String get serviceName;

  /// Verifica se o serviço foi inicializado
  bool get isInitialized;

  /// Inicializa o serviço de storage
  /// [config] configurações específicas do serviço
  Future<Result<void>> initialize(Map<String, dynamic>? config);

  /// Verifica a saúde/integridade do serviço
  Future<Result<Map<String, dynamic>>> healthCheck();

  /// Obtém estatísticas gerais do storage
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
  Future<Result<void>> performMaintenance();

  /// Fecha/destrói o serviço liberando recursos
  Future<Result<void>> dispose();
}

/// Interface específica para storage baseado em box (como Hive)
abstract class IBoxStorageService extends IStorageService {
  /// Lista todas as boxes disponíveis
  Future<Result<List<String>>> listBoxes();

  /// Verifica se uma box específica existe
  Future<Result<bool>> boxExists(String boxName);

  /// Obtém estatísticas de uma box específica
  Future<Result<Map<String, dynamic>>> getBoxStatistics(String boxName);

  /// Compacta uma box específica
  Future<Result<void>> compactBox(String boxName);

  /// Remove uma box específica
  Future<Result<void>> deleteBox(String boxName);

  /// Faz backup de uma box específica
  Future<Result<Map<String, dynamic>>> backupBox(String boxName);

  /// Restaura uma box específica
  Future<Result<void>> restoreBox(String boxName, Map<String, dynamic> boxData);
}

/// Interface para configuração de storage
abstract class IStorageConfig {
  /// Nome da aplicação
  String get appName;

  /// Configurações específicas do storage
  Map<String, dynamic> get storageConfig;

  /// Configurações de backup
  Map<String, dynamic>? get backupConfig;

  /// Configurações de cache
  Map<String, dynamic>? get cacheConfig;

  /// Configurações de sincronização
  Map<String, dynamic>? get syncConfig;

  /// Valida se a configuração é válida
  Result<void> validate();
}