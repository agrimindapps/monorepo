/// Financial Sync Service for GasOMeter
/// Provides enhanced sync capabilities with retry mechanism and prioritization for financial data
library;

import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';

import '../../../audit/domain/services/audit_trail_service.dart';
import 'financial_conflict_resolver.dart';
import 'financial_validator.dart';

/// Sync operation result
class FinancialSyncResult {
  const FinancialSyncResult({
    required this.success,
    this.error,
    required this.attemptCount,
    required this.totalTime,
    this.requiresManualReview = false,
    this.warnings = const [],
  });

  factory FinancialSyncResult.success({
    required int attemptCount,
    required Duration totalTime,
    bool requiresManualReview = false,
    List<String> warnings = const [],
  }) {
    return FinancialSyncResult(
      success: true,
      attemptCount: attemptCount,
      totalTime: totalTime,
      requiresManualReview: requiresManualReview,
      warnings: warnings,
    );
  }

  factory FinancialSyncResult.failure({
    required String error,
    required int attemptCount,
    required Duration totalTime,
  }) {
    return FinancialSyncResult(
      success: false,
      error: error,
      attemptCount: attemptCount,
      totalTime: totalTime,
    );
  }
  final bool success;
  final String? error;
  final int attemptCount;
  final Duration totalTime;
  final bool requiresManualReview;
  final List<String> warnings;

  @override
  String toString() {
    if (success) {
      return 'FinancialSyncResult(success: true, attempts: $attemptCount, time: ${totalTime.inMilliseconds}ms, review: $requiresManualReview)';
    } else {
      return 'FinancialSyncResult(success: false, error: $error, attempts: $attemptCount)';
    }
  }
}

// Helper functions for legacy compatibility
// ignore: non_constant_identifier_names
FinancialSyncResult FinancialSyncRight({
  required int attemptCount,
  required Duration totalTime,
  bool requiresManualReview = false,
  List<String> warnings = const [],
}) => FinancialSyncResult.success(
  attemptCount: attemptCount,
  totalTime: totalTime,
  requiresManualReview: requiresManualReview,
  warnings: warnings,
);

/// Sync queue item with priority
class FinancialSyncQueueItem {
  FinancialSyncQueueItem({
    required this.entity,
    required this.priority,
    required this.queuedAt,
    this.retryCount = 0,
    this.lastAttempt,
    this.lastError,
  });
  final BaseSyncEntity entity;
  final int priority;
  final DateTime queuedAt;
  final int retryCount;
  final DateTime? lastAttempt;
  final String? lastError;

  FinancialSyncQueueItem copyWithRetry(String error) {
    return FinancialSyncQueueItem(
      entity: entity,
      priority: priority,
      queuedAt: queuedAt,
      retryCount: retryCount + 1,
      lastAttempt: DateTime.now(),
      lastError: error,
    );
  }

  /// Calculate next retry delay with exponential backoff
  Duration get nextRetryDelay {
    final baseDelay = Duration(
      seconds: min(pow(2, retryCount).toInt(), 300),
    ); // Max 5 minutes
    final jitter = Duration(milliseconds: Random().nextInt(1000)); // Add jitter
    return baseDelay + jitter;
  }

  /// Check if item should be retried
  bool get shouldRetry {
    const maxRetries = 5;
    if (retryCount >= maxRetries) return false;

    if (lastAttempt == null) return true;

    final timeSinceLastAttempt = DateTime.now().difference(lastAttempt!);
    return timeSinceLastAttempt >= nextRetryDelay;
  }

  /// Check if this is a high priority financial item
  bool get isHighPriority => priority >= 3;
}

/// Financial Sync Service
class FinancialSyncService {
  FinancialSyncService({
    required FinancialValidator validator,
    required FinancialAuditTrailService auditService,
    required FinancialConflictResolver conflictResolver,
    required UnifiedSyncManager coreSync,
  }) : // ignore: unused_field
       _auditService = auditService,
       _coreSync = coreSync;
  final FinancialAuditTrailService _auditService;
  final UnifiedSyncManager _coreSync;
  final List<FinancialSyncQueueItem> _syncQueue = [];
  final Map<String, Completer<FinancialSyncResult>> _pendingSyncs = {};
  bool _isSyncing = false;
  Timer? _syncTimer;
  DateTime? _lastSuccessfulSync;
  static const Duration _financialSyncInterval = Duration(
    minutes: 2,
  ); // More frequent for financial data
  static const int _maxConcurrentSyncs = 3;

