import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart'
    show StateNotifier, StateNotifierProvider, Provider;
import 'package:flutter/foundation.dart';

/// Callback para situações de pressão de memória
typedef MemoryPressureCallback =
    Future<void> Function(MemoryPressureLevel level);

/// Níveis de pressão de memória
enum MemoryPressureLevel { normal, warning, critical }

/// Entrada de cache gerenciado
class CacheEntry {
  final String name;
  final VoidCallback clearCallback;
  final int priority; // 1 = alta prioridade, 5 = baixa prioridade
  final DateTime lastAccessed;

  const CacheEntry({
    required this.name,
    required this.clearCallback,
    required this.priority,
    required this.lastAccessed,
  });

  CacheEntry copyWithAccess() {
    return CacheEntry(
      name: name,
      clearCallback: clearCallback,
      priority: priority,
      lastAccessed: DateTime.now(),
    );
  }
}

/// State para gerenciamento de memória
class MemoryState {
  const MemoryState({
    this.currentMemoryUsageMB = 0.0,
    this.isMemoryPressure = false,
    this.managedCaches = const {},
    this.cleanupCycles = 0,
    this.maxMemoryUsageMB = 0.0,
    this.lastCleanup,
    this.startTime,
  });

  final double currentMemoryUsageMB;
  final bool isMemoryPressure;
  final Map<String, CacheEntry> managedCaches;
  final int cleanupCycles;
  final double maxMemoryUsageMB;
  final DateTime? lastCleanup;
  final DateTime? startTime;

