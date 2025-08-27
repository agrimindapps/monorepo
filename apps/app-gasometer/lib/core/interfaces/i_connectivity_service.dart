
/// Interface for connectivity monitoring service
/// Provides contract for network connectivity operations
abstract class IConnectivityService {
  /// Get current connectivity status
  Future<ConnectivityStatus> get connectivityStatus;

  /// Stream of connectivity changes
  Stream<ConnectivityStatus> get connectivityStream;

  /// Check if device is connected to internet
  Future<bool> get isConnected;

  /// Check if device has Wi-Fi connection
  Future<bool> get hasWifiConnection;

  /// Check if device has mobile data connection
  Future<bool> get hasMobileConnection;

  /// Test internet connectivity with a ping
  Future<bool> testInternetConnection();

  /// Get connection quality metrics
  Future<ConnectionQuality> getConnectionQuality();

  /// Initialize connectivity monitoring
  Future<void> initialize();

  /// Dispose connectivity monitoring
  Future<void> dispose();
}

/// Connectivity status enumeration
enum ConnectivityStatus {
  connected,
  disconnected,
  limited,
  unknown,
}

/// Connection type enumeration
enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  none,
}

/// Connection quality data model
class ConnectionQuality {
  final ConnectionType type;
  final int? signalStrength; // ${AppDefaults.minSignalStrength}-${AppDefaults.maxSignalStrength}
  final double? speed; // Mbps
  final int? latency; // milliseconds
  final bool isStable;

  const ConnectionQuality({
    required this.type,
    this.signalStrength,
    this.speed,
    this.latency,
    required this.isStable,
  });
}

/// Network info data model
class NetworkInfo {
  final String? ssid;
  final String? bssid;
  final String? ipAddress;
  final String? gateway;
  final ConnectionType type;

  const NetworkInfo({
    this.ssid,
    this.bssid,
    this.ipAddress,
    this.gateway,
    required this.type,
  });
}