// Dart imports:
import 'dart:async';

// Project imports:
import '../exceptions/repository_exceptions.dart';
import '../logging/repository_logger.dart';

/// Tipo de operação para auditoria
enum TransactionOperationType {
  create,
  update,
  delete,
  batchCreate,
  batchUpdate,
  batchDelete,
}

/// Resultado de uma operação transacional
class TransactionResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final List<TransactionEvent> events;
  final String transactionId;

  const TransactionResult({
    required this.success,
    this.data,
    this.error,
    required this.events,
    required this.transactionId,
  });

  static TransactionResult<T> createSuccess<T>(
    T data,
    List<TransactionEvent> events,
    String transactionId,
  ) {
    return TransactionResult<T>(
      success: true,
      data: data,
      events: events,
      transactionId: transactionId,
    );
  }

  static TransactionResult<T> createFailure<T>(
    String error,
    List<TransactionEvent> events,
    String transactionId,
  ) {
    return TransactionResult<T>(
      success: false,
      error: error,
      events: events,
      transactionId: transactionId,
    );
  }
}

/// Event para auditoria de transações (Event Sourcing)
class TransactionEvent {
  final String eventId;
  final String transactionId;
  final TransactionOperationType operationType;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? beforeData;
  final Map<String, dynamic>? afterData;
  final DateTime timestamp;
  final bool isCompensating;

  TransactionEvent({
    required this.eventId,
    required this.transactionId,
    required this.operationType,
    required this.entityType,
    this.entityId,
    this.beforeData,
    this.afterData,
    required this.timestamp,
    this.isCompensating = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'transactionId': transactionId,
      'operationType': operationType.name,
      'entityType': entityType,
      'entityId': entityId,
      'beforeData': beforeData,
      'afterData': afterData,
      'timestamp': timestamp.toIso8601String(),
      'isCompensating': isCompensating,
    };
  }

  static TransactionEvent fromJson(Map<String, dynamic> json) {
    return TransactionEvent(
      eventId: json['eventId'],
      transactionId: json['transactionId'],
      operationType: TransactionOperationType.values
          .firstWhere((e) => e.name == json['operationType']),
      entityType: json['entityType'],
      entityId: json['entityId'],
      beforeData: json['beforeData']?.cast<String, dynamic>(),
      afterData: json['afterData']?.cast<String, dynamic>(),
      timestamp: DateTime.parse(json['timestamp']),
      isCompensating: json['isCompensating'] ?? false,
    );
  }
}

/// Ação compensatória para rollback
typedef CompensatingAction = Future<void> Function();

/// Operação transacional
class TransactionOperation<T> {
  final String operationId;
  final TransactionOperationType type;
  final Future<T> Function() operation;
  final CompensatingAction? compensatingAction;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? beforeData;
  final Map<String, dynamic>? afterData;

  TransactionOperation({
    required this.operationId,
    required this.type,
    required this.operation,
    this.compensatingAction,
    required this.entityType,
    this.entityId,
    this.beforeData,
    this.afterData,
  });
}

/// Gerenciador de transações atômicas com rollback e event sourcing
class TransactionManager {
  static TransactionManager? _instance;
  static TransactionManager get instance =>
      _instance ??= TransactionManager._();

  TransactionManager._();

  final RepositoryLogger _logger = RepositoryLogger(name: 'TransactionManager');
  final List<TransactionEvent> _eventStore = [];
  final Map<String, List<CompensatingAction>> _compensatingActions = {};

