// Dart imports:
import 'dart:async';

// Package imports:
import 'package:logging/logging.dart';

// Project imports:
import 'domain_event.dart';
import 'domain_events.dart';

/// Type definition para event handlers
typedef EventHandler<T extends DomainEvent> = Future<void> Function(T event);

/// Event Bus para comunicação desacoplada entre componentes
///
/// Implementa padrão Publisher-Subscriber permitindo:
/// - Comunicação assíncrona entre repositories e services
/// - Desacoplamento de dependências diretas
/// - Event-driven architecture
/// - Logging e auditoria centralizados
class EventBus {
  static EventBus? _instance;
  static EventBus get instance => _instance ??= EventBus._();

  EventBus._();

  // Mapeamento de tipos de evento para handlers
  final Map<Type, List<EventHandler>> _handlers = <Type, List<EventHandler>>{};

  // Stream controller para eventos
  final StreamController<DomainEvent> _eventStreamController =
      StreamController<DomainEvent>.broadcast();

  // Stream de todos os eventos (útil para logging/debugging)
  Stream<DomainEvent> get eventStream => _eventStreamController.stream;

  // Controle de estado
  bool _isDisposed = false;

  // Estatísticas
  int _totalEventsPublished = 0;
  int _totalHandlersExecuted = 0;
  final Map<String, int> _eventTypeCounters = <String, int>{};

  /// Registra um handler para um tipo específico de evento
  void on<T extends DomainEvent>(EventHandler<T> handler) {
    if (_isDisposed) {
      throw StateError('EventBus has been disposed');
    }

    final List<EventHandler> handlers = _handlers[T] ?? [];
    // Use type cast to ensure compatibility
    handlers.add(handler as EventHandler);
    _handlers[T] = handlers;
  }

  /// Remove um handler específico
  void off<T extends DomainEvent>(EventHandler<T> handler) {
    if (_isDisposed) return;

    final List<EventHandler>? handlers = _handlers[T];
    if (handlers != null) {
      handlers.remove(handler);
      if (handlers.isEmpty) {
        _handlers.remove(T);
      }
    }
  }

  /// Remove todos os handlers de um tipo de evento
  void offAll<T extends DomainEvent>() {
    if (_isDisposed) return;
    _handlers.remove(T);
  }

  /// Publica um evento para todos os handlers registrados
  Future<void> publish<T extends DomainEvent>(T event) async {
    if (_isDisposed) {
      throw StateError('EventBus has been disposed');
    }

    // Atualizar estatísticas
    _totalEventsPublished++;
    _eventTypeCounters[event.eventType] =
        (_eventTypeCounters[event.eventType] ?? 0) + 1;

    // Adicionar ao stream principal
    _eventStreamController.add(event);

    // Encontrar handlers para o tipo específico
    final List<EventHandler> typeHandlers = _handlers[T] ?? [];

    // Encontrar handlers para tipos base (herança)
    final List<EventHandler> baseHandlers = [];
    for (final entry in _handlers.entries) {
      if (entry.key != T && _isSubtype(T, entry.key)) {
        baseHandlers.addAll(entry.value);
      }
    }

    final allHandlers = [...typeHandlers, ...baseHandlers];

    if (allHandlers.isEmpty) {
      // Log para debug se necessário
      Logger('EventBus').warning('No handlers registered for event type $T');
      return;
    }

    // Executar todos os handlers concorrentemente
    final List<Future<void>> handlerExecutions = [];

    for (final handler in allHandlers) {
      handlerExecutions.add(_executeHandlerSafely(handler, event));
    }

    // Aguardar todos os handlers completarem
    await Future.wait(handlerExecutions);

    _totalHandlersExecuted += handlerExecutions.length;
  }

  /// Executa handler com tratamento seguro de erros
  Future<void> _executeHandlerSafely<T extends DomainEvent>(
    EventHandler handler,
    T event,
  ) async {
    try {
      await handler(event);
    } catch (error, stackTrace) {
      // Log error mas não interrompe outros handlers
      Logger('EventBus').severe('Handler error for event ${event.eventType}: $error');
      Logger('EventBus').severe('Stack trace: $stackTrace');
    }
  }

  /// Verifica se um tipo é subtipo de outro (simplificado)
  bool _isSubtype(Type subtype, Type supertype) {
    // Esta é uma implementação simplificada
    // Em caso real, seria necessário reflection mais avançada
    if (supertype == DomainEvent) {
      return true; // Todos eventos são subtipos de DomainEvent
    }

    // Verificações específicas para hierarquia de eventos
    if (supertype == EspacoEvent) {
      return _isEspacoEventSubtype(subtype);
    }

    if (supertype == PlantaEvent) {
      return _isPlantaEventSubtype(subtype);
    }

    if (supertype == TarefaEvent) {
      return _isTarefaEventSubtype(subtype);
    }

    if (supertype == PlantaConfigEvent) {
      return _isPlantaConfigEventSubtype(subtype);
    }

    return false;
  }

