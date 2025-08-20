/// Interface for resources that require cleanup when no longer needed
abstract class DisposableResource {
  /// Dispose of any resources held by this object
  /// Should be called when the object is no longer needed to prevent memory leaks
  void dispose();

  /// Whether this resource has been disposed
  bool get isDisposed;
}

/// Base implementation of DisposableResource
abstract class BaseDisposableResource implements DisposableResource {
  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (_isDisposed) return;

    onDispose();
    _isDisposed = true;
  }

  /// Override this method to implement custom disposal logic
  void onDispose();

  /// Throws an exception if this resource has been disposed
  void checkNotDisposed() {
    if (_isDisposed) {
      throw StateError('This resource has been disposed and cannot be used');
    }
  }
}
