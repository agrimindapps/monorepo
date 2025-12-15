import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/widgets/feedback/progress_tracker.dart';

part 'progress_tracker_provider.g.dart';

/// State class for progress tracking
class ProgressTrackerState {
  final Map<String, ProgressOperation> activeOperations;
  final int operationCount;

  const ProgressTrackerState({
    this.activeOperations = const {},
    this.operationCount = 0,
  });

  ProgressTrackerState copyWith({
    Map<String, ProgressOperation>? activeOperations,
    int? operationCount,
  }) {
    return ProgressTrackerState(
      activeOperations: activeOperations ?? this.activeOperations,
      operationCount: operationCount ?? this.operationCount,
    );
  }

  bool get hasActiveOperations => activeOperations.isNotEmpty;
  int get activeOperationCount => activeOperations.length;

  ProgressOperation? getOperation(String key) => activeOperations[key];

  List<ProgressOperation> get activeOperationsList =>
      activeOperations.values.toList();
}

/// Riverpod notifier for managing progress tracking state
/// Provides reactive interface to static ProgressTracker
@riverpod
class ProgressTrackerNotifier extends _$ProgressTrackerNotifier {
  @override
  ProgressTrackerState build() {
    // Listen to ProgressTracker changes
    void listener() {
      _updateState();
    }

    ProgressTracker.addListener(listener);

    ref.onDispose(() {
      ProgressTracker.removeListener(listener);
    });

    return _buildState();
  }

  ProgressTrackerState _buildState() {
    final operations = ProgressTracker.activeOperations;

    return ProgressTrackerState(
      activeOperations: operations,
      operationCount: operations.length,
    );
  }

  void _updateState() {
    state = _buildState();
  }

  /// Starts a new progress operation
  ProgressOperation startOperation({
    required String key,
    required String title,
    String? description,
    bool showToast = true,
    bool includeHaptic = true,
  }) {
    final operation = ProgressTracker.startOperation(
      key: key,
      title: title,
      description: description,
      showToast: showToast,
      includeHaptic: includeHaptic,
    );

    _updateState();
    return operation;
  }

  /// Updates progress of an operation
  void updateProgress(
    String key, {
    required double progress,
    String? message,
    String? description,
    bool includeHaptic = false,
  }) {
    ProgressTracker.updateProgress(
      key,
      progress: progress,
      message: message,
      description: description,
      includeHaptic: includeHaptic,
    );

    _updateState();
  }

  /// Completes an operation successfully
  void completeOperation(String key, {String? successMessage}) {
    ProgressTracker.completeOperation(key, successMessage: successMessage);
    _updateState();
  }

  /// Fails an operation
  void failOperation(String key, [String? errorMessage]) {
    ProgressTracker.failOperation(
      key,
      errorMessage: errorMessage ?? 'Erro na operação',
    );
    _updateState();
  }

  /// Pauses an operation
  void pauseOperation(String key) {
    ProgressTracker.pauseOperation(key);
    _updateState();
  }

  /// Resumes an operation
  void resumeOperation(String key) {
    ProgressTracker.resumeOperation(key);
    _updateState();
  }

  /// Cancels an operation
  void cancelOperation(String key) {
    ProgressTracker.cancelOperation(key);
    _updateState();
  }

  /// Gets a specific operation
  ProgressOperation? getOperation(String key) {
    return ProgressTracker.getOperation(key);
  }

  /// Gets all active operations
  List<ProgressOperation> getActiveOperations({bool onlyActive = false}) {
    final operations = ProgressTracker.activeOperations.values.toList();
    if (onlyActive) {
      return operations
          .where((op) => op.state == OperationState.running)
          .toList();
    }
    return operations;
  }

  /// Clears all operations
  void clearAll() {
    ProgressTracker.clearAll();
    _updateState();
  }
}

// =============================================================================
// HELPER PROVIDERS
// =============================================================================

/// Helper provider to check if there are active operations
@riverpod
bool hasActiveOperations(Ref ref) {
  final state = ref.watch(progressTrackerProvider);
  return state.hasActiveOperations;
}

/// Helper provider to get count of active operations
@riverpod
int activeOperationCount(Ref ref) {
  final state = ref.watch(progressTrackerProvider);
  return state.activeOperationCount;
}

/// Helper provider to get specific operation
@riverpod
ProgressOperation? getProgressOperation(Ref ref, String key) {
  final state = ref.watch(progressTrackerProvider);
  return state.getOperation(key);
}

/// Helper provider to get all active operations
@riverpod
List<ProgressOperation> activeProgressOperations(Ref ref) {
  final state = ref.watch(progressTrackerProvider);
  return state.activeOperationsList;
}
