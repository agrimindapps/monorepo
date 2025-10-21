// Dart imports:
import 'dart:async';

// Project imports:
import '../models/exercicio_model.dart';

/// Tipos de eventos que podem ser emitidos
enum ExercicioEventType {
  created,
  updated,
  deleted,
  metasUpdated,
  dataRefreshed,
}

/// Classe que representa um evento de exercício
class ExercicioEvent {
  final ExercicioEventType type;
  final ExercicioModel? exercicio;
  final String? exercicioId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  ExercicioEvent({
    required this.type,
    this.exercicio,
    this.exercicioId,
    this.data,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'ExercicioEvent{type: $type, exercicioId: $exercicioId, timestamp: $timestamp}';
  }
}

/// Service responsável por gerenciar eventos entre controllers
/// Implementa padrão Observer/EventBus para desacoplar componentes
class ExercicioEventService {
  static final ExercicioEventService _instance = ExercicioEventService._internal();
  factory ExercicioEventService() => _instance;
  ExercicioEventService._internal();

  // Stream controllers para diferentes tipos de eventos
  final StreamController<ExercicioEvent> _eventController = 
      StreamController<ExercicioEvent>.broadcast();

  final StreamController<ExercicioModel> _exercicioCreatedController = 
      StreamController<ExercicioModel>.broadcast();

  final StreamController<ExercicioModel> _exercicioUpdatedController = 
      StreamController<ExercicioModel>.broadcast();

  final StreamController<String> _exercicioDeletedController = 
      StreamController<String>.broadcast();

  final StreamController<Map<String, dynamic>> _metasUpdatedController = 
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<void> _dataRefreshedController = 
      StreamController<void>.broadcast();

  // ========================================================================
  // STREAMS PÚBLICOS PARA SUBSCRIPTION
  // ========================================================================

  /// Stream geral de todos os eventos
  Stream<ExercicioEvent> get events => _eventController.stream;

  /// Stream específico para exercícios criados
  Stream<ExercicioModel> get exercicioCreated => _exercicioCreatedController.stream;

  /// Stream específico para exercícios atualizados
  Stream<ExercicioModel> get exercicioUpdated => _exercicioUpdatedController.stream;

  /// Stream específico para exercícios deletados
  Stream<String> get exercicioDeleted => _exercicioDeletedController.stream;

  /// Stream específico para metas atualizadas
  Stream<Map<String, dynamic>> get metasUpdated => _metasUpdatedController.stream;

  /// Stream específico para refresh de dados
  Stream<void> get dataRefreshed => _dataRefreshedController.stream;

  // ========================================================================
  // MÉTODOS PARA EMITIR EVENTOS
  // ========================================================================

  /// Emite evento quando um exercício é criado
  void emitExercicioCreated(ExercicioModel exercicio) {
    final event = ExercicioEvent(
      type: ExercicioEventType.created,
      exercicio: exercicio,
      exercicioId: exercicio.id,
    );
    
    _eventController.add(event);
    _exercicioCreatedController.add(exercicio);
    
    _logEvent(event);
  }

  /// Emite evento quando um exercício é atualizado
  void emitExercicioUpdated(ExercicioModel exercicio) {
    final event = ExercicioEvent(
      type: ExercicioEventType.updated,
      exercicio: exercicio,
      exercicioId: exercicio.id,
    );
    
    _eventController.add(event);
    _exercicioUpdatedController.add(exercicio);
    
    _logEvent(event);
  }

  /// Emite evento quando um exercício é deletado
  void emitExercicioDeleted(String exercicioId) {
    final event = ExercicioEvent(
      type: ExercicioEventType.deleted,
      exercicioId: exercicioId,
    );
    
    _eventController.add(event);
    _exercicioDeletedController.add(exercicioId);
    
    _logEvent(event);
  }

  /// Emite evento quando metas são atualizadas
  void emitMetasUpdated(double metaMinutos, double metaCalorias) {
    final metasData = {
      'metaMinutos': metaMinutos,
      'metaCalorias': metaCalorias,
    };
    
    final event = ExercicioEvent(
      type: ExercicioEventType.metasUpdated,
      data: metasData,
    );
    
    _eventController.add(event);
    _metasUpdatedController.add(metasData);
    
    _logEvent(event);
  }

  /// Emite evento quando dados precisam ser atualizados
  void emitDataRefresh() {
    final event = ExercicioEvent(
      type: ExercicioEventType.dataRefreshed,
    );
    
    _eventController.add(event);
    _dataRefreshedController.add(null);
    
    _logEvent(event);
  }

  // ========================================================================
  // MÉTODOS DE SUBSCRIPTION COM CALLBACK
  // ========================================================================

  /// Subscribe para eventos de criação de exercício
  StreamSubscription<ExercicioModel> onExercicioCreated(
    void Function(ExercicioModel) callback,
  ) {
    return exercicioCreated.listen(callback);
  }

