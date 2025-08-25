// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_flutter/hive_flutter.dart';

/// Singleton manager for Hive boxes with efficient lifecycle management
///
/// This service centralizes box management, keeping them open during the app session
/// to avoid repeated open/close overhead. Implements lazy loading, connection pooling,
/// and graceful shutdown for optimal performance.
class BoxManager {
  static BoxManager? _instance;
  static BoxManager get instance => _instance ??= BoxManager._internal();

  BoxManager._internal();

  /// ========================================
  /// BOX REGISTRY AND STATE
  /// ========================================

  /// Registry of all managed boxes
  final Map<String, Box<dynamic>> _openBoxes = <String, Box<dynamic>>{};

  /// Registry of box initialization functions
  final Map<String, Future<Box> Function()> _boxInitializers =
      <String, Future<Box> Function()>{};

  /// Lock to prevent concurrent box operations
  final Map<String, Completer<Box>> _pendingBoxes = <String, Completer<Box>>{};

  /// Frequently accessed boxes (connection pool)
  final Set<String> _frequentlyUsedBoxes = <String>{};

  /// Box access statistics for optimization
  final Map<String, BoxStats> _boxStats = <String, BoxStats>{};

  /// Shutdown flag
  bool _isShuttingDown = false;

  /// ========================================
  /// BOX CONFIGURATION
  /// ========================================

  /// Box configurations with their adapters and settings
  static const Map<String, BoxConfig> _boxConfigs = {
    'box_car_veiculos': BoxConfig(
      name: 'box_car_veiculos',
      typeId: 21,
      isFrequentlyUsed: true,
      priority: BoxPriority.high,
    ),
    'box_car_odometros': BoxConfig(
      name: 'box_car_odometros',
      typeId: 22,
      isFrequentlyUsed: false,
      priority: BoxPriority.medium,
    ),
    'box_car_abastecimentos': BoxConfig(
      name: 'box_car_abastecimentos',
      typeId: 23,
      isFrequentlyUsed: false,
      priority: BoxPriority.medium,
    ),
    'box_car_manutencoes': BoxConfig(
      name: 'box_car_manutencoes',
      typeId: 24,
      isFrequentlyUsed: false,
      priority: BoxPriority.medium,
    ),
    'box_car_despesas': BoxConfig(
      name: 'box_car_despesas',
      typeId: 25,
      isFrequentlyUsed: false,
      priority: BoxPriority.low,
    ),
  };

  /// ========================================
  /// INITIALIZATION
  /// ========================================

  /// Initialize the BoxManager and preload frequent boxes
  static Future<void> initialize() async {
    final manager = BoxManager.instance;

    // Preload frequently used boxes
    for (final config in _boxConfigs.values) {
      if (config.isFrequentlyUsed) {
        manager._frequentlyUsedBoxes.add(config.name);
      }
    }

    // Initialize high priority boxes
    await manager._preloadHighPriorityBoxes();

    debugPrint(
        'BoxManager initialized with ${manager._openBoxes.length} preloaded boxes');
  }

  /// Preload high priority boxes for better performance
  Future<void> _preloadHighPriorityBoxes() async {
    final highPriorityBoxes = _boxConfigs.values
        .where((config) => config.priority == BoxPriority.high)
        .map((config) => config.name);

    for (final boxName in highPriorityBoxes) {
      try {
        await getBox(boxName);
        debugPrint('Preloaded high priority box: $boxName');
      } catch (e) {
        debugPrint('Failed to preload box $boxName: $e');
      }
    }
  }

  /// ========================================
  /// BOX ACCESS METHODS
  /// ========================================

  /// Get a box, opening it if necessary (thread-safe)
  Future<Box<T>> getBox<T>(String boxName) async {
    if (_isShuttingDown) {
      throw StateError('BoxManager is shutting down');
    }

    // Update access statistics
    _updateBoxStats(boxName);

    // Return existing box if already open
    if (_openBoxes.containsKey(boxName) && _openBoxes[boxName]!.isOpen) {
      final existingBox = _openBoxes[boxName];
      if (existingBox is Box<T>) {
        return existingBox;
      } else {
        // Box exists but with wrong type, close and reopen with correct type
        await existingBox.close();
        _openBoxes.remove(boxName);
      }
    }

    // Check if box is currently being opened
    if (_pendingBoxes.containsKey(boxName)) {
      final pendingBox = await _pendingBoxes[boxName]!.future;
      if (pendingBox is Box<T>) {
        return pendingBox;
      } else {
        throw StateError('Pending box type mismatch for $boxName');
      }
    }

    // Open the box
    return await _openBox<T>(boxName);
  }

  /// Get a box synchronously (only if already open)
  Box<T>? getBoxSync<T>(String boxName) {
    if (_openBoxes.containsKey(boxName) && _openBoxes[boxName]!.isOpen) {
      final existingBox = _openBoxes[boxName];
      if (existingBox is Box<T>) {
        return existingBox;
      }
    }
    return null;
  }

