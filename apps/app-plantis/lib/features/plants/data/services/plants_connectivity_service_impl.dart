import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/data/adapters/network_info_adapter.dart';
import '../../../../core/interfaces/network_info.dart';
import '../../domain/services/plants_connectivity_service.dart';

class PlantsConnectivityServiceImpl implements PlantsConnectivityService {
  PlantsConnectivityServiceImpl({required this.networkInfo}) {
    // Initialize monitoring in constructor
    startMonitoring();
  }

  final NetworkInfo networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isMonitoring = false;

  @override
  void startMonitoring() {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced == null) {
        if (kDebugMode) {
          debugPrint(
            'ℹ️ PlantsConnectivityService: Basic NetworkInfo - real-time monitoring unavailable',
          );
        }
        return;
      }

      _connectivitySubscription = enhanced.connectivityStream.listen(
        _onConnectivityChanged,
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ PlantsConnectivityService: Connectivity monitoring error: $error',
            );
          }
        },
      );

      _isMonitoring = true;

      if (kDebugMode) {
        debugPrint(
          '✅ PlantsConnectivityService: Real-time connectivity monitoring started',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          debugPrint(
            '❌ PlantsConnectivityService: Failed to start connectivity monitoring: $e',
          );
        }
      }
    }
  }

  @override
  Future<void> stopMonitoring() async {
    try {
      if (_connectivitySubscription != null) {
        await _connectivitySubscription!.cancel();
        _connectivitySubscription = null;
        _isMonitoring = false;

        if (kDebugMode) {
          debugPrint(
            '✅ PlantsConnectivityService: Connectivity monitoring stopped',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          debugPrint(
            '❌ PlantsConnectivityService: Error stopping connectivity monitoring: $e',
          );
        }
      }
    }
  }

  @override
  bool get isMonitoring => _isMonitoring;

  @override
  Future<Map<String, dynamic>> getConnectivityStatus() async {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced != null) {
        final status = await enhanced.detailedStatus;
        return {
          ...?status,
          'monitoring_active': _isMonitoring,
          'service': 'PlantsConnectivityService',
        };
      } else {
        final isConnected = await networkInfo.isConnected;
        return {
          'is_online': isConnected,
          'monitoring_active': false,
          'service': 'PlantsConnectivityService',
          'adapter_type': 'basic',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      return {
        'error': e.toString(),
        'monitoring_active': _isMonitoring,
        'service': 'PlantsConnectivityService',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  void _onConnectivityChanged(bool isConnected) {
    if (kDebugMode) {
      debugPrint(
        '🔄 PlantsConnectivityService: Connectivity changed - ${isConnected ? 'Online' : 'Offline'}',
      );
    }
  }
}
