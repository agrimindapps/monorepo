import 'dart:async';
import 'package:flutter/foundation.dart';

/// Gerenciador de streams e subscriptions para prevenir memory leaks
/// Garante que todos os streams sejam cancelados adequadamente
class StreamManager {
  final Map<String, StreamSubscription<dynamic>> _subscriptions = {};
  final Map<String, StreamController<dynamic>> _controllers = {};
  final Map<String, Timer> _timers = {};

  bool _isDisposed = false;

  /// Registra uma subscription para ser gerenciada
  void registerSubscription(String key, StreamSubscription<dynamic> subscription) {
    if (_isDisposed) {
      subscription.cancel();
      throw StateError('StreamManager already disposed');
    }
    _subscriptions[key]?.cancel();
    _subscriptions[key] = subscription;
  }

  /// Registra um stream controller para ser gerenciado
  void registerController<T>(String key, StreamController<T> controller) {
    if (_isDisposed) {
      controller.close();
      throw StateError('StreamManager already disposed');
    }
    _controllers[key]?.close();
    _controllers[key] = controller;
  }

  /// Registra um timer para ser gerenciado
  void registerTimer(String key, Timer timer) {
    if (_isDisposed) {
      timer.cancel();
      throw StateError('StreamManager already disposed');
    }
    _timers[key]?.cancel();
    _timers[key] = timer;
  }

  /// Cria e registra uma subscription com auto-cancelamento
  StreamSubscription<T> listenToStream<T>(
    String key,
    Stream<T> stream, {
    required void Function(T) onData,
    void Function(dynamic, StackTrace)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (_isDisposed) {
      throw StateError('StreamManager already disposed');
    }
    
    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: () {
        onDone?.call();
        _subscriptions.remove(key);
      },
      cancelOnError: cancelOnError ?? false,
    );
    
    registerSubscription(key, subscription);
    return subscription;
  }

  /// Cria e registra um broadcast stream controller
  StreamController<T> createBroadcastController<T>(String key) {
    if (_isDisposed) {
      throw StateError('StreamManager already disposed');
    }
    
    final controller = StreamController<T>.broadcast(
      onCancel: () {
        if (_controllers[key]?.hasListener == false) {
          _controllers.remove(key);
        }
      },
    );
    
    registerController(key, controller);
    return controller;
  }

  /// Cria e registra um single-subscription stream controller
  StreamController<T> createController<T>(String key, {bool sync = false}) {
    if (_isDisposed) {
      throw StateError('StreamManager already disposed');
    }
    
    final controller = StreamController<T>(
      sync: sync,
      onCancel: () {
        _controllers.remove(key);
      },
    );
    
    registerController(key, controller);
    return controller;
  }

  /// Cria e registra um timer periódico
  Timer createPeriodicTimer(
    String key,
    Duration duration,
    void Function(Timer) callback,
  ) {
    if (_isDisposed) {
      throw StateError('StreamManager already disposed');
    }
    
    final timer = Timer.periodic(duration, callback);
    registerTimer(key, timer);
    return timer;
  }

  /// Cria e registra um timer único
  Timer createTimer(
    String key,
    Duration duration,
    void Function() callback,
  ) {
    if (_isDisposed) {
      throw StateError('StreamManager already disposed');
    }
    
    final timer = Timer(duration, () {
      callback();
      _timers.remove(key);
    });
    
    registerTimer(key, timer);
    return timer;
  }

  /// Cancela uma subscription específica
  Future<void> cancelSubscription(String key) async {
    await _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
  }

  /// Fecha um controller específico
  Future<void> closeController(String key) async {
    await _controllers[key]?.close();
    _controllers.remove(key);
  }

  /// Cancela um timer específico
  void cancelTimer(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Verifica se tem subscription ativa
  bool hasSubscription(String key) => _subscriptions.containsKey(key);

  /// Verifica se tem controller ativo
  bool hasController(String key) => _controllers.containsKey(key);

  /// Verifica se tem timer ativo
  bool hasTimer(String key) => _timers.containsKey(key);

  /// Obtém estatísticas do manager
  Map<String, int> get stats => {
    'subscriptions': _subscriptions.length,
    'controllers': _controllers.length,
    'timers': _timers.length,
    'total': _subscriptions.length + _controllers.length + _timers.length,
  };

  /// Limpa recursos específicos por tipo
  Future<void> clearSubscriptions() async {
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> clearControllers() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
  }

  void clearTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Dispose completo - limpa todos os recursos
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    _isDisposed = true;
    await clearSubscriptions();
    await clearControllers();
    clearTimers();

    if (kDebugMode) {
      debugPrint('StreamManager disposed - cleaned up ${stats['total']} resources');
    }
  }

  /// Verifica se foi disposed
  bool get isDisposed => _isDisposed;
}

/// Mixin para adicionar StreamManager a classes
mixin StreamManagerMixin {
  final StreamManager _streamManager = StreamManager();
  
  @protected
  StreamManager get streamManager => _streamManager;
  
  /// Registra uma subscription
  @protected
  void addSubscription(String key, StreamSubscription<dynamic> subscription) {
    _streamManager.registerSubscription(key, subscription);
  }
  
  /// Registra um controller
  @protected
  void addController<T>(String key, StreamController<T> controller) {
    _streamManager.registerController(key, controller);
  }
  
  /// Registra um timer
  @protected
  void addTimer(String key, Timer timer) {
    _streamManager.registerTimer(key, timer);
  }
  
  /// Listen to stream com auto-gerenciamento
  @protected
  StreamSubscription<T> listenTo<T>(
    String key,
    Stream<T> stream, {
    required void Function(T) onData,
    void Function(dynamic, StackTrace)? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _streamManager.listenToStream(
      key,
      stream,
      onData: onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
  
  /// Dispose do mixin - deve ser chamado no dispose da classe
  @protected
  Future<void> disposeStreams() async {
    await _streamManager.dispose();
  }
}

/// Base class para providers com gerenciamento automático de streams
abstract class ManagedProvider with StreamManagerMixin {
  /// Inicializa o provider
  void init();
  
  /// Dispose do provider
  Future<void> dispose() async {
    await disposeStreams();
  }
}

/// Exemplo de uso em um provider
class ExampleProvider extends ManagedProvider {
  late final StreamController<String> _dataController;
  
  @override
  void init() {
    _dataController = streamManager.createBroadcastController('data');
    listenTo(
      'external_data',
      externalDataStream,
      onData: (data) {
        _dataController.add(processData(data));
      },
      onError: (error, stack) {
        _dataController.addError(error as Object? ?? 'Unknown error', stack as StackTrace? ?? StackTrace.empty);
      },
    );
    streamManager.createPeriodicTimer(
      'refresh_timer',
      const Duration(minutes: 5),
      (_) => refresh(),
    );
  }
  
  Stream<String> get dataStream => _dataController.stream;
  
  Stream<String> get externalDataStream => Stream<String>.periodic(
    const Duration(seconds: 1),
    (i) => 'Data $i',
  );
  
  String processData(String data) => 'Processed: $data';
  
  void refresh() {
    _dataController.add('Refreshed at ${DateTime.now()}');
  }
  
  @override
  Future<void> dispose() async {
    await super.dispose();
  }
}
