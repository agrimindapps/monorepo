import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../shared/utils/failure.dart';

/// Service responsible for completely cleaning up anonymous user data
/// 
/// This service handles the complete removal of anonymous user data from all
/// storage locations including local storage (Hive, SharedPreferences, secure storage),
/// remote storage (Firebase), and user account deletion.
abstract class AnonymousDataCleaner {
  /// Clean all anonymous user data completely
  /// 
  /// This method should perform a comprehensive cleanup of all anonymous data:
  /// - Local storage (Hive boxes, SharedPreferences, secure storage)
  /// - Remote storage (Firestore documents)
  /// - Firebase Authentication (delete anonymous account)
  /// - Any cached data in memory
  Future<Either<Failure, AnonymousDataCleanupResult>> cleanAllAnonymousData({
    required String anonymousUserId,
    bool includeAuthAccount = true,
    Map<String, dynamic> cleanupOptions = const {},
  });

  /// Clean only local anonymous data
  /// 
  /// This method cleans only local storage, preserving remote data and account.
  /// Useful for testing or partial cleanup scenarios.
  Future<Either<Failure, AnonymousDataCleanupResult>> cleanLocalAnonymousData({
    required String anonymousUserId,
    Map<String, dynamic> cleanupOptions = const {},
  });

  /// Clean only remote anonymous data
  /// 
  /// This method cleans only remote storage (Firestore), preserving local data and account.
  /// Useful for cases where you want to clear server data but keep local cache.
  Future<Either<Failure, AnonymousDataCleanupResult>> cleanRemoteAnonymousData({
    required String anonymousUserId,
    Map<String, dynamic> cleanupOptions = const {},
  });

  /// Delete the anonymous Firebase Authentication account
  /// 
  /// This method removes the anonymous user account from Firebase Auth.
  /// Should be called as the final step in complete cleanup.
  Future<Either<Failure, void>> deleteAnonymousAccount({
    required String anonymousUserId,
  });

  /// Validate that cleanup is safe to proceed
  /// 
  /// This method should verify that the user is currently anonymous and
  /// that cleanup won't affect non-anonymous data.
  Future<Either<Failure, bool>> validateCleanupPreconditions({
    required String anonymousUserId,
  });

  /// Get progress updates during cleanup operations
  /// 
  /// This stream provides real-time updates about the cleanup process.
  Stream<CleanupProgress> get cleanupProgress;

  /// Cancel an ongoing cleanup operation
  /// 
  /// This method attempts to cancel cleanup and restore data to a consistent state.
  /// Note: Some cleanup operations may not be reversible.
  Future<Either<Failure, void>> cancelCleanup();

  /// Verify that cleanup was successful
  /// 
  /// This method performs post-cleanup verification to ensure all data was removed.
  Future<Either<Failure, CleanupVerificationResult>> verifyCleanupSuccess({
    required String anonymousUserId,
  });
}

/// Result of anonymous data cleanup operations
class AnonymousDataCleanupResult {
  const AnonymousDataCleanupResult({
    required this.success,
    required this.cleanupType,
    this.message,
    this.clearedCounts = const {},
    this.errors = const [],
    this.warnings = const [],
    this.duration,
  });

  /// Whether the cleanup was successful
  final bool success;
  
  /// Type of cleanup that was performed
  final CleanupType cleanupType;
  
  /// Optional result message
  final String? message;
  
  /// Map of data types to number of items cleared
  final Map<String, int> clearedCounts;
  
  /// Any errors that occurred during cleanup
  final List<String> errors;
  
  /// Any warnings generated during cleanup
  final List<String> warnings;
  
  /// Duration of the cleanup operation
  final Duration? duration;

  /// Total number of items cleared across all data types
  int get totalClearedItems => clearedCounts.values.fold(0, (sum, count) => sum + count);

  /// Whether there were any errors during cleanup
  bool get hasErrors => errors.isNotEmpty;

  /// Whether there were any warnings during cleanup
  bool get hasWarnings => warnings.isNotEmpty;

  /// Get a summary message for display
  String get summaryMessage {
    if (message != null) return message!;
    
    if (!success) {
      return 'Limpeza falhou. ${errors.join('. ')}';
    }
    
    return 'Limpeza concluída com sucesso. $totalClearedItems itens removidos.';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'cleanup_type': cleanupType.name,
      'message': message,
      'cleared_counts': clearedCounts,
      'total_cleared': totalClearedItems,
      'errors': errors,
      'warnings': warnings,
      'duration_ms': duration?.inMilliseconds,
    };
  }

  /// Create from JSON
  factory AnonymousDataCleanupResult.fromJson(Map<String, dynamic> json) {
    return AnonymousDataCleanupResult(
      success: json['success'] as bool,
      cleanupType: CleanupType.values.firstWhere(
        (type) => type.name == json['cleanup_type'],
      ),
      message: json['message'] as String?,
      clearedCounts: Map<String, int>.from(json['cleared_counts'] as Map? ?? {}),
      errors: List<String>.from(json['errors'] as List? ?? []),
      warnings: List<String>.from(json['warnings'] as List? ?? []),
      duration: json['duration_ms'] != null 
          ? Duration(milliseconds: json['duration_ms'] as int)
          : null,
    );
  }
}

