import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/performance_entity.dart';
import '../../domain/repositories/i_performance_repository.dart';

/// Implementação do serviço de monitoramento de performance
class PerformanceService implements IPerformanceRepository {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Services
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebasePerformance _firebasePerformance = FirebasePerformance.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Estado do monitoramento
  PerformanceMonitoringState _state = PerformanceMonitoringState.stopped;
  PerformanceConfig _config = const PerformanceConfig();
  PerformanceThresholds _thresholds = const PerformanceThresholds();

  // FPS Tracking
  final StreamController<double> _fpsController = StreamController.broadcast();
  Timer? _fpsTimer;
  final List<double> _fpsHistory = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  final List<Duration> _frameTimes = [];

  // Memory Tracking
  final StreamController<MemoryUsage> _memoryController = StreamController.broadcast();
  Timer? _memoryTimer;
  final List<MemoryUsage> _memoryHistory = [];

  // CPU Tracking
  final StreamController<double> _cpuController = StreamController.broadcast();
  Timer? _cpuTimer;

  // Startup Tracking
  DateTime? _appStartTime;
  DateTime? _firstFrameTime;
  DateTime? _appInteractiveTime;

  // Traces
  final Map<String, DateTime> _activeTraces = {};
  final Map<String, Trace> _firebaseTraces = {};
  final List<TraceResult> _completedTraces = [];

  // Performance History
  final List<PerformanceMetrics> _performanceHistory = [];
  Timer? _metricsCollectionTimer;

  // Alertas
  final StreamController<Map<String, dynamic>> _alertsController = 
      StreamController.broadcast();
  void Function(String, Map<String, dynamic>)? _alertCallback;

  // ==========================================================================
  // CONTROLE DE MONITORAMENTO
  // ==========================================================================

  @override
  Future<bool> startPerformanceTracking({PerformanceConfig? config}) async {
    try {
      _config = config ?? _config;
      _state = PerformanceMonitoringState.running;
      
      // Marcar início se não foi marcado
      _appStartTime ??= DateTime.now();

      // Inicializar monitoramentos baseados na configuração
      if (_config.enableFpsMonitoring) {
        _startFpsTracking();
      }

      if (_config.enableMemoryMonitoring) {
        _startMemoryTracking();
      }

      if (_config.enableCpuMonitoring) {
        _startCpuTracking();
      }

      // Inicializar coleta de métricas consolidadas
      _startMetricsCollection();

      // Configurar primeiro frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _firstFrameTime ??= DateTime.now();
        _onFirstFrame();
      });

