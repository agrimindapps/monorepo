// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'bootstrap_phase.dart';

/// State Machine para gerenciar transições de fase de inicialização
/// Resolve race conditions usando Completer e StreamController
class BootstrapStateMachine {
  static BootstrapStateMachine? _instance;
  static final _initializationLock = Completer<void>();
  
  static Future<BootstrapStateMachine> get instance async {
    if (_instance == null) {
      if (!_initializationLock.isCompleted) {
        _instance = BootstrapStateMachine._internal();
        _initializationLock.complete();
      } else {
        await _initializationLock.future;
      }
    }
    return _instance!;
  }

  BootstrapStateMachine._internal() {
    _initializeStateMachine();
  }

  // Estado interno
  BootstrapPhase _currentPhase = BootstrapPhase.notStarted;
  final Map<BootstrapPhase, Completer<bool>> _phaseCompleters = {};
  final StreamController<BootstrapPhaseTransition> _transitionController = 
      StreamController<BootstrapPhaseTransition>.broadcast();
  
  // Controle de concorrência
  final Map<BootstrapPhase, bool> _phaseExecuting = {};
  bool _machineRunning = false;

  /// Stream de transições de fase
  Stream<BootstrapPhaseTransition> get transitions => 
      _transitionController.stream;
  
  /// Fase atual
  BootstrapPhase get currentPhase => _currentPhase;
  
  /// Verifica se uma fase está sendo executada
  bool isPhaseExecuting(BootstrapPhase phase) => 
      _phaseExecuting[phase] ?? false;
  
  /// Verifica se máquina está rodando
  bool get isRunning => _machineRunning;

  /// Inicializa state machine
  void _initializeStateMachine() {
    // Cria completers para cada fase
    for (final phase in BootstrapPhase.values) {
      if (phase != BootstrapPhase.rollback && phase != BootstrapPhase.notStarted) {
        _phaseCompleters[phase] = Completer<bool>();
        _phaseExecuting[phase] = false;
      }
    }
    
    debugPrint('🔧 BootstrapStateMachine: Inicializada com ${_phaseCompleters.length} fases');
  }

