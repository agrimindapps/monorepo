// Dart imports:
import 'dart:async';

/// Gerenciador de subscriptions para evitar memory leaks
class StreamManager {
  final List<StreamSubscription> _subscriptions = [];
  final List<StreamController> _controllers = [];
  final Set<String> _managedStreamKeys = <String>{};
  final Map<String, WeakReference<StreamSubscription>> _weakSubscriptions = {};
  bool _isDisposed = false;

  /// Adicionar subscription ao gerenciador
  void addSubscription(StreamSubscription subscription, [String? key]) {
    if (_isDisposed) return; // Ignorar se já foi disposed

    _subscriptions.add(subscription);

    if (key != null) {
      _managedStreamKeys.add(key);
      _weakSubscriptions[key] = WeakReference(subscription);
    }
  }

  /// Adicionar controller ao gerenciador
  void addController(StreamController controller, [String? key]) {
    if (_isDisposed) return; // Ignorar se já foi disposed

    _controllers.add(controller);

    if (key != null) {
      _managedStreamKeys.add(key);
    }
  }

  /// Cancelar todas as subscriptions
  Future<void> dispose() async {
    if (_isDisposed) return; // Evitar dispose múltiplo

    _isDisposed = true;

    // Cancelar todas as subscriptions de forma segura
    final cancelFutures = <Future>[];
    for (final sub in _subscriptions) {
      try {
        cancelFutures.add(sub.cancel());
      } catch (e) {
        // Log erro mas continue o cleanup
        print('Erro ao cancelar subscription: $e');
      }
    }

    if (cancelFutures.isNotEmpty) {
      await Future.wait(cancelFutures, eagerError: false);
    }
    _subscriptions.clear();

    // Fechar todos os controllers de forma segura
    for (final controller in _controllers) {
      try {
        if (!controller.isClosed) {
          await controller.close();
        }
      } catch (e) {
        // Log erro mas continue o cleanup
        print('Erro ao fechar controller: $e');
      }
    }
    _controllers.clear();

    // Limpar weak references e keys
    _weakSubscriptions.clear();
    _managedStreamKeys.clear();
  }

  /// Verificar se tem resources ativos
  bool get hasActiveResources =>
      !_isDisposed && (_subscriptions.isNotEmpty || _controllers.isNotEmpty);

  /// Verificar se foi disposed
  bool get isDisposed => _isDisposed;

  /// Obter número de subscriptions ativas
  int get activeSubscriptionsCount => _isDisposed ? 0 : _subscriptions.length;

  /// Obter número de controllers ativos
  int get activeControllersCount => _isDisposed ? 0 : _controllers.length;

  /// Obter número de weak references ativas
  int get activeWeakReferencesCount => _weakSubscriptions.length;

  /// Verificar se uma key específica está sendo gerenciada
  bool isManagedKey(String key) => _managedStreamKeys.contains(key);

  /// Cancelar subscription específica por key
  Future<void> cancelByKey(String key) async {
    final weakRef = _weakSubscriptions[key];
    if (weakRef != null) {
      final subscription = weakRef.target;
      if (subscription != null) {
        await subscription.cancel();
        _subscriptions.remove(subscription);
      }
      _weakSubscriptions.remove(key);
    }
    _managedStreamKeys.remove(key);
  }
}

/// Extensões para facilitar o uso do StreamManager
extension StreamExtensions<T> on Stream<T> {
  /// Fazer takeUntil com gerenciamento automático
  Stream<T> takeUntilDispose(StreamManager manager) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        manager.addSubscription(subscription,
            'takeUntil_${T.toString()}_${DateTime.now().millisecondsSinceEpoch}');
      },
      onCancel: () {
        subscription.cancel();
      },
    );

    manager.addController(controller);
    return controller.stream;
  }

  /// Fazer listen com gerenciamento automático
  StreamSubscription<T> listenManaged(
    StreamManager manager,
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    String? subscriptionKey,
  }) {
    final subscription = listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    manager.addSubscription(subscription, subscriptionKey);
    return subscription;
  }
}

/// Helper para criar streams com lifecycle management
class ManagedStream<T> {
  final StreamManager _manager = StreamManager();
  final StreamController<T> _controller = StreamController<T>.broadcast();

