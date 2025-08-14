/// Enhanced loading state management for complex operations
/// Following Single Responsibility Principle (SOLID)
enum LoadingStateType {
  idle,
  loading,
  refreshing,
  loadingMore,
  success,
  error,
  partialError,
  cached,
}

class LoadingState {
  final LoadingStateType type;
  final String? message;
  final String? errorMessage;
  final double? progress;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  LoadingState({
    required this.type,
    this.message,
    this.errorMessage,
    this.progress,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructors for common states
  factory LoadingState.idle([String? message]) {
    return LoadingState(
      type: LoadingStateType.idle,
      message: message,
    );
  }

  factory LoadingState.loading([String? message, double? progress]) {
    return LoadingState(
      type: LoadingStateType.loading,
      message: message ?? 'Carregando...',
      progress: progress,
    );
  }

  factory LoadingState.refreshing([String? message]) {
    return LoadingState(
      type: LoadingStateType.refreshing,
      message: message ?? 'Atualizando...',
    );
  }

  factory LoadingState.loadingMore([String? message]) {
    return LoadingState(
      type: LoadingStateType.loadingMore,
      message: message ?? 'Carregando mais...',
    );
  }

  factory LoadingState.success([String? message, Map<String, dynamic>? metadata]) {
    return LoadingState(
      type: LoadingStateType.success,
      message: message ?? 'Carregado com sucesso',
      metadata: metadata,
    );
  }

  factory LoadingState.error(String errorMessage, [Map<String, dynamic>? metadata]) {
    return LoadingState(
      type: LoadingStateType.error,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }

  factory LoadingState.partialError(String errorMessage, [String? successMessage]) {
    return LoadingState(
      type: LoadingStateType.partialError,
      message: successMessage,
      errorMessage: errorMessage,
    );
  }

  factory LoadingState.cached([String? message, Map<String, dynamic>? metadata]) {
    return LoadingState(
      type: LoadingStateType.cached,
      message: message ?? 'Dados em cache',
      metadata: metadata,
    );
  }

  /// Convenience getters
  bool get isIdle => type == LoadingStateType.idle;
  bool get isLoading => type == LoadingStateType.loading;
  bool get isRefreshing => type == LoadingStateType.refreshing;
  bool get isLoadingMore => type == LoadingStateType.loadingMore;
  bool get isSuccess => type == LoadingStateType.success;
  bool get isError => type == LoadingStateType.error;
  bool get isPartialError => type == LoadingStateType.partialError;
  bool get isCached => type == LoadingStateType.cached;
  
  bool get hasError => isError || isPartialError;
  bool get isProcessing => isLoading || isRefreshing || isLoadingMore;
  bool get hasData => isSuccess || isCached || isPartialError;

  /// Copy with modifications
  LoadingState copyWith({
    LoadingStateType? type,
    String? message,
    String? errorMessage,
    double? progress,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return LoadingState(
      type: type ?? this.type,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message,
      'errorMessage': errorMessage,
      'progress': progress,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory LoadingState.fromJson(Map<String, dynamic> json) {
    return LoadingState(
      type: LoadingStateType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LoadingStateType.idle,
      ),
      message: json['message'] as String?,
      errorMessage: json['errorMessage'] as String?,
      progress: (json['progress'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadingState &&
        other.type == type &&
        other.message == message &&
        other.errorMessage == errorMessage &&
        other.progress == progress;
  }

  @override
  int get hashCode {
    return Object.hash(type, message, errorMessage, progress);
  }

  @override
  String toString() {
    return 'LoadingState(type: $type, message: $message, error: $errorMessage, progress: $progress)';
  }
}

/// Manager for multiple loading states
class LoadingStateManager {
  final Map<String, LoadingState> _states = {};

  /// Set state for a specific operation
  void setState(String operation, LoadingState state) {
    _states[operation] = state;
  }

  /// Get state for a specific operation
  LoadingState getState(String operation) {
    return _states[operation] ?? LoadingState.idle();
  }

  /// Check if any operation is loading
  bool get hasLoadingOperations {
    return _states.values.any((state) => state.isProcessing);
  }

  /// Check if any operation has errors
  bool get hasErrors {
    return _states.values.any((state) => state.hasError);
  }

  /// Get all error messages
  List<String> get errorMessages {
    return _states.values
        .where((state) => state.hasError)
        .map((state) => state.errorMessage!)
        .toList();
  }

  /// Clear state for operation
  void clearState(String operation) {
    _states.remove(operation);
  }

  /// Clear all states
  void clearAll() {
    _states.clear();
  }

  /// Get all operations
  List<String> get operations => _states.keys.toList();

  /// Get states map (readonly)
  Map<String, LoadingState> get states => Map.unmodifiable(_states);
}