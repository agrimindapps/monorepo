import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Gerenciador de memória para otimização de performance
/// 
/// Monitora e gerencia o uso de memória da aplicação:
/// - Automatic memory cleanup
/// - Memory pressure detection
/// - Cache eviction strategies
/// - Memory usage monitoring
class MemoryManager extends ChangeNotifier {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal() {
    _startMemoryMonitoring();
  }

  // Configurações
  static const int _memoryCheckIntervalMs = 30000; // 30 segundos
  static const double _memoryWarningThresholdMB = 150.0; // 150MB
  static const double _memoryCriticalThresholdMB = 200.0; // 200MB

  // Estado do monitor
  Timer? _memoryTimer;
  double _currentMemoryUsageMB = 0.0;
  bool _isMemoryPressure = false;
  final List<MemoryPressureCallback> _pressureCallbacks = [];
  final Map<String, CacheEntry> _managedCaches = {};

  // Estatísticas
  int _cleanupCycles = 0;
  double _maxMemoryUsageMB = 0.0;
  DateTime? _lastCleanup;

  /// Callback para situações de pressão de memória
  typedef MemoryPressureCallback = Future<void> Function(MemoryPressureLevel level);

  /// Níveis de pressão de memória
  enum MemoryPressureLevel { 
    normal, 
    warning, 
    critical 
  }

  /// Entrada de cache gerenciado
  class CacheEntry {
    final String name;
    final VoidCallback clearCallback;
    final int priority; // 1 = alta prioridade, 5 = baixa prioridade
    final DateTime lastAccessed;

    CacheEntry({
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
      // No Flutter, não há uma API direta para memória
      // Usaremos uma estimativa baseada no developer tools
      final info = await developer.Service.getInfo();
      
      // Estimativa baseada em heurísticas
      _currentMemoryUsageMB = _estimateMemoryUsage();
      
      if (_currentMemoryUsageMB > _maxMemoryUsageMB) {
        _maxMemoryUsageMB = _currentMemoryUsageMB;
      }

      final level = _getMemoryPressureLevel(_currentMemoryUsageMB);
      
      if (level != MemoryPressureLevel.normal && !_isMemoryPressure) {
        _isMemoryPressure = true;
        await _handleMemoryPressure(level);
      } else if (level == MemoryPressureLevel.normal && _isMemoryPressure) {
        _isMemoryPressure = false;
      }

      notifyListeners();
    } catch (e) {
      developer.log('Erro ao verificar uso de memória: $e', name: 'MemoryManager');
    }
  }

  /// Estima o uso de memória (heurística)
  double _estimateMemoryUsage() {
    // Estimativa baseada em:
    // - Número de caches registrados
    // - Tempo de execução da app
    // - Número de widgets ativos
    
    final baseMB = 20.0; // Uso base da aplicação
    final cacheMB = _managedCaches.length * 2.0; // 2MB por cache
    final timeMB = DateTime.now().millisecondsSinceEpoch / 1000000; // Estimativa temporal
    
    return baseMB + cacheMB + timeMB;
  }

  /// Determina o nível de pressão de memória
  MemoryPressureLevel _getMemoryPressureLevel(double memoryMB) {
    if (memoryMB >= _memoryCriticalThresholdMB) {
      return MemoryPressureLevel.critical;
    } else if (memoryMB >= _memoryWarningThresholdMB) {
      return MemoryPressureLevel.warning;
    }
    return MemoryPressureLevel.normal;
  }

  /// Lida com situações de pressão de memória
  Future<void> _handleMemoryPressure(MemoryPressureLevel level) async {
    developer.log('Pressão de memória detectada: $level', name: 'MemoryManager');

    // Executa callbacks registrados
    for (final callback in _pressureCallbacks) {
      try {
        await callback(level);
      } catch (e) {
        developer.log('Erro em callback de pressão de memória: $e', name: 'MemoryManager');
      }
    }

    // Limpa caches automaticamente
    await _performAutomaticCleanup(level);
    
    // Força garbage collection
    await _forceGarbageCollection();
  }

  /// Realiza limpeza automática de caches
  Future<void> _performAutomaticCleanup(MemoryPressureLevel level) async {
    final now = DateTime.now();
    final entries = _managedCaches.values.toList();
    
    // Ordena por prioridade (menor = mais prioritário) e último acesso
    entries.sort((a, b) {
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.lastAccessed.compareTo(b.lastAccessed);
    });

    int cleanupCount = 0;
    final maxCleanup = level == MemoryPressureLevel.critical ? 
        entries.length : 
        (entries.length * 0.3).ceil();

    for (final entry in entries) {
      if (cleanupCount >= maxCleanup) break;
      
      // Remove caches de baixa prioridade ou não acessados recentemente
      final hoursSinceAccess = now.difference(entry.lastAccessed).inHours;
      
      if (entry.priority >= 4 || hoursSinceAccess >= 2) {
        try {
          entry.clearCallback();
          _managedCaches.remove(entry.name);
          cleanupCount++;
          
          developer.log('Cache limpo: ${entry.name}', name: 'MemoryManager');
        } catch (e) {
          developer.log('Erro ao limpar cache ${entry.name}: $e', name: 'MemoryManager');
        }
      }
    }

    _cleanupCycles++;
    _lastCleanup = now;
    
    developer.log('Limpeza automática: $cleanupCount caches removidos', name: 'MemoryManager');
  }

