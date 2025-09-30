import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../services/background_sync_service.dart';
import '../sync/background_sync_status.dart';

/// Provider for managing background synchronization state in the UI
/// Bridges between BackgroundSyncService and UI components
@singleton
class BackgroundSyncProvider extends ChangeNotifier {
  final BackgroundSyncService _backgroundSyncService;

  StreamSubscription<String>? _messageSubscription;
  StreamSubscription<bool>? _progressSubscription;
  StreamSubscription<BackgroundSyncStatus>? _statusSubscription;

  BackgroundSyncProvider(this._backgroundSyncService) {
    _listenToSyncUpdates();
  }

  // Expose service getters
  bool get isSyncInProgress => _backgroundSyncService.isSyncInProgress;
  bool get hasPerformedInitialSync =>
      _backgroundSyncService.hasPerformedInitialSync;
  String get currentSyncMessage => _backgroundSyncService.currentSyncMessage;
  BackgroundSyncStatus get syncStatus => _backgroundSyncService.syncStatus;

  // Expose service streams
  Stream<BackgroundSyncStatus> get syncStatusStream =>
      _backgroundSyncService.syncStatusStream;
  Stream<String> get syncMessageStream =>
      _backgroundSyncService.syncMessageStream;
  Stream<bool> get syncProgressStream =>
      _backgroundSyncService.syncProgressStream;

  /// Listen to sync service updates and propagate to UI
  void _listenToSyncUpdates() {
    _messageSubscription = _backgroundSyncService.syncMessageStream.listen((
      message,
    ) {
      notifyListeners();
    });

    _progressSubscription = _backgroundSyncService.syncProgressStream.listen((
      inProgress,
    ) {
      notifyListeners();
    });

    _statusSubscription = _backgroundSyncService.syncStatusStream.listen((
      status,
    ) {
      notifyListeners();
    });
  }

  /// Starts background sync for authenticated user
  Future<void> startBackgroundSync({
    required String userId,
    bool isInitialSync = false,
  }) async {
    await _backgroundSyncService.startBackgroundSync(
      userId: userId,
      isInitialSync: isInitialSync,
    );
  }

  /// Cancels ongoing sync
  void cancelSync() {
    _backgroundSyncService.cancelSync();
  }

  /// Retries failed sync
  Future<void> retrySync(String userId) async {
    await _backgroundSyncService.retrySync(userId);
  }

  /// Syncs specific data type
  Future<void> syncSpecificData({
    required String userId,
    required String dataType,
  }) async {
    await _backgroundSyncService.syncSpecificData(
      userId: userId,
      dataType: dataType,
    );
  }

  /// Gets detailed operation status
  Map<String, bool> getOperationStatus() {
    return _backgroundSyncService.getOperationStatus();
  }

  /// Checks if specific operation was successful
  bool isOperationSuccessful(String operation) {
    return _backgroundSyncService.isOperationSuccessful(operation);
  }

  /// Resets sync state (useful for logout)
  void resetSyncState() {
    _backgroundSyncService.resetSyncState();
  }

  /// Helper method to check if sync is needed
  bool shouldStartInitialSync(String? userId) {
    return userId != null &&
        userId.isNotEmpty &&
        !hasPerformedInitialSync &&
        !isSyncInProgress;
  }

  /// Helper method to get sync progress percentage
  double getSyncProgress() {
    final operations = getOperationStatus();
    if (operations.isEmpty) return 0.0;

    final completedCount =
        operations.values.where((completed) => completed).length;
    return completedCount / operations.length;
  }

  /// Helper method to get human-readable sync status
  String getSyncStatusMessage() {
    switch (syncStatus) {
      case BackgroundSyncStatus.idle:
        return 'Pronto para sincronizar';
      case BackgroundSyncStatus.syncing:
        return currentSyncMessage;
      case BackgroundSyncStatus.completed:
        return 'Sincronização concluída';
      case BackgroundSyncStatus.error:
        return 'Erro na sincronização';
      case BackgroundSyncStatus.cancelled:
        return 'Sincronização cancelada';
    }
  }

  /// Helper method to determine if sync indicator should be shown
  bool shouldShowSyncIndicator() {
    return isSyncInProgress || syncStatus == BackgroundSyncStatus.error;
  }

  /// Helper method to determine sync indicator color
  String getSyncIndicatorColor() {
    switch (syncStatus) {
      case BackgroundSyncStatus.syncing:
        return 'blue';
      case BackgroundSyncStatus.completed:
        return 'green';
      case BackgroundSyncStatus.error:
        return 'red';
      case BackgroundSyncStatus.cancelled:
        return 'orange';
      case BackgroundSyncStatus.idle:
        return 'grey';
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _progressSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }
}