  /// Executar operação transacional simples
  Future<TransactionResult<T>> executeTransaction<T>(
    String transactionId,
    TransactionOperation<T> operation,
  ) async {
    final events = <TransactionEvent>[];
    final compensatingActions = <CompensatingAction>[];

    try {
      _logger.info('Iniciando transação: $transactionId');

      // Criar event de início
      final startEvent = TransactionEvent(
        eventId: _generateEventId(),
        transactionId: transactionId,
        operationType: operation.type,
        entityType: operation.entityType,
        entityId: operation.entityId,
        beforeData: operation.beforeData,
        timestamp: DateTime.now(),
      );
      events.add(startEvent);
      _eventStore.add(startEvent);

      // Executar operação
      final result = await operation.operation();

      // Criar event de sucesso
      final successEvent = TransactionEvent(
        eventId: _generateEventId(),
        transactionId: transactionId,
        operationType: operation.type,
        entityType: operation.entityType,
        entityId: operation.entityId,
        beforeData: operation.beforeData,
        afterData: operation.afterData,
        timestamp: DateTime.now(),
      );
      events.add(successEvent);
      _eventStore.add(successEvent);

      // Registrar compensating action se fornecida
      if (operation.compensatingAction != null) {
        compensatingActions.add(operation.compensatingAction!);
        _compensatingActions[transactionId] = compensatingActions;
      }

      _logger.info('Transação concluída com sucesso: $transactionId');
      return TransactionResult.createSuccess(result, events, transactionId);
    } catch (e) {
      _logger.error('Erro na transação $transactionId: $e');

      // Executar rollback se necessário
      await _executeRollback(transactionId, compensatingActions);

      // Criar event de erro
      final errorEvent = TransactionEvent(
        eventId: _generateEventId(),
        transactionId: transactionId,
        operationType: operation.type,
        entityType: operation.entityType,
        entityId: operation.entityId,
        beforeData: operation.beforeData,
        timestamp: DateTime.now(),
      );
      events.add(errorEvent);
      _eventStore.add(errorEvent);

      return TransactionResult.createFailure(
          e.toString(), events, transactionId);
    }
  }

  /// Executar transação batch com rollback automático
  Future<TransactionResult<List<T>>> executeBatchTransaction<T>(
    String transactionId,
    List<TransactionOperation<T>> operations,
  ) async {
    final results = <T>[];
    final events = <TransactionEvent>[];
    final compensatingActions = <CompensatingAction>[];

    try {
      _logger.info(
          'Iniciando transação batch: $transactionId com ${operations.length} operações');

      // Executar operações em sequência
      for (int i = 0; i < operations.length; i++) {
        final operation = operations[i];

        // Criar event de início da operação
        final startEvent = TransactionEvent(
          eventId: _generateEventId(),
          transactionId: transactionId,
          operationType: operation.type,
          entityType: operation.entityType,
          entityId: operation.entityId,
          beforeData: operation.beforeData,
          timestamp: DateTime.now(),
        );
        events.add(startEvent);
        _eventStore.add(startEvent);

        try {
          // Executar operação individual
          final result = await operation.operation();
          results.add(result);

          // Criar event de sucesso da operação
          final successEvent = TransactionEvent(
            eventId: _generateEventId(),
            transactionId: transactionId,
            operationType: operation.type,
            entityType: operation.entityType,
            entityId: operation.entityId,
            beforeData: operation.beforeData,
            afterData: operation.afterData,
            timestamp: DateTime.now(),
          );
          events.add(successEvent);
          _eventStore.add(successEvent);

          // Registrar compensating action
          if (operation.compensatingAction != null) {
            compensatingActions.insert(
                0, operation.compensatingAction!); // LIFO order for rollback
          }
        } catch (operationError) {
          _logger.error(
              'Erro na operação $i da transação batch $transactionId: $operationError');

          // Rollback de todas as operações já executadas
          await _executeRollback(transactionId, compensatingActions);

          // Criar event de erro
          final errorEvent = TransactionEvent(
            eventId: _generateEventId(),
            transactionId: transactionId,
            operationType: operation.type,
            entityType: operation.entityType,
            entityId: operation.entityId,
            beforeData: operation.beforeData,
            timestamp: DateTime.now(),
          );
          events.add(errorEvent);
          _eventStore.add(errorEvent);

          throw BatchTransactionException(
            'Falha na operação $i: $operationError',
            transactionId,
            i,
            operationError,
          );
        }
      }

      // Armazenar compensating actions para possível rollback futuro
      _compensatingActions[transactionId] = compensatingActions;

      _logger.info('Transação batch concluída com sucesso: $transactionId');
      return TransactionResult.createSuccess(results, events, transactionId);
    } catch (e) {
      _logger.error('Erro na transação batch $transactionId: $e');
      return TransactionResult.createFailure(
          e.toString(), events, transactionId);
    }
  }