  /// Check if a box is currently open
  bool isBoxOpen(String boxName) {
    return _openBoxes.containsKey(boxName) && _openBoxes[boxName]!.isOpen;
  }

  /// Open a box with proper error handling and concurrency control
  Future<Box<T>> _openBox<T>(String boxName) async {
    final completer = Completer<Box>();
    _pendingBoxes[boxName] = completer;

    try {
      Box<T> box;

      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box<T>(boxName);
      } else {
        // Check if we have a custom initializer
        if (_boxInitializers.containsKey(boxName)) {
          box = await _boxInitializers[boxName]!() as Box<T>;
        } else {
          box = await Hive.openBox<T>(boxName);
        }
      }

      _openBoxes[boxName] = box;
      completer.complete(box);

      debugPrint('Opened box: $boxName (${box.length} items)');
      return box;
    } catch (e) {
      completer.completeError(e);
      debugPrint('Failed to open box $boxName: $e');
      rethrow;
    } finally {
      _pendingBoxes.remove(boxName);
    }
  }

  /// ========================================
  /// BOX LIFECYCLE MANAGEMENT
  /// ========================================

  /// Register a custom box initializer
  void registerBoxInitializer(
      String boxName, Future<Box> Function() initializer) {
    _boxInitializers[boxName] = initializer;
  }

  /// Preload a specific box
  Future<void> preloadBox(String boxName) async {
    await getBox(boxName);
  }

  /// Close a specific box (rarely needed during app lifecycle)
  Future<void> closeBox(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      try {
        await _openBoxes[boxName]!.close();
        _openBoxes.remove(boxName);
        debugPrint('Closed box: $boxName');
      } catch (e) {
        debugPrint('Error closing box $boxName: $e');
      }
    }
  }

  /// Compact a box to optimize storage
  Future<void> compactBox(String boxName) async {
    final box = await getBox(boxName);
    try {
      await box.compact();
      debugPrint('Compacted box: $boxName');
    } catch (e) {
      debugPrint('Error compacting box $boxName: $e');
    }
  }

  /// ========================================
  /// PERFORMANCE OPTIMIZATION
  /// ========================================

  /// Update box access statistics
  void _updateBoxStats(String boxName) {
    if (!_boxStats.containsKey(boxName)) {
      _boxStats[boxName] = BoxStats(boxName);
    }
    _boxStats[boxName]!.recordAccess();
  }

  /// Get box statistics
  BoxStats? getBoxStats(String boxName) => _boxStats[boxName];

  /// Get all box statistics
  Map<String, BoxStats> getAllBoxStats() => Map.unmodifiable(_boxStats);

  /// Optimize boxes based on access patterns
  Future<void> optimizeBoxes() async {
    final sortedStats = _boxStats.values.toList()
      ..sort((a, b) => b.accessCount.compareTo(a.accessCount));

    // Preload frequently accessed boxes
    for (final stats in sortedStats.take(3)) {
      if (!isBoxOpen(stats.boxName)) {
        await preloadBox(stats.boxName);
      }
    }

    // Consider closing rarely used boxes (only if memory is a concern)
    final rarelyUsed = sortedStats
        .where((stats) =>
            stats.accessCount < 5 &&
            !_frequentlyUsedBoxes.contains(stats.boxName))
        .toList();

    for (final stats in rarelyUsed) {
      if (_openBoxes.length > 5) {
        // Keep at least 5 boxes open
        await closeBox(stats.boxName);
      }
    }
  }

  /// Clear access statistics
  void clearStats() {
    _boxStats.clear();
  }

  /// ========================================
  /// HEALTH AND MONITORING
  /// ========================================

  /// Get health status of all managed boxes
  Future<Map<String, BoxHealthStatus>> getHealthStatus() async {
    final healthStatus = <String, BoxHealthStatus>{};

    for (final boxName in _boxConfigs.keys) {
      try {
        final isOpen = isBoxOpen(boxName);
        final itemCount = isOpen ? _openBoxes[boxName]!.length : 0;
        final stats = _boxStats[boxName];

        healthStatus[boxName] = BoxHealthStatus(
          boxName: boxName,
          isOpen: isOpen,
          itemCount: itemCount,
          accessCount: stats?.accessCount ?? 0,
          lastAccessed: stats?.lastAccessed,
          isHealthy: isOpen && _openBoxes[boxName]!.isOpen,
        );
      } catch (e) {
        healthStatus[boxName] = BoxHealthStatus(
          boxName: boxName,
          isOpen: false,
          itemCount: 0,
          accessCount: 0,
          lastAccessed: null,
          isHealthy: false,
          error: e.toString(),
        );
      }
    }

    return healthStatus;
  }

  /// Validate box integrity
  Future<bool> validateBoxIntegrity(String boxName) async {
    try {
      final box = await getBox(boxName);

      // Basic integrity checks
      if (!box.isOpen) return false;

      // Try to access the box
      final length = box.length;
      debugPrint('Box $boxName integrity check: $length items');

      return true;
    } catch (e) {
      debugPrint('Box $boxName failed integrity check: $e');
      return false;
    }
  }

  /// ========================================
  /// GRACEFUL SHUTDOWN
  /// ========================================

  /// Gracefully shutdown all boxes
  Future<void> shutdown() async {
    _isShuttingDown = true;

    debugPrint('BoxManager shutting down ${_openBoxes.length} boxes...');

    // Close all boxes in reverse priority order
    final sortedBoxes = _openBoxes.keys.toList();
    sortedBoxes.sort((a, b) {
      final priorityA = _boxConfigs[a]?.priority ?? BoxPriority.low;
      final priorityB = _boxConfigs[b]?.priority ?? BoxPriority.low;
      return priorityA.index.compareTo(priorityB.index);
    });

    for (final boxName in sortedBoxes.reversed) {
      try {
        await _openBoxes[boxName]!.close();
        debugPrint('Closed box: $boxName');
      } catch (e) {
        debugPrint('Error closing box $boxName during shutdown: $e');
      }
    }

    _openBoxes.clear();
    _boxStats.clear();
    _pendingBoxes.clear();

    debugPrint('BoxManager shutdown complete');
  }

  /// Force close all boxes (emergency shutdown)
  void forceShutdown() {
    _isShuttingDown = true;

    for (final box in _openBoxes.values) {
      try {
        box.close();
      } catch (e) {
        debugPrint('Error force closing box: $e');
      }
    }

    _openBoxes.clear();
    _boxStats.clear();
    _pendingBoxes.clear();
  }

  /// ========================================
  /// UTILITY METHODS
  /// ========================================

  /// Get memory usage summary
  String getMemoryUsage() {
    final totalItems =
        _openBoxes.values.fold<int>(0, (sum, box) => sum + box.length);
    return 'Open boxes: ${_openBoxes.length}, Total items: $totalItems';
  }

  /// Get box configuration
  BoxConfig? getBoxConfig(String boxName) => _boxConfigs[boxName];

  /// List all configured boxes
  List<String> getConfiguredBoxes() => _boxConfigs.keys.toList();

  /// List all open boxes
  List<String> getOpenBoxes() => _openBoxes.keys.toList();
}

