import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/interfaces/network_info.dart';

/// Service responsible for monitoring connectivity changes
/// Extracted from PlantsRepository to follow Single Responsibility Principle (SRP)
@injectable
class PlantsConnectivityMonitor {
  PlantsConnectivityMonitor({required this.networkInfo});

  final NetworkInfo networkInfo;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isMonitoring = false;

  bool get isMonitoring => _isMonitoring;

  /// Initialize real-time connectivity monitoring
  void startMonitoring(Function(bool) onConnectivityChanged) {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced == null) {
        logger.debug('Basic NetworkInfo - real-time monitoring unavailable');
        return;
      }

      _connectivitySubscription = enhanced.connectivityStream.listen(
        (isConnected) {
          logger.debug(
            'Connectivity changed - ${isConnected ? 'Online' : 'Offline'}',
          );
          onConnectivityChanged(isConnected);
        },
        onError: (Object error) {
          logger.warning('Connectivity monitoring error', error: error);
        },
      );

      _isMonitoring = true;
      logger.info('Real-time connectivity monitoring started');
    } catch (e) {
      logger.error('Failed to start connectivity monitoring', error: e);
    }
  }

  /// Stop connectivity monitoring and cleanup resources
  Future<void> stopMonitoring() async {
    try {
      if (_connectivitySubscription != null) {
        await _connectivitySubscription!.cancel();
        _connectivitySubscription = null;
        _isMonitoring = false;

        logger.info('Connectivity monitoring stopped');
      }
    } catch (e) {
      logger.error('Error stopping connectivity monitoring', error: e);
    }
  }

  /// Get current connectivity status
  Future<Map<String, dynamic>> getConnectivityStatus() async {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced != null) {
        final status = await enhanced.detailedStatus;
        return {...?status, 'monitoring_active': _isMonitoring};
      } else {
        final isConnected = await networkInfo.isConnected;
        return {
          'is_online': isConnected,
          'monitoring_active': false,
          'adapter_type': 'basic',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      return {
        'error': e.toString(),
        'monitoring_active': _isMonitoring,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