  /// Subscribe para eventos de atualização de exercício
  StreamSubscription<ExercicioModel> onExercicioUpdated(
    void Function(ExercicioModel) callback,
  ) {
    return exercicioUpdated.listen(callback);
  }

  /// Subscribe para eventos de exclusão de exercício
  StreamSubscription<String> onExercicioDeleted(
    void Function(String) callback,
  ) {
    return exercicioDeleted.listen(callback);
  }

  /// Subscribe para eventos de atualização de metas
  StreamSubscription<Map<String, dynamic>> onMetasUpdated(
    void Function(Map<String, dynamic>) callback,
  ) {
    return metasUpdated.listen(callback);
  }

  /// Subscribe para eventos de refresh de dados
  StreamSubscription<void> onDataRefresh(
    void Function() callback,
  ) {
    return dataRefreshed.listen((_) => callback());
  }

  /// Subscribe para todos os eventos
  StreamSubscription<ExercicioEvent> onAnyEvent(
    void Function(ExercicioEvent) callback,
  ) {
    return events.listen(callback);
  }

  // ========================================================================
  // MÉTODOS DE SUBSCRIPTION COM FILTROS
  // ========================================================================

  /// Subscribe para eventos de um tipo específico
  StreamSubscription<ExercicioEvent> onEventType(
    ExercicioEventType type,
    void Function(ExercicioEvent) callback,
  ) {
    return events
        .where((event) => event.type == type)
        .listen(callback);
  }

  /// Subscribe para eventos de um exercício específico
  StreamSubscription<ExercicioEvent> onExercicioEvents(
    String exercicioId,
    void Function(ExercicioEvent) callback,
  ) {
    return events
        .where((event) => event.exercicioId == exercicioId)
        .listen(callback);
  }

  /// Subscribe para múltiplos tipos de eventos
  StreamSubscription<ExercicioEvent> onEventTypes(
    List<ExercicioEventType> types,
    void Function(ExercicioEvent) callback,
  ) {
    return events
        .where((event) => types.contains(event.type))
        .listen(callback);
  }

  // ========================================================================
  // MÉTODOS DE GERENCIAMENTO E DEBUG
  // ========================================================================

  /// Obtém estatísticas dos listeners ativos
  Map<String, int> getListenerStats() {
    return {
      'events': _eventController.hasListener ? 1 : 0,
      'exercicioCreated': _exercicioCreatedController.hasListener ? 1 : 0,
      'exercicioUpdated': _exercicioUpdatedController.hasListener ? 1 : 0,
      'exercicioDeleted': _exercicioDeletedController.hasListener ? 1 : 0,
      'metasUpdated': _metasUpdatedController.hasListener ? 1 : 0,
      'dataRefreshed': _dataRefreshedController.hasListener ? 1 : 0,
    };
  }

  /// Verifica se há listeners ativos
  bool get hasActiveListeners {
    return _eventController.hasListener ||
           _exercicioCreatedController.hasListener ||
           _exercicioUpdatedController.hasListener ||
           _exercicioDeletedController.hasListener ||
           _metasUpdatedController.hasListener ||
           _dataRefreshedController.hasListener;
  }

  /// Log interno para debug
  void _logEvent(ExercicioEvent event) {
    // Em desenvolvimento, você pode descomentar esta linha para debug
    // debugPrint('ExercicioEventService: ${event.toString()}');
  }

  /// Limpa todos os eventos pendentes (usado para testes ou reset)
  void clearPendingEvents() {
    // Os streams broadcast não acumulam eventos, então não há necessidade
    // de limpeza específica, mas este método pode ser útil para futuras extensões
  }

  /// Dispose de todos os stream controllers
  void dispose() {
    _eventController.close();
    _exercicioCreatedController.close();
    _exercicioUpdatedController.close();
    _exercicioDeletedController.close();
    _metasUpdatedController.close();
    _dataRefreshedController.close();
  }

  // ========================================================================
  // MÉTODOS DE CONVENIÊNCIA PARA BATCH OPERATIONS
  // ========================================================================

  /// Emite múltiplos eventos em sequência
  void emitBatch(List<ExercicioEvent> events) {
    for (final event in events) {
      _eventController.add(event);
      _logEvent(event);
    }
  }

  /// Cria um listener temporário que se auto-cancela após primeira execução
  StreamSubscription<T> listenOnce<T>(
    Stream<T> stream,
    void Function(T) callback,
  ) {
    late StreamSubscription<T> subscription;
    subscription = stream.listen((data) {
      callback(data);
      subscription.cancel();
    });
    return subscription;
  }

  /// Cria um listener que se cancela após um timeout
  StreamSubscription<T> listenWithTimeout<T>(
    Stream<T> stream,
    void Function(T) callback,
    Duration timeout,
  ) {
    late StreamSubscription<T> subscription;
    final timer = Timer(timeout, () {
      subscription.cancel();
    });
    
    subscription = stream.listen(
      (data) {
        callback(data);
      },
      onDone: () {
        timer.cancel();
      },
      onError: (_) {
        timer.cancel();
      },
    );
    
    return subscription;
  }
}
