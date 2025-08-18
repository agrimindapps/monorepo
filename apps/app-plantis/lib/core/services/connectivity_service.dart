import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkStatus {
  offline,
  online,
  mobile,
  wifi
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // Stream controller for network status
  final _networkStatusController = StreamController<NetworkStatus>.broadcast();
  
  // Expose stream to listen to network status
  Stream<NetworkStatus> get networkStatusStream => _networkStatusController.stream;

  ConnectivityService() {
    // Initialize network status monitoring
    _initConnectivityMonitoring();
  }

  void _initConnectivityMonitoring() {
    // Initial check
    _checkNetworkStatus();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.first;
      _updateNetworkStatus(result);
    });
  }

  Future<void> _checkNetworkStatus() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      _updateNetworkStatus(result.first);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      _networkStatusController.add(NetworkStatus.offline);
    }
  }

  void _updateNetworkStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        _networkStatusController.add(NetworkStatus.mobile);
        break;
      case ConnectivityResult.wifi:
        _networkStatusController.add(NetworkStatus.wifi);
        break;
      case ConnectivityResult.ethernet:
        _networkStatusController.add(NetworkStatus.online);
        break;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.none:
        _networkStatusController.add(NetworkStatus.offline);
        break;
      case ConnectivityResult.vpn:
        _networkStatusController.add(NetworkStatus.online);
        break;
      default:
        _networkStatusController.add(NetworkStatus.offline);
    }
  }

  // Utility method to check current network status
  Future<NetworkStatus> getCurrentNetworkStatus() async {
    try {
      final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      switch (result.first) {
        case ConnectivityResult.mobile:
          return NetworkStatus.mobile;
        case ConnectivityResult.wifi:
          return NetworkStatus.wifi;
        case ConnectivityResult.ethernet:
          return NetworkStatus.online;
        case ConnectivityResult.bluetooth:
        case ConnectivityResult.none:
          return NetworkStatus.offline;
        case ConnectivityResult.vpn:
          return NetworkStatus.online;
        default:
          return NetworkStatus.offline;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current network status: $e');
      }
      return NetworkStatus.offline;
    }
  }

  void dispose() {
    _networkStatusController.close();
  }
}