  /// Stream público
  Stream<T> get stream => _controller.stream;

  /// Adicionar dados ao stream
  void add(T data) {
    if (!_controller.isClosed) {
      _controller.add(data);
    }
  }

  /// Adicionar erro ao stream
  void addError(Object error, [StackTrace? stackTrace]) {
    if (!_controller.isClosed) {
      _controller.addError(error, stackTrace);
    }
  }

  /// Fechar o stream
  Future<void> close() async {
    await _controller.close();
    await _manager.dispose();
  }

  /// Verificar se está fechado
  bool get isClosed => _controller.isClosed;

  /// Obter informações de debug
  Map<String, dynamic> get debugInfo => {
        'isClosed': isClosed,
        'hasListeners': _controller.hasListener,
        'activeSubscriptions': _manager.activeSubscriptionsCount,
        'activeControllers': _manager.activeControllersCount,
      };
}

/// Mixin para repositories com stream management
mixin StreamLifecycleManager {
  StreamManager? _streamManager;
  bool _isStreamManagerDisposed = false;

  /// Lazy initialization do StreamManager
  StreamManager get streamManager {
    if (_isStreamManagerDisposed) {
      throw StateError('StreamManager já foi disposed');
    }
    return _streamManager ??= StreamManager();
  }

  /// Fazer subscribe com lifecycle management
  StreamSubscription<T> subscribe<T>(
    Stream<T> stream,
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    String? subscriptionKey,
  }) {
    if (_isStreamManagerDisposed) {
      throw StateError('Não é possível criar subscriptions após dispose');
    }

    return stream.listenManaged(
      streamManager,
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
      subscriptionKey: subscriptionKey,
    );
  }

  /// Criar stream gerenciado
  Stream<T> createManagedStream<T>(Stream<T> source, [String? streamKey]) {
    if (_isStreamManagerDisposed) {
      throw StateError('Não é possível criar streams após dispose');
    }

    return source.takeUntilDispose(streamManager);
  }

  /// Criar stream com asyncMap gerenciado (evita memory leaks)
  Stream<R> createManagedAsyncMapStream<T, R>(
    Stream<T> source,
    Future<R> Function(T) mapper, {
    String? streamKey,
  }) {
    if (_isStreamManagerDisposed) {
      throw StateError('Não é possível criar streams após dispose');
    }

    late StreamController<R> controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<R>(
      onListen: () {
        subscription = source.listen(
          (data) async {
            try {
              final result = await mapper(data);
              if (!controller.isClosed) {
                controller.add(result);
              }
            } catch (error, stackTrace) {
              if (!controller.isClosed) {
                controller.addError(error, stackTrace);
              }
            }
          },
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );

        streamManager.addSubscription(subscription!, streamKey);
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    streamManager.addController(
        controller, streamKey != null ? '${streamKey}_controller' : null);
    return controller.stream;
  }

  /// Limpar todos os recursos de stream
  Future<void> disposeStreams() async {
    if (!_isStreamManagerDisposed && _streamManager != null) {
      _isStreamManagerDisposed = true;
      await _streamManager!.dispose();
      _streamManager = null;
    }
  }

  /// Verificar se tem resources ativos (útil para debug)
  bool get hasActiveStreamResources =>
      !_isStreamManagerDisposed &&
      (_streamManager?.hasActiveResources ?? false);

  /// Obter informações de debug sobre streams
  Map<String, dynamic> get streamDebugInfo => {
        'activeSubscriptions': _streamManager?.activeSubscriptionsCount ?? 0,
        'activeControllers': _streamManager?.activeControllersCount ?? 0,
        'activeWeakReferences': _streamManager?.activeWeakReferencesCount ?? 0,
        'hasActiveResources': hasActiveStreamResources,
        'isDisposed': _isStreamManagerDisposed,
      };

  /// Cancelar subscription específica por key
  Future<void> cancelStreamByKey(String key) async {
    if (!_isStreamManagerDisposed && _streamManager != null) {
      await _streamManager!.cancelByKey(key);
    }
  }

  /// Verificar se uma subscription key está ativa
  bool isStreamKeyActive(String key) {
    return !_isStreamManagerDisposed &&
        (_streamManager?.isManagedKey(key) ?? false);
  }
}
