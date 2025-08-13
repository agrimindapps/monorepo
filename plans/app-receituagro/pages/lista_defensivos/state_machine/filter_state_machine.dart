import 'dart:async';

import '../models/migrated_lista_defensivos_state.dart';

/// Estados possíveis do filtro
enum FilterState {
  idle,          // Estado inicial, sem filtros
  filtering,     // Filtrando dados
  sorting,       // Ordenando dados
  paginating,    // Carregando mais páginas
  error,         // Estado de erro
}

/// Eventos que podem causar transições de estado
enum FilterEvent {
  startFilter,
  startSort,
  startPagination,
  complete,
  error,
  reset,
}

/// State Machine para gerenciar transições de filtro de forma atômica
class FilterStateMachine {
  FilterState _currentState = FilterState.idle;
  final StreamController<FilterState> _stateController = StreamController<FilterState>.broadcast();
  
  FilterState get currentState => _currentState;
  Stream<FilterState> get stateStream => _stateController.stream;
  
  /// Mapas de transições válidas
  static const Map<FilterState, Set<FilterEvent>> _validTransitions = {
    FilterState.idle: {
      FilterEvent.startFilter,
      FilterEvent.startSort,
      FilterEvent.startPagination,
    },
    FilterState.filtering: {
      FilterEvent.complete,
      FilterEvent.error,
      FilterEvent.reset,
    },
    FilterState.sorting: {
      FilterEvent.complete,
      FilterEvent.error,
      FilterEvent.reset,
    },
    FilterState.paginating: {
      FilterEvent.complete,
      FilterEvent.error,
      FilterEvent.reset,
    },
    FilterState.error: {
      FilterEvent.reset,
      FilterEvent.startFilter,
      FilterEvent.startSort,
    },
  };

  /// Executa transição de estado se for válida
  bool tryTransition(FilterEvent event) {
    final validEvents = _validTransitions[_currentState];
    if (validEvents?.contains(event) != true) {
      return false;
    }

    final previousState = _currentState;
    _currentState = _getNextState(event);
    
    // Emite o novo estado apenas se mudou
    if (_currentState != previousState) {
      _stateController.add(_currentState);
    }
    
    return true;
  }

  /// Determina o próximo estado baseado no evento
  FilterState _getNextState(FilterEvent event) {
    switch (event) {
      case FilterEvent.startFilter:
        return FilterState.filtering;
      case FilterEvent.startSort:
        return FilterState.sorting;
      case FilterEvent.startPagination:
        return FilterState.paginating;
      case FilterEvent.complete:
        return FilterState.idle;
      case FilterEvent.error:
        return FilterState.error;
      case FilterEvent.reset:
        return FilterState.idle;
    }
  }

  /// Verifica se uma transição é válida sem executá-la
  bool canTransition(FilterEvent event) {
    final validEvents = _validTransitions[_currentState];
    return validEvents?.contains(event) ?? false;
  }

  /// Força reset para estado idle (usado em casos de emergência)
  void forceReset() {
    _currentState = FilterState.idle;
    _stateController.add(_currentState);
  }

  /// Retorna se está em um estado de processamento
  bool get isProcessing => _currentState != FilterState.idle && _currentState != FilterState.error;

  /// Retorna se está em estado de erro
  bool get isError => _currentState == FilterState.error;

  void dispose() {
    _stateController.close();
  }
}

/// Operação atômica para execução de filtros
class FilterOperation {
  final FilterEvent event;
  final Future<MigratedListaDefensivosState> Function() operation;
  final String description;

  FilterOperation({
    required this.event,
    required this.operation,
    required this.description,
  });
}

/// Executor de operações de filtro com garantia de atomicidade
class AtomicFilterExecutor {
  final FilterStateMachine _stateMachine;
  
  AtomicFilterExecutor(this._stateMachine);

  /// Executa operação de filtro de forma atômica
  Future<MigratedListaDefensivosState?> executeOperation(FilterOperation operation) async {
    // Verifica se a transição é válida
    if (!_stateMachine.canTransition(operation.event)) {
      throw StateError(
        'Invalid transition: ${operation.event} from state ${_stateMachine.currentState}'
      );
    }

    // Inicia a transição
    if (!_stateMachine.tryTransition(operation.event)) {
      return null;
    }

    try {
      // Executa a operação
      final result = await operation.operation();
      
      // Marca como completa se ainda estiver no estado de processamento
      if (_stateMachine.isProcessing) {
        _stateMachine.tryTransition(FilterEvent.complete);
      }
      
      return result;
    } catch (e) {
      // Marca como erro
      _stateMachine.tryTransition(FilterEvent.error);
      rethrow;
    }
  }

  /// Cancela operação em andamento (força reset)
  void cancelOperation() {
    _stateMachine.forceReset();
  }
}