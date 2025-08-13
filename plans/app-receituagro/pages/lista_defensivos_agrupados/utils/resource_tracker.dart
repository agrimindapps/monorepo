// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../config/ui_constants.dart';

/// Utilitário para rastrear e gerenciar recursos ativos
class ResourceTracker {
  static final ResourceTracker _instance = ResourceTracker._internal();
  factory ResourceTracker() => _instance;
  ResourceTracker._internal();

  final Map<String, Set<String>> _activeResources = {};
  final Map<String, DateTime> _resourceTimestamps = {};

  /// Registra um recurso como ativo
  void registerResource(String controllerId, String resourceType, String resourceId) {
    if (kDebugMode) {
      _activeResources.putIfAbsent(controllerId, () => <String>{});
      final resourceKey = '$resourceType:$resourceId';
      _activeResources[controllerId]!.add(resourceKey);
      _resourceTimestamps[resourceKey] = DateTime.now();
      
    }
  }

  /// Remove um recurso da lista de ativos
  void unregisterResource(String controllerId, String resourceType, String resourceId) {
    if (kDebugMode) {
      final resourceKey = '$resourceType:$resourceId';
      _activeResources[controllerId]?.remove(resourceKey);
      _resourceTimestamps.remove(resourceKey);
      
      
      // Remove controller se não tem mais recursos
      if (_activeResources[controllerId]?.isEmpty == true) {
        _activeResources.remove(controllerId);
      }
    }
  }

  /// Remove todos os recursos de um controller
  void cleanupController(String controllerId) {
    if (kDebugMode) {
      final resources = _activeResources[controllerId];
      if (resources != null) {
        for (final resource in resources) {
          _resourceTimestamps.remove(resource);
        }
        _activeResources.remove(controllerId);
      }
    }
  }

  /// Obtém total de recursos ativos
  int getTotalActiveResources() {
    return _activeResources.values
        .map((resources) => resources.length)
        .fold(0, (sum, count) => sum + count);
  }

  /// Obtém recursos ativos de um controller específico
  Set<String> getActiveResources(String controllerId) {
    return _activeResources[controllerId] ?? <String>{};
  }

  /// Lista todos os controllers com recursos ativos
  List<String> getActiveControllers() {
    return _activeResources.keys.toList();
  }

  /// Detecta vazamentos de recursos (recursos muito antigos)
  List<String> detectLeaks({Duration threshold = const Duration(minutes: MonitoringConstants.resourceLeakThresholdMinutes)}) {
    final now = DateTime.now();
    final leaks = <String>[];
    
    _resourceTimestamps.forEach((resource, timestamp) {
      if (now.difference(timestamp) > threshold) {
        leaks.add(resource);
      }
    });
    
    return leaks;
  }

  /// Gera relatório de recursos ativos
  void printResourceReport() {
    if (kDebugMode) {
      
      _activeResources.forEach((controllerId, resources) {
        for (final resource in resources) {
          final timestamp = _resourceTimestamps[resource];
          final age = timestamp != null ? DateTime.now().difference(timestamp) : null;
        }
      });
      
      final leaks = detectLeaks();
      if (leaks.isNotEmpty) {
        for (final leak in leaks) {
        }
      }
      
    }
  }

  /// Limpa todos os recursos (usar apenas em casos extremos)
  void clearAll() {
    if (kDebugMode) {
      final totalResources = getTotalActiveResources();
      _activeResources.clear();
      _resourceTimestamps.clear();
    }
  }
}
