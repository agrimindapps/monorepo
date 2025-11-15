import 'dart:async';

/// Interface for plant connectivity monitoring
abstract class PlantsConnectivityService {
  /// Start monitoring connectivity changes
  void startMonitoring();

  /// Stop monitoring connectivity
  Future<void> stopMonitoring();

  /// Get current monitoring status
  bool get isMonitoring;

  /// Get detailed connectivity status
  Future<Map<String, dynamic>> getConnectivityStatus();
}