  MemoryState copyWith({
    double? currentMemoryUsageMB,
    bool? isMemoryPressure,
    Map<String, CacheEntry>? managedCaches,
    int? cleanupCycles,
    double? maxMemoryUsageMB,
    DateTime? lastCleanup,
    DateTime? startTime,
  }) {
    return MemoryState(
      currentMemoryUsageMB: currentMemoryUsageMB ?? this.currentMemoryUsageMB,
      isMemoryPressure: isMemoryPressure ?? this.isMemoryPressure,
      managedCaches: managedCaches ?? this.managedCaches,
      cleanupCycles: cleanupCycles ?? this.cleanupCycles,
      maxMemoryUsageMB: maxMemoryUsageMB ?? this.maxMemoryUsageMB,
      lastCleanup: lastCleanup ?? this.lastCleanup,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Determina o nível de pressão de memória
  MemoryPressureLevel get memoryPressureLevel {
    if (currentMemoryUsageMB >= _memoryCriticalThresholdMB) {
      return MemoryPressureLevel.critical;
    } else if (currentMemoryUsageMB >= _memoryWarningThresholdMB) {
      return MemoryPressureLevel.warning;
    }
    return MemoryPressureLevel.normal;
  }

  /// Obtém estatísticas de memória
  Map<String, dynamic> get memoryStats {
    return {
      'current_memory_mb': currentMemoryUsageMB,
      'max_memory_mb': maxMemoryUsageMB,
      'is_memory_pressure': isMemoryPressure,
      'managed_caches': managedCaches.length,
      'cleanup_cycles': cleanupCycles,
      'last_cleanup': lastCleanup?.toIso8601String(),
      'memory_level': memoryPressureLevel.name,
    };
  }
  static const double _memoryWarningThresholdMB = 150.0; // 150MB
  static const double _memoryCriticalThresholdMB = 200.0; // 200MB
}

/// StateNotifier para gerenciamento de memória
///
/// Monitora e gerencia o uso de memória da aplicação:
/// - Automatic memory cleanup
/// - Memory pressure detection
/// - Cache eviction strategies
/// - Memory usage monitoring
class MemoryNotifier extends StateNotifier<MemoryState> {
  MemoryNotifier() : super(MemoryState(startTime: DateTime.now())) {
    _startMemoryMonitoring();
  }
  static const int _memoryCheckIntervalMs = 30000; // 30 segundos
  Timer? _memoryTimer;
  final List<MemoryPressureCallback> _pressureCallbacks = [];

  /// Inicia o monitoramento de memória
  void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(
      const Duration(milliseconds: _memoryCheckIntervalMs),
      (_) => _checkMemoryUsage(),
    );
  }

  /// Verifica o uso atual de memória
  Future<void> _checkMemoryUsage() async {
    try {
      final currentUsage = _estimateMemoryUsage();

      final newMaxUsage =
          currentUsage > state.maxMemoryUsageMB
              ? currentUsage
              : state.maxMemoryUsageMB;

      final level = _getMemoryPressureLevel(currentUsage);

      if (level != MemoryPressureLevel.normal && !state.isMemoryPressure) {
        state = state.copyWith(
          currentMemoryUsageMB: currentUsage,
          maxMemoryUsageMB: newMaxUsage,
          isMemoryPressure: true,
        );
        await _handleMemoryPressure(level);
      } else if (level == MemoryPressureLevel.normal &&
          state.isMemoryPressure) {
        state = state.copyWith(
          currentMemoryUsageMB: currentUsage,
          maxMemoryUsageMB: newMaxUsage,
          isMemoryPressure: false,
        );
      } else {
        state = state.copyWith(
          currentMemoryUsageMB: currentUsage,
          maxMemoryUsageMB: newMaxUsage,
        );
      }
    } catch (e) {
      developer.log(
        'Erro ao verificar uso de memória: $e',
        name: 'MemoryManager',
      );
    }
  }

  /// Estima o uso de memória (heurística)
  double _estimateMemoryUsage() {

    const baseMB = 20.0; // Uso base da aplicação
    final cacheMB = state.managedCaches.length * 2.0; // 2MB por cache
    final runTimeMinutes =
        state.startTime != null
            ? DateTime.now().difference(state.startTime!).inMinutes
            : 0;
    final timeMB = (runTimeMinutes * 0.1).clamp(
      0.0,
      50.0,
    ); // Max 50MB por tempo

    return baseMB + cacheMB + timeMB;
  }

  /// Determina o nível de pressão de memória
  MemoryPressureLevel _getMemoryPressureLevel(double memoryMB) {
    if (memoryMB >= MemoryState._memoryCriticalThresholdMB) {
      return MemoryPressureLevel.critical;
    } else if (memoryMB >= MemoryState._memoryWarningThresholdMB) {
      return MemoryPressureLevel.warning;
    }
    return MemoryPressureLevel.normal;
  }

  /// Lida com situações de pressão de memória
  Future<void> _handleMemoryPressure(MemoryPressureLevel level) async {
    developer.log(
      'Pressão de memória detectada: $level',
      name: 'MemoryManager',
    );
    for (final callback in _pressureCallbacks) {
      try {
        await callback(level);
      } catch (e) {
        developer.log(
          'Erro em callback de pressão de memória: $e',
          name: 'MemoryManager',
        );
      }
    }
    await _performAutomaticCleanup(level);
    await _forceGarbageCollection();
  }

  /// Realiza limpeza automática de caches
  Future<void> _performAutomaticCleanup(MemoryPressureLevel level) async {
    final now = DateTime.now();
    final entries = state.managedCaches.values.toList();
    entries.sort((a, b) {
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.lastAccessed.compareTo(b.lastAccessed);
    });

    int cleanupCount = 0;
    final maxCleanup =
        level == MemoryPressureLevel.critical
            ? entries.length
            : (entries.length * 0.3).ceil();

    final newManagedCaches = Map<String, CacheEntry>.from(state.managedCaches);

    for (final entry in entries) {
      if (cleanupCount >= maxCleanup) break;
      final hoursSinceAccess = now.difference(entry.lastAccessed).inHours;

      if (entry.priority >= 4 || hoursSinceAccess >= 2) {
        try {
          entry.clearCallback();
          newManagedCaches.remove(entry.name);
          cleanupCount++;

          developer.log('Cache limpo: ${entry.name}', name: 'MemoryManager');
        } catch (e) {
          developer.log(
            'Erro ao limpar cache ${entry.name}: $e',
            name: 'MemoryManager',
          );
        }
      }
    }

    state = state.copyWith(
      managedCaches: newManagedCaches,
      cleanupCycles: state.cleanupCycles + 1,
      lastCleanup: now,
    );

    developer.log(
      'Limpeza automática: $cleanupCount caches removidos',
      name: 'MemoryManager',
    );
  }

  /// Força garbage collection
  Future<void> _forceGarbageCollection() async {
    try {
      final list = List.generate(1000, (i) => Object());
      list.clear();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      developer.log('Garbage collection forçado', name: 'MemoryManager');
    } catch (e) {
      developer.log(
        'Erro ao forçar garbage collection: $e',
        name: 'MemoryManager',
      );
    }
  }

  /// Registra um cache para gerenciamento automático
  void registerCache({
    required String name,
    required VoidCallback clearCallback,
    int priority = 3,
  }) {
    final newManagedCaches = Map<String, CacheEntry>.from(state.managedCaches);
    newManagedCaches[name] = CacheEntry(
      name: name,
      clearCallback: clearCallback,
      priority: priority,
      lastAccessed: DateTime.now(),
    );

    state = state.copyWith(managedCaches: newManagedCaches);

    developer.log(
      'Cache registrado: $name (prioridade: $priority)',
      name: 'MemoryManager',
    );
  }

  /// Marca um cache como acessado (atualiza timestamp)
  void markCacheAccessed(String name) {
    final entry = state.managedCaches[name];
    if (entry != null) {
      final newManagedCaches = Map<String, CacheEntry>.from(
        state.managedCaches,
      );
      newManagedCaches[name] = entry.copyWithAccess();
      state = state.copyWith(managedCaches: newManagedCaches);
    }
  }

  /// Remove o registro de um cache
  void unregisterCache(String name) {
    final newManagedCaches = Map<String, CacheEntry>.from(state.managedCaches);
    newManagedCaches.remove(name);
    state = state.copyWith(managedCaches: newManagedCaches);
    developer.log('Cache não registrado: $name', name: 'MemoryManager');
  }

  /// Registra callback para pressão de memória
  void addMemoryPressureCallback(MemoryPressureCallback callback) {
    _pressureCallbacks.add(callback);
  }

  /// Remove callback de pressão de memória
  void removeMemoryPressureCallback(MemoryPressureCallback callback) {
    _pressureCallbacks.remove(callback);
  }

  /// Força limpeza manual de todos os caches de baixa prioridade
  Future<void> performManualCleanup() async {
    await _performAutomaticCleanup(MemoryPressureLevel.warning);
    await _forceGarbageCollection();
  }

  /// Obtém estatísticas de memória
  Map<String, dynamic> getMemoryStats() => state.memoryStats;

  /// Para o monitoramento de memória
  @override
  void dispose() {
    _memoryTimer?.cancel();
    _pressureCallbacks.clear();
    super.dispose();
  }
}

/// Provider para gerenciamento de memória
final memoryProvider = StateNotifierProvider<MemoryNotifier, MemoryState>((
  ref,
) {
  return MemoryNotifier();
});

/// Provider derivado para estatísticas de memória
final memoryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(memoryProvider).memoryStats;
});

/// Provider derivado para nível de pressão de memória
final memoryPressureLevelProvider = Provider<MemoryPressureLevel>((ref) {
  return ref.watch(memoryProvider).memoryPressureLevel;
});

/// Provider derivado para verificar se está sob pressão de memória
final isMemoryPressureProvider = Provider<bool>((ref) {
  return ref.watch(memoryProvider).isMemoryPressure;
});