  /// Executar rollback manual de uma transação
  Future<void> rollbackTransaction(String transactionId) async {
    final compensatingActions = _compensatingActions[transactionId];
    if (compensatingActions == null) {
      _logger.warning(
          'Nenhuma compensating action encontrada para transação: $transactionId');
      return;
    }

    await _executeRollback(transactionId, compensatingActions);
    _compensatingActions.remove(transactionId);
  }

  /// Executar compensating actions (rollback)
  Future<void> _executeRollback(
    String transactionId,
    List<CompensatingAction> compensatingActions,
  ) async {
    if (compensatingActions.isEmpty) {
      _logger.info(
          'Nenhuma compensating action para executar na transação: $transactionId');
      return;
    }

    _logger.info('Executando rollback da transação: $transactionId');

    // Executar compensating actions em ordem reversa (LIFO)
    for (int i = compensatingActions.length - 1; i >= 0; i--) {
      try {
        await compensatingActions[i]();

        // Criar event de compensação
        final compensatingEvent = TransactionEvent(
          eventId: _generateEventId(),
          transactionId: transactionId,
          operationType:
              TransactionOperationType.batchDelete, // Compensating action
          entityType: 'compensating_action',
          timestamp: DateTime.now(),
          isCompensating: true,
        );
        _eventStore.add(compensatingEvent);
      } catch (rollbackError) {
        _logger.error(
            'Erro ao executar compensating action $i da transação $transactionId: $rollbackError');
        // Continuar com as próximas compensating actions mesmo se uma falhar
      }
    }

    _logger.info('Rollback concluído para transação: $transactionId');
  }

  /// Obter histórico de events de uma transação (Event Sourcing)
  List<TransactionEvent> getTransactionHistory(String transactionId) {
    return _eventStore
        .where((event) => event.transactionId == transactionId)
        .toList();
  }

  /// Obter todos os events do Event Store
  List<TransactionEvent> getAllEvents() {
    return List.unmodifiable(_eventStore);
  }

  /// Obter events por tipo de operação
  List<TransactionEvent> getEventsByOperationType(
      TransactionOperationType type) {
    return _eventStore.where((event) => event.operationType == type).toList();
  }

  /// Obter events por entidade
  List<TransactionEvent> getEventsByEntity(String entityType,
      [String? entityId]) {
    return _eventStore.where((event) {
      return event.entityType == entityType &&
          (entityId == null || event.entityId == entityId);
    }).toList();
  }

  /// Limpar events antigos (para evitar memory leak)
  void cleanupOldEvents({Duration maxAge = const Duration(days: 7)}) {
    final cutoff = DateTime.now().subtract(maxAge);
    _eventStore.removeWhere((event) => event.timestamp.isBefore(cutoff));
    _logger.info('Limpeza de events: removidos events anteriores a $cutoff');
  }

  /// Obter estatísticas das transações
  Map<String, dynamic> getTransactionStats() {
    final totalEvents = _eventStore.length;
    final successfulTransactions = _eventStore
        .where((e) => !e.isCompensating)
        .map((e) => e.transactionId)
        .toSet()
        .length;
    final compensatingEvents =
        _eventStore.where((e) => e.isCompensating).length;

    return {
      'totalEvents': totalEvents,
      'successfulTransactions': successfulTransactions,
      'compensatingEvents': compensatingEvents,
      'activeTransactions': _compensatingActions.length,
      'eventTypes': _getEventTypeStats(),
    };
  }

  Map<String, int> _getEventTypeStats() {
    final stats = <String, int>{};
    for (final event in _eventStore) {
      final key = event.operationType.name;
      stats[key] = (stats[key] ?? 0) + 1;
    }
    return stats;
  }

  String _generateEventId() {
    return 'evt_${DateTime.now().millisecondsSinceEpoch}_${_eventStore.length}';
  }

  String generateTransactionId(String operation) {
    return '${operation}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Limpar todas as transações e events (para testes)
  void clearAll() {
    _eventStore.clear();
    _compensatingActions.clear();
  }
}
