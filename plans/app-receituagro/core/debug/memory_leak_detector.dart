// Dart imports:
import 'dart:collection';
import 'dart:developer' as developer;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../mixins/disposable_mixin.dart';

/// Detector de vazamentos de memória para debug mode
/// 
/// Monitora controllers que usam DisposableMixin e detecta vazamentos
/// potenciais baseado em análise de recursos não limpos e tempo de vida.
/// 
/// Funciona apenas em debug mode para não impactar performance de produção.
class MemoryLeakDetector {
  static const String _logTag = '[MEMORY_LEAK_DETECTOR]';
  
  // Singleton para controle global
  static MemoryLeakDetector? _instance;
  static MemoryLeakDetector get instance => _instance ??= MemoryLeakDetector._();
  
  MemoryLeakDetector._();
  
  // Tracking de controllers registrados
  final Map<String, ControllerLeakInfo> _trackedControllers = <String, ControllerLeakInfo>{};
  final Queue<LeakEvent> _leakHistory = Queue<LeakEvent>();
  bool _isEnabled = kDebugMode;
  
  /// Habilita/desabilita o detector
  bool get isEnabled => _isEnabled;
  set isEnabled(bool enabled) {
    _isEnabled = enabled && kDebugMode; // Força desabilitar em produção
    _logDebug('Memory leak detection ${_isEnabled ? 'enabled' : 'disabled'}');
  }
  
  /// Registra um controller para monitoramento
  void registerController(DisposableMixin controller) {
    if (!_isEnabled) return;
    
    final controllerId = _getControllerId(controller);
    final info = ControllerLeakInfo(
      controller: controller,
      registrationTime: DateTime.now(),
      controllerType: controller.runtimeType.toString(),
    );
    
    _trackedControllers[controllerId] = info;
    _logDebug('Controller registered: ${info.controllerType} (id: $controllerId)');
  }
  
  /// Remove um controller do monitoramento
  void unregisterController(DisposableMixin controller) {
    if (!_isEnabled) return;
    
    final controllerId = _getControllerId(controller);
    final info = _trackedControllers.remove(controllerId);
    
    if (info != null) {
      _analyzeControllerDisposal(info);
      _logDebug('Controller unregistered: ${info.controllerType} (id: $controllerId)');
    }
  }
  
  /// Analisa todos os controllers registrados em busca de vazamentos
  LeakDetectionReport analyzeLeaks() {
    if (!_isEnabled) {
      return LeakDetectionReport.empty();
    }
    
    final now = DateTime.now();
    final leaks = <LeakInfo>[];
    final warnings = <String>[];
    
    _trackedControllers.forEach((controllerId, info) {
      final controller = info.controller;
      final age = now.difference(info.registrationTime);
      
      // Análise 1: Controller muito antigo sem dispose
      if (age.inMinutes > 10) {
        leaks.add(LeakInfo(
          controllerId: controllerId,
          controllerType: info.controllerType,
          leakType: LeakType.longLivedController,
          description: 'Controller exists for ${age.inMinutes} minutes without disposal',
          severity: LeakSeverity.warning,
          resourceCount: controller.getTotalResourcesCount(),
        ));
      }
      
      // Análise 2: Muitos recursos ativos
      final resourceCount = controller.getTotalResourcesCount();
      if (resourceCount > 20) {
        leaks.add(LeakInfo(
          controllerId: controllerId,
          controllerType: info.controllerType,
          leakType: LeakType.excessiveResources,
          description: 'Controller has $resourceCount active resources',
          severity: LeakSeverity.error,
          resourceCount: resourceCount,
        ));
      }
      
      // Análise 3: Controller descartado mas ainda com recursos
      if (controller.isDisposed && controller.hasActiveResources()) {
        leaks.add(LeakInfo(
          controllerId: controllerId,
          controllerType: info.controllerType,
          leakType: LeakType.resourcesAfterDispose,
          description: 'Controller disposed but has ${controller.getTotalResourcesCount()} active resources',
          severity: LeakSeverity.critical,
          resourceCount: controller.getTotalResourcesCount(),
        ));
      }
    });
    
    // Gera warnings gerais
    if (_trackedControllers.length > 50) {
      warnings.add('High number of tracked controllers: ${_trackedControllers.length}');
    }
    
    final report = LeakDetectionReport(
      timestamp: now,
      totalControllers: _trackedControllers.length,
      leaks: leaks,
      warnings: warnings,
    );
    
    _logReport(report);
    return report;
  }
  
  /// Força uma análise completa e gera relatório
  void performFullAnalysis() {
    if (!_isEnabled) return;
    
    final report = analyzeLeaks();
    
    if (report.hasLeaks) {
      _logDebug('=== MEMORY LEAK ANALYSIS RESULTS ===');
      _logDebug('Total controllers tracked: ${report.totalControllers}');
      _logDebug('Leaks found: ${report.leaks.length}');
      
      for (final leak in report.leaks) {
        _logDebug('${leak.severity.name.toUpperCase()}: ${leak.controllerType} - ${leak.description}');
      }
      
      if (report.warnings.isNotEmpty) {
        _logDebug('Warnings: ${report.warnings.join(', ')}');
      }
      
      // Em caso crítico, força um assert
      final criticalLeaks = report.leaks.where((l) => l.severity == LeakSeverity.critical);
      if (criticalLeaks.isNotEmpty) {
        final criticalTypes = criticalLeaks.map((l) => l.controllerType).toSet().join(', ');
        assert(false, 'CRITICAL MEMORY LEAKS detected in: $criticalTypes');
      }
    }
  }
  
