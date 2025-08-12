// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'box_manager.dart';
import 'veiculo_index.dart';

/// Centralized service lifecycle management for the veiculos module
///
/// This manager coordinates the initialization, dependency resolution, and
/// shutdown of all services in a predictable and reliable manner.
class VeiculosServiceManager {
  static VeiculosServiceManager? _instance;
  static VeiculosServiceManager get instance =>
      _instance ??= VeiculosServiceManager._internal();

  VeiculosServiceManager._internal();

  /// ========================================
  /// SERVICE REGISTRY AND STATE
  /// ========================================

  /// Registry of managed services with their metadata
  final Map<Type, ServiceInfo> _services = <Type, ServiceInfo>{};

  /// Service initialization order based on dependencies
  final List<Type> _initializationOrder = <Type>[];

  /// Currently initializing services to prevent circular dependencies
  final Set<Type> _initializing = <Type>{};

  /// Manager state
  bool _isInitialized = false;
  bool _isShuttingDown = false;

  /// Health check timer
  Timer? _healthCheckTimer;

  /// ========================================
  /// SERVICE CONFIGURATION
  /// ========================================

  /// Define service configurations with dependencies and lifecycle
  static const Map<Type, ServiceConfig> _serviceConfigs = {
    BoxManager: ServiceConfig(
      name: 'BoxManager',
      priority: ServicePriority.critical,
      dependencies: [],
      hasState: true,
      healthCheckInterval: Duration(minutes: 5),
    ),
    VeiculoIndex: ServiceConfig(
      name: 'VeiculoIndex',
      priority: ServicePriority.high,
      dependencies: [],
      hasState: true,
      healthCheckInterval: Duration(minutes: 10),
    ),
  };

  /// ========================================
  /// INITIALIZATION
  /// ========================================

  /// Initialize all services in the correct order
  static Future<void> initialize() async {
    final manager = VeiculosServiceManager.instance;
    await manager._initialize();
  }

  /// Internal initialization implementation
  Future<void> _initialize() async {
    if (_isInitialized) {
      debugPrint('VeiculosServiceManager: Already initialized');
      return;
    }

    _isShuttingDown = false;
    final stopwatch = Stopwatch()..start();

    debugPrint('VeiculosServiceManager: Starting initialization...');

    try {
      // Build dependency graph and initialization order
      _buildInitializationOrder();

      // Initialize services in dependency order
      await _initializeServices();

      // Start health monitoring
      _startHealthMonitoring();

      _isInitialized = true;
      stopwatch.stop();

      debugPrint(
          'VeiculosServiceManager: Initialization completed in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint(
          'VeiculosServiceManager: ${_services.length} services initialized');
    } catch (e) {
      stopwatch.stop();
      debugPrint('VeiculosServiceManager: Initialization failed: $e');
      await _cleanup();
      rethrow;
    }
  }

  /// Build the correct initialization order based on dependencies
  void _buildInitializationOrder() {
    _initializationOrder.clear();
    final visited = <Type>{};
    final visiting = <Type>{};

    // Sort by priority first, then resolve dependencies
    final sortedConfigs = _serviceConfigs.entries.toList()
      ..sort(
          (a, b) => b.value.priority.index.compareTo(a.value.priority.index));

    for (final entry in sortedConfigs) {
      _visitService(entry.key, visited, visiting);
    }
  }

  /// Topological sort for dependency resolution
  void _visitService(Type serviceType, Set<Type> visited, Set<Type> visiting) {
    if (visited.contains(serviceType)) return;
    if (visiting.contains(serviceType)) {
      throw StateError('Circular dependency detected involving $serviceType');
    }

    visiting.add(serviceType);

    final config = _serviceConfigs[serviceType];
    if (config != null) {
      // Visit dependencies first
      for (final dependency in config.dependencies) {
        _visitService(dependency, visited, visiting);
      }
    }

    visiting.remove(serviceType);
    visited.add(serviceType);
    _initializationOrder.add(serviceType);
  }

  /// Initialize all services in the correct order
  Future<void> _initializeServices() async {
    for (final serviceType in _initializationOrder) {
      await _initializeService(serviceType);
    }
  }

