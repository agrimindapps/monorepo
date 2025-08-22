import 'dart:async';
import 'package:flutter/foundation.dart';

/// Gerenciador de lazy loading para otimização de performance
/// 
/// Implementa estratégias de carregamento preguiçoso para:
/// - Providers
/// - Datasets grandes
/// - Componentes pesados
/// - Cálculos complexos
class LazyLoadingManager extends ChangeNotifier {
  static final LazyLoadingManager _instance = LazyLoadingManager._internal();
  factory LazyLoadingManager() => _instance;
  LazyLoadingManager._internal();

  // Cache de instâncias lazy
  final Map<String, dynamic> _lazyCache = {};
  final Map<String, Future<dynamic>> _loadingFutures = {};
  final Set<String> _loadedKeys = {};

  /// Registra um provider para lazy loading
  void registerProvider<T>(String key, T Function() factory) {
    if (!_lazyCache.containsKey(key)) {
      _lazyCache[key] = factory;
    }
  }

  /// Obtém um provider com lazy loading
  Future<T> getProvider<T>(String key) async {
    // Se já foi carregado, retorna imediatamente
    if (_loadedKeys.contains(key)) {
      return _lazyCache[key] as T;
    }

    // Se está sendo carregado, aguarda o carregamento
    if (_loadingFutures.containsKey(key)) {
      return await _loadingFutures[key] as T;
    }

    // Inicia o carregamento
    final completer = Completer<T>();
    _loadingFutures[key] = completer.future;

    try {
      final factory = _lazyCache[key] as T Function();
      final instance = factory();
      
      _lazyCache[key] = instance;
      _loadedKeys.add(key);
      
      completer.complete(instance);
      _loadingFutures.remove(key);
      
      notifyListeners();
      return instance;
    } catch (error) {
      _loadingFutures.remove(key);
      completer.completeError(error);
      rethrow;
    }
  }

  /// Verifica se um provider está carregado
  bool isLoaded(String key) => _loadedKeys.contains(key);

  /// Verifica se um provider está sendo carregado
  bool isLoading(String key) => _loadingFutures.containsKey(key);

  /// Pré-carrega providers com prioridade
  Future<void> preloadProviders(List<String> keys, {int? priority}) async {
    final futures = keys.where((key) => !isLoaded(key)).map((key) {
      return getProvider(key);
    });

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Remove um provider do cache (para economizar memória)
  void unloadProvider(String key) {
    _lazyCache.remove(key);
    _loadedKeys.remove(key);
    _loadingFutures.remove(key);
    notifyListeners();
  }

  /// Limpa todo o cache
  void clearCache() {
    _lazyCache.clear();
    _loadedKeys.clear();
    _loadingFutures.clear();
    notifyListeners();
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStats() {
    return {
      'total_registered': _lazyCache.length,
      'loaded': _loadedKeys.length,
      'loading': _loadingFutures.length,
      'memory_usage_kb': _estimateMemoryUsage(),
    };
  }

  /// Estima o uso de memória do cache
  double _estimateMemoryUsage() {
    // Estimativa simples baseada no número de instâncias
    return _loadedKeys.length * 0.5; // 0.5KB por instância (estimativa)
  }
}

/// Mixin para facilitar o uso de lazy loading em widgets
mixin LazyLoadingMixin<T extends StatefulWidget> on State<T> {
  final LazyLoadingManager _lazyManager = LazyLoadingManager();

  /// Carrega um provider de forma lazy
  Future<P> loadProvider<P>(String key) {
    return _lazyManager.getProvider<P>(key);
  }

  /// Verifica se um provider está carregado
  bool isProviderLoaded(String key) {
    return _lazyManager.isLoaded(key);
  }

  /// Verifica se um provider está sendo carregado
  bool isProviderLoading(String key) {
    return _lazyManager.isLoading(key);
  }

  @override
  void dispose() {
    // Providers não são descarregados automaticamente no dispose
    // para permitir reutilização entre widgets
    super.dispose();
  }
}

/// Decorator para automatizar o lazy loading
class LazyProvider<T> {
  final String key;
  final T Function() _factory;
  final LazyLoadingManager _manager = LazyLoadingManager();

  LazyProvider(this.key, this._factory) {
    _manager.registerProvider<T>(key, _factory);
  }

  /// Obtém a instância (carrega se necessário)
  Future<T> get instance => _manager.getProvider<T>(key);

  /// Verifica se está carregado
  bool get isLoaded => _manager.isLoaded(key);

  /// Verifica se está carregando
  bool get isLoading => _manager.isLoading(key);

  /// Descarrega da memória
  void unload() => _manager.unloadProvider(key);
}

/// Widget para exibir loading state durante lazy loading
class LazyLoadingBuilder<T> extends StatefulWidget {
  final String providerKey;
  final Widget Function(BuildContext context, T provider) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, dynamic error)? errorBuilder;
  final bool preload;

  const LazyLoadingBuilder({
    Key? key,
    required this.providerKey,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.preload = false,
  }) : super(key: key);

  @override
  State<LazyLoadingBuilder<T>> createState() => _LazyLoadingBuilderState<T>();
}

class _LazyLoadingBuilderState<T> extends State<LazyLoadingBuilder<T>> {
  final LazyLoadingManager _manager = LazyLoadingManager();
  T? _provider;
  dynamic _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.preload) {
      _loadProvider();
    }
  }

  Future<void> _loadProvider() async {
    if (_manager.isLoaded(widget.providerKey)) {
      _provider = await _manager.getProvider<T>(widget.providerKey);
      if (mounted) setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _provider = await _manager.getProvider<T>(widget.providerKey);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _error) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(height: 8),
                Text('Erro: $_error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProvider,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
    }

    if (_provider == null || _isLoading) {
      if (!widget.preload && _provider == null) {
        _loadProvider();
      }
      
      return widget.loadingBuilder?.call(context) ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando...'),
              ],
            ),
          );
    }

    return widget.builder(context, _provider!);
  }
}

/// Extensão para facilitar o uso do lazy loading
extension LazyLoadingExtension on BuildContext {
  /// Carrega um provider de forma lazy
  Future<T> loadProvider<T>(String key) {
    return LazyLoadingManager().getProvider<T>(key);
  }
}