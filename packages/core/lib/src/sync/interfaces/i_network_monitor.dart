import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';

/// Interface para monitoramento de rede específico para sincronização
/// Separada do UnifiedSyncManager seguindo Single Responsibility Principle
abstract class INetworkMonitor {
  /// Inicializa o monitor de rede
  Future<Either<Failure, void>> initialize();
  
  /// Verifica se há conectividade com a internet
  Future<bool> isConnected();
  
  /// Verifica conectividade com um endpoint específico
  Future<bool> canReachEndpoint(String endpoint);
  
  /// Verifica a qualidade da conexão
  Future<ConnectionQuality> getConnectionQuality();
  
  /// Testa latência para um endpoint
  Future<Duration?> getLatency(String endpoint);
  
  /// Verifica se a conexão é adequada para sync
  Future<bool> isSuitableForSync();
  
  /// Stream de status de conectividade
  Stream<bool> get connectivityStream;
  
  /// Stream de mudanças na qualidade da conexão
  Stream<ConnectionQuality> get qualityStream;
  
  /// Stream de eventos de rede
  Stream<NetworkEvent> get eventStream;
  
  /// Obtém informações detalhadas da rede atual
  Future<NetworkInfo> getCurrentNetworkInfo();
  
  /// Configura endpoints para monitoramento
  void configureEndpoints(List<String> endpoints);
  
  /// Inicia monitoramento contínuo
  Future<void> startMonitoring();
  
  /// Para monitoramento contínuo
  Future<void> stopMonitoring();
  
  /// Obtém estatísticas de conectividade
  Future<NetworkStatistics> getStatistics();
  
  /// Verifica saúde da conexão
  Future<NetworkHealthCheck> checkNetworkHealth();
  
  /// Força uma verificação de conectividade
  Future<Either<Failure, bool>> forceConnectivityCheck();
  
  /// Libera recursos do monitor
  Future<void> dispose();
}

/// Qualidade da conexão de rede
enum ConnectionQuality {
  /// Sem conexão
  none,
  /// Conexão muito lenta (< 1 Mbps)
  poor,
  /// Conexão lenta (1-5 Mbps)
  fair,
  /// Conexão adequada (5-25 Mbps)
  good,
  /// Conexão excelente (> 25 Mbps)
  excellent,
}

/// Tipo de conexão de rede
enum NetworkType {
  wifi,
  cellular,
  ethernet,
  vpn,
  unknown,
}

/// Informações detalhadas da rede
class NetworkInfo {
  final bool isConnected;
  final NetworkType type;
  final ConnectionQuality quality;
  final String? ssid;
  final String? operatorName;
  final int? signalStrength;
  final bool isMetered;
  final bool isRoaming;
  final DateTime timestamp;
  
  NetworkInfo({
    required this.isConnected,
    required this.type,
    required this.quality,
    this.ssid,
    this.operatorName,
    this.signalStrength,
    this.isMetered = false,
    this.isRoaming = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  bool get isSuitableForSync => isConnected && 
      quality != ConnectionQuality.none && 
      quality != ConnectionQuality.poor;
  
  @override
  String toString() => 'NetworkInfo($type, $quality, connected: $isConnected)';
}

/// Evento de rede
class NetworkEvent {
  final NetworkEventType type;
  final NetworkInfo? networkInfo;
  final String? message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  NetworkEvent({
    required this.type,
    this.networkInfo,
    this.message,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();
  
  @override
  String toString() => 'NetworkEvent($type: $message)';
}

/// Tipos de eventos de rede
enum NetworkEventType {
  connected,
  disconnected,
  qualityChanged,
  typeChanged,
  endpointUnreachable,
  latencyHigh,
  connectionRestored,
  monitoringStarted,
  monitoringStopped,
}

/// Estatísticas de rede
class NetworkStatistics {
  final int totalChecks;
  final int successfulChecks;
  final int failedChecks;
  final Duration averageLatency;
  final Duration maxLatency;
  final Duration minLatency;
  final DateTime lastCheck;
  final Map<String, int> connectionTypes;
  final Map<String, int> qualityDistribution;
  
  const NetworkStatistics({
    required this.totalChecks,
    required this.successfulChecks,
    required this.failedChecks,
    required this.averageLatency,
    required this.maxLatency,
    required this.minLatency,
    required this.lastCheck,
    this.connectionTypes = const {},
    this.qualityDistribution = const {},
  });
  
  double get successRate => totalChecks > 0 ? (successfulChecks / totalChecks) * 100 : 0;
  
  @override
  String toString() => 'NetworkStats(success: ${successRate.toStringAsFixed(1)}%, avg latency: ${averageLatency.inMilliseconds}ms)';
}

/// Verificação de saúde da rede
class NetworkHealthCheck {
  final bool isHealthy;
  final List<String> issues;
  final NetworkInfo currentInfo;
  final Map<String, bool> endpointReachability;
  final DateTime checkedAt;
  
  NetworkHealthCheck({
    required this.isHealthy,
    this.issues = const [],
    required this.currentInfo,
    this.endpointReachability = const {},
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();
  
  @override
  String toString() => 'NetworkHealth(healthy: $isHealthy, issues: ${issues.length})';
}