/// Types of cleanup operations
enum CleanupType {
  /// Complete cleanup (local + remote + account deletion)
  complete,
  
  /// Local data cleanup only
  localOnly,
  
  /// Remote data cleanup only
  remoteOnly,
  
  /// Account deletion only
  accountOnly;

  /// Display name for the cleanup type
  String get displayName {
    switch (this) {
      case CleanupType.complete:
        return 'Limpeza Completa';
      case CleanupType.localOnly:
        return 'Limpeza Local';
      case CleanupType.remoteOnly:
        return 'Limpeza Remota';
      case CleanupType.accountOnly:
        return 'Exclusão de Conta';
    }
  }

  /// Description of what this cleanup type does
  String get description {
    switch (this) {
      case CleanupType.complete:
        return 'Remove todos os dados locais, remotos e deleta a conta anônima';
      case CleanupType.localOnly:
        return 'Remove apenas dados armazenados localmente no dispositivo';
      case CleanupType.remoteOnly:
        return 'Remove apenas dados armazenados no servidor';
      case CleanupType.accountOnly:
        return 'Remove apenas a conta de autenticação anônima';
    }
  }
}

/// Progress information for cleanup operations
class CleanupProgress {
  const CleanupProgress({
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
  
  /// Estimated time remaining
  final Duration? estimatedTimeRemaining;

  /// Progress percentage as an integer (0 to 100)
  int get percentageInt => (percentage * 100).round();

  /// Whether the operation is complete
  bool get isComplete => percentage >= 1.0;

  @override
  String toString() {
    return 'CleanupProgress($percentageInt%): $currentOperation';
  }
}

/// Result of cleanup verification
class CleanupVerificationResult {
  const CleanupVerificationResult({
    required this.isComplete,
    this.remainingItems = const {},
    this.verificationErrors = const [],
  });

  /// Whether cleanup was verified as complete
  final bool isComplete;
  
  /// Map of data types to number of remaining items (if any)
  final Map<String, int> remainingItems;
  
  /// Any errors found during verification
  final List<String> verificationErrors;

  /// Total number of remaining items
  int get totalRemainingItems => remainingItems.values.fold(0, (sum, count) => sum + count);

  /// Whether there are any verification errors
  bool get hasErrors => verificationErrors.isNotEmpty;

  /// Get verification summary
  String get summary {
    if (isComplete && totalRemainingItems == 0) {
      return 'Limpeza verificada com sucesso. Nenhum dado restante encontrado.';
    }
    
    if (totalRemainingItems > 0) {
      return 'Verificação encontrou $totalRemainingItems itens restantes.';
    }
    
    if (hasErrors) {
      return 'Erros encontrados durante verificação: ${verificationErrors.join(', ')}';
    }
    
    return 'Verificação de limpeza não pôde ser concluída.';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'is_complete': isComplete,
      'remaining_items': remainingItems,
      'total_remaining': totalRemainingItems,
      'verification_errors': verificationErrors,
    };
  }
}

/// Base implementation with common functionality
abstract class BaseAnonymousDataCleaner implements AnonymousDataCleaner {
  
  /// Stream controller for cleanup progress
  @protected
  Stream<CleanupProgress>? _progressStream;
  
  @override
  Stream<CleanupProgress> get cleanupProgress => 
      _progressStream ?? const Stream.empty();

  /// Helper method to emit progress updates
  @protected
  void emitCleanupProgress({
    required double percentage,
    required String operation,
    String? details,
    Duration? estimatedTime,
  }) {
    if (kDebugMode) {
      debugPrint('Cleanup Progress: ${(percentage * 100).toInt()}% - $operation');
    }
  }

  /// Common validation logic
  @protected
  Future<Either<Failure, bool>> validateBasicPreconditions({
    required String anonymousUserId,
  }) async {
    try {
      if (anonymousUserId.isEmpty) {
        return const Left(ValidationFailure('ID de usuário anônimo inválido'));
      }
      
      return const Right(true);
    } catch (e) {
      return Left(UnknownFailure('Erro na validação: $e'));
    }
  }

  /// Helper method to safely execute cleanup operations
  @protected
  Future<T> safeExecuteCleanup<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🧹 Starting: $operationName');
      }
      
      final result = await operation();
      
      if (kDebugMode) {
        debugPrint('✅ Cleanup completed: $operationName');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Cleanup failed: $operationName - $e');
      }
      rethrow;
    }
  }
}