  /// Initialize the financial sync service
  Future<void> initialize() async {
    _syncTimer = Timer.periodic(
      _financialSyncInterval,
      (_) => _processSyncQueue(),
    );
  }

  /// Queue entity for sync with financial prioritization
  Future<FinancialSyncResult> queueForSync(BaseSyncEntity entity) async {
    final validation = FinancialValidator.validateForSync(entity);
    if (!validation.isValid) {
      await _auditService.logValidationFailure(
        entity,
        errors: validation.errors,
        warnings: validation.warnings,
      );
      return FinancialSyncResult.failure(
        error: 'Validation failed: ${validation.errorMessage}',
        attemptCount: 0,
        totalTime: Duration.zero,
      );
    }
    final priority = _calculatePriority(entity);
    final queueItem = FinancialSyncQueueItem(
      entity: entity,
      priority: priority,
      queuedAt: DateTime.now(),
    );

    _syncQueue.add(queueItem);
    _sortQueue();
    final completer = Completer<FinancialSyncResult>();
    _pendingSyncs[entity.id] = completer;
    if (priority >= 3) {
      unawaited(_processSyncQueue());
    }

    return completer.future;
  }

  /// Force immediate sync for critical financial data
  Future<FinancialSyncResult> syncImmediately(BaseSyncEntity entity) async {
    final stopwatch = Stopwatch()..start();

    try {
      final validation = FinancialValidator.validateForSync(entity);
      if (!validation.isValid) {
        await _auditService.logValidationFailure(
          entity,
          errors: validation.errors,
          warnings: validation.warnings,
        );
        return FinancialSyncResult.failure(
          error: 'Validation failed: ${validation.errorMessage}',
          attemptCount: 1,
          totalTime: stopwatch.elapsed,
        );
      }
      final result = await _performSync(entity);
      await _auditService.logSync(
        entity,
        success: result.success,
        error: result.error,
        syncSource: 'immediate',
      );

      return result.copyWith(totalTime: stopwatch.elapsed);
    } catch (e) {
      final error = 'Immediate sync failed: $e';
      await _auditService.logSync(
        entity,
        success: false,
        error: error,
        syncSource: 'immediate',
      );

      return FinancialSyncResult.failure(
        error: error,
        attemptCount: 1,
        totalTime: stopwatch.elapsed,
      );
    }
  }

  /// Get sync status for entity
  FinancialSyncStatus getSyncStatus(String entityId) {
    if (_pendingSyncs.containsKey(entityId)) {
      return FinancialSyncStatus.syncing;
    }
    final queueItem = _syncQueue
        .where((item) => item.entity.id == entityId)
        .firstOrNull;
    if (queueItem != null) {
      if (queueItem.retryCount > 0) {
        return FinancialSyncStatus.retrying;
      }
      return FinancialSyncStatus.pending;
    }
    return FinancialSyncStatus.synced; // Assume synced if not in our queue
  }

  /// Get pending financial sync count
  int get pendingFinancialSyncCount {
    return _syncQueue
        .where((item) => FinancialValidator.isFinancialData(item.entity))
        .length;
  }

  /// Get high priority pending count
  int get highPriorityPendingCount {
    return _syncQueue.where((item) => item.isHighPriority).length;
  }

  /// Get last sync time
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  /// Process sync queue with retry logic
  Future<void> _processSyncQueue() async {
    if (_isSyncing || _syncQueue.isEmpty) return;

    _isSyncing = true;

    try {
      _sortQueue();
      final itemsToProcess = _syncQueue
          .where((item) => item.shouldRetry)
          .take(_maxConcurrentSyncs)
          .toList();

      final futures = itemsToProcess.map((item) => _processSyncItem(item));
      await Future.wait(futures, eagerError: false);
    } finally {
      _isSyncing = false;
    }
  }

  /// Process individual sync item
  Future<void> _processSyncItem(FinancialSyncQueueItem item) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await _performSync(item.entity);

