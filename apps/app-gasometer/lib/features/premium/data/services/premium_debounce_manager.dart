import 'dart:async';


/// Service responsible for debouncing operations
/// Follows SRP by handling only debounce logic

class PremiumDebounceManager {
  final Map<String, Timer> _timers = {};
  final Map<String, Completer<void>> _completers = {};

  /// Debounce an operation with a specific key
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

  /// Debounce an operation without waiting for result
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
  void cancel(String key) {
    _cancelTimer(key);
    final completer = _completers[key];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(DebounceCancelledException(key));
    }
    _completers.remove(key);
  }

  /// Cancel all pending debounces
  void cancelAll() {
    for (final key in _timers.keys.toList()) {
      cancel(key);
    }
  }

  /// Check if a debounce is pending for a key
  bool isPending(String key) {
    return _timers.containsKey(key);
  }

  /// Get pending debounce count
  int get pendingCount => _timers.length;

  /// Execute immediately and cancel debounce
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
  void dispose() {
    cancelAll();
  }
}

/// Exception thrown when debounce is cancelled
class DebounceCancelledException implements Exception {

  DebounceCancelledException(this.key);
  final String key;

  @override
  String toString() => 'Debounce cancelled for key: $key';
}