  /// Initialize a specific service
  Future<void> _initializeService(Type serviceType) async {
    if (_initializing.contains(serviceType)) {
      throw StateError('Service $serviceType is already being initialized');
    }

    final config = _serviceConfigs[serviceType];
    if (config == null) {
      debugPrint(
          'VeiculosServiceManager: No configuration found for $serviceType');
      return;
    }

    _initializing.add(serviceType);
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('VeiculosServiceManager: Initializing ${config.name}...');

      dynamic service;

      // Initialize specific services
      if (serviceType == BoxManager) {
        await BoxManager.initialize();
        service = BoxManager.instance;
      } else if (serviceType == VeiculoIndex) {
        service = VeiculoIndex.instance;
        // VeiculoIndex will be initialized when data is first loaded
      } else {
        debugPrint('VeiculosServiceManager: Unknown service type $serviceType');
        return;
      }

      // Register service info
      _services[serviceType] = ServiceInfo(
        service: service,
        config: config,
        initializationTime: DateTime.now(),
        isHealthy: true,
      );

      stopwatch.stop();
      debugPrint(
          'VeiculosServiceManager: ${config.name} initialized in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          'VeiculosServiceManager: Failed to initialize ${config.name}: $e');

      // Register failed service for tracking
      _services[serviceType] = ServiceInfo(
        service: null,
        config: config,
        initializationTime: DateTime.now(),
        isHealthy: false,
        lastError: e.toString(),
      );

      // For critical services, fail the entire initialization
      if (config.priority == ServicePriority.critical) {
        rethrow;
      }
    } finally {
      _initializing.remove(serviceType);
    }
  }

  /// ========================================
  /// SERVICE ACCESS
  /// ========================================

  /// Get a service instance with type safety
  T? getService<T>() {
    final serviceInfo = _services[T];
    if (serviceInfo == null) {
      debugPrint('VeiculosServiceManager: Service $T not registered');
      return null;
    }

    if (!serviceInfo.isHealthy) {
      debugPrint('VeiculosServiceManager: Service $T is not healthy');
      return null;
    }

    return serviceInfo.service as T?;
  }

  /// Check if a service is registered and healthy
  bool isServiceHealthy<T>() {
    final serviceInfo = _services[T];
    return serviceInfo?.isHealthy ?? false;
  }

  /// Get service information
  ServiceInfo? getServiceInfo<T>() {
    return _services[T];
  }

  /// Get all service statuses
  Map<Type, ServiceStatus> getServicesStatus() {
    return _services.map((type, info) => MapEntry(
          type,
          ServiceStatus(
            name: info.config.name,
            isHealthy: info.isHealthy,
            initializationTime: info.initializationTime,
            lastHealthCheck: info.lastHealthCheck,
            lastError: info.lastError,
            priority: info.config.priority,
          ),
        ));
  }

  /// ========================================
  /// HEALTH MONITORING
  /// ========================================

  /// Start periodic health monitoring
  void _startHealthMonitoring() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isShuttingDown) {
        timer.cancel();
        return;
      }

      _performHealthChecks();
    });
  }

  /// Perform health checks on all services
  Future<void> _performHealthChecks() async {
    debugPrint('VeiculosServiceManager: Performing health checks...');

    for (final entry in _services.entries) {
      await _checkServiceHealth(entry.key, entry.value);
    }
  }

  /// Check health of a specific service
  Future<void> _checkServiceHealth(
      Type serviceType, ServiceInfo serviceInfo) async {
    try {
      bool isHealthy = false;

      if (serviceType == BoxManager) {
        final boxManager = serviceInfo.service as BoxManager?;
        if (boxManager != null) {
          // Check if BoxManager can access its configured boxes
          final healthStatus = await boxManager.getHealthStatus();
          isHealthy = healthStatus.values.every((status) => status.isHealthy);
        }
      } else if (serviceType == VeiculoIndex) {
        final index = serviceInfo.service as VeiculoIndex?;
        if (index != null) {
          // Check if index is built and responsive
          isHealthy = index.isBuilt;
        }
      } else {
        // Default health check - just verify service exists
        isHealthy = serviceInfo.service != null;
      }

      serviceInfo.isHealthy = isHealthy;
      serviceInfo.lastHealthCheck = DateTime.now();

      if (!isHealthy) {
        debugPrint(
            'VeiculosServiceManager: Health check failed for ${serviceInfo.config.name}');
      }
    } catch (e) {
      serviceInfo.isHealthy = false;
      serviceInfo.lastError = e.toString();
      serviceInfo.lastHealthCheck = DateTime.now();

      debugPrint(
          'VeiculosServiceManager: Health check error for ${serviceInfo.config.name}: $e');
    }
  }

  /// Force health check for a specific service
  Future<bool> checkServiceHealth<T>() async {
    final serviceInfo = _services[T];
    if (serviceInfo == null) return false;

    await _checkServiceHealth(T, serviceInfo);
    return serviceInfo.isHealthy;
  }

  /// ========================================
  /// LIFECYCLE MANAGEMENT
  /// ========================================

  /// Restart a failed service
  Future<bool> restartService<T>() async {
    if (_isShuttingDown) return false;

    debugPrint('VeiculosServiceManager: Restarting service $T...');

    try {
      // Remove current service instance
      _services.remove(T);

      // Reinitialize the service
      await _initializeService(T);

      final serviceInfo = _services[T];
      return serviceInfo?.isHealthy ?? false;
    } catch (e) {
      debugPrint('VeiculosServiceManager: Failed to restart service $T: $e');
      return false;
    }
  }

  /// Graceful shutdown of all services
  static Future<void> shutdown() async {
    final manager = VeiculosServiceManager.instance;
    await manager._shutdown();
  }

  /// Internal shutdown implementation
  Future<void> _shutdown() async {
    if (_isShuttingDown) return;

    _isShuttingDown = true;
    debugPrint('VeiculosServiceManager: Starting graceful shutdown...');

    // Stop health monitoring
    _healthCheckTimer?.cancel();

    // Shutdown services in reverse order
    final shutdownOrder = _initializationOrder.reversed.toList();

    for (final serviceType in shutdownOrder) {
      await _shutdownService(serviceType);
    }

    await _cleanup();
    debugPrint('VeiculosServiceManager: Shutdown completed');
  }

  /// Shutdown a specific service
  Future<void> _shutdownService(Type serviceType) async {
    final serviceInfo = _services[serviceType];
    if (serviceInfo == null) return;

    try {
      debugPrint(
          'VeiculosServiceManager: Shutting down ${serviceInfo.config.name}...');

      if (serviceType == BoxManager) {
        final boxManager = serviceInfo.service as BoxManager?;
        await boxManager?.shutdown();
      } else if (serviceType == VeiculoIndex) {
        final index = serviceInfo.service as VeiculoIndex?;
        index?.clearCache();
      }
    } catch (e) {
      debugPrint(
          'VeiculosServiceManager: Error shutting down ${serviceInfo.config.name}: $e');
    }
  }

  /// Cleanup internal state
  Future<void> _cleanup() async {
    _services.clear();
    _initializationOrder.clear();
    _initializing.clear();
    _isInitialized = false;
    _healthCheckTimer?.cancel();
  }

  /// ========================================
  /// UTILITY METHODS
  /// ========================================

  /// Get manager status
  ManagerStatus getStatus() {
    return ManagerStatus(
      isInitialized: _isInitialized,
      isShuttingDown: _isShuttingDown,
      serviceCount: _services.length,
      healthyServiceCount:
          _services.values.where((info) => info.isHealthy).length,
      criticalServiceCount: _services.values
          .where((info) => info.config.priority == ServicePriority.critical)
          .length,
    );
  }

  /// Check if all critical services are healthy
  bool get areAllCriticalServicesHealthy {
    return _services.values
        .where((info) => info.config.priority == ServicePriority.critical)
        .every((info) => info.isHealthy);
  }

  /// Get initialization summary
  String getInitializationSummary() {
    final status = getStatus();
    return 'VeiculosServiceManager: ${status.healthyServiceCount}/${status.serviceCount} services healthy, '
        'Critical services: ${status.criticalServiceCount}';
  }
}