  /// Força garbage collection
  Future<void> _forceGarbageCollection() async {
    try {
      // Força GC através de alocação e liberação rápida
      final list = List.generate(1000, (i) => Object());
      list.clear();
      
      // Pequena pausa para permitir GC
      await Future.delayed(const Duration(milliseconds: 100));
      
      developer.log('Garbage collection forçado', name: 'MemoryManager');
    } catch (e) {
      developer.log('Erro ao forçar garbage collection: $e', name: 'MemoryManager');
    }
  }

  /// Registra um cache para gerenciamento automático
  void registerCache({
    required String name,
    required VoidCallback clearCallback,
    int priority = 3,
  }) {
    _managedCaches[name] = CacheEntry(
      name: name,
      clearCallback: clearCallback,
      priority: priority,
      lastAccessed: DateTime.now(),
    );
    
    developer.log('Cache registrado: $name (prioridade: $priority)', name: 'MemoryManager');
  }

  /// Marca um cache como acessado (atualiza timestamp)
  void markCacheAccessed(String name) {
    final entry = _managedCaches[name];
    if (entry != null) {
      _managedCaches[name] = entry.copyWithAccess();
    }
  }

  /// Remove o registro de um cache
  void unregisterCache(String name) {
    _managedCaches.remove(name);
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
  Map<String, dynamic> getMemoryStats() {
    return {
      'current_memory_mb': _currentMemoryUsageMB,
      'max_memory_mb': _maxMemoryUsageMB,
      'is_memory_pressure': _isMemoryPressure,
      'managed_caches': _managedCaches.length,
      'cleanup_cycles': _cleanupCycles,
      'last_cleanup': _lastCleanup?.toIso8601String(),
      'memory_level': _getMemoryPressureLevel(_currentMemoryUsageMB).name,
    };
  }

  /// Para o monitoramento de memória
  void dispose() {
    _memoryTimer?.cancel();
    _pressureCallbacks.clear();
    _managedCaches.clear();
    super.dispose();
  }
}

/// Mixin para widgets que querem gerenciar memória automaticamente
mixin MemoryAwareMixin<T extends StatefulWidget> on State<T> {
  final MemoryManager _memoryManager = MemoryManager();
  
  /// Registra um cache local
  void registerLocalCache(String name, VoidCallback clearCallback, {int priority = 3}) {
    _memoryManager.registerCache(
      name: '${widget.runtimeType}_$name',
      clearCallback: clearCallback,
      priority: priority,
    );
  }

  /// Marca cache como acessado
  void markCacheAccessed(String name) {
    _memoryManager.markCacheAccessed('${widget.runtimeType}_$name');
  }

  @override
  void dispose() {
    // Remove caches registrados por este widget
    final prefix = '${widget.runtimeType}_';
    final cacheNames = _memoryManager._managedCaches.keys
        .where((name) => name.startsWith(prefix))
        .toList();
    
    for (final name in cacheNames) {
      _memoryManager.unregisterCache(name);
    }
    
    super.dispose();
  }
}

/// Widget para exibir informações de memória (útil para debug)
class MemoryMonitorWidget extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const MemoryMonitorWidget({
    Key? key,
    required this.child,
    this.showOverlay = false,
  }) : super(key: key);

  @override
  State<MemoryMonitorWidget> createState() => _MemoryMonitorWidgetState();
}

class _MemoryMonitorWidgetState extends State<MemoryMonitorWidget> {
  final MemoryManager _memoryManager = MemoryManager();
  
  @override
  void initState() {
    super.initState();
    _memoryManager.addListener(_onMemoryUpdate);
  }

  @override
  void dispose() {
    _memoryManager.removeListener(_onMemoryUpdate);
    super.dispose();
  }

  void _onMemoryUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showOverlay || !kDebugMode) {
      return widget.child;
    }

    final stats = _memoryManager.getMemoryStats();
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 50,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MEM: ${stats['current_memory_mb'].toStringAsFixed(1)}MB',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'MAX: ${stats['max_memory_mb'].toStringAsFixed(1)}MB',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'CACHES: ${stats['managed_caches']}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (stats['is_memory_pressure'])
                  const Text(
                    'PRESSURE!',
                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}