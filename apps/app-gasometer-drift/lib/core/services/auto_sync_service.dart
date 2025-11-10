import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

/// Service responsible for automatic periodic synchronization
///
/// Follows SRP: Single responsibility of managing periodic background sync
/// Uses Timer-based approach for foreground sync (simple and effective for MVP)
///
/// Features:
/// - Periodic sync every 3 minutes when app is in foreground
/// - Immediate sync on service start
/// - Prevents concurrent syncs (mutex-like behavior)
/// - Respects connectivity status
/// - Lifecycle-aware (can be paused/resumed)
class AutoSyncService {
  AutoSyncService({required ConnectivityService connectivityService})
    : _connectivityService = connectivityService;

  final ConnectivityService _connectivityService;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isInitialized = false;

  // Configuration
  static const Duration _syncInterval = Duration(minutes: 3);
  static const String _appId = 'gasometer';

  /// Initialize the auto-sync service
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('AutoSyncService already initialized', name: 'AutoSync');
      return;
    }

    _isInitialized = true;

    developer.log(
      'AutoSyncService initialized (interval: $_syncInterval)',
      name: 'AutoSync',
    );
  }

  /// Start periodic auto-sync
  void start() {
    if (!_isInitialized) {
      developer.log('Cannot start - service not initialized', name: 'AutoSync');
      return;
    }

    if (_syncTimer != null) {
      developer.log('Auto-sync already running', name: 'AutoSync');
      return;
    }

    developer.log(
      'Starting auto-sync with $_syncInterval interval',
      name: 'AutoSync',
    );

    // Start periodic timer
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _performSync();
    });

    // Trigger immediate initial sync
    _performSync();
  }

  /// Stop periodic auto-sync
  void stop() {
    if (_syncTimer == null) {
      return;
    }

    developer.log('Stopping auto-sync', name: 'AutoSync');

    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Pause auto-sync (when app goes to background)
  void pause() {
    if (_syncTimer == null) {
      return;
    }

    developer.log('Pausing auto-sync (app backgrounded)', name: 'AutoSync');

    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Resume auto-sync (when app returns to foreground)
  void resume() {
    if (_syncTimer != null) {
      // Already running
      return;
    }

    developer.log('Resuming auto-sync (app foregrounded)', name: 'AutoSync');

    start();
  }

  /// Force immediate sync (manual trigger)
  Future<void> syncNow() async {
    developer.log('Manual sync triggered', name: 'AutoSync');

    await _performSync();
  }

  /// Perform sync operation with guards
  Future<void> _performSync() async {
    // Guard: Prevent concurrent syncs
    if (_isSyncing) {
      developer.log('Sync already in progress, skipping', name: 'AutoSync');
      return;
    }

    // Guard: Check connectivity
    final connectivityResult = await _connectivityService.isOnline();
    final isOnline = connectivityResult.fold(
      (_) => false, // Treat errors as offline
      (online) => online,
    );

    if (!isOnline) {
      developer.log('Device offline, skipping sync', name: 'AutoSync');
      return;
    }

    try {
      _isSyncing = true;

      developer.log('Starting background sync for $_appId', name: 'AutoSync');

      // Trigger sync via BackgroundSyncManager
      // O GasometerSyncService está registrado no BackgroundSyncManager
      await BackgroundSyncManager.instance.triggerSync(
        _appId,
        force: true, // Força sync mesmo se throttled
      );

      developer.log('Background sync triggered successfully', name: 'AutoSync');
    } catch (e, stackTrace) {
      developer.log(
        'Background sync failed: $e',
        name: 'AutoSync',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - background sync errors shouldn't crash the app
    } finally {
      _isSyncing = false;
    }
  }

  /// Check if auto-sync is currently running
  bool get isRunning => _syncTimer != null;

  /// Check if sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Dispose resources
  void dispose() {
    developer.log('Disposing AutoSyncService', name: 'AutoSync');

    stop();
    _isInitialized = false;
  }
}
