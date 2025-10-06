/// Exceções específicas para operações de storage com Hive
/// Fornece hierarquia de exceções bem definida para diferentes cenários
library;

/// Exceção base para todas as operações de storage
abstract class StorageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const StorageException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'StorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exceção para falhas na inicialização do Hive
class HiveInitializationException extends StorageException {
  const HiveInitializationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'HiveInitializationException: $message';
}

/// Exceção para operações em boxes do Hive
class HiveBoxException extends StorageException {
  final String boxName;

  const HiveBoxException(
    super.message,
    this.boxName, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'HiveBoxException: $message (Box: $boxName)';
}

/// Exceção para operações CRUD
class HiveCrudException extends StorageException {
  final String operation;
  final String? entityId;

  const HiveCrudException(
    super.message,
    this.operation, {
    this.entityId,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'HiveCrudException: $message (Operation: $operation${entityId != null ? ', Entity: $entityId' : ''})';
}

/// Exceção para adaptadores do Hive
class HiveAdapterException extends StorageException {
  final Type? adapterType;

  const HiveAdapterException(
    super.message, {
    this.adapterType,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'HiveAdapterException: $message${adapterType != null ? ' (Type: $adapterType)' : ''}';
}

/// Exceção para operações de serialização/deserialização
class HiveSerializationException extends StorageException {
  final Type? targetType;

  const HiveSerializationException(
    super.message, {
    this.targetType,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'HiveSerializationException: $message${targetType != null ? ' (Type: $targetType)' : ''}';
}
