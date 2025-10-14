import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../domain/interfaces/i_disposable_service.dart';
import '../../shared/utils/app_error.dart';
import '../../shared/utils/result.dart';

/// Enhanced Connectivity Service - Monitoramento avançado de conectividade
/// 
/// Funcionalidades:
/// - Monitoramento em tempo real da conectividade
/// - Detecção de tipo de conexão (WiFi, Cellular, Ethernet)
/// - Teste de conectividade real (ping)
/// - Quality of Service (QoS) monitoring
/// - Retry automático com backoff exponencial
/// - Cache de status de conectividade
/// - Métricas de rede (latência, velocidade)
/// - Notificações de mudança de status
class EnhancedConnectivityService implements IDisposableService {
  bool _isDisposed = false;
  static const String _defaultPingHost = '8.8.8.8';
  static const int _defaultPingPort = 53;
  static const Duration _defaultTimeout = Duration(seconds: 5);
  static const Duration _statusCacheDuration = Duration(seconds: 10);
  
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController = 
      StreamController<ConnectivityStatus>.broadcast();
  final StreamController<NetworkQuality> _qualityController = 
      StreamController<NetworkQuality>.broadcast();
  ConnectivityStatus? _cachedStatus;
  DateTime? _lastStatusCheck;
  NetworkQuality? _cachedQuality;
  DateTime? _lastQualityCheck;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _qualityCheckTimer;
  Timer? _retryTimer;
  String _pingHost = _defaultPingHost;
  int _pingPort = _defaultPingPort;
  Duration _pingTimeout = _defaultTimeout;
  bool _qualityMonitoringEnabled = true;
  Duration _qualityCheckInterval = const Duration(minutes: 1);
  int _connectionChanges = 0;
  DateTime? _lastConnectionChange;
  final List<NetworkMetric> _metrics = [];
  final int _maxMetricsHistory = 100;

  /// Stream de mudanças no status de conectividade
  Stream<ConnectivityStatus> get onConnectivityChanged => _statusController.stream;
  
  /// Stream de mudanças na qualidade da rede
  Stream<NetworkQuality> get onQualityChanged => _qualityController.stream;

