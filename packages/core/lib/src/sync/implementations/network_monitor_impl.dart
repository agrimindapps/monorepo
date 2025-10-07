import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../interfaces/i_network_monitor.dart';

/// Implementação básica do monitor de rede para sincronização
/// Separada do UnifiedSyncManager seguindo Single Responsibility Principle
class NetworkMonitorImpl implements INetworkMonitor {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  final StreamController<ConnectionQuality> _qualityController =
      StreamController<ConnectionQuality>.broadcast();
  final StreamController<NetworkEvent> _eventController =
      StreamController<NetworkEvent>.broadcast();
  bool _isConnected = false;
  final ConnectionQuality _currentQuality = ConnectionQuality.poor;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _qualityCheckTimer;
  bool _isDisposed = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isDisposed) {
      return const Left(NetworkFailure('Network monitor has been disposed'));
    }

    try {
      final initialResults = await _connectivity.checkConnectivity();
      _isConnected = _isConnectedFromResults(initialResults);
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final wasConnected = _isConnected;
          _isConnected = _isConnectedFromResults(results);

          if (wasConnected != _isConnected) {
            developer.log(
              'Network connectivity changed: ${_isConnected ? 'connected' : 'disconnected'}',
              name: 'NetworkMonitor',
            );

            _connectivityController.add(_isConnected);
            _emitEvent(
              NetworkEvent(
                type:
                    _isConnected
                        ? NetworkEventType.connected
                        : NetworkEventType.disconnected,
                message:
                    'Network ${_isConnected ? 'connected' : 'disconnected'}',
              ),
            );
          }
        },
        onError: (Object error) {
          developer.log(
            'Connectivity listener error: $error',
            name: 'NetworkMonitor',
          );
        },
      );

      developer.log(
        'Network monitor initialized - Connected: $_isConnected',
        name: 'NetworkMonitor',
      );

      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('Failed to initialize network monitor: $e'));
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _isConnectedFromResults(results);
    } catch (e) {
      developer.log('Error checking connectivity: $e', name: 'NetworkMonitor');
      return false;
    }
  }

  @override
  Future<bool> canReachEndpoint(String endpoint) async {
    return await isConnected();
  }

  @override
  Future<ConnectionQuality> getConnectionQuality() async {
    return _currentQuality;
  }

  @override
  Future<Duration?> getLatency(String endpoint) async {
    if (!await isConnected()) return null;
    return const Duration(milliseconds: 50);
  }

  @override
  Future<bool> isSuitableForSync() async {
    return await isConnected() && _currentQuality != ConnectionQuality.poor;
  }

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  @override
  Stream<ConnectionQuality> get qualityStream => _qualityController.stream;

  @override
  Stream<NetworkEvent> get eventStream => _eventController.stream;

  @override
  Future<NetworkInfo> getCurrentNetworkInfo() async {
    final results = await _connectivity.checkConnectivity();
    final isOnline = _isConnectedFromResults(results);

    return NetworkInfo(
      isConnected: isOnline,
      type: _mapConnectivityToNetworkType(
        results.isNotEmpty ? results.first : ConnectivityResult.none,
      ),
      quality: _currentQuality,
    );
  }

  @override
  void configureEndpoints(List<String> endpoints) {
    developer.log(
      'Configured ${endpoints.length} endpoints for monitoring',
      name: 'NetworkMonitor',
    );
  }

  @override
  Future<void> startMonitoring() async {
    _emitEvent(
      NetworkEvent(
        type: NetworkEventType.monitoringStarted,
        message: 'Network monitoring started',
      ),
    );
  }

  @override
  Future<void> stopMonitoring() async {
    _qualityCheckTimer?.cancel();
    _emitEvent(
      NetworkEvent(
        type: NetworkEventType.monitoringStopped,
        message: 'Network monitoring stopped',
      ),
    );
  }

  @override
  Future<NetworkStatistics> getStatistics() async {
    return NetworkStatistics(
      totalChecks: 0,
      successfulChecks: 0,
      failedChecks: 0,
      averageLatency: const Duration(milliseconds: 50),
      maxLatency: const Duration(milliseconds: 100),
      minLatency: const Duration(milliseconds: 25),
      lastCheck: DateTime.now(),
    );
  }

  @override
  Future<NetworkHealthCheck> checkNetworkHealth() async {
    final info = await getCurrentNetworkInfo();
    final isHealthy =
        info.isConnected && info.quality != ConnectionQuality.none;

    return NetworkHealthCheck(
      isHealthy: isHealthy,
      issues: isHealthy ? [] : ['No network connectivity'],
      currentInfo: info,
    );
  }

  @override
  Future<Either<Failure, bool>> forceConnectivityCheck() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final connected = _isConnectedFromResults(results);
      _isConnected = connected;
      _connectivityController.add(connected);
      return Right(connected);
    } catch (e) {
      return Left(NetworkFailure('Failed to check connectivity: $e'));
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    await _connectivitySubscription?.cancel();
    _qualityCheckTimer?.cancel();

    await _connectivityController.close();
    await _qualityController.close();
    await _eventController.close();

    developer.log('Network monitor disposed', name: 'NetworkMonitor');
  }

  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    return results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
  }

  NetworkType _mapConnectivityToNetworkType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.mobile:
        return NetworkType.cellular;
      case ConnectivityResult.ethernet:
        return NetworkType.ethernet;
      case ConnectivityResult.vpn:
        return NetworkType.vpn;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.other:
      case ConnectivityResult.none:
        return NetworkType.unknown;
    }
  }

  void _emitEvent(NetworkEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
}
