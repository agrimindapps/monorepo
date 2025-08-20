// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../utils/error_handler.dart';

/// Types of critical operations that require validation
enum CriticalOperation {
  delete,
  update,
  create,
  export,
  importData,
}

/// Security validation result
class SecurityValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;

  SecurityValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
  });

  factory SecurityValidationResult.valid() {
    return SecurityValidationResult(isValid: true);
  }

  factory SecurityValidationResult.invalid(String message) {
    return SecurityValidationResult(isValid: false, errorMessage: message);
  }

  factory SecurityValidationResult.validWithWarnings(List<String> warnings) {
    return SecurityValidationResult(isValid: true, warnings: warnings);
  }
}

/// Rate limiting tracker
class RateLimiter {
  final Map<String, List<DateTime>> _actionLog = {};
  final int maxActions;
  final Duration timeWindow;

  RateLimiter({
    required this.maxActions,
    required this.timeWindow,
  });

  bool isAllowed(String actionKey) {
    final now = DateTime.now();
    final actions = _actionLog[actionKey] ?? [];
    
    // Remove old actions outside the time window
    actions.removeWhere((time) => now.difference(time) > timeWindow);
    
    // Check if limit is exceeded
    if (actions.length >= maxActions) {
      return false;
    }
    
    // Add current action
    actions.add(now);
    _actionLog[actionKey] = actions;
    
    return true;
  }

  void reset(String actionKey) {
    _actionLog.remove(actionKey);
  }

  void resetAll() {
    _actionLog.clear();
  }
}

/// Audit log entry
class AuditLogEntry {
  final String userId;
  final String action;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final bool success;
  final String? errorMessage;

  AuditLogEntry({
    required this.userId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.success,
    this.errorMessage,
    this.metadata = const {},
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'action': action,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'success': success,
      'errorMessage': errorMessage,
    };
  }
}

