import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Service centralizado para tracking e logging de erros
/// 
/// Integra com FirebaseAnalytics e futuramente com Crashlytics
/// Implementa diferentes níveis de logging e contexto de erro
@singleton
class ErrorTrackingService {
  final FirebaseAnalyticsService _analyticsService;
  final HiveStorageService _hiveStorageService;
  
  const ErrorTrackingService(
    this._analyticsService,
    this._hiveStorageService,
  );
  
  /// Registra um erro crítico que afeta a funcionalidade principal
  Future<void> logCriticalError(
    String error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
    String? userId,
    String? feature,
  }) async {
    try {
      final errorData = _buildErrorData(
        error: error,
        stackTrace: stackTrace,
        level: 'critical',
        context: context,
        userId: userId,
        feature: feature,
      );
      
      // Log to analytics
      await _analyticsService.logEvent(
        'critical_error',
        parameters: _sanitizeParameters(errorData),
      );
      
      // Store locally for debugging
      await _storeErrorLocally(errorData);
      
      // Print to console in debug mode
      if (kDebugMode) {
        debugPrint('🔴 CRITICAL ERROR: $error');
        if (stackTrace != null) {
          debugPrint('StackTrace: $stackTrace');
        }
      }
    } catch (e) {
      // Silent fail to prevent error loops
      debugPrint('ErrorTrackingService: Failed to log critical error - $e');
    }
  }
  
  /// Registra um erro não crítico que não quebra funcionalidade
  Future<void> logWarning(
    String warning, {
    Map<String, dynamic>? context,
    String? userId,
    String? feature,
  }) async {
    try {
      final warningData = _buildErrorData(
        error: warning,
        level: 'warning',
        context: context,
        userId: userId,
        feature: feature,
      );
      
      // Log to analytics
      await _analyticsService.logEvent(
        'warning',
        parameters: _sanitizeParameters(warningData),
      );
      
      // Print to console in debug mode
      if (kDebugMode) {
        debugPrint('🟡 WARNING: $warning');
      }
    } catch (e) {
      // Silent fail
      debugPrint('ErrorTrackingService: Failed to log warning - $e');
    }
  }
  
  /// Registra informação para debugging
  Future<void> logInfo(
    String info, {
    Map<String, dynamic>? context,
    String? userId,
    String? feature,
  }) async {
    try {
      final infoData = _buildErrorData(
        error: info,
        level: 'info',
        context: context,
        userId: userId,
        feature: feature,
      );
      
      // Only log to analytics in debug mode for info
      if (kDebugMode) {
        await _analyticsService.logEvent(
          'debug_info',
          parameters: _sanitizeParameters(infoData),
        );
        
        debugPrint('ℹ️ INFO: $info');
      }
    } catch (e) {
      // Silent fail
      debugPrint('ErrorTrackingService: Failed to log info - $e');
    }
  }
  
  /// Registra erro de performance
  Future<void> logPerformanceIssue(
    String operation,
    int durationMs, {
    int? threshold,
    Map<String, dynamic>? context,
    String? userId,
    String? feature,
  }) async {
    try {
      final performanceData = _buildErrorData(
        error: 'Performance issue in $operation',
        level: 'performance',
        context: {
          'operation': operation,
          'duration_ms': durationMs,
          'threshold_ms': threshold,
          ...?context,
        },
        userId: userId,
        feature: feature,
      );
      
      await _analyticsService.logEvent(
        'performance_issue',
        parameters: _sanitizeParameters(performanceData),
      );
      
      if (kDebugMode) {
        debugPrint('⚡ PERFORMANCE: $operation took ${durationMs}ms');
      }
    } catch (e) {
      debugPrint('ErrorTrackingService: Failed to log performance issue - $e');
    }
  }
  
  /// Registra erro de network
  Future<void> logNetworkError(
    String endpoint,
    int? statusCode,
    String error, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    try {
      final networkData = _buildErrorData(
        error: 'Network error: $error',
        level: 'network',
        context: {
          'endpoint': endpoint,
          'status_code': statusCode,
          'platform': Platform.operatingSystem,
          ...?context,
        },
        userId: userId,
        feature: 'network',
      );
      
      await _analyticsService.logEvent(
        'network_error',
        parameters: _sanitizeParameters(networkData),
      );
      
      if (kDebugMode) {
        debugPrint('🌐 NETWORK ERROR: $endpoint - $error');
      }
    } catch (e) {
      debugPrint('ErrorTrackingService: Failed to log network error - $e');
    }
  }
  
  /// Registra erro de cache/storage
  Future<void> logStorageError(
    String operation,
    String error, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    try {
      final storageData = _buildErrorData(
        error: 'Storage error: $error',
        level: 'storage',
        context: {
          'operation': operation,
          'platform': Platform.operatingSystem,
          ...?context,
        },
        userId: userId,
        feature: 'storage',
      );
      
      await _analyticsService.logEvent(
        'storage_error',
        parameters: _sanitizeParameters(storageData),
      );
      
      if (kDebugMode) {
        debugPrint('💾 STORAGE ERROR: $operation - $error');
      }
    } catch (e) {
      debugPrint('ErrorTrackingService: Failed to log storage error - $e');
    }
  }
  
  /// Constrói dados estruturados do erro
  Map<String, dynamic> _buildErrorData({
    required String error,
    StackTrace? stackTrace,
    required String level,
    Map<String, dynamic>? context,
    String? userId,
    String? feature,
  }) {
    return {
      'error_message': error,
      'level': level,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'platform_version': Platform.operatingSystemVersion,
      'dart_version': Platform.version,
      'user_id': userId,
      'feature': feature,
      'stack_trace': stackTrace?.toString().substring(0, 1000), // Limit size
      'context': context,
    };
  }
  
  /// Sanitiza parâmetros para analytics (remove dados sensíveis e limita tamanho)
  Map<String, dynamic> _sanitizeParameters(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (entry.value == null) continue;
      
      final key = entry.key;
      final value = entry.value;
      
      // Skip sensitive keys
      if (_isSensitiveKey(key)) continue;
      
      // Limit string length for analytics
      if (value is String && value.length > 500) {
        sanitized[key] = '${value.substring(0, 500)}...';
      } else if (value is Map) {
        // Limit nested objects
        sanitized[key] = _sanitizeNestedMap(value);
      } else {
        sanitized[key] = value;
      }
    }
    
    return sanitized;
  }
  
  Map<String, dynamic> _sanitizeNestedMap(Map<dynamic, dynamic> map) {
    final sanitized = <String, dynamic>{};
    int count = 0;
    
    for (final entry in map.entries) {
      if (count >= 10) break; // Limit nested properties
      
      final key = entry.key.toString();
      final value = entry.value;
      
      if (_isSensitiveKey(key)) continue;
      
      if (value is String && value.length > 100) {
        sanitized[key] = '${value.substring(0, 100)}...';
      } else {
        sanitized[key] = value;
      }
      
      count++;
    }
    
    return sanitized;
  }
  
  bool _isSensitiveKey(String key) {
    const sensitiveKeys = {
      'password',
      'token',
      'secret',
      'key',
      'auth',
      'credential',
      'private',
    };
    
    return sensitiveKeys.any((sensitive) => 
      key.toLowerCase().contains(sensitive)
    );
  }
  
  /// Armazena erro localmente para debugging
  Future<void> _storeErrorLocally(Map<String, dynamic> errorData) async {
    try {
      final errorId = DateTime.now().millisecondsSinceEpoch.toString();
      await _hiveStorageService.put(
        boxName: 'error_logs',
        key: 'error_$errorId',
        value: errorData,
      );
    } catch (e) {
      // Silent fail
      debugPrint('Failed to store error locally: $e');
    }
  }
  
  /// Obtém logs de erro locais para debugging
  Future<List<Map<String, dynamic>>> getLocalErrorLogs({int? limit}) async {
    try {
      final errorBox = await _hiveStorageService.getBox('error_logs');
      final errors = <Map<String, dynamic>>[];
      
      for (final key in errorBox.keys) {
        final errorData = errorBox.get(key);
        if (errorData is Map<String, dynamic>) {
          errors.add(errorData);
        }
      }
      
      // Sort by timestamp desc
      errors.sort((a, b) {
        final timestampA = a['timestamp'] as String?;
        final timestampB = b['timestamp'] as String?;
        
        if (timestampA == null || timestampB == null) return 0;
        
        return timestampB.compareTo(timestampA);
      });
      
      if (limit != null && errors.length > limit) {
        return errors.take(limit).toList();
      }
      
      return errors;
    } catch (e) {
      debugPrint('Failed to get local error logs: $e');
      return [];
    }
  }
  
  /// Limpa logs antigos
  Future<void> clearOldErrorLogs({int maxAge = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: maxAge));
      final errorBox = await _hiveStorageService.getBox('error_logs');
      final keysToDelete = <String>[];
      
      for (final key in errorBox.keys) {
        final errorData = errorBox.get(key) as Map<String, dynamic>?;
        if (errorData != null) {
          final timestampStr = errorData['timestamp'] as String?;
          if (timestampStr != null) {
            final timestamp = DateTime.tryParse(timestampStr);
            if (timestamp != null && timestamp.isBefore(cutoffDate)) {
              keysToDelete.add(key.toString());
            }
          }
        }
      }
      
      for (final key in keysToDelete) {
        await _hiveStorageService.delete(
          boxName: 'error_logs',
          key: key,
        );
      }
      
      debugPrint('Cleared ${keysToDelete.length} old error logs');
    } catch (e) {
      debugPrint('Failed to clear old error logs: $e');
    }
  }
}