      debugPrint('🚀 Performance tracking started');
      return true;
    } catch (e) {
      debugPrint('❌ Error starting performance tracking: $e');
      return false;
    }
  }

  @override
  Future<bool> stopPerformanceTracking() async {
    try {
      _state = PerformanceMonitoringState.stopped;
      
      // Parar todos os timers
      _fpsTimer?.cancel();
      _memoryTimer?.cancel();
      _cpuTimer?.cancel();
      _metricsCollectionTimer?.cancel();

      // Fechar streams
      await _fpsController.close();
      await _memoryController.close();
      await _cpuController.close();
      await _alertsController.close();

      // Parar todos os traces ativos
      for (final traceName in _activeTraces.keys.toList()) {
        await stopTrace(traceName);
      }

      debugPrint('🛑 Performance tracking stopped');
      return true;
    } catch (e) {
      debugPrint('❌ Error stopping performance tracking: $e');
      return false;
    }
  }

  @override
  Future<bool> pausePerformanceTracking() async {
    if (_state == PerformanceMonitoringState.running) {
      _state = PerformanceMonitoringState.paused;
      
      _fpsTimer?.cancel();
      _memoryTimer?.cancel();
      _cpuTimer?.cancel();
      
      return true;
    }
    return false;
  }

  @override
  Future<bool> resumePerformanceTracking() async {
    if (_state == PerformanceMonitoringState.paused) {
      _state = PerformanceMonitoringState.running;
      
      if (_config.enableFpsMonitoring) _startFpsTracking();
      if (_config.enableMemoryMonitoring) _startMemoryTracking();
      if (_config.enableCpuMonitoring) _startCpuTracking();
      
      return true;
    }
    return false;
  }

  @override
  PerformanceMonitoringState getMonitoringState() => _state;

  @override
  Future<void> setPerformanceThresholds(PerformanceThresholds thresholds) async {
    _thresholds = thresholds;
  }

  // ==========================================================================
  // FPS TRACKING
  // ==========================================================================

  void _startFpsTracking() {
    _fpsTimer?.cancel();
    
    // Usar SchedulerBinding para tracking mais preciso
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
    
    // Timer para calcular FPS médio
    _fpsTimer = Timer.periodic(_config.fpsMonitoringInterval, (_) {
      _calculateAndEmitFps();
    });
  }

  void _onFrame(Duration timeStamp) {
    final now = DateTime.now();
    
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime);
      
      // Manter apenas os últimos 60 frames
      if (_frameTimes.length > 60) {
        _frameTimes.removeAt(0);
      }
    }
    
    _lastFrameTime = now;
    _frameCount++;
  }

  void _onFirstFrame() {
    if (_appStartTime != null && _firstFrameTime != null) {
      final timeToFirstFrame = _firstFrameTime!.difference(_appStartTime!);
      debugPrint('⏱️ Time to first frame: ${timeToFirstFrame.inMilliseconds}ms');
      
      // Registrar métrica
      recordCustomMetric(
        name: 'time_to_first_frame',
        value: timeToFirstFrame.inMilliseconds.toDouble(),
        type: MetricType.timing,
        unit: 'ms',
      );
    }
  }

  void _calculateAndEmitFps() {
    if (_frameTimes.isEmpty) return;

    // Calcular FPS baseado nos frame times
    final totalTime = _frameTimes.fold<Duration>(
      Duration.zero, 
      (sum, frameTime) => sum + frameTime,
    );

    if (totalTime.inMilliseconds > 0) {
      final avgFrameTime = totalTime.inMilliseconds / _frameTimes.length;
      final fps = 1000 / avgFrameTime;
      final clampedFps = fps.clamp(0, 60).toDouble();
      
      _fpsHistory.add(clampedFps);
      if (_fpsHistory.length > 100) {
        _fpsHistory.removeAt(0);
      }

      if (!_fpsController.isClosed) {
        _fpsController.add(clampedFps);
      }

      // Verificar threshold
      if (clampedFps < _thresholds.minFps) {
        _emitAlert('low_fps', {
          'current_fps': clampedFps,
          'threshold': _thresholds.minFps,
        });
      }
    }
  }

  @override
  Stream<double> getFpsStream() => _fpsController.stream;

  @override
  Future<double> getCurrentFps() async {
    return _fpsHistory.isNotEmpty ? _fpsHistory.last : 0.0;
  }

  @override
  Future<FpsMetrics> getFpsMetrics({Duration? period}) async {
    final relevantData = period != null 
        ? _fpsHistory.take(_fpsHistory.length).toList()  // Implementar filtro por período
        : _fpsHistory;

    if (relevantData.isEmpty) {
      return const FpsMetrics(
        currentFps: 0,
        averageFps: 0,
        minFps: 0,
        maxFps: 0,
        frameDrops: 0,
        jankFrames: 0,
        measurementDuration: Duration.zero,
      );
    }

    final currentFps = relevantData.last;
    final averageFps = relevantData.reduce((a, b) => a + b) / relevantData.length;
    final minFps = relevantData.reduce((a, b) => a < b ? a : b);
    final maxFps = relevantData.reduce((a, b) => a > b ? a : b);
    
    // Contar frame drops (FPS < 30)
    final frameDrops = relevantData.where((fps) => fps < 30).length;
    
    // Contar jank frames (frame time > 16.67ms = FPS < 60)
    final jankFrames = relevantData.where((fps) => fps < 60).length;

    return FpsMetrics(
      currentFps: currentFps,
      averageFps: averageFps,
      minFps: minFps,
      maxFps: maxFps,
      frameDrops: frameDrops,
      jankFrames: jankFrames,
      measurementDuration: Duration(seconds: relevantData.length),
    );
  }

  @override
  Future<bool> isFpsHealthy() async {
    final currentFps = await getCurrentFps();
    return currentFps >= _thresholds.minFps;
  }

  // ==========================================================================
  // MEMORY TRACKING
  // ==========================================================================

  void _startMemoryTracking() {
    _memoryTimer?.cancel();
    
    _memoryTimer = Timer.periodic(_config.monitoringInterval, (_) async {
      try {
        final memoryUsage = await getMemoryUsage();
        _memoryHistory.add(memoryUsage);
        
        // Manter apenas os últimos 100 registros
        if (_memoryHistory.length > 100) {
          _memoryHistory.removeAt(0);
        }

        if (!_memoryController.isClosed) {
          _memoryController.add(memoryUsage);
        }

        // Verificar threshold
        if (memoryUsage.usagePercentage > _thresholds.maxMemoryUsagePercent) {
          _emitAlert('high_memory_usage', {
            'current_usage': memoryUsage.usagePercentage,
            'threshold': _thresholds.maxMemoryUsagePercent,
            'used_mb': memoryUsage.usedMemoryMB,
          });
        }
      } catch (e) {
        debugPrint('❌ Error tracking memory: $e');
      }
    });
  }

  @override
  Future<MemoryUsage> getMemoryUsage() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidMemoryUsage();
      } else if (Platform.isIOS) {
        return await _getIOSMemoryUsage();
      }
      
      // Fallback para outras plataformas
      return await _getGenericMemoryUsage();
    } catch (e) {
      debugPrint('❌ Error getting memory usage: $e');
      return const MemoryUsage(
        usedMemory: 0,
        totalMemory: 0,
        availableMemory: 0,
      );
    }
  }

  Future<MemoryUsage> _getAndroidMemoryUsage() async {
    try {
      // Usar ActivityManager para Android
      const platform = MethodChannel('performance_service');
      final result = await platform.invokeMethod('getMemoryInfo');
      
      return MemoryUsage(
        usedMemory: result['usedMemory'] ?? 0,
        totalMemory: result['totalMemory'] ?? 0,
        availableMemory: result['availableMemory'] ?? 0,
        heapSize: result['heapSize'],
        nativeHeapSize: result['nativeHeapSize'],
      );
    } catch (e) {
      // Fallback usando /proc/meminfo
      return await _getLinuxMemoryUsage();
    }
  }

  Future<MemoryUsage> _getLinuxMemoryUsage() async {
    try {
      final result = await Process.run('cat', ['/proc/meminfo']);
      final lines = result.stdout.toString().split('\n');
      
      int totalMemory = 0;
      int availableMemory = 0;
      
      for (final line in lines) {
        if (line.startsWith('MemTotal:')) {
          totalMemory = _parseMemoryValue(line) * 1024; // KB para bytes
        } else if (line.startsWith('MemAvailable:')) {
          availableMemory = _parseMemoryValue(line) * 1024;
        }
      }
      
      final usedMemory = totalMemory - availableMemory;
      
      return MemoryUsage(
        usedMemory: usedMemory,
        totalMemory: totalMemory,
        availableMemory: availableMemory,
      );
    } catch (e) {
      debugPrint('❌ Error getting Linux memory usage: $e');
      rethrow;
    }
  }

  Future<MemoryUsage> _getIOSMemoryUsage() async {
    try {
      const platform = MethodChannel('performance_service');
      final result = await platform.invokeMethod('getMemoryUsage');
      
      return MemoryUsage(
        usedMemory: result['used'] ?? 0,
        totalMemory: result['total'] ?? 0,
        availableMemory: result['available'] ?? 0,
      );
    } catch (e) {
      debugPrint('❌ Error getting iOS memory usage: $e');
      return const MemoryUsage(usedMemory: 0, totalMemory: 0, availableMemory: 0);
    }
  }

  Future<MemoryUsage> _getGenericMemoryUsage() async {
    // Para web e desktop, usar estimativas básicas
    return const MemoryUsage(
      usedMemory: 100 * 1024 * 1024,     // 100MB estimado
      totalMemory: 4 * 1024 * 1024 * 1024, // 4GB estimado
      availableMemory: 3 * 1024 * 1024 * 1024, // 3GB estimado
    );
  }

  int _parseMemoryValue(String line) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(line);
    return int.parse(match?.group(1) ?? '0');
  }

  @override
  Stream<MemoryUsage> getMemoryStream() => _memoryController.stream;

  @override
  Future<bool> isMemoryHealthy() async {
    final memoryUsage = await getMemoryUsage();
    return memoryUsage.usagePercentage <= _thresholds.maxMemoryUsagePercent;
  }

  @override
  Future<void> forceGarbageCollection() async {
    // Apenas disponível em debug mode
    if (kDebugMode) {
      // No Flutter, não há API direta para GC
      // Podemos tentar forçar através de algumas operações
      try {
        final largeList = List.generate(10000, (i) => i);
        largeList.clear();
      } catch (e) {
        debugPrint('❌ Error forcing GC: $e');
      }
    }
  }

  // ==========================================================================
  // CPU TRACKING
  // ==========================================================================

  void _startCpuTracking() {
    _cpuTimer?.cancel();
    
    _cpuTimer = Timer.periodic(_config.monitoringInterval, (_) async {
      try {
        final cpuUsage = await getCpuUsage();
        
        if (!_cpuController.isClosed) {
          _cpuController.add(cpuUsage);
        }

        // Verificar threshold
        if (cpuUsage > _thresholds.maxCpuUsage) {
          _emitAlert('high_cpu_usage', {
            'current_usage': cpuUsage,
            'threshold': _thresholds.maxCpuUsage,
          });
        }
      } catch (e) {
        debugPrint('❌ Error tracking CPU: $e');
      }
    });
  }

  @override
  Future<double> getCpuUsage() async {
    try {
      if (Platform.isLinux || Platform.isAndroid) {
        return await _getLinuxCpuUsage();
      } else if (Platform.isIOS || Platform.isMacOS) {
        return await _getDarwinCpuUsage();
      }
      
      // Fallback
      return 0.0;
    } catch (e) {
      debugPrint('❌ Error getting CPU usage: $e');
      return 0.0;
    }
  }

  Future<double> _getLinuxCpuUsage() async {
    try {
      // Implementação simplificada usando /proc/stat
      final result = await Process.run('cat', ['/proc/stat']);
      final lines = result.stdout.toString().split('\n');
      
      if (lines.isNotEmpty) {
        final cpuLine = lines.first;
        final values = cpuLine.split(' ').where((s) => s.isNotEmpty).toList();
        
        if (values.length >= 5) {
          final idle = int.parse(values[4]);
          final total = values.skip(1).take(7).map(int.parse).reduce((a, b) => a + b);
          final usage = ((total - idle) / total) * 100;
          return usage.clamp(0, 100).toDouble();
        }
      }
      
      return 0.0;
    } catch (e) {
      debugPrint('❌ Error getting Linux CPU usage: $e');
      return 0.0;
    }
  }

  Future<double> _getDarwinCpuUsage() async {
    try {
      const platform = MethodChannel('performance_service');
      final result = await platform.invokeMethod('getCpuUsage');
      return (result as double?) ?? 0.0;
    } catch (e) {
      debugPrint('❌ Error getting Darwin CPU usage: $e');
      return 0.0;
    }
  }

  @override
  Stream<double> getCpuStream() => _cpuController.stream;

  @override
  Future<bool> isCpuHealthy() async {
    final cpuUsage = await getCpuUsage();
    return cpuUsage <= _thresholds.maxCpuUsage;
  }

  // ==========================================================================
  // STARTUP METRICS
  // ==========================================================================

  @override
  Future<void> markAppStarted() async {
    _appStartTime = DateTime.now();
  }

  @override
  Future<void> markFirstFrame() async {
    _firstFrameTime = DateTime.now();
  }

  @override
  Future<void> markAppInteractive() async {
    _appInteractiveTime = DateTime.now();
  }

  @override
  Future<AppStartupMetrics> getStartupMetrics() async {
    final now = DateTime.now();
    
    return AppStartupMetrics(
      coldStartTime: _appStartTime != null 
          ? now.difference(_appStartTime!) 
          : Duration.zero,
      warmStartTime: Duration.zero, // Implementar lógica específica
      firstFrameTime: _firstFrameTime != null && _appStartTime != null
          ? _firstFrameTime!.difference(_appStartTime!) 
          : Duration.zero,
      timeToInteractive: _appInteractiveTime != null && _appStartTime != null
          ? _appInteractiveTime!.difference(_appStartTime!)
          : Duration.zero,
    );
  }

  // ==========================================================================
  // TRACES CUSTOMIZADOS
  // ==========================================================================

  @override
  Future<void> startTrace(String traceName, {Map<String, String>? attributes}) async {
    try {
      _activeTraces[traceName] = DateTime.now();
      
      // Iniciar trace no Firebase Performance
      if (_config.enableFirebaseIntegration) {
        final trace = _firebasePerformance.newTrace(traceName);
        
        if (attributes != null) {
          for (final entry in attributes.entries) {
            trace.putAttribute(entry.key, entry.value);
          }
        }
        
        await trace.start();
        _firebaseTraces[traceName] = trace;
      }
    } catch (e) {
      debugPrint('❌ Error starting trace: $e');
    }
  }

  @override
  Future<TraceResult?> stopTrace(String traceName, {Map<String, double>? metrics}) async {
    try {
      final startTime = _activeTraces.remove(traceName);
      if (startTime == null) return null;
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // Parar trace no Firebase
      final firebaseTrace = _firebaseTraces.remove(traceName);
      if (firebaseTrace != null) {
        if (metrics != null) {
          for (final entry in metrics.entries) {
            firebaseTrace.putMetric(entry.key, entry.value.round());
          }
        }
        await firebaseTrace.stop();
      }
      
      final result = TraceResult(
        name: traceName,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        metrics: metrics ?? {},
      );
      
      _completedTraces.add(result);
      
      return result;
    } catch (e) {
      debugPrint('❌ Error stopping trace: $e');
      return null;
    }
  }

  @override
  Future<Duration> measureOperationTime<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    await startTrace(operationName, attributes: attributes);
    
    final stopwatch = Stopwatch()..start();
    try {
      await operation();
    } finally {
      stopwatch.stop();
      await stopTrace(operationName, metrics: {
        'duration_ms': stopwatch.elapsedMilliseconds.toDouble(),
      });
    }
    
    return stopwatch.elapsed;
  }

  @override
  List<String> getActiveTraces() => _activeTraces.keys.toList();

  // ==========================================================================
  // MÉTRICAS CUSTOMIZADAS
  // ==========================================================================

  @override
  Future<void> recordCustomMetric({
    required String name,
    required double value,
    required MetricType type,
    String? unit,
    Map<String, String>? tags,
  }) async {
    try {
      // Enviar para Firebase Analytics
      await _analytics.logEvent(
        name: 'custom_metric',
        parameters: {
          'metric_name': name,
          'metric_value': value,
          'metric_type': type.value,
          'metric_unit': unit ?? '',
          ...?tags,
        },
      );
    } catch (e) {
      debugPrint('❌ Error recording custom metric: $e');
    }
  }

  @override
  Future<void> incrementCounter(String name, {Map<String, String>? tags}) async {
    await recordCustomMetric(
      name: name,
      value: 1,
      type: MetricType.counter,
      tags: tags,
    );
  }

  @override
  Future<void> recordGauge(String name, double value, {Map<String, String>? tags}) async {
    await recordCustomMetric(
      name: name,
      value: value,
      type: MetricType.gauge,
      tags: tags,
    );
  }

  @override
  Future<void> recordTiming(String name, Duration duration, {Map<String, String>? tags}) async {
    await recordCustomMetric(
      name: name,
      value: duration.inMilliseconds.toDouble(),
      type: MetricType.timing,
      unit: 'ms',
      tags: tags,
    );
  }

  // ==========================================================================
  // MÉTRICAS CONSOLIDADAS
  // ==========================================================================

  void _startMetricsCollection() {
    _metricsCollectionTimer?.cancel();
    
    _metricsCollectionTimer = Timer.periodic(
      Duration(seconds: 30), // Coletar métricas a cada 30s
      (_) => _collectCurrentMetrics(),
    );
  }

  Future<void> _collectCurrentMetrics() async {
    try {
      final metrics = await getCurrentMetrics();
      _performanceHistory.add(metrics);
      
      // Manter apenas as últimas 100 entradas
      if (_performanceHistory.length > 100) {
        _performanceHistory.removeAt(0);
      }
    } catch (e) {
      debugPrint('❌ Error collecting metrics: $e');
    }
  }

  @override
  Future<PerformanceMetrics> getCurrentMetrics() async {
    final fps = await getCurrentFps();
    final memoryUsage = await getMemoryUsage();
    final cpuUsage = await getCpuUsage();
    
    return PerformanceMetrics(
      timestamp: DateTime.now(),
      fps: fps,
      memoryUsage: memoryUsage,
      cpuUsage: cpuUsage,
      frameDrops: _fpsHistory.where((f) => f < 30).length,
    );
  }

  @override
  Future<List<PerformanceMetrics>> getPerformanceHistory({
    DateTime? since,
    int? limit,
    Duration? period,
  }) async {
    var filtered = _performanceHistory;
    
    if (since != null) {
      filtered = filtered.where((m) => m.timestamp.isAfter(since)).toList();
    }
    
    if (period != null) {
      final cutoff = DateTime.now().subtract(period);
      filtered = filtered.where((m) => m.timestamp.isAfter(cutoff)).toList();
    }
    
    if (limit != null) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }

  // ==========================================================================
  // ALERTAS
  // ==========================================================================

  void _emitAlert(String alertType, Map<String, dynamic> data) {
    final alert = {
      'type': alertType,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };
    
    if (!_alertsController.isClosed) {
      _alertsController.add(alert);
    }
    
    _alertCallback?.call(alertType, data);
  }

  @override
  Stream<Map<String, dynamic>> getPerformanceAlertsStream() => _alertsController.stream;

  @override
  Future<void> setPerformanceAlertCallback(
    void Function(String alertType, Map<String, dynamic> data) callback,
  ) async {
    _alertCallback = callback;
  }

  @override
  Future<List<String>> checkPerformanceIssues() async {
    final issues = <String>[];
    
    final fps = await getCurrentFps();
    if (fps < _thresholds.minFps) {
      issues.add('Low FPS detected: ${fps.toStringAsFixed(1)}');
    }
    
    final memory = await getMemoryUsage();
    if (memory.usagePercentage > _thresholds.maxMemoryUsagePercent) {
      issues.add('High memory usage: ${memory.usagePercentage.toStringAsFixed(1)}%');
    }
    
    final cpu = await getCpuUsage();
    if (cpu > _thresholds.maxCpuUsage) {
      issues.add('High CPU usage: ${cpu.toStringAsFixed(1)}%');
    }
    
    return issues;
  }

  // ==========================================================================
  // UTILITÁRIOS E OUTROS MÉTODOS
  // ==========================================================================

  @override
  Future<Map<String, dynamic>> getPerformanceReport({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    // Implementação básica do relatório
    final metrics = await getCurrentMetrics();
    final fpsMetrics = await getFpsMetrics();
    
    return {
      'current_metrics': {
        'fps': metrics.fps,
        'memory_usage_percent': metrics.memoryUsage.usagePercentage,
        'cpu_usage': metrics.cpuUsage,
      },
      'fps_analysis': {
        'average': fpsMetrics.averageFps,
        'min': fpsMetrics.minFps,
        'max': fpsMetrics.maxFps,
        'jank_percentage': fpsMetrics.jankPercentage,
      },
      'health_status': {
        'fps_healthy': await isFpsHealthy(),
        'memory_healthy': await isMemoryHealthy(),
        'cpu_healthy': await isCpuHealthy(),
      },
      'completed_traces': _completedTraces.length,
      'active_traces': _activeTraces.length,
    };
  }

  @override
  Future<String> exportPerformanceData({
    required String format,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    // Implementação básica de exportação
    final data = await getPerformanceReport(
      startTime: startTime,
      endTime: endTime,
    );
    
    if (format.toLowerCase() == 'json') {
      return data.toString();
    }
    
    throw UnsupportedError('Format $format not supported yet');
  }

  @override
  Future<bool> syncWithFirebase() async {
    try {
      // Sincronização já acontece em tempo real através dos traces
      return true;
    } catch (e) {
      debugPrint('❌ Error syncing with Firebase: $e');
      return false;
    }
  }

  @override
  Future<void> enableFirebaseSync({Duration? interval}) async {
    _config = PerformanceConfig(
      enableFpsMonitoring: _config.enableFpsMonitoring,
      enableMemoryMonitoring: _config.enableMemoryMonitoring,
      enableCpuMonitoring: _config.enableCpuMonitoring,
      enableFirebaseIntegration: true,
      monitoringInterval: _config.monitoringInterval,
      fpsMonitoringInterval: _config.fpsMonitoringInterval,
    );
  }

  @override
  Future<void> disableFirebaseSync() async {
    _config = PerformanceConfig(
      enableFpsMonitoring: _config.enableFpsMonitoring,
      enableMemoryMonitoring: _config.enableMemoryMonitoring,
      enableCpuMonitoring: _config.enableCpuMonitoring,
      enableFirebaseIntegration: false,
      monitoringInterval: _config.monitoringInterval,
      fpsMonitoringInterval: _config.fpsMonitoringInterval,
    );
  }

  @override
  Future<void> clearOldPerformanceData({Duration? olderThan}) async {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(days: 7));
    
    _performanceHistory.removeWhere((metrics) => metrics.timestamp.isBefore(cutoff));
    _completedTraces.removeWhere((trace) => trace.startTime.isBefore(cutoff));
  }

  @override
  Future<Map<String, dynamic>> getDevicePerformanceInfo() async {
    try {
      final deviceInfo = await _deviceInfo.deviceInfo;
      return deviceInfo.data;
    } catch (e) {
      debugPrint('❌ Error getting device info: $e');
      return {};
    }
  }

  @override
  Future<Map<String, bool>> getFeatureSupport() async {
    return {
      'fps_monitoring': true,
      'memory_monitoring': Platform.isAndroid || Platform.isIOS,
      'cpu_monitoring': Platform.isAndroid || Platform.isIOS || Platform.isLinux,
      'firebase_performance': true,
      'custom_traces': true,
      'device_info': true,
    };
  }

  @override
  Future<void> resetAllMetrics() async {
    _fpsHistory.clear();
    _memoryHistory.clear();
    _performanceHistory.clear();
    _completedTraces.clear();
    _frameCount = 0;
  }
}