import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:gasometer/core/services/gasometer_analytics_service.dart';
import '../entities/log_entry.dart';
import '../repositories/log_repository.dart';

/// Serviço centralizado de logging para o Gasometer
/// Integra com Analytics, Crashlytics e persistência local
@lazySingleton
class LoggingService {
  
  LoggingService(
    this._logRepository,
    this._analyticsService,
  );
  final LogRepository _logRepository;
  final GasometerAnalyticsService _analyticsService;

  String? _currentUserId;
  final Map<String, DateTime> _operationStartTimes = {};

  /// Define o usuário atual para contexto dos logs
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Log de início de operação com tracking de performance
  Future<void> logOperationStart({
    required String category,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final operationKey = '${category}_$operation';
    _operationStartTimes[operationKey] = DateTime.now();

    final logEntry = LogEntry.operationStart(
      category: category,
      operation: operation,
      message: message,
      userId: _currentUserId,
      metadata: metadata,
    );

    await _saveLog(logEntry);
    
    if (kDebugMode) {
      debugPrint('🚀 [$category] Starting $operation: $message');
    }
  }

  /// Log de sucesso de operação com duração calculada
  Future<void> logOperationSuccess({
    required String category,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final operationKey = '${category}_$operation';
    final startTime = _operationStartTimes.remove(operationKey);
    final duration = startTime != null 
        ? DateTime.now().difference(startTime).inMilliseconds 
        : null;

    final logEntry = LogEntry.operationSuccess(
      category: category,
      operation: operation,
      message: message,
      userId: _currentUserId,
      metadata: {
        ...?metadata,
        if (duration != null) 'duration_ms': duration,
      },
      duration: duration,
    );

    await _saveLog(logEntry);
    
    // Send performance analytics
    await _analyticsService.logEvent('operation_completed', {
      'category': category,
      'operation': operation,
      if (duration != null) 'duration_ms': duration,
      'success': true,
    });
    
    if (kDebugMode) {
      final durationText = duration != null ? ' (${duration}ms)' : '';
      debugPrint('✅ [$category] Completed $operation$durationText: $message');
    }
  }

  /// Log de erro em operação com stack trace
  Future<void> logOperationError({
    required String category,
    required String operation,
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    final operationKey = '${category}_$operation';
    final startTime = _operationStartTimes.remove(operationKey);
    final duration = startTime != null 
        ? DateTime.now().difference(startTime).inMilliseconds 
        : null;

    final logEntry = LogEntry.operationError(
      category: category,
      operation: operation,
      message: message,
      userId: _currentUserId,
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      metadata: {
        ...?metadata,
        if (duration != null) 'duration_ms': duration,
      },
      duration: duration,
    );

    await _saveLog(logEntry);
    
    // Send error analytics
    await _analyticsService.logEvent('operation_error', {
      'category': category,
      'operation': operation,
      'error_type': error.runtimeType.toString(),
      if (duration != null) 'duration_ms': duration,
    });
    
    // Record error in Crashlytics
    await _analyticsService.recordError(
      error,
      stackTrace,
      reason: 'Operation error: $category.$operation',
      customKeys: {
        'category': category,
        'operation': operation,
        'user_id': _currentUserId ?? 'unknown',
        if (metadata != null) ...metadata.map((k, v) => MapEntry(k, v?.toString() ?? 'null')),
      },
    );
    
    if (kDebugMode) {
      final durationText = duration != null ? ' (${duration}ms)' : '';
      debugPrint('❌ [$category] Failed $operation$durationText: $message');
      debugPrint('   Error: $error');
    }
  }

  /// Log de warning em operação
  Future<void> logOperationWarning({
    required String category,
    required String operation,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final operationKey = '${category}_$operation';
    final startTime = _operationStartTimes[operationKey];
    final duration = startTime != null 
        ? DateTime.now().difference(startTime).inMilliseconds 
        : null;

    final logEntry = LogEntry.operationWarning(
      category: category,
      operation: operation,
      message: message,
      userId: _currentUserId,
      metadata: {
        ...?metadata,
        if (duration != null) 'duration_ms': duration,
      },
      duration: duration,
    );

    await _saveLog(logEntry);
    
    if (kDebugMode) {
      debugPrint('⚠️ [$category] Warning in $operation: $message');
    }
  }

  /// Log informativo genérico
  Future<void> logInfo({
    required String category,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.info.name,
      category: category,
      operation: 'INFO',
      message: message,
      userId: _currentUserId,
      metadata: metadata,
    );

    await _saveLog(logEntry);
    
    if (kDebugMode) {
      debugPrint('ℹ️ [$category] $message');
    }
  }

  /// Log de debug (só salva em debug mode)
  Future<void> logDebug({
    required String category,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    if (!kDebugMode) return;

    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.debug.name,
      category: category,
      operation: 'DEBUG',
      message: message,
      userId: _currentUserId,
      metadata: metadata,
    );

    await _saveLog(logEntry);
    debugPrint('🐛 [$category] $message');
  }

  // === MÉTODOS ESPECÍFICOS DO GASOMETER ===

  /// Log para operações de veículos
  Future<void> logVehicleOperation({
    required String operation,
    required String message,
    String? vehicleId,
    Map<String, dynamic>? metadata,
  }) async {
    await logOperationStart(
      category: LogCategory.vehicles,
      operation: operation,
      message: message,
      metadata: {
        if (vehicleId != null) 'vehicle_id': vehicleId,
        ...?metadata,
      },
    );
  }

  /// Log para operações de manutenção
  Future<void> logMaintenanceOperation({
    required String operation,
    required String message,
    String? vehicleId,
    String? maintenanceId,
    Map<String, dynamic>? metadata,
  }) async {
    await logOperationStart(
      category: LogCategory.maintenance,
      operation: operation,
      message: message,
      metadata: {
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (maintenanceId != null) 'maintenance_id': maintenanceId,
        ...?metadata,
      },
    );
  }

  /// Log para operações de despesas
  Future<void> logExpenseOperation({
    required String operation,
    required String message,
    String? vehicleId,
    String? expenseId,
    Map<String, dynamic>? metadata,
  }) async {
    await logOperationStart(
      category: LogCategory.expenses,
      operation: operation,
      message: message,
      metadata: {
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (expenseId != null) 'expense_id': expenseId,
        ...?metadata,
      },
    );
  }

  /// Log para operações de odômetro
  Future<void> logOdometerOperation({
    required String operation,
    required String message,
    String? vehicleId,
    int? reading,
    Map<String, dynamic>? metadata,
  }) async {
    await logOperationStart(
      category: LogCategory.odometer,
      operation: operation,
      message: message,
      metadata: {
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (reading != null) 'odometer_reading': reading,
        ...?metadata,
      },
    );
  }

  /// Log para operações de combustível
  Future<void> logFuelOperation({
    required String operation,
    required String message,
    String? vehicleId,
    String? fuelId,
    Map<String, dynamic>? metadata,
  }) async {
    await logOperationStart(
      category: LogCategory.fuel,
      operation: operation,
      message: message,
      metadata: {
        if (vehicleId != null) 'vehicle_id': vehicleId,
        if (fuelId != null) 'fuel_id': fuelId,
        ...?metadata,
      },
    );
  }

  // === MÉTODOS DE CONSULTA ===

  /// Obtém estatísticas dos logs
  Future<Map<String, dynamic>?> getStatistics() async {
    final result = await _logRepository.getLogStatistics();
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ Failed to get log statistics: ${failure.toString()}');
        }
        return null;
      },
      (stats) => stats,
    );
  }

  /// Obtém logs com erro
  Future<List<LogEntry>> getErrorLogs() async {
    final result = await _logRepository.getErrorLogs();
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ Failed to get error logs: ${failure.toString()}');
        }
        return <LogEntry>[];
      },
      (logs) => logs,
    );
  }

  /// Limpa logs antigos
  Future<bool> cleanOldLogs({int daysToKeep = 30}) async {
    final result = await _logRepository.cleanOldLogs(daysToKeep: daysToKeep);
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ Failed to clean old logs: ${failure.toString()}');
        }
        return false;
      },
      (_) {
        if (kDebugMode) {
          debugPrint('✅ Cleaned logs older than $daysToKeep days');
        }
        return true;
      },
    );
  }

  /// Exporta logs para JSON
  Future<String?> exportLogsToJson() async {
    final result = await _logRepository.exportLogsToJson();
    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ Failed to export logs: ${failure.toString()}');
        }
        return null;
      },
      (jsonString) => jsonString,
    );
  }

  /// Força sincronização de logs pendentes
  Future<bool> forceSyncLogs() async {
    final unsyncedResult = await _logRepository.getUnsyncedLogs();
    
    return unsyncedResult.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ Failed to get unsynced logs: ${failure.toString()}');
        }
        return false;
      },
      (unsyncedLogs) async {
        if (unsyncedLogs.isEmpty) {
          if (kDebugMode) {
            debugPrint('✅ No logs to sync');
          }
          return true;
        }

        final syncResult = await _logRepository.syncLogsToRemote(unsyncedLogs);
        return syncResult.fold(
          (failure) {
            if (kDebugMode) {
              debugPrint('❌ Failed to sync logs: ${failure.toString()}');
            }
            return false;
          },
          (_) {
            if (kDebugMode) {
              debugPrint('✅ Synced ${unsyncedLogs.length} logs');
            }
            return true;
          },
        );
      },
    );
  }

  // === MÉTODOS PRIVADOS ===

  /// Salva log localmente com tratamento de erro
  Future<void> _saveLog(LogEntry logEntry) async {
    try {
      final result = await _logRepository.saveLog(logEntry);
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Failed to save log: ${failure.toString()}');
          }
        },
        (_) {
          // Log salvo com sucesso
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error saving log: $e');
      }
    }
  }
}