/// ========================================
/// SUPPORTING CLASSES
/// ========================================

/// Service configuration
class ServiceConfig {
  final String name;
  final ServicePriority priority;
  final List<Type> dependencies;
  final bool hasState;
  final Duration? healthCheckInterval;

  const ServiceConfig({
    required this.name,
    required this.priority,
    required this.dependencies,
    required this.hasState,
    this.healthCheckInterval,
  });
}

/// Service priority levels
enum ServicePriority {
  low,
  medium,
  high,
  critical,
}

/// Service runtime information
class ServiceInfo {
  final dynamic service;
  final ServiceConfig config;
  final DateTime initializationTime;
  bool isHealthy;
  DateTime? lastHealthCheck;
  String? lastError;

  ServiceInfo({
    required this.service,
    required this.config,
    required this.initializationTime,
    required this.isHealthy,
    this.lastHealthCheck,
    this.lastError,
  });
}

/// Service status for external consumers
class ServiceStatus {
  final String name;
  final bool isHealthy;
  final DateTime initializationTime;
  final DateTime? lastHealthCheck;
  final String? lastError;
  final ServicePriority priority;

  const ServiceStatus({
    required this.name,
    required this.isHealthy,
    required this.initializationTime,
    required this.lastHealthCheck,
    required this.lastError,
    required this.priority,
  });

  @override
  String toString() =>
      'ServiceStatus($name: ${isHealthy ? "Healthy" : "Unhealthy"}, '
      'priority: $priority, initialized: $initializationTime)';
}

/// Manager status
class ManagerStatus {
  final bool isInitialized;
  final bool isShuttingDown;
  final int serviceCount;
  final int healthyServiceCount;
  final int criticalServiceCount;

  const ManagerStatus({
    required this.isInitialized,
    required this.isShuttingDown,
    required this.serviceCount,
    required this.healthyServiceCount,
    required this.criticalServiceCount,
  });

  @override
  String toString() => 'ManagerStatus(initialized: $isInitialized, '
      'services: $healthyServiceCount/$serviceCount healthy, '
      'critical: $criticalServiceCount)';
}

/// Interface for services with lifecycle management
abstract class ILifecycleService {
  /// Initialize the service
  Future<void> init();

  /// Dispose/cleanup the service
  Future<void> dispose();

  /// Check if service is healthy
  Future<bool> isHealthy();

  /// Get service name for logging
  String get serviceName;
}
