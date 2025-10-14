import 'dart:async';

/// Interface for services that require cleanup on disposal
///
/// Services that manage resources (streams, timers, subscriptions, etc.)
/// should implement this interface to ensure proper cleanup.
///
/// Usage:
/// ```dart
/// class MyService implements IDisposableService {
///   final StreamController _controller = StreamController.broadcast();
///   Timer? _timer;
///   bool _disposed = false;
///
///   @override
///   Future<void> dispose() async {
///     if (_disposed) return;
///     _disposed = true;
///
///     await _controller.close();
///     _timer?.cancel();
///   }
///
///   @override
///   bool get isDisposed => _disposed;
/// }
/// ```
abstract class IDisposableService {
  /// Disposes resources held by this service
  ///
  /// Should be idempotent (safe to call multiple times)
  /// Should not throw exceptions
  Future<void> dispose();

  /// Whether this service has been disposed
  bool get isDisposed;
}

/// Mixin to help implement IDisposableService
///
/// Provides standard dispose flag management
mixin DisposableServiceMixin implements IDisposableService {
  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  /// Mark service as disposed
  ///
  /// Call this at the START of your dispose() implementation
  void markDisposed() {
    _isDisposed = true;
  }

  /// Helper to dispose a StreamController safely
  Future<void> disposeStreamController(StreamController? controller) async {
    try {
      await controller?.close();
    } catch (e) {
      // Ignore errors when closing controllers
      // (they may already be closed)
    }
  }

  /// Helper to cancel a Timer safely
  void disposeTimer(Timer? timer) {
    try {
      timer?.cancel();
    } catch (e) {
      // Ignore errors when canceling timers
    }
  }

  /// Helper to cancel a StreamSubscription safely
  Future<void> disposeSubscription(StreamSubscription? subscription) async {
    try {
      await subscription?.cancel();
    } catch (e) {
      // Ignore errors when canceling subscriptions
    }
  }

  /// Helper to dispose multiple resources at once
  Future<void> disposeAll({
    List<StreamController>? controllers,
    List<Timer>? timers,
    List<StreamSubscription>? subscriptions,
  }) async {
    // Dispose in parallel for efficiency
    await Future.wait([
      ...?controllers?.map(disposeStreamController),
      ...?subscriptions?.map(disposeSubscription),
    ]);

    timers?.forEach(disposeTimer);
  }
}
