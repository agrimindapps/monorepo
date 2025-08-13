// Dart imports:
import 'dart:core';

/// Classe base para todas as exceptions dos repositories
/// Extends ValidationError para integração com Result<T> pattern existente
abstract class RepositoryException implements Exception {
  /// Mensagem descritiva do erro
  final String message;

  /// Código único para identificar o tipo de erro
  final String code;

  /// Repository que originou o erro
  final String repository;

  /// Operação que causou o erro (create, read, update, delete, etc.)
  final String operation;

  /// Exception original que causou este erro (se houver)
  final Exception? cause;

  /// Timestamp quando o erro ocorreu
  final DateTime timestamp;

  /// Dados adicionais contextuais do erro
  final Map<String, dynamic> context;

  RepositoryException({
    required this.message,
    required this.code,
    required this.repository,
    required this.operation,
    this.cause,
    DateTime? timestamp,
    this.context = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType[$code]');
    buffer.write(' in $repository.$operation: $message');

    if (cause != null) {
      buffer.write(' (caused by: $cause)');
    }

    if (context.isNotEmpty) {
      buffer.write(' - Context: $context');
    }

    return buffer.toString();
  }

  /// Retorna informações estruturadas do erro para logging
  Map<String, dynamic> toLogMap() {
    return {
      'error_type': runtimeType.toString(),
      'code': code,
      'message': message,
      'repository': repository,
      'operation': operation,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      if (cause != null) 'caused_by': cause.toString(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepositoryException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code &&
          repository == other.repository &&
          operation == other.operation;

  @override
  int get hashCode =>
      message.hashCode ^
      code.hashCode ^
      repository.hashCode ^
      operation.hashCode;
}

/// Exception para erros de inicialização de repository
class RepositoryInitializationException extends RepositoryException {
  RepositoryInitializationException({
    required super.repository,
    required super.message,
    super.cause,
    super.context,
  }) : super(
          code: 'INITIALIZATION_FAILED',
          operation: 'initialize',
        );
}

/// Exception para erros de data access (problemas com Hive/Firebase)
class DataAccessException extends RepositoryException {
  DataAccessException({
    required super.repository,
    required super.operation,
    required super.message,
    super.cause,
    super.context,
  }) : super(
          code: 'DATA_ACCESS_ERROR',
        );
}

/// Exception para erros de network/conectividade
class NetworkException extends RepositoryException {
  /// Indica se erro é temporário e pode ser retentado
  final bool isRetryable;

  /// Número de tentativas já realizadas
  final int retryCount;

  NetworkException({
    required super.repository,
    required super.operation,
    required super.message,
    this.isRetryable = true,
    this.retryCount = 0,
    super.cause,
    super.context,
  }) : super(
          code: 'NETWORK_ERROR',
        );

  /// Cria nova exception com contador de retry incrementado
  NetworkException withIncrementedRetry() {
    return NetworkException(
      repository: repository,
      operation: operation,
      message: message,
      isRetryable: isRetryable,
      retryCount: retryCount + 1,
      cause: cause,
      context: context,
    );
  }

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['is_retryable'] = isRetryable;
    map['retry_count'] = retryCount;
    return map;
  }
}

/// Exception para timeouts em operações
class TimeoutException extends RepositoryException {
  /// Duração do timeout que foi excedido
  final Duration timeoutDuration;

  TimeoutException({
    required super.repository,
    required super.operation,
    required this.timeoutDuration,
    String? message,
    super.cause,
    super.context,
  }) : super(
          message: message ??
              'Operation timed out after ${timeoutDuration.inSeconds}s',
          code: 'TIMEOUT',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['timeout_duration_ms'] = timeoutDuration.inMilliseconds;
    return map;
  }
}

/// Exception para conflitos de dados (ex: unique constraints)
class DataConflictException extends RepositoryException {
  /// Campo que causou o conflito
  final String conflictingField;

  /// Valor que causou o conflito
  final dynamic conflictingValue;

  DataConflictException({
    required super.repository,
    required super.operation,
    required this.conflictingField,
    required this.conflictingValue,
    String? message,
    super.cause,
    super.context,
  }) : super(
          message: message ??
              'Data conflict on field $conflictingField with value $conflictingValue',
          code: 'DATA_CONFLICT',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['conflicting_field'] = conflictingField;
    map['conflicting_value'] = conflictingValue.toString();
    return map;
  }
}

/// Exception para entidades não encontradas
class EntityNotFoundException extends RepositoryException {
  /// Tipo da entidade que não foi encontrada
  final String entityType;

  /// ID ou critério de busca que não retornou resultado
  final String searchCriteria;

  EntityNotFoundException({
    required super.repository,
    required super.operation,
    required this.entityType,
    required this.searchCriteria,
    String? message,
    super.cause,
    super.context,
  }) : super(
          message:
              message ?? '$entityType not found with criteria: $searchCriteria',
          code: 'ENTITY_NOT_FOUND',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['entity_type'] = entityType;
    map['search_criteria'] = searchCriteria;
    return map;
  }
}

/// Exception para operações batch que falharam parcialmente
class BatchOperationException extends RepositoryException {
  /// Total de itens na operação batch
  final int totalItems;

  /// Quantidade de itens processados com sucesso
  final int successfulItems;

  /// Quantidade de itens que falharam
  final int failedItems;

  /// Lista de erros individuais que ocorreram
  final List<RepositoryException> individualErrors;

  BatchOperationException({
    required super.repository,
    required super.operation,
    required this.totalItems,
    required this.successfulItems,
    required this.failedItems,
    required this.individualErrors,
    String? message,
    super.cause,
    super.context,
  }) : super(
          message: message ??
              'Batch operation partially failed: $successfulItems/$totalItems successful, $failedItems failed',
          code: 'BATCH_OPERATION_FAILED',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['total_items'] = totalItems;
    map['successful_items'] = successfulItems;
    map['failed_items'] = failedItems;
    map['individual_errors'] =
        individualErrors.map((e) => e.toLogMap()).toList();
    return map;
  }
}

/// Exception para erros de validação de dados antes de persistir
class ValidationException extends RepositoryException {
  /// Lista de campos que falharam na validação
  final List<String> invalidFields;

  /// Mapa de field -> motivo da falha
  final Map<String, String> validationErrors;

  ValidationException({
    required super.repository,
    required super.operation,
    required this.invalidFields,
    required this.validationErrors,
    String? message,
    super.cause,
    super.context,
  }) : super(
          message: message ??
              'Validation failed for fields: ${invalidFields.join(", ")}',
          code: 'VALIDATION_FAILED',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['invalid_fields'] = invalidFields;
    map['validation_errors'] = validationErrors;
    return map;
  }
}

/// Exception para erros de state inconsistente (ex: repository não inicializado)
class InvalidStateException extends RepositoryException {
  /// Estado atual do repository
  final String currentState;

  /// Estado esperado para a operação
  final String expectedState;

  InvalidStateException({
    required super.repository,
    required super.operation,
    required this.currentState,
    required this.expectedState,
    String? message,
    super.cause,
    super.context,
  }) : super(
          message: message ??
              'Invalid state for $operation: expected $expectedState, but was $currentState',
          code: 'INVALID_STATE',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['current_state'] = currentState;
    map['expected_state'] = expectedState;
    return map;
  }
}

/// Exception para falhas de sincronização com sistemas externos (Firebase)
class SyncException extends RepositoryException {
  /// Sistema externo que falhou (ex: 'Firebase', 'API')
  final String externalSystem;

  /// Indica se erro é temporário
  final bool isTemporary;

  SyncException({
    required super.repository,
    required super.operation,
    required this.externalSystem,
    required super.message,
    this.isTemporary = true,
    super.cause,
    super.context,
  }) : super(
          code: 'SYNC_ERROR',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['external_system'] = externalSystem;
    map['is_temporary'] = isTemporary;
    return map;
  }
}

/// Exception para transações que falharam
class TransactionException extends RepositoryException {
  /// ID da transação que falhou
  final String transactionId;

  /// Número de operações executadas com sucesso antes da falha
  final int successfulOperations;

  /// Número total de operações na transação
  final int totalOperations;

  TransactionException({
    required super.repository,
    required super.operation,
    required this.transactionId,
    required this.successfulOperations,
    required this.totalOperations,
    required super.message,
    super.cause,
    super.context,
  }) : super(
          code: 'TRANSACTION_FAILED',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['transaction_id'] = transactionId;
    map['successful_operations'] = successfulOperations;
    map['total_operations'] = totalOperations;
    return map;
  }
}

/// Exception para transações batch que falharam
class BatchTransactionException extends TransactionException {
  /// Índice da operação que causou a falha
  final int failedOperationIndex;

  /// Erro da operação específica que falhou
  final dynamic operationError;

  BatchTransactionException(
    String message,
    String transactionId,
    this.failedOperationIndex,
    this.operationError, {
    super.repository = 'BatchTransaction',
    super.operation = 'executeBatch',
    super.successfulOperations = 0,
    super.totalOperations = 0,
    super.cause,
    super.context,
  }) : super(
          transactionId: transactionId,
          message: message,
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['failed_operation_index'] = failedOperationIndex;
    map['operation_error'] = operationError.toString();
    return map;
  }
}

/// Exception para rollback de transações que falharam
class RollbackException extends RepositoryException {
  /// ID da transação original que estava sendo revertida
  final String originalTransactionId;

  /// Operações de rollback que falharam
  final List<String> failedRollbackOperations;

  RollbackException({
    required super.repository,
    required this.originalTransactionId,
    required this.failedRollbackOperations,
    String? message,
    super.cause,
    super.context,
  }) : super(
          message: message ??
              'Rollback failed for transaction $originalTransactionId. Failed rollback operations: ${failedRollbackOperations.join(", ")}',
          code: 'ROLLBACK_FAILED',
          operation: 'rollback',
        );

  @override
  Map<String, dynamic> toLogMap() {
    final map = super.toLogMap();
    map['original_transaction_id'] = originalTransactionId;
    map['failed_rollback_operations'] = failedRollbackOperations;
    return map;
  }
}

/// Utilitários para criar exceptions padronizadas rapidamente
class RepositoryExceptions {
  /// Cria NetworkException para falha de conectividade
  static NetworkException networkError({
    required String repository,
    required String operation,
    Exception? cause,
    bool isRetryable = true,
    int retryCount = 0,
    Map<String, dynamic> context = const {},
  }) {
    return NetworkException(
      repository: repository,
      operation: operation,
      message: 'Network connectivity failed',
      isRetryable: isRetryable,
      retryCount: retryCount,
      cause: cause,
      context: context,
    );
  }

  /// Cria TimeoutException para operação que demorou muito
  static TimeoutException timeout({
    required String repository,
    required String operation,
    required Duration timeout,
    Exception? cause,
    Map<String, dynamic> context = const {},
  }) {
    return TimeoutException(
      repository: repository,
      operation: operation,
      timeoutDuration: timeout,
      cause: cause,
      context: context,
    );
  }

  /// Cria EntityNotFoundException para entidade não encontrada
  static EntityNotFoundException notFound({
    required String repository,
    required String operation,
    required String entityType,
    required String searchCriteria,
    Exception? cause,
    Map<String, dynamic> context = const {},
  }) {
    return EntityNotFoundException(
      repository: repository,
      operation: operation,
      entityType: entityType,
      searchCriteria: searchCriteria,
      cause: cause,
      context: context,
    );
  }

  /// Cria DataConflictException para conflito de dados
  static DataConflictException conflict({
    required String repository,
    required String operation,
    required String conflictingField,
    required dynamic conflictingValue,
    Exception? cause,
    Map<String, dynamic> context = const {},
  }) {
    return DataConflictException(
      repository: repository,
      operation: operation,
      conflictingField: conflictingField,
      conflictingValue: conflictingValue,
      cause: cause,
      context: context,
    );
  }

  /// Cria InvalidStateException para estado inválido
  static InvalidStateException invalidState({
    required String repository,
    required String operation,
    required String currentState,
    required String expectedState,
    Exception? cause,
    Map<String, dynamic> context = const {},
  }) {
    return InvalidStateException(
      repository: repository,
      operation: operation,
      currentState: currentState,
      expectedState: expectedState,
      cause: cause,
      context: context,
    );
  }
}
