// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../config/ui_constants.dart';

/// Monitor de memória para detectar vazamentos
class MemoryMonitor {
  static final MemoryMonitor _instance = MemoryMonitor._internal();
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();

  final Map<String, Map<String, dynamic>> _memorySnapshots = {};
  bool _isMonitoring = false;

  /// Inicia o monitoramento de memória
  void startMonitoring({Duration interval = const Duration(seconds: MonitoringConstants.memoryMonitoringIntervalSeconds)}) {
    if (_isMonitoring || !kDebugMode) return;
    
    _isMonitoring = true;
    
    _scheduleNextSnapshot(interval);
  }

  /// Para o monitoramento de memória
  void stopMonitoring() {
    _isMonitoring = false;
  }

  /// Agenda o próximo snapshot de memória
  void _scheduleNextSnapshot(Duration interval) {
    if (!_isMonitoring) return;
    
    Future.delayed(interval, () {
      _takeMemorySnapshot();
      _scheduleNextSnapshot(interval);
    });
  }

  /// Captura um snapshot da memória atual
  void _takeMemorySnapshot() {
    if (!kDebugMode) return;
    
    try {
      // Força garbage collection para obter medição mais precisa
      // developer.gc(); // Não disponível em todas as plataformas
      
      final timestamp = DateTime.now();
      final memoryInfo = _getMemoryInfo();
      
      _memorySnapshots[timestamp.toIso8601String()] = {
        'timestamp': timestamp,
        'memory': memoryInfo,
      };
      
      // Manter apenas os últimos snapshots conforme configuração
      if (_memorySnapshots.length > MonitoringConstants.maxMemorySnapshots) {
        final oldestKey = _memorySnapshots.keys.first;
        _memorySnapshots.remove(oldestKey);
      }
      
      _analyzeMemoryTrend();
      
    } catch (e) {
      // Error monitoring memory - continue without monitoring
    }
  }

  /// Obtém informações de memória
  Map<String, dynamic> _getMemoryInfo() {
    return {
      'used': _getCurrentMemoryUsage(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Obtém uso atual de memória (simulado - Flutter não expõe APIs nativas)
  double _getCurrentMemoryUsage() {
    // Em uma implementação real, usaríamos APIs específicas da plataforma
    // Por enquanto, retornamos um valor baseado no timestamp para demonstração
    return DateTime.now().millisecondsSinceEpoch % 
           PerformanceConstants.memoryCalculationModulo / 
           PerformanceConstants.memoryCalculationDivisor;
  }

  /// Analisa tendência de uso de memória
  void _analyzeMemoryTrend() {
    if (_memorySnapshots.length < PerformanceConstants.memoryTrendAnalysisWindow) return;
    
    final snapshots = _memorySnapshots.values.toList();
    final recent = snapshots.length > PerformanceConstants.memoryTrendAnalysisWindow ? 
        snapshots.sublist(snapshots.length - PerformanceConstants.memoryTrendAnalysisWindow) : 
        snapshots;
    
    final memoryValues = recent.map((s) => s['memory']['used'] as double).toList();
    
    // Verifica se há tendência crescente
    bool isIncreasing = true;
    for (int i = 1; i < memoryValues.length; i++) {
      if (memoryValues[i] <= memoryValues[i - 1]) {
        isIncreasing = false;
        break;
      }
    }
    
    if (isIncreasing) {
      final increase = memoryValues.last - memoryValues.first;
      if (increase > MonitoringConstants.memoryLeakThresholdMB) { // Threshold de aumento suspeito
        _printMemoryReport();
      }
    }
  }

  /// Gera relatório de memória
  void _printMemoryReport() {
    if (!kDebugMode || _memorySnapshots.isEmpty) return;
    
    
    final snapshots = _memorySnapshots.values.toList();
    final latest = snapshots.last;
    final oldest = snapshots.first;
    
    final latestMemory = latest['memory']['used'] as double;
    final oldestMemory = oldest['memory']['used'] as double;
    final difference = latestMemory - oldestMemory;
    
    
    // Mostrar últimos 5 snapshots
    final recent = snapshots.length > 5 ? snapshots.sublist(snapshots.length - 5) : snapshots;
    for (final snapshot in recent) {
      final timestamp = snapshot['timestamp'] as DateTime;
      final memory = snapshot['memory']['used'] as double;
      final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    }
    
  }

  /// Força captura de snapshot manual
  void captureSnapshot(String label) {
    if (!kDebugMode) return;
    
    _takeMemorySnapshot();
  }

  /// Obtém estatísticas de memória
  Map<String, dynamic> getMemoryStats() {
    if (_memorySnapshots.isEmpty) {
      return {'error': 'Nenhum snapshot disponível'};
    }
    
    final snapshots = _memorySnapshots.values.toList();
    final memoryValues = snapshots.map((s) => s['memory']['used'] as double).toList();
    
    memoryValues.sort();
    
    return {
      'current': memoryValues.last,
      'min': memoryValues.first,
      'max': memoryValues.last,
      'average': memoryValues.reduce((a, b) => a + b) / memoryValues.length,
      'snapshots_count': _memorySnapshots.length,
      'monitoring': _isMonitoring,
    };
  }

  /// Limpa histórico de snapshots
  void clearHistory() {
    _memorySnapshots.clear();
  }
}
