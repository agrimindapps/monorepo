import 'package:core/core.dart' as core;

/// Export core failures for reuse
export 'package:core/core.dart'
    show
        Failure,
        ServerFailure,
        CacheFailure,
        ValidationFailure,
        AuthFailure,
        PermissionFailure,
        NetworkFailure,
        ParseFailure,
        UnknownFailure,
        FirebaseFailure,
        SyncFailure,
        NotFoundFailure;

// ========== APP-SPECIFIC GASOMETER FAILURES ==========

/// Vehicle-specific failures
class VehicleNotFoundFailure extends core.NotFoundFailure {
  const VehicleNotFoundFailure(String message)
      : super(message, code: 'VEHICLE_NOT_FOUND');
}

class DuplicateVehicleFailure extends core.ValidationFailure {
  const DuplicateVehicleFailure(String message)
      : super(message, code: 'DUPLICATE_VEHICLE');
}

/// Fuel-specific failures
class InvalidFuelDataFailure extends core.ValidationFailure {
  const InvalidFuelDataFailure(String message)
      : super(message, code: 'INVALID_FUEL_DATA');
}

/// Maintenance-specific failures
class MaintenanceNotFoundFailure extends core.NotFoundFailure {
  const MaintenanceNotFoundFailure(String message)
      : super(message, code: 'MAINTENANCE_NOT_FOUND');
}

/// Offline/connectivity specific failure
class OfflineFailure extends core.NetworkFailure {
  const OfflineFailure(String message) : super(message, code: 'OFFLINE');
}

/// Financial-specific failures (from core/errors/)

/// Failure específica para conflitos de sincronização financeira
/// Usado quando há divergência entre dados locais e remotos em operações financeiras
class FinancialConflictFailure extends core.Failure {
  final dynamic localData;
  final dynamic remoteData;
  final String entityType;
  final String entityId;

  const FinancialConflictFailure({
    required String message,
    required this.entityType,
    required this.entityId,
    String? code,
    this.localData,
    this.remoteData,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'FINANCIAL_CONFLICT',
          details: details,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        localData,
        remoteData,
        entityType,
        entityId,
      ];

  @override
  String toString() {
    return 'FinancialConflictFailure('
        'message: $message, '
        'entityType: $entityType, '
        'entityId: $entityId, '
        'code: $code)';
  }
}

/// Failure para erros de integridade de dados financeiros
/// Usado quando regras de negócio financeiras são violadas
class FinancialIntegrityFailure extends core.ValidationFailure {
  final String? fieldName;
  final dynamic invalidValue;
  final String? constraint;

  const FinancialIntegrityFailure({
    required String message,
    String? code,
    this.fieldName,
    this.invalidValue,
    this.constraint,
    dynamic details,
  }) : super(
          message,
          code: code ?? 'FINANCIAL_INTEGRITY_ERROR',
          details: details,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        fieldName,
        invalidValue,
        constraint,
      ];

  @override
  String toString() {
    return 'FinancialIntegrityFailure('
        'message: $message, '
        'fieldName: $fieldName, '
        'invalidValue: $invalidValue, '
        'constraint: $constraint)';
  }
}

/// Failure para erros de conectividade
/// Wrapper específico do app-gasometer para NetworkFailure
class ConnectivityFailure extends core.NetworkFailure {
  const ConnectivityFailure({
    String message = 'Sem conexão com a internet',
    String? code,
    dynamic details,
  }) : super(message, code: code ?? 'NO_CONNECTION', details: details);
}

/// Failure para operações de storage (Firebase Storage, Drift)
class StorageFailure extends core.CacheFailure {
  final String? storageType; // 'firebase_storage', 'drift', etc
  final String? operation; // 'read', 'write', 'delete', etc

  const StorageFailure({
    required String message,
    String? code,
    this.storageType,
    this.operation,
    dynamic details,
  }) : super(message, code: code ?? 'STORAGE_ERROR', details: details);

  @override
  List<Object?> get props => [...super.props, storageType, operation];

  @override
  String toString() {
    return 'StorageFailure('
        'message: $message, '
        'storageType: $storageType, '
        'operation: $operation)';
  }
}

/// Failure para erros de reconciliação de IDs
/// Usado quando há problemas ao mapear IDs locais para IDs remotos
class IdReconciliationFailure extends core.SyncFailure {
  final String localId;
  final String? remoteId;
  final String entityType;

  const IdReconciliationFailure({
    required String message,
    required this.localId,
    required this.entityType,
    this.remoteId,
    String? code,
    dynamic details,
  }) : super(
          message,
          code: code ?? 'ID_RECONCILIATION_ERROR',
          details: details,
        );

  @override
  List<Object?> get props => [...super.props, localId, remoteId, entityType];

  @override
  String toString() {
    return 'IdReconciliationFailure('
        'message: $message, '
        'localId: $localId, '
        'remoteId: $remoteId, '
        'entityType: $entityType)';
  }
}

/// Failure para erros em operações de imagem (upload/download)
class ImageOperationFailure extends core.Failure {
  final String operation; // 'upload', 'download', 'compress', etc
  final String? imagePath;

  const ImageOperationFailure({
    required String message,
    required this.operation,
    this.imagePath,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code ?? 'IMAGE_OPERATION_ERROR',
          details: details,
        );

  @override
  List<Object?> get props => [...super.props, operation, imagePath];

  @override
  String toString() {
    return 'ImageOperationFailure('
        'message: $message, '
        'operation: $operation, '
        'imagePath: $imagePath)';
  }
}

/// Extensions para facilitar o uso de failures
extension GasometerFailureExtensions on core.Failure {
  /// Retorna true se é uma falha de dados financeiros
  bool get isFinancialFailure =>
      this is FinancialConflictFailure || this is FinancialIntegrityFailure;

  /// Retorna true se é uma falha de conectividade
  bool get isConnectivityFailure => this is ConnectivityFailure;

  /// Retorna true se é uma falha de storage
  bool get isStorageFailure => this is StorageFailure;

  /// Retorna true se é uma falha de reconciliação de IDs
  bool get isIdReconciliationFailure => this is IdReconciliationFailure;

  /// Retorna mensagem user-friendly específica do gasometer
  String get gasometerUserMessage {
    if (isFinancialFailure) {
      return 'Erro ao processar dados financeiros. Verifique os valores e tente novamente.';
    }
    if (isConnectivityFailure) {
      return 'Sem conexão com a internet. Suas alterações serão sincronizadas quando você estiver online.';
    }
    if (isStorageFailure) {
      return 'Erro ao salvar dados. Verifique o espaço disponível e tente novamente.';
    }
    if (isIdReconciliationFailure) {
      return 'Erro de sincronização. Suas alterações serão sincronizadas automaticamente.';
    }

    // Fallback to core user message
    return userMessage;
  }
}