/// Security service for validating critical operations
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final RateLimiter _deleteRateLimiter = RateLimiter(
    maxActions: 5,
    timeWindow: const Duration(minutes: 1),
  );

  final RateLimiter _generalRateLimiter = RateLimiter(
    maxActions: 20,
    timeWindow: const Duration(minutes: 1),
  );

  final List<AuditLogEntry> _auditLog = [];

  /// Validate a critical operation before execution
  Future<SecurityValidationResult> validateCriticalOperation({
    required CriticalOperation operation,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Check rate limiting
      if (!_checkRateLimit(operation, resourceId)) {
        return SecurityValidationResult.invalid(
          'Muitas tentativas. Aguarde antes de tentar novamente.',
        );
      }

      // Validate permissions
      final permissionResult = await _validatePermissions(operation, resourceType, context);
      if (!permissionResult.isValid) {
        return permissionResult;
      }

      // Validate data integrity
      final integrityResult = await _validateDataIntegrity(operation, resourceType, resourceId, context);
      if (!integrityResult.isValid) {
        return integrityResult;
      }

      // Check for dependencies (for delete operations)
      if (operation == CriticalOperation.delete) {
        final dependencyResult = await _checkDependencies(resourceType, resourceId);
        if (!dependencyResult.isValid) {
          return dependencyResult;
        }
      }

      return SecurityValidationResult.valid();
    } catch (error, stackTrace) {
      ErrorHandler().handleError(
        error,
        userMessage: 'Erro na validação de segurança',
        type: ErrorType.validation,
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
      );
      
      return SecurityValidationResult.invalid(
        'Erro interno na validação de segurança',
      );
    }
  }

  /// Log a critical operation for audit purposes
  void logCriticalOperation({
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
    required bool success,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    final entry = AuditLogEntry(
      userId: userId,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      success: success,
      errorMessage: errorMessage,
      metadata: metadata ?? {},
    );

    _auditLog.add(entry);

    // Keep only last 1000 entries
    if (_auditLog.length > 1000) {
      _auditLog.removeAt(0);
    }

    // Debug logging
    if (kDebugMode) {
      debugPrint('🔒 AUDIT: ${entry.action} on ${entry.resourceType}:${entry.resourceId} - ${entry.success ? 'SUCCESS' : 'FAILED'}');
    }
  }

  /// Execute a critical operation with full security validation and audit logging
  Future<T> executeCriticalOperation<T>({
    required CriticalOperation operation,
    required String resourceType,
    required String resourceId,
    required Future<T> Function() action,
    String userId = 'system',
    Map<String, dynamic>? context,
  }) async {
    final operationName = operation.toString().split('.').last;
    
    // Validate operation
    final validationResult = await validateCriticalOperation(
      operation: operation,
      resourceType: resourceType,
      resourceId: resourceId,
      context: context,
    );

    if (!validationResult.isValid) {
      // Log failed validation
      logCriticalOperation(
        userId: userId,
        action: operationName,
        resourceType: resourceType,
        resourceId: resourceId,
        success: false,
        errorMessage: validationResult.errorMessage,
      );
      
      throw SecurityException(validationResult.errorMessage ?? 'Validação de segurança falhou');
    }

    // Execute operation with timeout
    try {
      final result = await ErrorHandler().withTimeout(
        action,
        timeout: const Duration(minutes: 2),
        operationName: '$operationName on $resourceType:$resourceId',
      );

      // Log successful operation
      logCriticalOperation(
        userId: userId,
        action: operationName,
        resourceType: resourceType,
        resourceId: resourceId,
        success: true,
        metadata: context,
      );

      return result;
    } catch (error, stackTrace) {
      // Log failed operation
      logCriticalOperation(
        userId: userId,
        action: operationName,
        resourceType: resourceType,
        resourceId: resourceId,
        success: false,
        errorMessage: error.toString(),
        metadata: context,
      );

      ErrorHandler().handleError(
        error,
        userMessage: 'Falha na operação $operationName',
        type: ErrorType.unknown,
        severity: ErrorSeverity.high,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  /// Get audit log for security monitoring
  List<AuditLogEntry> getAuditLog({
    String? userId,
    String? resourceType,
    DateTime? since,
  }) {
    var filtered = _auditLog.where((entry) => true);

    if (userId != null) {
      filtered = filtered.where((entry) => entry.userId == userId);
    }

    if (resourceType != null) {
      filtered = filtered.where((entry) => entry.resourceType == resourceType);
    }

    if (since != null) {
      filtered = filtered.where((entry) => entry.timestamp.isAfter(since));
    }

    return filtered.toList();
  }

  /// Clear audit log
  void clearAuditLog() {
    _auditLog.clear();
  }

  bool _checkRateLimit(CriticalOperation operation, String resourceId) {
    final key = '${operation.toString()}_$resourceId';
    
    if (operation == CriticalOperation.delete) {
      return _deleteRateLimiter.isAllowed(key);
    }
    
    return _generalRateLimiter.isAllowed(key);
  }

  Future<SecurityValidationResult> _validatePermissions(
    CriticalOperation operation,
    String resourceType,
    Map<String, dynamic>? context,
  ) async {
    // Basic permission validation
    // In a real app, this would check user roles, permissions, etc.
    
    // For now, just basic validation
    if (resourceType.isEmpty) {
      return SecurityValidationResult.invalid('Tipo de recurso inválido');
    }

    return SecurityValidationResult.valid();
  }

  Future<SecurityValidationResult> _validateDataIntegrity(
    CriticalOperation operation,
    String resourceType,
    String resourceId,
    Map<String, dynamic>? context,
  ) async {
    // Basic data integrity validation
    if (resourceId.isEmpty) {
      return SecurityValidationResult.invalid('ID do recurso inválido');
    }

    if (resourceId.length < 3) {
      return SecurityValidationResult.invalid('ID do recurso muito curto');
    }

    return SecurityValidationResult.valid();
  }

  Future<SecurityValidationResult> _checkDependencies(
    String resourceType,
    String resourceId,
  ) async {
    // Check if resource has dependencies that would prevent deletion
    // In a real app, this would check database relationships
    
    // For animals, we might check if they have associated records
    if (resourceType == 'animal') {
      // Mock dependency check - in real app would query database
      // Return warnings if there might be dependencies
      return SecurityValidationResult.validWithWarnings([
        'Este animal pode ter registros associados (consultas, medicamentos, etc.)',
      ]);
    }

    return SecurityValidationResult.valid();
  }
}

/// Custom exception for security violations
class SecurityException implements Exception {
  final String message;
  
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}