  /// Transita para uma nova fase de forma atômica
  Future<bool> transitionToPhase(
    BootstrapPhase targetPhase,
    Future<void> Function() phaseExecutor, {
    Duration? timeout,
  }) async {
    if (_machineRunning && _phaseExecuting[targetPhase] == true) {
      debugPrint('⚠️ BootstrapStateMachine: Fase $targetPhase já em execução');
      return await _phaseCompleters[targetPhase]?.future ?? false;
    }
    
    // Marca fase como executando
    _phaseExecuting[targetPhase] = true;
    _machineRunning = true;
    
    try {
      // Emite transição iniciada
      _emitTransition(BootstrapPhaseTransition(
        from: _currentPhase,
        to: targetPhase,
        status: TransitionStatus.started,
        timestamp: DateTime.now(),
      ));
      
      // Atualiza estado atual
      _currentPhase = targetPhase;
      
      // Executa fase com timeout opcional
      if (timeout != null) {
        await Future.any([
          phaseExecutor(),
          Future.delayed(timeout).then((_) => throw TimeoutException(
            'Timeout na execução da fase $targetPhase',
            timeout,
          )),
        ]);
      } else {
        await phaseExecutor();
      }
      
      // Marca como concluída
      if (!_phaseCompleters[targetPhase]!.isCompleted) {
        _phaseCompleters[targetPhase]!.complete(true);
      }
      
      // Emite transição concluída
      _emitTransition(BootstrapPhaseTransition(
        from: _currentPhase,
        to: targetPhase,
        status: TransitionStatus.completed,
        timestamp: DateTime.now(),
      ));
      
      debugPrint('✅ BootstrapStateMachine: Transição para $targetPhase concluída');
      return true;
      
    } catch (e, stackTrace) {
      // Marca como falhada
      if (!_phaseCompleters[targetPhase]!.isCompleted) {
        _phaseCompleters[targetPhase]!.complete(false);
      }
      
      // Emite transição falhada
      _emitTransition(BootstrapPhaseTransition(
        from: _currentPhase,
        to: targetPhase,
        status: TransitionStatus.failed,
        timestamp: DateTime.now(),
        error: e,
      ));
      
      debugPrint('❌ BootstrapStateMachine: Falha na transição para $targetPhase: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      
      return false;
    } finally {
      _phaseExecuting[targetPhase] = false;
    }
  }

  /// Aguarda uma fase ser concluída
  Future<bool> waitForPhase(BootstrapPhase phase, {Duration? timeout}) async {
    if (_phaseCompleters[phase]?.isCompleted == true) {
      return await _phaseCompleters[phase]!.future;
    }
    
    final future = _phaseCompleters[phase]?.future ?? Future.value(false);
    
    if (timeout != null) {
      try {
        return await Future.any([
          future,
          Future.delayed(timeout).then((_) => false),
        ]);
      } catch (e) {
        return false;
      }
    }
    
    return await future;
  }

  /// Reseta state machine
  Future<void> reset() async {
    debugPrint('🔄 BootstrapStateMachine: Resetando...');
    
    _machineRunning = false;
    _currentPhase = BootstrapPhase.notStarted;
    
    // Cancela completers pendentes
    for (final completer in _phaseCompleters.values) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
    
    // Limpa mapas
    _phaseCompleters.clear();
    _phaseExecuting.clear();
    
    // Reinicializa
    _initializeStateMachine();
    
    debugPrint('✅ BootstrapStateMachine: Reset concluído');
  }

  /// Emite transição no stream
  void _emitTransition(BootstrapPhaseTransition transition) {
    if (!_transitionController.isClosed) {
      _transitionController.add(transition);
    }
  }

  /// Obtém status de todas as fases
  Map<BootstrapPhase, PhaseStatus> getAllPhaseStatuses() {
    final statuses = <BootstrapPhase, PhaseStatus>{};
    
    for (final phase in BootstrapPhase.values) {
      if (phase == BootstrapPhase.notStarted || phase == BootstrapPhase.rollback) {
        continue;
      }
      
      final completer = _phaseCompleters[phase];
      final executing = _phaseExecuting[phase] ?? false;
      
      if (executing) {
        statuses[phase] = PhaseStatus.executing;
      } else if (completer?.isCompleted == true) {
        // Precisa verificar o resultado
        completer!.future.then((success) {
          statuses[phase] = success ? PhaseStatus.completed : PhaseStatus.failed;
        });
        statuses[phase] = PhaseStatus.completed; // Assume sucesso por padrão
      } else {
        statuses[phase] = PhaseStatus.pending;
      }
    }
    
    return statuses;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await reset();
    await _transitionController.close();
    _instance = null;
  }

  /// Reset static instance
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }
}

/// Transição de fase
class BootstrapPhaseTransition {
  final BootstrapPhase from;
  final BootstrapPhase to;
  final TransitionStatus status;
  final DateTime timestamp;
  final Object? error;

  BootstrapPhaseTransition({
    required this.from,
    required this.to,
    required this.status,
    required this.timestamp,
    this.error,
  });
  
  @override
  String toString() => 
      'Transition: $from -> $to ($status) at ${timestamp.toIso8601String()}';
}

/// Status da transição
enum TransitionStatus {
  started('Iniciada'),
  completed('Concluída'),
  failed('Falhada');

  const TransitionStatus(this.displayName);
  final String displayName;
}

/// Status da fase
enum PhaseStatus {
  pending('Pendente'),
  executing('Executando'),
  completed('Concluída'),
  failed('Falhada');

  const PhaseStatus(this.displayName);
  final String displayName;
}

/// Exception para timeout
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (${timeout.inSeconds}s)';
}