  /// Inicializa o service de conectividade
  Future<Result<void>> initialize({
    String? customPingHost,
    int? customPingPort,
    Duration? pingTimeout,
    bool enableQualityMonitoring = true,
    Duration qualityCheckInterval = const Duration(minutes: 1),
  }) async {
    try {
      if (customPingHost != null) _pingHost = customPingHost;
      if (customPingPort != null) _pingPort = customPingPort;
      if (pingTimeout != null) _pingTimeout = pingTimeout;
      _qualityMonitoringEnabled = enableQualityMonitoring;
      _qualityCheckInterval = qualityCheckInterval;
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: _handleConnectivityError,
      );
      final initialStatus = await getCurrentStatus();
      if (initialStatus.isSuccess) {
        _cachedStatus = initialStatus.data;
        _lastStatusCheck = DateTime.now();
        _statusController.add(_cachedStatus!);
      }
      if (_qualityMonitoringEnabled) {
        _startQualityMonitoring();
      }

      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        NetworkError(
          message: 'Erro ao inicializar connectivity service: ${e.toString()}',
          code: 'CONNECTIVITY_INIT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Obtém o status atual de conectividade
  Future<Result<ConnectivityStatus>> getCurrentStatus({bool forceRefresh = false}) async {
    if (!forceRefresh && 
        _cachedStatus != null && 
        _lastStatusCheck != null &&
        DateTime.now().difference(_lastStatusCheck!) < _statusCacheDuration) {
      return Result.success(_cachedStatus!);
    }

    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final hasRealConnection = await _checkRealConnectivity();
      
      final status = ConnectivityStatus(
        types: connectivityResults,
        hasInternet: hasRealConnection.data ?? false,
        timestamp: DateTime.now(),
        isConnected: connectivityResults.isNotEmpty && 
                     connectivityResults.first != ConnectivityResult.none &&
                     (hasRealConnection.data ?? false),
      );

      _cachedStatus = status;
      _lastStatusCheck = DateTime.now();

      return Result.success(status);
    } catch (e, stackTrace) {
      return Result.error(
        NetworkError(
          message: 'Erro ao verificar conectividade: ${e.toString()}',
          code: 'CONNECTIVITY_CHECK_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Testa conectividade real fazendo ping
  Future<Result<bool>> _checkRealConnectivity() async {
    try {
      final socket = await Socket.connect(
        _pingHost, 
        _pingPort, 
        timeout: _pingTimeout,
      );
      
      await socket.close();
      return Result.success(true);
    } catch (e) {
      final alternativeHosts = ['1.1.1.1', '208.67.222.222'];
      
      for (final host in alternativeHosts) {
        try {
          final socket = await Socket.connect(
            host, 
            _pingPort, 
            timeout: _pingTimeout,
          );
          await socket.close();
          return Result.success(true);
        } catch (_) {
          continue;
        }
      }
      
      return Result.success(false);
    }
  }

  /// Testa a qualidade da rede medindo latência
  Future<Result<NetworkQuality>> checkNetworkQuality() async {
    if (_cachedQuality != null && 
        _lastQualityCheck != null &&
        DateTime.now().difference(_lastQualityCheck!) < const Duration(minutes: 2)) {
      return Result.success(_cachedQuality!);
    }

    try {
      final measurements = <int>[];
      const testCount = 3;
      
      for (int i = 0; i < testCount; i++) {
        final stopwatch = Stopwatch()..start();
        
        final connectivityResult = await _checkRealConnectivity();
        stopwatch.stop();
        
        if (connectivityResult.data == true) {
          measurements.add(stopwatch.elapsedMilliseconds);
        } else {
          final quality = NetworkQuality(
            latency: -1,
            quality: ConnectionQuality.poor,
            timestamp: DateTime.now(),
            isStable: false,
          );
          
          _cachedQuality = quality;
          _lastQualityCheck = DateTime.now();
          return Result.success(quality);
        }
        if (i < testCount - 1) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }

      final averageLatency = measurements.isNotEmpty 
          ? measurements.reduce((a, b) => a + b) / measurements.length 
          : -1.0;
      
      final quality = NetworkQuality(
        latency: averageLatency,
        quality: _determineQuality(averageLatency),
        timestamp: DateTime.now(),
        isStable: _isLatencyStable(measurements),
      );
      _addMetric(NetworkMetric(
        timestamp: DateTime.now(),
        latency: averageLatency,
        quality: quality.quality,
      ));

      _cachedQuality = quality;
      _lastQualityCheck = DateTime.now();

      return Result.success(quality);
    } catch (e, stackTrace) {
      return Result.error(
        NetworkError(
          message: 'Erro ao medir qualidade da rede: ${e.toString()}',
          code: 'QUALITY_CHECK_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Força reconexão (útil para WiFi problemático)
  Future<Result<void>> forceReconnection() async {
    try {
      _cachedStatus = null;
      _lastStatusCheck = null;
      _cachedQuality = null;
      _lastQualityCheck = null;

      final newStatus = await getCurrentStatus(forceRefresh: true);
      if (newStatus.isSuccess) {
        _statusController.add(newStatus.data!);
      }

      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        NetworkError(
          message: 'Erro ao forçar reconexão: ${e.toString()}',
          code: 'FORCE_RECONNECTION_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Executa uma operação com retry automático baseado na conectividade
  Future<Result<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool waitForConnection = true,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      if (waitForConnection) {
        final statusResult = await getCurrentStatus();
        if (statusResult.isSuccess && !statusResult.data!.isConnected) {
          await _waitForConnection(timeout: const Duration(minutes: 2));
        }
      }

      try {
        final result = await operation();
        return Result.success(result);
      } catch (e, stackTrace) {
        attempt++;
        
        if (attempt >= maxRetries) {
          return Result.error(
            NetworkError(
              message: 'Operação falhou após $maxRetries tentativas: ${e.toString()}',
              code: 'RETRY_EXHAUSTED',
              details: 'Última tentativa: ${e.toString()}',
              stackTrace: stackTrace,
            ),
          );
        }
        await Future<void>.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * backoffMultiplier).round());
      }
    }

    return Result.error(
      NetworkError(
        message: 'Falha inesperada no retry loop',
        code: 'RETRY_LOOP_ERROR',
      ),
    );
  }

  /// Espera por conectividade com timeout
  Future<Result<void>> waitForConnection({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    return _waitForConnection(timeout: timeout);
  }

  /// Obtém estatísticas de conectividade
  Future<Result<ConnectivityStats>> getStats() async {
    try {
      final currentStatus = await getCurrentStatus();
      final currentQuality = await checkNetworkQuality();

      final stats = ConnectivityStats(
        currentStatus: currentStatus.data,
        currentQuality: currentQuality.data,
        connectionChanges: _connectionChanges,
        lastConnectionChange: _lastConnectionChange,
        metricsHistory: List.unmodifiable(_metrics),
        averageLatency: _calculateAverageLatency(),
        uptimePercentage: _calculateUptimePercentage(),
      );

      return Result.success(stats);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao obter estatísticas: ${e.toString()}',
          code: 'STATS_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Limpa cache e força nova verificação
  Future<Result<void>> clearCache() async {
    try {
      _cachedStatus = null;
      _lastStatusCheck = null;
      _cachedQuality = null;
      _lastQualityCheck = null;
      
      return Result.success(null);
    } catch (e) {
      return Result.success(null); // Falha não crítica
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    try {
      _connectionChanges++;
      _lastConnectionChange = DateTime.now();
      final hasRealConnection = await _checkRealConnectivity();
      
      final status = ConnectivityStatus(
        types: results,
        hasInternet: hasRealConnection.data ?? false,
        timestamp: DateTime.now(),
        isConnected: results.isNotEmpty && 
                     results.first != ConnectivityResult.none &&
                     (hasRealConnection.data ?? false),
      );

      _cachedStatus = status;
      _lastStatusCheck = DateTime.now();

      _statusController.add(status);
      debugPrint('Conectividade mudou: ${status.isConnected ? 'Conectado' : 'Desconectado'} '
                '(${results.map((r) => r.name).join(', ')})');
      if (!status.isConnected && _qualityCheckTimer != null) {
        _qualityCheckTimer?.cancel();
        _qualityCheckTimer = null;
      } else if (status.isConnected && _qualityMonitoringEnabled && _qualityCheckTimer == null) {
        _startQualityMonitoring();
      }
    } catch (e) {
      _handleConnectivityError(e);
    }
  }

  void _handleConnectivityError(Object error) {
    debugPrint('Erro no monitoramento de conectividade: $error');
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), () {
      _connectivitySubscription?.cancel();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: _handleConnectivityError,
      );
    });
  }

  void _startQualityMonitoring() {
    _qualityCheckTimer?.cancel();
    _qualityCheckTimer = Timer.periodic(_qualityCheckInterval, (_) async {
      final qualityResult = await checkNetworkQuality();
      if (qualityResult.isSuccess) {
        _qualityController.add(qualityResult.data!);
      }
    });
  }

  Future<Result<void>> _waitForConnection({required Duration timeout}) async {
    final completer = Completer<Result<void>>();
    Timer? timeoutTimer;
    StreamSubscription<ConnectivityStatus>? subscription;
    timeoutTimer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete(Result.error(
          NetworkError(
            message: 'Timeout aguardando conectividade',
            code: 'WAIT_CONNECTION_TIMEOUT',
          ),
        ));
      }
    });
    subscription = onConnectivityChanged.listen((status) {
      if (status.isConnected) {
        timeoutTimer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(Result.success(null));
        }
      }
    });
    final currentStatus = await getCurrentStatus();
    if (currentStatus.isSuccess && currentStatus.data!.isConnected) {
      timeoutTimer.cancel();
      subscription.cancel();
      return Result.success(null);
    }

    return completer.future;
  }

  ConnectionQuality _determineQuality(double latency) {
    if (latency < 0) return ConnectionQuality.none;
    if (latency <= 50) return ConnectionQuality.excellent;
    if (latency <= 100) return ConnectionQuality.good;
    if (latency <= 200) return ConnectionQuality.fair;
    if (latency <= 500) return ConnectionQuality.poor;
    return ConnectionQuality.terrible;
  }

  bool _isLatencyStable(List<int> measurements) {
    if (measurements.length < 2) return true;
    
    final average = measurements.reduce((a, b) => a + b) / measurements.length;
    final variance = measurements
        .map((m) => (m - average) * (m - average))
        .reduce((a, b) => a + b) / measurements.length;
    
    final standardDeviation = sqrt(variance);
    return standardDeviation < (average * 0.3);
  }

  void _addMetric(NetworkMetric metric) {
    _metrics.add(metric);
    if (_metrics.length > _maxMetricsHistory) {
      _metrics.removeAt(0);
    }
  }

  double _calculateAverageLatency() {
    if (_metrics.isEmpty) return 0.0;
    
    final validLatencies = _metrics
        .where((m) => m.latency > 0)
        .map((m) => m.latency)
        .toList();
    
    if (validLatencies.isEmpty) return 0.0;
    
    return validLatencies.reduce((a, b) => a + b) / validLatencies.length;
  }

  double _calculateUptimePercentage() {
    if (_metrics.isEmpty) return 0.0;
    
    final connectedMetrics = _metrics
        .where((m) => m.quality != ConnectionQuality.none)
        .length;
    
    return (connectedMetrics / _metrics.length) * 100;
  }

  /// Dispose - limpa recursos
  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      await _connectivitySubscription?.cancel();
    } catch (e) {
      debugPrint('Error canceling connectivity subscription: $e');
    }

    try {
      _qualityCheckTimer?.cancel();
    } catch (e) {
      debugPrint('Error canceling quality timer: $e');
    }

    try {
      _retryTimer?.cancel();
    } catch (e) {
      debugPrint('Error canceling retry timer: $e');
    }

    try {
      await _statusController.close();
    } catch (e) {
      debugPrint('Error closing status controller: $e');
    }

    try {
      await _qualityController.close();
    } catch (e) {
      debugPrint('Error closing quality controller: $e');
    }

    _metrics.clear();
  }

  @override
  bool get isDisposed => _isDisposed;
}

/// Status de conectividade
class ConnectivityStatus {
  /// Tipos de conectividade disponíveis
  final List<ConnectivityResult> types;
  
  /// Se tem internet real (testado via ping)
  final bool hasInternet;
  
  /// Timestamp da verificação
  final DateTime timestamp;
  
  /// Se está efetivamente conectado
  final bool isConnected;

  ConnectivityStatus({
    required this.types,
    required this.hasInternet,
    required this.timestamp,
    required this.isConnected,
  });

  /// Se está conectado via WiFi
  bool get isWiFi => types.contains(ConnectivityResult.wifi);
  
  /// Se está conectado via dados móveis
  bool get isMobile => types.contains(ConnectivityResult.mobile);
  
  /// Se está conectado via ethernet
  bool get isEthernet => types.contains(ConnectivityResult.ethernet);
  
  /// Tipo de conexão principal
  ConnectivityResult get primaryType => types.isNotEmpty ? types.first : ConnectivityResult.none;

  Map<String, dynamic> toMap() {
    return {
      'types': types.map((t) => t.name).toList(),
      'hasInternet': hasInternet,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isConnected': isConnected,
      'isWiFi': isWiFi,
      'isMobile': isMobile,
      'isEthernet': isEthernet,
      'primaryType': primaryType.name,
    };
  }

  @override
  String toString() {
    return 'ConnectivityStatus(connected: $isConnected, type: ${primaryType.name}, internet: $hasInternet)';
  }
}

/// Qualidade da rede
class NetworkQuality {
  /// Latência média em milissegundos
  final double latency;
  
  /// Qualidade da conexão
  final ConnectionQuality quality;
  
  /// Timestamp da medição
  final DateTime timestamp;
  
  /// Se a latência é estável
  final bool isStable;

  NetworkQuality({
    required this.latency,
    required this.quality,
    required this.timestamp,
    required this.isStable,
  });

  Map<String, dynamic> toMap() {
    return {
      'latency': latency,
      'quality': quality.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isStable': isStable,
    };
  }

  @override
  String toString() {
    return 'NetworkQuality(${quality.name}, ${latency.toStringAsFixed(0)}ms, stable: $isStable)';
  }
}

/// Qualidade da conexão
enum ConnectionQuality {
  none,
  terrible,
  poor,
  fair,
  good,
  excellent,
}

/// Métrica de rede
class NetworkMetric {
  final DateTime timestamp;
  final double latency;
  final ConnectionQuality quality;

  NetworkMetric({
    required this.timestamp,
    required this.latency,
    required this.quality,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'latency': latency,
      'quality': quality.name,
    };
  }
}

/// Estatísticas de conectividade
class ConnectivityStats {
  final ConnectivityStatus? currentStatus;
  final NetworkQuality? currentQuality;
  final int connectionChanges;
  final DateTime? lastConnectionChange;
  final List<NetworkMetric> metricsHistory;
  final double averageLatency;
  final double uptimePercentage;

  ConnectivityStats({
    this.currentStatus,
    this.currentQuality,
    required this.connectionChanges,
    this.lastConnectionChange,
    required this.metricsHistory,
    required this.averageLatency,
    required this.uptimePercentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentStatus': currentStatus?.toMap(),
      'currentQuality': currentQuality?.toMap(),
      'connectionChanges': connectionChanges,
      'lastConnectionChange': lastConnectionChange?.millisecondsSinceEpoch,
      'metricsHistory': metricsHistory.map((m) => m.toMap()).toList(),
      'averageLatency': averageLatency,
      'uptimePercentage': uptimePercentage,
    };
  }

  @override
  String toString() {
    return 'ConnectivityStats('
           'changes: $connectionChanges, '
           'avg latency: ${averageLatency.toStringAsFixed(0)}ms, '
           'uptime: ${uptimePercentage.toStringAsFixed(1)}%)';
  }
}

/// Função auxiliar para calcular raiz quadrada (para desvio padrão)
double sqrt(double x) {
  if (x < 0) return double.nan;
  if (x == 0) return 0.0;
  
  double guess = x / 2;
  double previous = 0;
  
  while ((guess - previous).abs() > 0.0001) {
    previous = guess;
    guess = (guess + x / guess) / 2;
  }
  
  return guess;
}
