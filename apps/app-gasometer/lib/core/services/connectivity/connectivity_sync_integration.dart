import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import 'connectivity_state_manager.dart';

/// Integrates ConnectivityService with UnifiedSyncManager
///
/// Follows SRP: Single responsibility of coordinating connectivity and sync
/// Automatically triggers sync when connectivity is restored
class ConnectivitySyncIntegration {
  ConnectivitySyncIntegration({
    required ConnectivityService connectivityService,
    required ConnectivityStateManager stateManager,
  })  : _connectivityService = connectivityService,
        _stateManager = stateManager;

  final ConnectivityService _connectivityService;
  final ConnectivityStateManager _stateManager;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isInitialized = false;

  /// Initialize connectivity monitoring and sync integration
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log(
        'ConnectivitySyncIntegration already initialized',
        name: 'ConnectivitySync',
      );
      return;
    }

    try {
      // Initialize ConnectivityService
      final initResult = await _connectivityService.initialize();
      initResult.fold(
        (failure) {
          developer.log(
            'Failed to initialize ConnectivityService: ${failure.message}',
            name: 'ConnectivitySync',
          );
        },
        (_) {
          developer.log(
            'ConnectivityService initialized successfully',
            name: 'ConnectivitySync',
          );
        },
      );

      // Load last saved state
      final lastState = await _stateManager.loadState();
      developer.log(
        'Last connectivity state: ${lastState ? "Online" : "Offline"}',
        name: 'ConnectivitySync',
      );

      // Listen to connectivity changes
      _connectivitySubscription = _connectivityService.connectivityStream
          .distinct() // Only emit when value changes
          .listen(
        (isOnline) async {
          developer.log(
            'Connectivity changed: ${isOnline ? "Online" : "Offline"}',
            name: 'ConnectivitySync',
          );

          // Save current state
          await _stateManager.saveState(isOnline);

          // Trigger sync when going online
          if (isOnline) {
            await _triggerAutoSync();
          }
        },
        onError: (Object error) {
          developer.log(
            'Error in connectivity stream: $error',
            name: 'ConnectivitySync',
          );
        },
      );

      _isInitialized = true;

      developer.log(
        'ConnectivitySyncIntegration initialized successfully',
        name: 'ConnectivitySync',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing ConnectivitySyncIntegration: $e',
        name: 'ConnectivitySync',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Trigger automatic sync when connectivity is restored
  Future<void> _triggerAutoSync() async {
    try {
      developer.log(
        'Triggering auto-sync after connectivity restoration',
        name: 'ConnectivitySync',
      );

      // Get UnifiedSyncManager instance
      final syncManager = UnifiedSyncManager.instance;

      // Trigger sync for gasometer app
      // Note: If app is not registered, forceSyncApp will fail gracefully
      await syncManager.forceSyncApp('gasometer');

      developer.log(
        'Auto-sync triggered successfully',
        name: 'ConnectivitySync',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error triggering auto-sync: $e',
        name: 'ConnectivitySync',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - sync errors shouldn't crash the app
    }
  }

  /// Get current connectivity status
  Future<bool> isOnline() async {
    final result = await _connectivityService.isOnline();
    return result.fold(
      (_) => false, // Assume offline on error
      (isOnline) => isOnline,
    );
  }

  /// Force connectivity check
  Future<void> forceConnectivityCheck() async {
    await _connectivityService.forceConnectivityCheck();
  }

  /// Stream of connectivity status
  Stream<bool> get connectivityStream =>
      _connectivityService.connectivityStream;

  /// Dispose resources
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _isInitialized = false;

    developer.log(
      'ConnectivitySyncIntegration disposed',
      name: 'ConnectivitySync',
    );
  }

  /// Check if integration is initialized
  bool get isInitialized => _isInitialized;
}
