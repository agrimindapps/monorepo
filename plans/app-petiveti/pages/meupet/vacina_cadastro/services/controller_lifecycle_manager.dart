// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controllers/vacina_cadastro_controller.dart';

/// Manages the lifecycle of VacinaCadastroController instances to prevent memory leaks
/// 
/// This service implements a pool-based approach to controller management,
/// reusing instances where possible and ensuring proper cleanup of resources.
class ControllerLifecycleManager {
  static final ControllerLifecycleManager _instance = ControllerLifecycleManager._internal();
  factory ControllerLifecycleManager() => _instance;
  ControllerLifecycleManager._internal();

  final Map<String, VacinaCadastroController> _controllerPool = {};
  final Map<String, Timer> _cleanupTimers = {};
  final Map<String, int> _usageCount = {};
  
  static const Duration cleanupDelay = Duration(minutes: 5);
  static const int maxPoolSize = 3;

  /// Gets or creates a controller instance for the given context
  VacinaCadastroController getController(String contextId) {
    // Cancel any pending cleanup for this context
    _cancelCleanupTimer(contextId);
    
    // Check if we already have a controller for this context
    if (_controllerPool.containsKey(contextId)) {
      final controller = _controllerPool[contextId]!;
      _incrementUsage(contextId);
      return controller;
    }

    // Try to reuse an existing controller if pool is not full
    if (_controllerPool.length < maxPoolSize) {
      final controller = VacinaCadastroController();
      _controllerPool[contextId] = controller;
      _usageCount[contextId] = 1;
      
      // Register in GetX with the context ID
      Get.put(controller, tag: contextId);
      
      return controller;
    }

    // Pool is full, find least used controller to replace
    final leastUsedEntry = _usageCount.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );
    
    // Clean up the least used controller
    _forceCleanupController(leastUsedEntry.key);
    
    // Create new controller
    final controller = VacinaCadastroController();
    _controllerPool[contextId] = controller;
    _usageCount[contextId] = 1;
    
    Get.put(controller, tag: contextId);
    
    return controller;
  }

  /// Releases a controller instance (schedules for cleanup)
  void releaseController(String contextId) {
    if (!_controllerPool.containsKey(contextId)) return;

    _decrementUsage(contextId);
    
    // Schedule cleanup after delay
    _scheduleCleanup(contextId);
  }

  /// Forces immediate cleanup of a controller
  void _forceCleanupController(String contextId) {
    _cancelCleanupTimer(contextId);
    
    final controller = _controllerPool[contextId];
    if (controller != null) {
      // Dispose the controller
      controller.onClose();
      
      // Remove from GetX
      if (Get.isRegistered<VacinaCadastroController>(tag: contextId)) {
        Get.delete<VacinaCadastroController>(tag: contextId);
      }
      
      // Remove from our tracking
      _controllerPool.remove(contextId);
      _usageCount.remove(contextId);
    }
  }

  /// Schedules controller cleanup after a delay
  void _scheduleCleanup(String contextId) {
    _cancelCleanupTimer(contextId);
    
    _cleanupTimers[contextId] = Timer(cleanupDelay, () {
      _forceCleanupController(contextId);
    });
  }

  /// Cancels pending cleanup timer
  void _cancelCleanupTimer(String contextId) {
    final timer = _cleanupTimers[contextId];
    if (timer != null) {
      timer.cancel();
      _cleanupTimers.remove(contextId);
    }
  }

  /// Increments usage count
  void _incrementUsage(String contextId) {
    _usageCount[contextId] = (_usageCount[contextId] ?? 0) + 1;
  }

  /// Decrements usage count
  void _decrementUsage(String contextId) {
    final currentCount = _usageCount[contextId] ?? 0;
    if (currentCount > 0) {
      _usageCount[contextId] = currentCount - 1;
    }
  }

  /// Gets controller statistics for debugging
  Map<String, dynamic> getStats() {
    return {
      'activeControllers': _controllerPool.length,
      'pendingCleanups': _cleanupTimers.length,
      'totalUsage': _usageCount.values.fold(0, (sum, count) => sum + count),
      'controllers': _controllerPool.keys.toList(),
      'usageCount': Map.from(_usageCount),
    };
  }

  /// Clears all controllers (for testing or emergency cleanup)
  void clearAll() {
    for (final contextId in _controllerPool.keys.toList()) {
      _forceCleanupController(contextId);
    }
    
    // Cancel all pending timers
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
  }

  /// Performs maintenance cleanup (removes unused controllers)
  void performMaintenance() {
    final staleControllers = <String>[];
    
    // Find controllers with zero usage that have been idle
    for (final entry in _usageCount.entries) {
      if (entry.value == 0 && !_cleanupTimers.containsKey(entry.key)) {
        staleControllers.add(entry.key);
      }
    }
    
    // Clean up stale controllers
    for (final contextId in staleControllers) {
      _forceCleanupController(contextId);
    }
  }
}

/// Extension to provide a convenient way to get managed controllers
extension ControllerLifecycleExtension on String {
  /// Gets a managed controller instance for this context ID
  VacinaCadastroController getManagedController() {
    return ControllerLifecycleManager().getController(this);
  }
  
  /// Releases the managed controller for this context ID
  void releaseManagedController() {
    ControllerLifecycleManager().releaseController(this);
  }
}
