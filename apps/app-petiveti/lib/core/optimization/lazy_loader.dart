import 'dart:async';
import 'package:flutter/material.dart';

/// Serviço de lazy loading para otimizar carregamento de features
class LazyLoader {
  static final LazyLoader _instance = LazyLoader._internal();
  factory LazyLoader() => _instance;
  LazyLoader._internal();

  final Map<String, Completer<dynamic>> _loadingCompleters = {};
  final Map<String, dynamic> _loadedModules = {};

  /// Carrega um módulo lazy se ainda não foi carregado
  Future<T> loadModule<T>(
    String moduleKey,
    Future<T> Function() loader, {
    bool forceReload = false,
  }) async {
    // Se já está carregado e não é para forçar reload
    if (_loadedModules.containsKey(moduleKey) && !forceReload) {
      return _loadedModules[moduleKey] as T;
    }

    // Se já está sendo carregado, aguarda o carregamento atual
    if (_loadingCompleters.containsKey(moduleKey)) {
      return await _loadingCompleters[moduleKey]!.future as T;
    }

    // Inicia o carregamento
    final completer = Completer<T>();
    _loadingCompleters[moduleKey] = completer;

    try {
      final module = await loader();
      _loadedModules[moduleKey] = module;
      completer.complete(module);
      return module;
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _loadingCompleters.remove(moduleKey);
    }
  }

  /// Verifica se um módulo está carregado
  bool isLoaded(String moduleKey) {
    return _loadedModules.containsKey(moduleKey);
  }

  /// Verifica se um módulo está sendo carregado
  bool isLoading(String moduleKey) {
    return _loadingCompleters.containsKey(moduleKey);
  }

  /// Remove um módulo da memória
  void unloadModule(String moduleKey) {
    _loadedModules.remove(moduleKey);
  }

  /// Limpa todos os módulos carregados
  void clearAll() {
    _loadedModules.clear();
  }

  /// Pré-carrega múltiplos módulos em paralelo
  Future<void> preloadModules(Map<String, Future<dynamic> Function()> modules) async {
    final futures = modules.entries.map((entry) => 
        loadModule(entry.key, entry.value)
    );
    
    await Future.wait(futures);
  }

  /// Obtém estatísticas de carregamento
  LazyLoadingStats getStats() {
    return LazyLoadingStats(
      loadedModules: _loadedModules.length,
      loadingModules: _loadingCompleters.length,
      moduleKeys: _loadedModules.keys.toList(),
    );
  }
}

/// Estatísticas de lazy loading
class LazyLoadingStats {
  final int loadedModules;
  final int loadingModules;
  final List<String> moduleKeys;

  const LazyLoadingStats({
    required this.loadedModules,
    required this.loadingModules,
    required this.moduleKeys,
  });
}

/// Widget que carrega conteúdo lazy
class LazyWidget<T> extends StatefulWidget {
  final String moduleKey;
  final Future<T> Function() loader;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorBuilder;
  final bool preload;

  const LazyWidget({
    super.key,
    required this.moduleKey,
    required this.loader,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.preload = false,
  });

  @override
  State<LazyWidget<T>> createState() => _LazyWidgetState<T>();
}

class _LazyWidgetState<T> extends State<LazyWidget<T>> {
  late Future<T> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = LazyLoader().loadModule(widget.moduleKey, widget.loader);
    
    if (widget.preload) {
      _loadingFuture.catchError((_) {
        // Preload sem bloquear UI - ignora erros
      }); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget ?? const CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(snapshot.error!) ?? 
                 Text('Erro: ${snapshot.error}');
        }
        
        if (snapshot.hasData) {
          return widget.builder(snapshot.data as T);
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}

/// Mixin para facilitar lazy loading em classes
mixin LazyLoadingMixin {
  final LazyLoader _lazyLoader = LazyLoader();

  /// Carrega um recurso lazy
  Future<T> loadLazy<T>(String key, Future<T> Function() loader) {
    return _lazyLoader.loadModule(key, loader);
  }

  /// Verifica se recurso está carregado
  bool isResourceLoaded(String key) {
    return _lazyLoader.isLoaded(key);
  }
}

/// Keys padronizadas para módulos lazy
class LazyModuleKeys {
  static const String calculators = 'calculators';
  static const String medications = 'medications';
  static const String vaccines = 'vaccines';
  static const String appointments = 'appointments';
  static const String expenses = 'expenses';
  static const String weights = 'weights';
  static const String reminders = 'reminders';
  static const String profile = 'profile';
  static const String reports = 'reports';
  static const String settings = 'settings';
  
  // Features específicas
  static const String calculatorEngine = 'calculator_engine';
  static const String reportGenerator = 'report_generator';
  static const String dataExporter = 'data_exporter';
  static const String backupService = 'backup_service';
}