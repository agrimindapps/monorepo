import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'secure_storage_service.dart';

/// Service responsável por auditoria de operações de backup
/// Implementa Single Responsibility Principle - apenas logging e auditoria
class BackupAuditService {
  final SecureStorageService _storageService;

  static const String _auditLogKey = 'backup_audit_log';
  static const int _maxLogEntries =
      100; // Limitar logs para evitar crescimento excessivo

  const BackupAuditService({required SecureStorageService storageService})
    : _storageService = storageService;

  /// Cria log de auditoria para operações de backup
  Future<void> logBackupOperation({
    required String operation,
    required String userId,
    String? backupId,
    Map<String, dynamic>? additionalData,
    bool isSuccess = true,
    String? errorMessage,
  }) async {
    try {
      final logEntry = AuditLogEntry(
        id: _generateLogId(),
        timestamp: DateTime.now(),
        operation: operation,
        userId: userId,
        backupId: backupId,
        isSuccess: isSuccess,
        errorMessage: errorMessage,
        additionalData: additionalData ?? {},
      );

      await _addLogEntry(logEntry);

      debugPrint(
        '📋 Audit Log: $operation ${isSuccess ? '✅' : '❌'} - User: $userId',
      );
    } catch (e) {
      debugPrint('❌ Erro ao criar log de auditoria: $e');
      // Não propaga erro para não afetar operação principal
    }
  }

