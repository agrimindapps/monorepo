import 'package:dartz/dartz.dart';
import '../../../../shared/utils/failure.dart';

/// Interface genérica para serviços de storage
/// Define contratos básicos que qualquer implementação de storage deve seguir
abstract class IStorageService {
  /// Nome do serviço de storage
  String get serviceName;

  /// Verifica se o serviço foi inicializado
  bool get isInitialized;

  /// Inicializa o serviço de storage
  /// [config] configurações específicas do serviço
  Future<Either<Failure, void>> initialize(Map<String, dynamic>? config);

  /// Verifica a saúde/integridade do serviço
  Future<Either<Failure, Map<String, dynamic>>> healthCheck();

  /// Obtém estatísticas gerais do storage
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
  Future<Either<Failure, void>> performMaintenance();

  /// Fecha/destrói o serviço liberando recursos
  Future<Either<Failure, void>> dispose();
}

/// Interface específica para storage baseado em box (como Hive)
abstract class IBoxStorageService extends IStorageService {
  /// Lista todas as boxes disponíveis
  Future<Either<Failure, List<String>>> listBoxes();

  /// Verifica se uma box específica existe
  Future<Either<Failure, bool>> boxExists(String boxName);

  /// Obtém estatísticas de uma box específica
  Future<Either<Failure, Map<String, dynamic>>> getBoxStatistics(
    String boxName,
  );

  /// Compacta uma box específica
  Future<Either<Failure, void>> compactBox(String boxName);

  /// Remove uma box específica
  Future<Either<Failure, void>> deleteBox(String boxName);

  /// Faz backup de uma box específica
  Future<Either<Failure, Map<String, dynamic>>> backupBox(String boxName);

  /// Restaura uma box específica
  Future<Either<Failure, void>> restoreBox(
    String boxName,
    Map<String, dynamic> boxData,
  );
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
  Either<Failure, void> validate();
}