  bool _isEspacoEventSubtype(Type type) {
    return type == EspacoCriado ||
        type == EspacoAtualizado ||
        type == EspacoRemovido ||
        type == EspacoStatusAlterado;
  }

  bool _isPlantaEventSubtype(Type type) {
    return type == PlantaCriada ||
        type == PlantaAtualizada ||
        type == PlantaRemovida ||
        type == PlantaMovida;
  }

  bool _isTarefaEventSubtype(Type type) {
    return type == TarefaCriada ||
        type == TarefaConcluida ||
        type == TarefaRemovida;
  }

  bool _isPlantaConfigEventSubtype(Type type) {
    return type == PlantaConfigCriada ||
        type == TipoCuidadoAlterado ||
        type == PlantaConfigRemovida;
  }

  /// Registra handlers para múltiplos eventos
  void onMultiple<T extends DomainEvent>(
    Map<Type, EventHandler<T>> handlerMap,
  ) {
    for (final entry in handlerMap.entries) {
      on(entry.value);
    }
  }

  /// Publica múltiplos eventos em batch
  Future<void> publishBatch(List<DomainEvent> events) async {
    final List<Future<void>> publishOperations = [];

    for (final event in events) {
      publishOperations.add(publish(event));
    }

    await Future.wait(publishOperations);
  }

  /// Stream filtrado por tipo de evento
  Stream<T> streamFor<T extends DomainEvent>() {
    return eventStream.where((event) => event is T).cast<T>();
  }

  /// Stream filtrado por tipo de evento com string
  Stream<DomainEvent> streamForEventType(String eventType) {
    return eventStream.where((event) => event.eventType == eventType);
  }

  /// Obtém estatísticas do event bus
  Map<String, dynamic> getStatistics() {
    return {
      'total_events_published': _totalEventsPublished,
      'total_handlers_executed': _totalHandlersExecuted,
      'event_type_counters': Map.from(_eventTypeCounters),
      'registered_handler_types':
          _handlers.keys.map((k) => k.toString()).toList(),
      'total_handler_types': _handlers.length,
      'total_handlers':
          _handlers.values.fold(0, (sum, handlers) => sum + handlers.length),
      'is_disposed': _isDisposed,
    };
  }

  /// Lista eventos recentes (últimos N eventos)
  List<DomainEvent> getRecentEvents({int limit = 10}) {
    // Implementação simplificada - em produção poderia usar buffer circular
    return [];
  }

  /// Limpa contadores de estatísticas
  void clearStatistics() {
    _totalEventsPublished = 0;
    _totalHandlersExecuted = 0;
    _eventTypeCounters.clear();
  }

  /// Verifica se existem handlers para um tipo de evento
  bool hasHandlers<T extends DomainEvent>() {
    return _handlers.containsKey(T) && _handlers[T]!.isNotEmpty;
  }

  /// Conta handlers registrados para um tipo
  int countHandlers<T extends DomainEvent>() {
    return _handlers[T]?.length ?? 0;
  }

  /// Aguarda todos os eventos pendentes serem processados
  Future<void> waitForPendingEvents() async {
    // Permite que todos eventos pendentes no stream sejam processados
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// Dispose do event bus
  void dispose() {
    if (_isDisposed) return;

    _handlers.clear();
    _eventStreamController.close();
    _eventTypeCounters.clear();
    _isDisposed = true;
  }

  /// Reset completo (útil para testes)
  void reset() {
    dispose();
    _instance = EventBus._();
  }
}

/// Extensions para facilitar uso
extension EventBusExtensions on EventBus {
  /// Publish com syntax mais limpa
  Future<void> emit<T extends DomainEvent>(T event) => publish(event);

  /// Subscribe com syntax mais limpa
  void subscribe<T extends DomainEvent>(EventHandler<T> handler) => on(handler);

  /// Unsubscribe com syntax mais limpa
  void unsubscribe<T extends DomainEvent>(EventHandler<T> handler) =>
      off(handler);
}

/// Mixin para facilitar uso do EventBus em classes
mixin EventPublisher {
  EventBus get _eventBus => EventBus.instance;

  /// Publica um evento
  Future<void> publishEvent<T extends DomainEvent>(T event) {
    return _eventBus.publish(event);
  }

  /// Registra handler para eventos
  void onEvent<T extends DomainEvent>(EventHandler<T> handler) {
    _eventBus.on(handler);
  }

  /// Remove handler
  void offEvent<T extends DomainEvent>(EventHandler<T> handler) {
    _eventBus.off(handler);
  }
}
