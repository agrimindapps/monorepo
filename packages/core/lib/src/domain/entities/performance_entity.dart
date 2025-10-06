import 'package:equatable/equatable.dart';

/// Métricas de performance do aplicativo
class PerformanceMetrics extends Equatable {
  const PerformanceMetrics({
    required this.timestamp,
    required this.fps,
    required this.memoryUsage,
    required this.cpuUsage,
    this.batteryLevel,
    this.networkLatency,
    this.renderTime,
    this.frameDrops,
  });

  final DateTime timestamp;
  final double fps;
  final MemoryUsage memoryUsage;
  final double cpuUsage;
  final double? batteryLevel;
  final Duration? networkLatency;
  final Duration? renderTime;
  final int? frameDrops;

  @override
  List<Object?> get props => [
    timestamp, fps, memoryUsage, cpuUsage, 
    batteryLevel, networkLatency, renderTime, frameDrops
  ];
}

/// Informações de uso de memória
class MemoryUsage extends Equatable {
  const MemoryUsage({
    required this.usedMemory,
    required this.totalMemory,
    required this.availableMemory,
    this.heapSize,
    this.nativeHeapSize,
  });

  final int usedMemory;      // em bytes
  final int totalMemory;     // em bytes
  final int availableMemory; // em bytes
  final int? heapSize;       // heap da VM em bytes
  final int? nativeHeapSize; // heap nativo em bytes
  
  /// Percentual de uso de memória
  double get usagePercentage => 
    totalMemory > 0 ? (usedMemory / totalMemory) * 100 : 0;

  /// Memória disponível em MB
  double get availableMemoryMB => availableMemory / (1024 * 1024);

  /// Memória usada em MB
  double get usedMemoryMB => usedMemory / (1024 * 1024);

  /// Memória total em MB
  double get totalMemoryMB => totalMemory / (1024 * 1024);

  @override
  List<Object?> get props => [
    usedMemory, totalMemory, availableMemory, heapSize, nativeHeapSize
  ];
}

/// Métricas de inicialização do aplicativo
class AppStartupMetrics extends Equatable {
  const AppStartupMetrics({
    required this.coldStartTime,
    required this.warmStartTime,
    required this.firstFrameTime,
    required this.timeToInteractive,
    this.splashScreenDuration,
    this.initializationTime,
  });

  final Duration coldStartTime;
  final Duration warmStartTime;
  final Duration firstFrameTime;
  final Duration timeToInteractive;
  final Duration? splashScreenDuration;
  final Duration? initializationTime;

  @override
  List<Object?> get props => [
    coldStartTime, warmStartTime, firstFrameTime, 
    timeToInteractive, splashScreenDuration, initializationTime
  ];
}

/// Métricas de FPS (Frames Per Second)
class FpsMetrics extends Equatable {
  const FpsMetrics({
    required this.currentFps,
    required this.averageFps,
    required this.minFps,
    required this.maxFps,
    required this.frameDrops,
    required this.jankFrames,
    required this.measurementDuration,
  });

  final double currentFps;
  final double averageFps;
  final double minFps;
  final double maxFps;
  final int frameDrops;
  final int jankFrames; // frames que levaram mais de 16ms
  final Duration measurementDuration;

  /// Indica se a performance está boa (>= 50 FPS)
  bool get isPerformanceGood => averageFps >= 50;

  /// Percentual de frames com jank
  double get jankPercentage {
    final totalFrames = (measurementDuration.inMilliseconds / 16.67).round();
    return totalFrames > 0 ? (jankFrames / totalFrames) * 100 : 0;
  }

  @override
  List<Object?> get props => [
    currentFps, averageFps, minFps, maxFps, 
    frameDrops, jankFrames, measurementDuration
  ];
}

/// Resultado de trace customizado
class TraceResult extends Equatable {
  const TraceResult({
    required this.name,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.attributes = const {},
    this.metrics = const {},
  });

  final String name;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, String> attributes;
  final Map<String, double> metrics;

  @override
  List<Object?> get props => [
    name, duration, startTime, endTime, attributes, metrics
  ];
}

/// Configuração de thresholds de performance
class PerformanceThresholds extends Equatable {
  const PerformanceThresholds({
    this.maxMemoryUsagePercent = 80.0,
    this.minFps = 30.0,
    this.maxCpuUsage = 70.0,
    this.maxStartupTime = const Duration(seconds: 5),
    this.maxFrameDrops = 5,
  });

  final double maxMemoryUsagePercent;
  final double minFps;
  final double maxCpuUsage;
  final Duration maxStartupTime;
  final int maxFrameDrops;

  @override
  List<Object?> get props => [
    maxMemoryUsagePercent, minFps, maxCpuUsage, 
    maxStartupTime, maxFrameDrops
  ];
}

/// Tipos de métricas customizadas
enum MetricType {
  counter('counter'),
  gauge('gauge'),
  histogram('histogram'),
  timing('timing');

  const MetricType(this.value);
  final String value;
}

/// Métrica customizada
class CustomMetric extends Equatable {
  const CustomMetric({
    required this.name,
    required this.value,
    required this.type,
    required this.timestamp,
    this.unit,
    this.tags = const {},
  });

  final String name;
  final double value;
  final MetricType type;
  final DateTime timestamp;
  final String? unit;
  final Map<String, String> tags;

  @override
  List<Object?> get props => [name, value, type, timestamp, unit, tags];
}

/// Estado do monitoramento de performance
enum PerformanceMonitoringState {
  stopped('stopped'),
  running('running'),
  paused('paused');

  const PerformanceMonitoringState(this.value);
  final String value;
}

/// Configuração do serviço de performance
class PerformanceConfig extends Equatable {
  const PerformanceConfig({
    this.enableFpsMonitoring = true,
    this.enableMemoryMonitoring = true,
    this.enableCpuMonitoring = false, // CPU pode ser custoso
    this.enableNetworkMonitoring = false,
    this.monitoringInterval = const Duration(seconds: 1),
    this.fpsMonitoringInterval = const Duration(milliseconds: 500),
    this.enableAutomaticTraces = true,
    this.enableFirebaseIntegration = true,
  });

  final bool enableFpsMonitoring;
  final bool enableMemoryMonitoring;
  final bool enableCpuMonitoring;
  final bool enableNetworkMonitoring;
  final Duration monitoringInterval;
  final Duration fpsMonitoringInterval;
  final bool enableAutomaticTraces;
  final bool enableFirebaseIntegration;

  @override
  List<Object?> get props => [
    enableFpsMonitoring, enableMemoryMonitoring, enableCpuMonitoring,
    enableNetworkMonitoring, monitoringInterval, fpsMonitoringInterval,
    enableAutomaticTraces, enableFirebaseIntegration
  ];
}
