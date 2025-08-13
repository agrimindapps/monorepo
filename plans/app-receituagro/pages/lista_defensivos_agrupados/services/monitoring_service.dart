// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../utils/memory_monitor.dart';
import '../utils/resource_tracker.dart';

abstract class IMonitoringService {
  void initializeMonitoring(String controllerId);
  void registerResource(String resourceType, String resourceId);
  void unregisterResource(String resourceType, String resourceId);
  void registerListener(String listenerType, VoidCallback disposeCallback);
  void registerWorker(String workerType);
  void unregisterWorker(String workerType);
  void captureMemorySnapshot(String label);
  void printResourceReport();
  void cleanupAllResources();
  void startMemoryMonitoring();
  void stopMemoryMonitoring();
}

class MonitoringService implements IMonitoringService {
  final ResourceTracker _resourceTracker;
  final MemoryMonitor _memoryMonitor;
  late final String _controllerId;
  final List<VoidCallback> _disposables = [];

  MonitoringService({
    ResourceTracker? resourceTracker,
    MemoryMonitor? memoryMonitor,
  })  : _resourceTracker = resourceTracker ?? ResourceTracker(),
        _memoryMonitor = memoryMonitor ?? MemoryMonitor();

  @override
  void initializeMonitoring(String controllerId) {
    _controllerId = controllerId;
    _resourceTracker.registerResource(_controllerId, 'controller', 'main');
    
    if (kDebugMode) {
      startMemoryMonitoring();
      captureMemorySnapshot('Controller $_controllerId iniciado');
    }
  }

  @override
  void registerResource(String resourceType, String resourceId) {
    _resourceTracker.registerResource(_controllerId, resourceType, resourceId);
  }

  @override
  void unregisterResource(String resourceType, String resourceId) {
    _resourceTracker.unregisterResource(_controllerId, resourceType, resourceId);
  }

  @override
  void registerListener(String listenerType, VoidCallback disposeCallback) {
    _disposables.add(disposeCallback);
    registerResource('listener', listenerType);
  }

  @override
  void registerWorker(String workerType) {
    registerResource('worker', workerType);
  }

  @override
  void unregisterWorker(String workerType) {
    unregisterResource('worker', workerType);
  }

  @override
  void captureMemorySnapshot(String label) {
    if (kDebugMode) {
      _memoryMonitor.captureSnapshot(label);
    }
  }

  @override
  void printResourceReport() {
    if (kDebugMode) {
      _resourceTracker.printResourceReport();
    }
  }

  @override
  void startMemoryMonitoring() {
    if (kDebugMode) {
      _memoryMonitor.startMonitoring();
    }
  }

  @override
  void stopMemoryMonitoring() {
    _memoryMonitor.stopMonitoring();
  }

  @override
  void cleanupAllResources() {
    if (!kDebugMode) return;
    
    
    // Imprimir relatório de recursos antes da limpeza
    printResourceReport();
    
    // Remover todos os listeners trackeados
    for (final dispose in _disposables) {
      try {
        dispose();
      } catch (e) {
        debugPrint('⚠️ Erro ao remover listener: $e');
      }
    }
    _disposables.clear();
    
    // Cleanup completo do controller no tracker
    _resourceTracker.cleanupController(_controllerId);
    
    // Capturar snapshot final de memória
    captureMemorySnapshot('Controller $_controllerId finalizado');
    
    
    // Imprimir relatório final
    printResourceReport();
  }
}
