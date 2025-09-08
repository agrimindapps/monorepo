import 'dart:async';
import 'package:flutter/foundation.dart';
import 'favorito_events.dart';

/// Event Bus robusto para gerenciar eventos de favoritos
/// Substitui o método estático frágil por um sistema confiável de notificações
class FavoritoEventBus {
  static final FavoritoEventBus _instance = FavoritoEventBus._internal();
  factory FavoritoEventBus() => _instance;
  FavoritoEventBus._internal();

  /// Singleton instance para acesso global
  static FavoritoEventBus get instance => _instance;

  /// Stream controller para eventos
  final StreamController<FavoritoEvent> _eventController = 
      StreamController<FavoritoEvent>.broadcast();

  /// Stream público para escutar eventos
  Stream<FavoritoEvent> get eventStream => _eventController.stream;

  /// Escutar eventos específicos por tipo
  Stream<T> on<T extends FavoritoEvent>() {
    return _eventController.stream
        .where((event) => event is T)
        .cast<T>();
  }

  /// Escutar eventos por tipo de favorito (defensivo, praga, etc)
  Stream<FavoritoEvent> onTipo(String tipo) {
    return _eventController.stream
        .where((event) => event.tipo == tipo);
  }

  /// Escutar eventos para um item específico
  Stream<FavoritoEvent> onItem(String tipo, String itemId) {
    return _eventController.stream
        .where((event) => event.tipo == tipo && event.itemId == itemId);
  }

  /// Disparar um evento
  void fire(FavoritoEvent event) {
    if (kDebugMode) {
      debugPrint('🔔 [FavoritoEventBus] Firing: $event');
    }
    
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// Métodos de conveniência para disparar eventos específicos
  void fireAdded(String tipo, String itemId, {Map<String, dynamic>? itemData}) {
    fire(FavoritoAdded(
      tipo: tipo,
      itemId: itemId,
      itemData: itemData,
    ));
  }

  void fireRemoved(String tipo, String itemId) {
    fire(FavoritoRemoved(
      tipo: tipo,
      itemId: itemId,
    ));
  }

  void fireBatchChanged(String tipo, List<String> itemIds, bool added) {
    fire(FavoritosBatchChanged(
      tipo: tipo,
      itemIds: itemIds,
      added: added,
    ));
  }

  void fireCleared(String tipo) {
    fire(FavoritosCleared(tipo: tipo));
  }

  void fireError(String tipo, String itemId, String errorMessage, {dynamic originalError}) {
    fire(FavoritoError(
      tipo: tipo,
      itemId: itemId,
      errorMessage: errorMessage,
      originalError: originalError,
    ));
  }

  /// Criar subscription com cleanup automático
  StreamSubscription<T> listen<T extends FavoritoEvent>(
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return on<T>().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Cleanup - fechar o stream controller
  void dispose() {
    _eventController.close();
  }

  /// Debug: estatísticas do event bus
  Map<String, dynamic> getStats() {
    return {
      'hasListeners': _eventController.hasListener,
      'isClosed': _eventController.isClosed,
      'streamCount': _eventController.stream.isBroadcast ? 'broadcast' : 'single',
    };
  }
}

/// Mixin para facilitar uso em providers e widgets
mixin FavoritoEventListener {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Escutar eventos de favorito com cleanup automático
  void listenToFavoritoEvents<T extends FavoritoEvent>(
    void Function(T event) onData, {
    Function? onError,
  }) {
    final subscription = FavoritoEventBus.instance.listen<T>(
      onData,
      onError: onError,
    );
    _subscriptions.add(subscription);
  }

  /// Escutar eventos por tipo com cleanup automático
  void listenToFavoritoType(
    String tipo,
    void Function(FavoritoEvent event) onData, {
    Function? onError,
  }) {
    final subscription = FavoritoEventBus.instance.onTipo(tipo).listen(
      onData,
      onError: onError,
    );
    _subscriptions.add(subscription);
  }

  /// Escutar item específico com cleanup automático
  void listenToFavoritoItem(
    String tipo,
    String itemId,
    void Function(FavoritoEvent event) onData, {
    Function? onError,
  }) {
    final subscription = FavoritoEventBus.instance.onItem(tipo, itemId).listen(
      onData,
      onError: onError,
    );
    _subscriptions.add(subscription);
  }

  /// Cleanup - chamar no dispose
  void disposeEventListeners() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

/// Extension para facilitar uso
extension FavoritoEventBusExtension on FavoritoEventBus {
  /// Sugar syntax para disparar eventos
  void operator <<(FavoritoEvent event) => fire(event);
}