/// ========================================
/// SUPPORTING CLASSES
/// ========================================

/// Box configuration
class BoxConfig {
  final String name;
  final int typeId;
  final bool isFrequentlyUsed;
  final BoxPriority priority;

  const BoxConfig({
    required this.name,
    required this.typeId,
    required this.isFrequentlyUsed,
    required this.priority,
  });
}

/// Box priority levels
enum BoxPriority {
  low,
  medium,
  high,
}

/// Box access statistics
class BoxStats {
  final String boxName;
  int accessCount = 0;
  DateTime? lastAccessed;
  DateTime firstAccessed = DateTime.now();

  BoxStats(this.boxName);

  void recordAccess() {
    accessCount++;
    lastAccessed = DateTime.now();
  }

  Duration get totalAge => DateTime.now().difference(firstAccessed);
  Duration? get timeSinceLastAccess =>
      lastAccessed != null ? DateTime.now().difference(lastAccessed!) : null;

  double get accessRate =>
      accessCount / totalAge.inMinutes.clamp(1, double.infinity);

  @override
  String toString() =>
      'BoxStats($boxName: $accessCount accesses, rate: ${accessRate.toStringAsFixed(2)}/min)';
}

/// Box health status
class BoxHealthStatus {
  final String boxName;
  final bool isOpen;
  final int itemCount;
  final int accessCount;
  final DateTime? lastAccessed;
  final bool isHealthy;
  final String? error;

  const BoxHealthStatus({
    required this.boxName,
    required this.isOpen,
    required this.itemCount,
    required this.accessCount,
    required this.lastAccessed,
    required this.isHealthy,
    this.error,
  });

  @override
  String toString() =>
      'BoxHealthStatus($boxName: ${isHealthy ? "Healthy" : "Unhealthy"}, '
      'open: $isOpen, items: $itemCount, accesses: $accessCount)';
}

/// Extension for easy box access
extension BoxManagerExtension on String {
  /// Get box by name using the string as box name
  Future<Box<T>> asBox<T>() => BoxManager.instance.getBox<T>(this);

  /// Get box synchronously
  Box<T>? asBoxSync<T>() => BoxManager.instance.getBoxSync<T>(this);

  /// Check if box is open
  bool get isBoxOpen => BoxManager.instance.isBoxOpen(this);
}
