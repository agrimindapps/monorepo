import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Sync coordinator service to prevent race conditions and coordinate background operations
///
/// Features:
/// - Prevents multiple sync operations of the same type from running simultaneously
/// - Queues operations to run sequentially
/// - Provides proper error handling and retry logic
/// - Tracks operation status and provides callbacks
/// - Supports different operation types with priority levels
class SyncCoordinatorService {
  static SyncCoordinatorService? _instance;
  static SyncCoordinatorService get instance =>
      _instance ??= SyncCoordinatorService._();

  SyncCoordinatorService._();

  final Map<String, SyncOperation> _activeOperations = {};
  final Queue<SyncOperation> _operationQueue = Queue<SyncOperation>();
  final Map<String, DateTime> _lastOperationTime = {};

  Timer? _queueProcessor;
  bool _isProcessing = false;

  /// Initialize the sync coordinator
  void initialize() {
    // Start the queue processor
    _queueProcessor = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _processQueue(),
    );

    debugPrint('🔄 Sync coordinator initialized');
  }

  /// Execute a sync operation with coordination
  Future<T> executeSyncOperation<T>({
    required String operationType,
    required Future<T> Function() operation,
    int priority = SyncPriority.normal,
    Duration? minimumInterval,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    final completer = Completer<T>();

    // Check if we should throttle this operation
    if (minimumInterval != null) {
      final lastTime = _lastOperationTime[operationType];
      if (lastTime != null) {
        final elapsed = DateTime.now().difference(lastTime);
        if (elapsed < minimumInterval) {
          debugPrint(
            '🚦 Throttling $operationType - too soon (${elapsed.inMilliseconds}ms < ${minimumInterval.inMilliseconds}ms)',
          );
          completer.completeError(
            SyncThrottledException(
              'Operation $operationType is being throttled',
            ),
          );
          return completer.future;
        }
      }
    }

    final syncOp = SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: operationType,
      operation: operation,
      completer: completer,
      priority: priority,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );

    // If operation of this type is already active, queue this one
    if (_activeOperations.containsKey(operationType)) {
      debugPrint('🔄 Queuing $operationType operation (already active)');
      _operationQueue.add(syncOp);
    } else {
      // Execute immediately
      _executeOperation(syncOp);
    }

    return completer.future;
  }

  /// Check if an operation type is currently active
  bool isOperationActive(String operationType) {
    return _activeOperations.containsKey(operationType);
  }

  /// Get the number of queued operations
  int get queuedOperationsCount => _operationQueue.length;

  /// Get active operations count
  int get activeOperationsCount => _activeOperations.length;

  /// Cancel all operations of a specific type
  void cancelOperations(String operationType) {
    // Cancel active operation
    final activeOp = _activeOperations[operationType];
    if (activeOp != null) {
      activeOp.completer.completeError(
        SyncCancelledException('Operation $operationType was cancelled'),
      );
      _activeOperations.remove(operationType);
      debugPrint('❌ Cancelled active operation: $operationType');
    }

    // Remove queued operations of this type
    _operationQueue.removeWhere((op) {
      final shouldRemove = op.type == operationType;
      if (shouldRemove) {
        op.completer.completeError(
          SyncCancelledException(
            'Queued operation $operationType was cancelled',
          ),
        );
        debugPrint('❌ Cancelled queued operation: $operationType');
      }
      return shouldRemove;
    });
  }

  /// Clear all operations
  void clearAllOperations() {
    // Cancel active operations
    for (final op in _activeOperations.values) {
      op.completer.completeError(
        const SyncCancelledException('All operations were cleared'),
      );
    }
    _activeOperations.clear();

    // Cancel queued operations
    while (_operationQueue.isNotEmpty) {
      final op = _operationQueue.removeFirst();
      op.completer.completeError(
        const SyncCancelledException('All operations were cleared'),
      );
    }

    debugPrint('🗑️ All sync operations cleared');
  }

  void _executeOperation<T>(SyncOperation<T> operation) async {
    _activeOperations[operation.type] = operation;
    _lastOperationTime[operation.type] = DateTime.now();

    debugPrint(
      '▶️ Executing ${operation.type} (attempt ${operation.currentRetry + 1}/${operation.maxRetries})',
    );

    try {
      final result = await operation.operation();
      operation.completer.complete(result);
      debugPrint('✅ ${operation.type} completed successfully');
    } catch (error) {
      debugPrint('❌ ${operation.type} failed: $error');

      if (operation.currentRetry < operation.maxRetries - 1) {
        operation.currentRetry++;
        debugPrint(
          '🔄 Retrying ${operation.type} in ${operation.retryDelay.inSeconds}s',
        );

        // Schedule retry
        Timer(operation.retryDelay, () {
          if (_activeOperations.containsKey(operation.type)) {
            _executeOperation(operation);
          }
        });
      } else {
        // Max retries reached
        operation.completer.completeError(error);
        debugPrint(
          '💥 ${operation.type} failed after ${operation.maxRetries} attempts',
        );
      }
    } finally {
      // Only remove from active if not retrying
      if (operation.currentRetry >= operation.maxRetries - 1 ||
          operation.completer.isCompleted) {
        _activeOperations.remove(operation.type);
      }
    }
  }

  void _processQueue() {
    if (_isProcessing || _operationQueue.isEmpty) {
      return;
    }

    _isProcessing = true;

    try {
      // Process operations by priority
      final sortedOps =
          _operationQueue.toList()
            ..sort((a, b) => b.priority.compareTo(a.priority));

      for (final operation in sortedOps) {
        // Check if this operation type is still active
        if (!_activeOperations.containsKey(operation.type)) {
          _operationQueue.remove(operation);
          _executeOperation(operation);
          break; // Process one at a time
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Dispose the sync coordinator
  void dispose() {
    _queueProcessor?.cancel();
    clearAllOperations();
    _lastOperationTime.clear();
    debugPrint('🔄 Sync coordinator disposed');
  }
}

/// Sync operation wrapper
class SyncOperation<T> {
  final String id;
  final String type;
  final Future<T> Function() operation;
  final Completer<T> completer;
  final int priority;
  final int maxRetries;
  final Duration retryDelay;
  int currentRetry;

  SyncOperation({
    required this.id,
    required this.type,
    required this.operation,
    required this.completer,
    required this.priority,
    required this.maxRetries,
    required this.retryDelay,
    this.currentRetry = 0,
  });
}

/// Sync operation priorities
class SyncPriority {
  static const int critical = 1000; // User-initiated operations
  static const int high = 800; // Real-time sync operations
  static const int normal = 500; // Background sync
  static const int low = 200; // Cleanup, analytics
  static const int background = 100; // Non-critical background tasks
}

/// Exception thrown when an operation is throttled
class SyncThrottledException implements Exception {
  final String message;
  const SyncThrottledException(this.message);

  @override
  String toString() => 'SyncThrottledException: $message';
}

/// Exception thrown when an operation is cancelled
class SyncCancelledException implements Exception {
  final String message;
  const SyncCancelledException(this.message);

  @override
  String toString() => 'SyncCancelledException: $message';
}

/// Sync operation types for tasks
class TaskSyncOperations {
  static const String loadTasks = 'load_tasks';
  static const String addTask = 'add_task';
  static const String completeTask = 'complete_task';
  static const String updateTask = 'update_task';
  static const String deleteTask = 'delete_task';
  static const String backgroundSync = 'background_sync';
}
