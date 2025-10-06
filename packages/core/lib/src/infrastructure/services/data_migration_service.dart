import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/data_migration/data_conflict_result.dart';
import '../../domain/entities/data_migration/data_resolution_choice.dart';
import '../../shared/utils/failure.dart';

/// Abstract base service for handling data migration between anonymous and account users
/// 
/// This service provides a common interface for detecting data conflicts and
/// managing the migration process. Each app should implement this service
/// to handle their specific data types and migration logic.
abstract class DataMigrationService {
  /// Detect conflicts between anonymous and account data
  /// 
  /// This method should analyze both data sources and determine if conflicts exist.
  /// It should return a [DataConflictResult] with details about any conflicts found.
  Future<Either<Failure, DataConflictResult>> detectConflicts({
    required String anonymousUserId,
    required String accountUserId,
  });

  /// Execute the user's choice for resolving data conflicts
  /// 
  /// This method handles the actual migration or cleanup based on the user's choice.
  /// It should perform all necessary operations to resolve the conflict completely.
  Future<Either<Failure, DataMigrationResult>> executeResolution({
    required DataResolutionChoice choice,
    required DataConflictResult conflictResult,
    Map<String, dynamic> additionalParams = const {},
  });

  /// Validate that a migration can be performed
  /// 
  /// This method should check if all prerequisites are met for migration,
  /// such as network connectivity, authentication state, etc.
  Future<Either<Failure, bool>> validateMigrationPreconditions({
    required String anonymousUserId,
    required String accountUserId,
  });

  /// Get progress updates during migration operations
  /// 
  /// This stream provides real-time updates about the migration process,
  /// including progress percentage and current operation description.
  Stream<MigrationProgress> get migrationProgress;

  /// Cancel an ongoing migration operation
  /// 
  /// This method attempts to cancel any ongoing migration and restore
  /// the system to a consistent state.
  Future<Either<Failure, void>> cancelMigration();
}

/// Result of executing a data migration resolution
class DataMigrationResult {
  const DataMigrationResult({
    required this.success,
    required this.choiceExecuted,
    this.message,
    this.affectedRecords = const {},
    this.errors = const [],
    this.warnings = const [],
  });

  /// Whether the migration was successful
  final bool success;
  
  /// The choice that was executed
  final DataResolutionChoice choiceExecuted;
  
  /// Optional result message
  final String? message;
  
  /// Map of data types to number of records affected
  final Map<String, int> affectedRecords;
  
  /// Any errors that occurred during migration
  final List<String> errors;
  
  /// Any warnings generated during migration
  final List<String> warnings;

  /// Total number of records affected across all data types
  int get totalAffectedRecords => affectedRecords.values.fold(0, (sum, count) => sum + count);

  /// Whether there were any errors during migration
  bool get hasErrors => errors.isNotEmpty;

  /// Whether there were any warnings during migration
  bool get hasWarnings => warnings.isNotEmpty;

  /// Get a summary message for display
  String get summaryMessage {
    if (message != null) return message!;
    
    if (!success) {
      return 'Migração falhou. ${errors.join('. ')}';
    }
    
    switch (choiceExecuted) {
      case DataResolutionChoice.keepAccountData:
        return 'Dados da conta mantidos. $totalAffectedRecords registros anônimos removidos.';
      case DataResolutionChoice.keepAnonymousData:
        return 'Redirecionamento para criação de nova conta.';
      case DataResolutionChoice.cancel:
        return 'Operação cancelada.';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'choice_executed': choiceExecuted.name,
      'message': message,
      'affected_records': affectedRecords,
      'total_affected': totalAffectedRecords,
      'errors': errors,
      'warnings': warnings,
    };
  }

  /// Create from JSON
  factory DataMigrationResult.fromJson(Map<String, dynamic> json) {
    return DataMigrationResult(
      success: json['success'] as bool,
      choiceExecuted: DataResolutionChoice.values.firstWhere(
        (choice) => choice.name == json['choice_executed'],
      ),
      message: json['message'] as String?,
      affectedRecords: Map<String, int>.from(json['affected_records'] as Map? ?? {}),
      errors: List<String>.from(json['errors'] as List? ?? []),
      warnings: List<String>.from(json['warnings'] as List? ?? []),
    );
  }
}

/// Progress information for migration operations
class MigrationProgress {
  const MigrationProgress({
    required this.percentage,
    required this.currentOperation,
    this.details,
    this.estimatedTimeRemaining,
  });

  /// Progress percentage (0.0 to 1.0)
  final double percentage;
  
  /// Description of the current operation
  final String currentOperation;
  
  /// Optional additional details
  final String? details;
  
  /// Estimated time remaining in milliseconds
  final Duration? estimatedTimeRemaining;

  /// Progress percentage as an integer (0 to 100)
  int get percentageInt => (percentage * 100).round();

  /// Whether the operation is complete
  bool get isComplete => percentage >= 1.0;

  @override
  String toString() {
    return 'MigrationProgress($percentageInt%): $currentOperation';
  }
}

/// Base implementation of DataMigrationService with common functionality
abstract class BaseDataMigrationService implements DataMigrationService {
  
  /// Stream controller for migration progress
  @protected
  Stream<MigrationProgress>? _progressStream;
  
  @override
  Stream<MigrationProgress> get migrationProgress => 
      _progressStream ?? const Stream.empty();

  /// Helper method to emit progress updates
  @protected
  void emitProgress({
    required double percentage,
    required String operation,
    String? details,
    Duration? estimatedTime,
  }) {
    if (kDebugMode) {
      debugPrint('Migration Progress: ${(percentage * 100).toInt()}% - $operation');
    }
  }

  /// Common validation logic that can be shared across implementations
  @protected
  Future<Either<Failure, bool>> validateBasicPreconditions({
    required String anonymousUserId,
    required String accountUserId,
  }) async {
    try {
      if (anonymousUserId.isEmpty) {
        return const Left(ValidationFailure('ID de usuário anônimo inválido'));
      }
      
      if (accountUserId.isEmpty) {
        return const Left(ValidationFailure('ID de conta de usuário inválido'));
      }
      
      if (anonymousUserId == accountUserId) {
        return const Left(ValidationFailure('IDs de usuário não podem ser iguais'));
      }
      
      return const Right(true);
    } catch (e) {
      return Left(UnknownFailure('Erro na validação: $e'));
    }
  }

  /// Helper method to safely execute operations with error handling
  @protected
  Future<T> safeExecute<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Executing: $operationName');
      }
      
      final result = await operation();
      
      if (kDebugMode) {
        debugPrint('✅ Completed: $operationName');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed: $operationName - $e');
      }
      rethrow;
    }
  }
}