      if (result.success) {
        _syncQueue.remove(item);
        _lastSuccessfulSync = DateTime.now();

        final completer = _pendingSyncs.remove(item.entity.id);
        completer?.complete(result.copyWith(totalTime: stopwatch.elapsed));

        await _auditService.logSync(
          item.entity,
          success: true,
          syncSource: 'queue',
        );
      } else {
        final retryItem = item.copyWithRetry(result.error ?? 'Unknown error');

        if (retryItem.shouldRetry) {
          final index = _syncQueue.indexOf(item);
          if (index >= 0) {
            _syncQueue[index] = retryItem;
          }
        } else {
          _syncQueue.remove(item);
          final completer = _pendingSyncs.remove(item.entity.id);
          completer?.complete(result.copyWith(totalTime: stopwatch.elapsed));
        }

        await _auditService.logSync(
          item.entity,
          success: false,
          error: result.error,
          syncSource: 'queue',
        );
      }
    } catch (e) {
      final retryItem = item.copyWithRetry('Unexpected error: $e');

      if (retryItem.shouldRetry) {
        final index = _syncQueue.indexOf(item);
        if (index >= 0) {
          _syncQueue[index] = retryItem;
        }
      } else {
        _syncQueue.remove(item);
        final completer = _pendingSyncs.remove(item.entity.id);
        completer?.complete(
          FinancialSyncResult.failure(
            error: 'Max retries exceeded: $e',
            attemptCount: retryItem.retryCount,
            totalTime: stopwatch.elapsed,
          ),
        );
      }
    }
  }

  /// Perform actual sync operation
  Future<FinancialSyncResult> _performSync(BaseSyncEntity entity) async {
    try {
      final result = await _coreSync.forceSyncApp('gasometer');

      return result.fold(
        (failure) => FinancialSyncResult.failure(
          error: failure.message,
          attemptCount: 1,
          totalTime: Duration.zero,
        ),
        (_) => FinancialSyncRight(attemptCount: 1, totalTime: Duration.zero),
      );
    } catch (e) {
      return FinancialSyncResult.failure(
        error: 'Sync exception: $e',
        attemptCount: 1,
        totalTime: Duration.zero,
      );
    }
  }

  /// Calculate priority for entity
  int _calculatePriority(BaseSyncEntity entity) {
    int priority = 1; // Base priority
    if (FinancialValidator.isFinancialData(entity)) {
      priority = 2;
      final importanceLevel = FinancialValidator.getFinancialImportanceLevel(
        entity,
      );
      priority += importanceLevel;
    }
    final age = DateTime.now().difference(
      entity.updatedAt ?? entity.createdAt ?? DateTime.now(),
    );
    if (age.inHours < 1) priority += 1;
    if (entity.isDirty) priority += 1;

    return priority.clamp(1, 5);
  }

  /// Sort queue by priority and age
  void _sortQueue() {
    _syncQueue.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      final retryCompare = a.retryCount.compareTo(b.retryCount);
      if (retryCompare != 0) return retryCompare;
      return a.queuedAt.compareTo(b.queuedAt);
    });
  }

  /// Clear failed items from queue
  void clearFailedItems() {
    _syncQueue.removeWhere((item) => !item.shouldRetry);
  }

  /// Get queue statistics
  Map<String, dynamic> getQueueStats() {
    final financial = _syncQueue.where(
      (item) => FinancialValidator.isFinancialData(item.entity),
    );
    final highPriority = _syncQueue.where((item) => item.isHighPriority);
    final retrying = _syncQueue.where((item) => item.retryCount > 0);

    return {
      'total_queued': _syncQueue.length,
      'financial_queued': financial.length,
      'high_priority_queued': highPriority.length,
      'retrying': retrying.length,
      'last_successful_sync': _lastSuccessfulSync?.toIso8601String(),
      'is_syncing': _isSyncing,
    };
  }

  /// Dispose the service
  void dispose() {
    _syncTimer?.cancel();
    for (final completer in _pendingSyncs.values) {
      if (!completer.isCompleted) {
        completer.complete(
          FinancialSyncResult.failure(
            error: 'Service disposed',
            attemptCount: 0,
            totalTime: Duration.zero,
          ),
        );
      }
    }

    _pendingSyncs.clear();
    _syncQueue.clear();
  }
}

/// Financial sync status enum
enum FinancialSyncStatus {
  synced,
  pending,
  syncing,
  retrying,
  failed,
  validationFailed,
}

/// Extension for FinancialSyncResult
extension FinancialSyncResultExtension on FinancialSyncResult {
  FinancialSyncResult copyWith({
    bool? success,
    String? error,
    int? attemptCount,
    Duration? totalTime,
    bool? requiresManualReview,
    List<String>? warnings,
  }) {
    return FinancialSyncResult(
      success: success ?? this.success,
      error: error ?? this.error,
      attemptCount: attemptCount ?? this.attemptCount,
      totalTime: totalTime ?? this.totalTime,
      requiresManualReview: requiresManualReview ?? this.requiresManualReview,
      warnings: warnings ?? this.warnings,
    );
  }
}
