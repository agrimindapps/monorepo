/// Exceções específicas do Drift Storage
/// Equivalentes às exceções Hive mas adaptadas para Drift

/// Exceção base para erros relacionados ao Drift
class DriftException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const DriftException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'DriftException: $message (Original: $originalError)';
    }
    return 'DriftException: $message';
  }
}

/// Exceção lançada quando há erro na inicialização do Drift
class DriftInitializationException extends DriftException {
  const DriftInitializationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'DriftInitializationException: $message';
}

/// Exceção lançada quando há erro em operações de database
class DriftDatabaseException extends DriftException {
  final String databaseName;

  const DriftDatabaseException(
    super.message,
    this.databaseName, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'DriftDatabaseException [$databaseName]: $message';
}

/// Exceção lançada quando há erro em operações de table
class DriftTableException extends DriftException {
  final String tableName;
  final String? databaseName;

  const DriftTableException(
    super.message,
    this.tableName, {
    this.databaseName,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (databaseName != null) {
      return 'DriftTableException [$databaseName.$tableName]: $message';
    }
    return 'DriftTableException [$tableName]: $message';
  }
}

/// Exceção lançada quando uma database não é encontrada
class DriftDatabaseNotFoundException extends DriftDatabaseException {
  const DriftDatabaseNotFoundException(super.databaseName)
    : super('Database not found or not registered');

  @override
  String toString() => 'DriftDatabaseNotFoundException: $databaseName';
}

/// Exceção lançada quando há erro em operações de migration
class DriftMigrationException extends DriftException {
  final int fromVersion;
  final int toVersion;
  final String databaseName;

  const DriftMigrationException(
    super.message,
    this.databaseName,
    this.fromVersion,
    this.toVersion, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return 'DriftMigrationException [$databaseName]: $message (v$fromVersion → v$toVersion)';
  }
}

/// Exceção lançada quando há erro em operações de query
class DriftQueryException extends DriftException {
  final String? query;
  final String? tableName;

  const DriftQueryException(
    super.message, {
    this.query,
    this.tableName,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (query != null) {
      return 'DriftQueryException: $message (Query: $query)';
    }
    if (tableName != null) {
      return 'DriftQueryException [$tableName]: $message';
    }
    return 'DriftQueryException: $message';
  }
}

/// Exceção lançada quando há erro de validação de dados
class DriftValidationException extends DriftException {
  final Map<String, dynamic>? invalidData;

  const DriftValidationException(
    super.message, {
    this.invalidData,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (invalidData != null) {
      return 'DriftValidationException: $message (Data: $invalidData)';
    }
    return 'DriftValidationException: $message';
  }
}

/// Exceção lançada quando há erro de constraint (FK, unique, etc)
class DriftConstraintException extends DriftException {
  final String constraintType;
  final String? tableName;

  const DriftConstraintException(
    super.message,
    this.constraintType, {
    this.tableName,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (tableName != null) {
      return 'DriftConstraintException [$tableName]: $message (Constraint: $constraintType)';
    }
    return 'DriftConstraintException: $message (Constraint: $constraintType)';
  }
}

/// Exceção lançada quando há erro de transação
class DriftTransactionException extends DriftException {
  final String? databaseName;

  const DriftTransactionException(
    super.message, {
    this.databaseName,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    if (databaseName != null) {
      return 'DriftTransactionException [$databaseName]: $message';
    }
    return 'DriftTransactionException: $message';
  }
}
