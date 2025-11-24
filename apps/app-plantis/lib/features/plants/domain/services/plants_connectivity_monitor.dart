import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/interfaces/network_info.dart';

/// Service responsible for monitoring connectivity changes
/// Extracted from PlantsRepository to follow Single Responsibility Principle (SRP)
class PlantsConnectivityMonitor {
  PlantsConnectivityMonitor({required this.networkInfo});

  final NetworkInfo networkInfo;

  Timer? _pollTimer;
  bool _isMonitoring = false;

  bool get isMonitoring => _isMonitoring;

  /// Initialize real-time connectivity monitoring
  void startMonitoring(void Function(bool) onConnectivityChanged) {
    try {
      // Start polling connectivity status since NetworkInfo only provides isConnected Future
      _startPolling(onConnectivityChanged);

      _isMonitoring = true;
      debugPrint('✅ Connectivity monitoring started');
    } catch (e) {
      debugPrint('❌ Failed to start connectivity monitoring: $e');
    }
  }

  /// Start polling connectivity status periodically
  void _startPolling(void Function(bool) onConnectivityChanged) {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final isConnected = await networkInfo.isConnected;
        onConnectivityChanged(isConnected);
      } catch (e) {
        debugPrint('⚠️ Error checking connectivity: $e');
      }
    });
  }

  /// Stop connectivity monitoring and cleanup resources
  Future<void> stopMonitoring() async {
    try {
      if (_pollTimer != null) {
        _pollTimer!.cancel();
        _pollTimer = null;
        _isMonitoring = false;

        debugPrint('✅ Connectivity monitoring stopped');
      }
    } catch (e) {
      debugPrint('❌ Error stopping connectivity monitoring: $e');
    }
  }

  /// Get current connectivity status
  Future<Map<String, dynamic>> getConnectivityStatus() async {
    try {
      final isConnected = await networkInfo.isConnected;
      return {
        'is_online': isConnected,
        'monitoring_active': _isMonitoring,
        'adapter_type': 'basic',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'monitoring_active': _isMonitoring,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