  /// Log específico para criação de backup
  Future<void> logBackupCreation({
    required String userId,
    required String backupId,
    required int itemsCount,
    bool isSuccess = true,
    String? errorMessage,
  }) async {
    await logBackupOperation(
      operation: 'create_backup',
      userId: userId,
      backupId: backupId,
      additionalData: {
        'items_count': itemsCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }

  /// Log específico para restore de backup
  Future<void> logBackupRestore({
    required String userId,
    required String backupId,
    required int itemsRestored,
    required Map<String, int> restoredCounts,
    required String mergeStrategy,
    bool isSuccess = true,
    String? errorMessage,
  }) async {
    await logBackupOperation(
      operation: 'restore_backup',
      userId: userId,
      backupId: backupId,
      additionalData: {
        'items_restored': itemsRestored,
        'restored_counts': restoredCounts,
        'merge_strategy': mergeStrategy,
        'timestamp': DateTime.now().toIso8601String(),
      },
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }

  /// Log específico para rollback de restore
  Future<void> logRestoreRollback({
    required String userId,
    required String backupId,
    required String originalError,
    bool isSuccess = true,
  }) async {
    await logBackupOperation(
      operation: 'rollback_restore',
      userId: userId,
      backupId: backupId,
      additionalData: {
        'original_error': originalError,
        'rollback_timestamp': DateTime.now().toIso8601String(),
      },
      isSuccess: isSuccess,
      errorMessage: isSuccess ? null : 'Falha no rollback',
    );
  }

  /// Log específico para deleção de backup
  Future<void> logBackupDeletion({
    required String userId,
    required String backupId,
    bool isSuccess = true,
    String? errorMessage,
  }) async {
    await logBackupOperation(
      operation: 'delete_backup',
      userId: userId,
      backupId: backupId,
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }

  /// Log específico para limpeza de backups antigos
  Future<void> logBackupCleanup({
    required String userId,
    required int deletedCount,
    required int keepCount,
    bool isSuccess = true,
    String? errorMessage,
  }) async {
    await logBackupOperation(
      operation: 'cleanup_old_backups',
      userId: userId,
      additionalData: {
        'deleted_count': deletedCount,
        'keep_count': keepCount,
        'cleanup_timestamp': DateTime.now().toIso8601String(),
      },
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }

  /// Recupera logs de auditoria
  Future<List<AuditLogEntry>> getAuditLogs({
    String? userId,
    String? operation,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final logs = await _getAllLogs();

      // Aplicar filtros
      var filteredLogs =
          logs.where((log) {
            if (userId != null && log.userId != userId) return false;
            if (operation != null && log.operation != operation) return false;
            if (startDate != null && log.timestamp.isBefore(startDate)) {
              return false;
            }
            if (endDate != null && log.timestamp.isAfter(endDate)) return false;
            return true;
          }).toList();

      // Ordenar por timestamp (mais recente primeiro)
      filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Aplicar limite
      if (limit != null && filteredLogs.length > limit) {
        filteredLogs = filteredLogs.take(limit).toList();
      }

      return filteredLogs;
    } catch (e) {
      debugPrint('❌ Erro ao recuperar logs de auditoria: $e');
      return [];
    }
  }

  /// Limpa logs antigos para evitar crescimento excessivo
  Future<void> cleanupOldLogs({int? maxEntries}) async {
    try {
      final logs = await _getAllLogs();
      final maxAllowed = maxEntries ?? _maxLogEntries;

      if (logs.length <= maxAllowed) return;

      // Manter apenas os logs mais recentes
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final logsToKeep = logs.take(maxAllowed).toList();

      await _saveLogs(logsToKeep);

      debugPrint(
        '🧹 Limpeza de logs: mantidos ${logsToKeep.length} de ${logs.length} logs',
      );
    } catch (e) {
      debugPrint('❌ Erro ao limpar logs antigos: $e');
    }
  }

  /// Gera estatísticas de auditoria
  Future<AuditStatistics> getAuditStatistics({String? userId}) async {
    try {
      final logs = await getAuditLogs(userId: userId);

      final Map<String, int> operationCounts = {};
      int successCount = 0;
      int failureCount = 0;

      for (final log in logs) {
        operationCounts[log.operation] =
            (operationCounts[log.operation] ?? 0) + 1;
        if (log.isSuccess) {
          successCount++;
        } else {
          failureCount++;
        }
      }

      return AuditStatistics(
        totalOperations: logs.length,
        successfulOperations: successCount,
        failedOperations: failureCount,
        operationCounts: operationCounts,
        oldestLogDate: logs.isNotEmpty ? logs.last.timestamp : null,
        newestLogDate: logs.isNotEmpty ? logs.first.timestamp : null,
      );
    } catch (e) {
      debugPrint('❌ Erro ao gerar estatísticas de auditoria: $e');
      return const AuditStatistics.empty();
    }
  }

  // ===== MÉTODOS PRIVADOS =====

  Future<void> _addLogEntry(AuditLogEntry entry) async {
    final logs = await _getAllLogs();
    logs.insert(0, entry); // Adicionar no início (mais recente primeiro)

    // Limitar tamanho da lista
    if (logs.length > _maxLogEntries) {
      logs.removeRange(_maxLogEntries, logs.length);
    }

    await _saveLogs(logs);
  }

  Future<List<AuditLogEntry>> _getAllLogs() async {
    try {
      final logsJson = await _storageService.getString(_auditLogKey);
      if (logsJson == null || logsJson.isEmpty) return [];

      final dynamic logsData = jsonDecode(logsJson);
      final List<dynamic> logsList = logsData is List ? logsData : [];
      return logsList
          .map((json) => AuditLogEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Erro ao carregar logs: $e');
      return [];
    }
  }

  Future<void> _saveLogs(List<AuditLogEntry> logs) async {
    try {
      final logsJson = jsonEncode(logs.map((log) => log.toJson()).toList());
      await _storageService.setString(_auditLogKey, logsJson);
    } catch (e) {
      debugPrint('❌ Erro ao salvar logs: $e');
    }
  }

  String _generateLogId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().toString()}';
  }
}

/// Entrada individual de log de auditoria
class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String operation;
  final String userId;
  final String? backupId;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic> additionalData;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.operation,
    required this.userId,
    this.backupId,
    required this.isSuccess,
    this.errorMessage,
    this.additionalData = const {},
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      operation: json['operation'] as String,
      userId: json['user_id'] as String,
      backupId: json['backup_id'] as String?,
      isSuccess: json['is_success'] as bool,
      errorMessage: json['error_message'] as String?,
      additionalData: json['additional_data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'operation': operation,
      'user_id': userId,
      'backup_id': backupId,
      'is_success': isSuccess,
      'error_message': errorMessage,
      'additional_data': additionalData,
    };
  }
}

/// Estatísticas de auditoria
class AuditStatistics {
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final Map<String, int> operationCounts;
  final DateTime? oldestLogDate;
  final DateTime? newestLogDate;

  const AuditStatistics({
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.operationCounts,
    this.oldestLogDate,
    this.newestLogDate,
  });

  const AuditStatistics.empty()
    : totalOperations = 0,
      successfulOperations = 0,
      failedOperations = 0,
      operationCounts = const {},
      oldestLogDate = null,
      newestLogDate = null;

  double get successRate =>
      totalOperations > 0 ? (successfulOperations / totalOperations) : 0.0;
}
