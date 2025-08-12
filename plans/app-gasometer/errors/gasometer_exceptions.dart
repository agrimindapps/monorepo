// Dart imports:
import 'dart:async';
import 'dart:io';

/// Hierarquia de exceptions customizadas para o módulo Gasometer
/// 
/// Estabelece padrão consistente de error handling com context preservado
/// e categorização adequada para diferentes tipos de erro

// MARK: - Base Exception
/// Exception base para todo o módulo Gasometer
abstract class GasometerException implements Exception {
  final String message;
  final String code;
  final Map<String, dynamic>? context;
  final Exception? cause;
  final StackTrace? stackTrace;

  const GasometerException(
    this.message, {
    required this.code,
    this.context,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message (code: $code)');
    if (context != null) {
      buffer.write(' | context: $context');
    }
    if (cause != null) {
      buffer.write(' | caused by: $cause');
    }
    return buffer.toString();
  }
}

// MARK: - Domain Specific Exceptions

/// Exceptions relacionadas a Veículos
abstract class VeiculoException extends GasometerException {
  const VeiculoException(
    super.message, {
    required super.code,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

class VeiculoNotFoundException extends VeiculoException {
  VeiculoNotFoundException(String veiculoId)
      : super(
          'Veículo não encontrado',
          code: 'VEICULO_NOT_FOUND',
          context: {'veiculoId': veiculoId},
        );
}

class VeiculoValidationException extends VeiculoException {
  VeiculoValidationException(String field, String reason)
      : super(
          'Dados do veículo inválidos',
          code: 'VEICULO_VALIDATION_ERROR',
          context: {'field': field, 'reason': reason},
        );
}

class VeiculoDuplicateException extends VeiculoException {
  VeiculoDuplicateException(String field, String value)
      : super(
          'Veículo já existe',
          code: 'VEICULO_DUPLICATE',
          context: {'field': field, 'value': value},
        );
}

class VeiculoHasRecordsException extends VeiculoException {
  VeiculoHasRecordsException(String veiculoId, int recordCount)
      : super(
          'Não é possível remover veículo com registros',
          code: 'VEICULO_HAS_RECORDS',
          context: {'veiculoId': veiculoId, 'recordCount': recordCount},
        );
}

/// Exceptions relacionadas a Abastecimentos
abstract class AbastecimentoException extends GasometerException {
  const AbastecimentoException(
    super.message, {
    required super.code,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

class AbastecimentoNotFoundException extends AbastecimentoException {
  AbastecimentoNotFoundException(String abastecimentoId)
      : super(
          'Abastecimento não encontrado',
          code: 'ABASTECIMENTO_NOT_FOUND',
          context: {'abastecimentoId': abastecimentoId},
        );
}

class AbastecimentoValidationException extends AbastecimentoException {
  AbastecimentoValidationException(String field, String reason)
      : super(
          'Dados do abastecimento inválidos',
          code: 'ABASTECIMENTO_VALIDATION_ERROR',
          context: {'field': field, 'reason': reason},
        );
}

class AbastecimentoCalculationException extends AbastecimentoException {
  AbastecimentoCalculationException(String calculationType, String reason)
      : super(
          'Erro no cálculo do abastecimento',
          code: 'ABASTECIMENTO_CALCULATION_ERROR',
          context: {'calculationType': calculationType, 'reason': reason},
        );
}

/// Exceptions relacionadas a Odômetro
abstract class OdometroException extends GasometerException {
  const OdometroException(
    super.message, {
    required super.code,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

class OdometroNotFoundException extends OdometroException {
  OdometroNotFoundException(String odometroId)
      : super(
          'Registro de odômetro não encontrado',
          code: 'ODOMETRO_NOT_FOUND',
          context: {'odometroId': odometroId},
        );
}

class OdometroValidationException extends OdometroException {
  OdometroValidationException(String field, String reason)
      : super(
          'Dados do odômetro inválidos',
          code: 'ODOMETRO_VALIDATION_ERROR',
          context: {'field': field, 'reason': reason},
        );
}

class OdometroSequenceException extends OdometroException {
  OdometroSequenceException(double currentValue, double previousValue)
      : super(
          'Sequência de odômetro inválida',
          code: 'ODOMETRO_SEQUENCE_ERROR',
          context: {'currentValue': currentValue, 'previousValue': previousValue},
        );
}

/// Exceptions relacionadas a Despesas
abstract class DespesaException extends GasometerException {
  const DespesaException(
    super.message, {
    required super.code,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

class DespesaNotFoundException extends DespesaException {
  DespesaNotFoundException(String despesaId)
      : super(
          'Despesa não encontrada',
          code: 'DESPESA_NOT_FOUND',
          context: {'despesaId': despesaId},
        );
}

class DespesaValidationException extends DespesaException {
  DespesaValidationException(String field, String reason)
      : super(
          'Dados da despesa inválidos',
          code: 'DESPESA_VALIDATION_ERROR',
          context: {'field': field, 'reason': reason},
        );
}

/// Exceptions relacionadas a Manutenções
abstract class ManutencaoException extends GasometerException {
  const ManutencaoException(
    super.message, {
    required super.code,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

class ManutencaoNotFoundException extends ManutencaoException {
  ManutencaoNotFoundException(String manutencaoId)
      : super(
          'Manutenção não encontrada',
          code: 'MANUTENCAO_NOT_FOUND',
          context: {'manutencaoId': manutencaoId},
        );
}

class ManutencaoValidationException extends ManutencaoException {
  ManutencaoValidationException(String field, String reason)
      : super(
          'Dados da manutenção inválidos',
          code: 'MANUTENCAO_VALIDATION_ERROR',
          context: {'field': field, 'reason': reason},
        );
}

// MARK: - Infrastructure Exceptions

/// Exceptions relacionadas ao storage/persistence
abstract class StorageException extends GasometerException {
  const StorageException(
    super.message, {
    required super.code,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

class HiveStorageException extends StorageException {
  HiveStorageException(String operation, Exception cause)
      : super(
          'Erro no armazenamento Hive',
          code: 'HIVE_STORAGE_ERROR',
          context: {'operation': operation},
          cause: cause,
        );
}

class FirestoreStorageException extends StorageException {
  FirestoreStorageException(String operation, Exception cause)
      : super(
          'Erro no Firestore',
          code: 'FIRESTORE_STORAGE_ERROR',
          context: {'operation': operation},
          cause: cause,
        );
}

class SharedPreferencesStorageException extends StorageException {
  SharedPreferencesStorageException(String operation, Exception cause)
      : super(
          'Erro no SharedPreferences',
          code: 'SHARED_PREFERENCES_ERROR',
          context: {'operation': operation},
          cause: cause,
        );
}

/// Exceptions relacionadas à rede
abstract class NetworkException extends GasometerException {
  const NetworkException(
    super.message, {
    required super.code,
    super.context,
    super.cause,
    super.stackTrace,
  });
}

class NetworkConnectionException extends NetworkException {
  const NetworkConnectionException()
      : super(
          'Sem conexão com a internet',
          code: 'NETWORK_CONNECTION_ERROR',
        );
}

class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException(String operation, Duration timeout)
      : super(
          'Timeout na operação de rede',
          code: 'NETWORK_TIMEOUT_ERROR',
          context: {'operation': operation, 'timeoutMs': timeout.inMilliseconds},
        );
}

class SyncException extends NetworkException {
  SyncException(String operation, Exception cause)
      : super(
          'Erro na sincronização',
          code: 'SYNC_ERROR',
          context: {'operation': operation},
          cause: cause,
        );
}

// MARK: - Utility Functions

/// Converte exceptions genéricas em exceptions específicas do domínio
GasometerException wrapException(
  Exception exception, {
  String? operation,
  Map<String, dynamic>? context,
  StackTrace? stackTrace,
}) {
  if (exception is GasometerException) {
    return exception;
  }

  // Network related errors
  if (exception is SocketException) {
    return const NetworkConnectionException();
  }

  if (exception is TimeoutException) {
    return NetworkTimeoutException(
      operation ?? 'unknown',
      exception.duration ?? const Duration(seconds: 30),
    );
  }

  // Storage related errors
  if (exception.toString().contains('Hive')) {
    return HiveStorageException(operation ?? 'unknown', exception);
  }

  if (exception.toString().contains('Firestore')) {
    return FirestoreStorageException(operation ?? 'unknown', exception);
  }

  if (exception.toString().contains('SharedPreferences')) {
    return SharedPreferencesStorageException(operation ?? 'unknown', exception);
  }

  // Default wrapper
  return GenericGasometerException(
    exception.toString(),
    operation: operation,
    context: context,
    cause: exception,
    stackTrace: stackTrace,
  );
}

/// Exception genérica para casos não cobertos por exceptions específicas
class GenericGasometerException extends GasometerException {
  const GenericGasometerException(
    super.message, {
    String? operation,
    super.context,
    super.cause,
    super.stackTrace,
  }) : super(
          code: operation != null ? 'GENERIC_ERROR_$operation' : 'GENERIC_ERROR',
        );
}