  /// Obtém estatísticas do detector
  Map<String, dynamic> getStatistics() {
    if (!_isEnabled) return {'enabled': false};
    
    final resourcesByType = <String, int>{};
    var totalResources = 0;
    
    _trackedControllers.forEach((id, info) {
      final controller = info.controller;
      final resources = controller.getTotalResourcesCount();
      totalResources += resources;
      
      final type = info.controllerType;
      resourcesByType[type] = (resourcesByType[type] ?? 0) + resources;
    });
    
    return {
      'enabled': _isEnabled,
      'trackedControllers': _trackedControllers.length,
      'totalResources': totalResources,
      'resourcesByType': resourcesByType,
      'leakHistorySize': _leakHistory.length,
    };
  }
  
  /// Limpa o histórico e redefine o detector
  void reset() {
    if (!_isEnabled) return;
    
    _trackedControllers.clear();
    _leakHistory.clear();
    _logDebug('Memory leak detector reset');
  }
  
  // ========== MÉTODOS PRIVADOS ==========
  
  String _getControllerId(DisposableMixin controller) {
    return '${controller.runtimeType}_${controller.hashCode}';
  }
  
  void _analyzeControllerDisposal(ControllerLeakInfo info) {
    final controller = info.controller;
    final disposeTime = DateTime.now();
    final lifetime = disposeTime.difference(info.registrationTime);
    
    // Registra evento de dispose
    final event = LeakEvent(
      timestamp: disposeTime,
      eventType: LeakEventType.controllerDisposed,
      controllerId: _getControllerId(controller),
      controllerType: info.controllerType,
      details: {
        'lifetime': lifetime.inMilliseconds,
        'resourcesAtDispose': controller.getTotalResourcesCount(),
        'wasCleanedProperly': !controller.hasActiveResources(),
      },
    );
    
    _leakHistory.add(event);
    
    // Mantém apenas os últimos 100 eventos
    while (_leakHistory.length > 100) {
      _leakHistory.removeFirst();
    }
    
    // Log se houve vazamento
    if (controller.hasActiveResources()) {
      _logDebug('WARNING: Controller ${info.controllerType} disposed with ${controller.getTotalResourcesCount()} active resources');
    }
  }
  
  void _logReport(LeakDetectionReport report) {
    if (report.hasLeaks) {
      final criticalCount = report.leaks.where((l) => l.severity == LeakSeverity.critical).length;
      final errorCount = report.leaks.where((l) => l.severity == LeakSeverity.error).length;
      final warningCount = report.leaks.where((l) => l.severity == LeakSeverity.warning).length;
      
      _logDebug('Leak analysis: $criticalCount critical, $errorCount errors, $warningCount warnings');
    }
  }
  
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('$_logTag $message');
      developer.log(message, name: 'MemoryLeakDetector');
    }
  }
}

// ========== CLASSES DE DADOS ==========

/// Informações sobre um controller sendo monitorado
class ControllerLeakInfo {
  final DisposableMixin controller;
  final DateTime registrationTime;
  final String controllerType;
  
  ControllerLeakInfo({
    required this.controller,
    required this.registrationTime,
    required this.controllerType,
  });
}

/// Relatório de análise de vazamentos
class LeakDetectionReport {
  final DateTime timestamp;
  final int totalControllers;
  final List<LeakInfo> leaks;
  final List<String> warnings;
  
  LeakDetectionReport({
    required this.timestamp,
    required this.totalControllers,
    required this.leaks,
    required this.warnings,
  });
  
  bool get hasLeaks => leaks.isNotEmpty;
  bool get hasCriticalLeaks => leaks.any((l) => l.severity == LeakSeverity.critical);
  bool get hasWarnings => warnings.isNotEmpty;
  
  LeakDetectionReport.empty()
      : timestamp = DateTime.now(),
        totalControllers = 0,
        leaks = const [],
        warnings = const [];
}

/// Informações sobre um vazamento específico
class LeakInfo {
  final String controllerId;
  final String controllerType;
  final LeakType leakType;
  final String description;
  final LeakSeverity severity;
  final int resourceCount;
  
  LeakInfo({
    required this.controllerId,
    required this.controllerType,
    required this.leakType,
    required this.description,
    required this.severity,
    required this.resourceCount,
  });
}

/// Evento no histórico de vazamentos
class LeakEvent {
  final DateTime timestamp;
  final LeakEventType eventType;
  final String controllerId;
  final String controllerType;
  final Map<String, dynamic> details;
  
  LeakEvent({
    required this.timestamp,
    required this.eventType,
    required this.controllerId,
    required this.controllerType,
    required this.details,
  });
}

// ========== ENUMS ==========

enum LeakType {
  longLivedController,
  excessiveResources,
  resourcesAfterDispose,
  memoryGrowth,
}

enum LeakSeverity {
  warning,
  error,
  critical,
}

enum LeakEventType {
  controllerRegistered,
  controllerDisposed,
  leakDetected,
  resourceThresholdExceeded,
}