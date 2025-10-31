import 'dart:async';

import 'package:injectable/injectable.dart';

/// Service responsible for debouncing subscription sync operations
///
/// Prevents excessive sync calls by delaying execution until a quiet period.
/// Useful for:
/// - Batching rapid subscription updates
/// - Reducing API calls during multi-source sync
/// - Preventing race conditions
///
/// Configuration via [AdvancedSyncConfiguration.debounceDuration]
@lazySingleton
class SubscriptionDebounceManager {
  final Map<String, Timer> _timers = {};
  final Map<String, Completer<void>> _completers = {};

  /// Debounce a subscription sync operation with a specific key
  ///
  /// If called multiple times with the same key, only the last operation
  /// will be executed after [duration] has passed without new calls.
  ///
  /// Example:
  /// ```dart
  /// await debounceManager.debounce(
  ///   key: 'sync-revenueCat',
  ///   duration: Duration(seconds: 2),
  ///   operation: () => syncService.forceSync(),
  /// );
  /// ```
  Future<void> debounce({
    required String key,
    required Duration duration,
    required Future<void> Function() operation,
  }) async {
    // Cancel existing timer if any
    _cancelTimer(key);

    // Create completer for this operation
    final completer = Completer<void>();
    _completers[key] = completer;

    // Create new timer
    _timers[key] = Timer(duration, () async {
      try {
        await operation();
        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      } finally {
        _timers.remove(key);
        _completers.remove(key);
      }
    });

    return completer.future;
  }

  /// Debounce a void operation (fire-and-forget)
  ///
  /// Similar to [debounce] but doesn't wait for completion.
  /// Useful for logging or non-critical operations.
  void debounceVoid({
    required String key,
    required Duration duration,
    required void Function() operation,
  }) {
    // Cancel existing timer if any
    _cancelTimer(key);

    // Create new timer
    _timers[key] = Timer(duration, () {
      try {
        operation();
      } finally {
        _timers.remove(key);
      }
    });
  }

  /// Cancel debounce for a specific key
  ///
  /// The pending operation will not be executed and will throw
  /// [DebounceCancelledException] if awaited.
  void cancel(String key) {
    _cancelTimer(key);
    final completer = _completers[key];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(DebounceCancelledException(key));
    }
    _completers.remove(key);
  }

  /// Cancel all pending debounces
  ///
  /// Useful during cleanup or when forcing immediate sync.
  void cancelAll() {
    for (final key in _timers.keys.toList()) {
      cancel(key);
    }
  }

  /// Check if a debounce is pending for a key
  bool isPending(String key) {
    return _timers.containsKey(key);
  }

  /// Get count of pending debounce operations
  int get pendingCount => _timers.length;

  /// Execute operation immediately and cancel any pending debounce
  ///
  /// Useful for user-initiated actions that should bypass debounce:
  /// ```dart
  /// await debounceManager.executeImmediately(
  ///   key: 'sync-revenueCat',
  ///   operation: () => syncService.forceSync(),
  /// );
  /// ```
  Future<void> executeImmediately({
    required String key,
    required Future<void> Function() operation,
  }) async {
    cancel(key);
    await operation();
  }

  void _cancelTimer(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Dispose all timers
  ///
  /// Should be called when the service is no longer needed.
  void dispose() {
    cancelAll();
  }
}

/// Exception thrown when a debounced operation is cancelled
class DebounceCancelledException implements Exception {
  final String key;

  DebounceCancelledException(this.key);

  @override
  String toString() => 'Debounce cancelled for key: $key';
}
