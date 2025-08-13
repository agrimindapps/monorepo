// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

import '../../core/services/logging_service.dart';
// Project imports:
import '../core/bootstrap/bootstrap_phase.dart';

/// Transaction Manager para bootstrap phases com undo operations
/// Implementa Command Pattern para operações reversíveis
class BootstrapTransactionManager {
  static BootstrapTransactionManager? _instance;
  static BootstrapTransactionManager get instance => _instance ??= BootstrapTransactionManager._();
  BootstrapTransactionManager._();
  
  // Stack de comandos executados (para undo)
  final List<TransactionCommand> _executedCommands = [];
  
  // Transações ativas por fase
  final Map<BootstrapPhase, BootstrapTransaction> _activeTransactions = {};
  
  // Estado de transação global
  bool _isInTransaction = false;
  BootstrapPhase? _currentPhase;
  
  /// Inicia uma nova transação para uma fase
  BootstrapTransaction beginTransaction(BootstrapPhase phase) {
    if (_activeTransactions.containsKey(phase)) {
      throw TransactionException('Transação já ativa para fase $phase');
    }
    
    final transaction = BootstrapTransaction(
      phase: phase,
      manager: this,
    );
    
    _activeTransactions[phase] = transaction;
    _isInTransaction = true;
    _currentPhase = phase;
    
    LoggingService.info(
      'Transação iniciada para fase ${phase.name}',
      tag: 'BootstrapTransactionManager',
    );
    
    return transaction;
  }
  
  /// Confirma transação (commit)
  Future<bool> commitTransaction(BootstrapPhase phase) async {
    final transaction = _activeTransactions[phase];
    if (transaction == null) {
      LoggingService.warning(
        'Tentativa de commit em transação inexistente para fase $phase',
        tag: 'BootstrapTransactionManager',
      );
      return false;
    }
    
    try {
      // Todos os comandos foram executados com sucesso
      // Marca comandos como committed (não podem mais ser desfeitos)
      transaction._markCommitted();
      
      _activeTransactions.remove(phase);
      
      LoggingService.info(
        'Transação confirmada (commit) para fase ${phase.name}',
        tag: 'BootstrapTransactionManager',
      );
      
      return true;
    } catch (e) {
      LoggingService.error(
        'Erro no commit da transação para fase $phase: $e',
        tag: 'BootstrapTransactionManager',
      );
      return false;
    }
  }
  
  /// Desfaz transação (rollback) e todas as operações
  Future<RollbackResult> rollbackTransaction(BootstrapPhase phase, {bool force = false}) async {
    final transaction = _activeTransactions[phase];
    if (transaction == null) {
      return RollbackResult.success(
        phase: phase,
        message: 'Nenhuma transação ativa para desfazer',
      );
    }
    
    final startTime = DateTime.now();
    final result = RollbackResult(phase: phase);
    
    try {
      LoggingService.info(
        'Iniciando rollback da transação para fase ${phase.name}',
        tag: 'BootstrapTransactionManager',
      );
      
      // Desfaz todos os comandos da transação em ordem reversa
      await transaction._performRollback(result, force: force);
      
      // Remove transação
      _activeTransactions.remove(phase);
      
      result.success = true;
      result.duration = DateTime.now().difference(startTime);
      
      LoggingService.info(
        'Rollback concluído para fase ${phase.name} em ${result.duration.inMilliseconds}ms',
        tag: 'BootstrapTransactionManager',
      );
      
      return result;
    } catch (e) {
      result.success = false;
      result.error = e.toString();
      result.duration = DateTime.now().difference(startTime);
      
      LoggingService.error(
        'Erro no rollback da transação para fase $phase: $e',
        tag: 'BootstrapTransactionManager',
      );
      
      return result;
    }
  }
  
  /// Rollback completo de todas as fases até um ponto específico
  Future<CompleteRollbackResult> rollbackToPhase(
    BootstrapPhase targetPhase, {
    bool force = false,
  }) async {
    final startTime = DateTime.now();
    final result = CompleteRollbackResult();
    
    // Determinar fases para rollback (ordem reversa)
    final phasesToRollback = _getPhasesForRollback(targetPhase);
    
    LoggingService.info(
      'Iniciando rollback completo até fase ${targetPhase.name}. '
      'Fases a desfazer: ${phasesToRollback.map((p) => p.name).join(', ')}',
      tag: 'BootstrapTransactionManager',
    );
    
    for (final phase in phasesToRollback) {
      final phaseResult = await rollbackTransaction(phase, force: force);
      result.phaseResults[phase] = phaseResult;
      
      if (!phaseResult.success && !force) {
        LoggingService.error(
          'Rollback falhou na fase ${phase.name}. Parando.',
          tag: 'BootstrapTransactionManager',
        );
        break;
      }
    }
    
    result.success = result.phaseResults.values.every((r) => r.success) || force;
    result.duration = DateTime.now().difference(startTime);
    
    LoggingService.info(
      'Rollback completo ${result.success ? 'concluído' : 'falhou'} '
      'em ${result.duration.inMilliseconds}ms',
      tag: 'BootstrapTransactionManager',
    );
    
    return result;
  }
  
  /// Obtém fases que precisam de rollback até o ponto alvo
  List<BootstrapPhase> _getPhasesForRollback(BootstrapPhase targetPhase) {
    final allPhases = [
      BootstrapPhase.routes,
      BootstrapPhase.uiServices,
      BootstrapPhase.controllers,
      BootstrapPhase.repositories,
      BootstrapPhase.coreDependencies,
      BootstrapPhase.configuration,
    ];
    
    final targetIndex = allPhases.indexOf(targetPhase);
    if (targetIndex == -1) return [];
    
    return allPhases.sublist(0, targetIndex + 1);
  }
  
  /// Registra comando executado globalmente
  void _registerExecutedCommand(TransactionCommand command) {
    _executedCommands.add(command);
  }
  
  /// Obtém estatísticas das transações
  Map<String, dynamic> getTransactionStats() {
    return {
      'isInTransaction': _isInTransaction,
      'currentPhase': _currentPhase?.name,
      'activeTransactions': _activeTransactions.length,
      'executedCommands': _executedCommands.length,
      'phases': _activeTransactions.keys.map((p) => p.name).toList(),
    };
  }
  
  /// Testa rollback de uma fase específica (modo dry-run)
  Future<RollbackTestResult> testRollback(BootstrapPhase phase) async {
    final transaction = _activeTransactions[phase];
    if (transaction == null) {
      return RollbackTestResult(
        phase: phase,
        canRollback: true,
        estimatedDuration: Duration.zero,
        commandsToUndo: 0,
        issues: [],
      );
    }
    
    final commands = transaction._getCommandsForRollback();
    final issues = <String>[];
    
    // Verifica cada comando para problemas potenciais
    for (final command in commands) {
      if (!command.canUndo) {
        issues.add('Comando "${command.description}" não pode ser desfeito');
      }
      
      if (command.undoOperation == null) {
        issues.add('Comando "${command.description}" não tem operação de undo');
      }
    }
    
    return RollbackTestResult(
      phase: phase,
      canRollback: issues.isEmpty,
      estimatedDuration: Duration(milliseconds: commands.length * 100), // Estimativa
      commandsToUndo: commands.length,
      issues: issues,
    );
  }
  
  /// Limpa estado (para testes ou reset completo)
  void reset() {
    _executedCommands.clear();
    _activeTransactions.clear();
    _isInTransaction = false;
    _currentPhase = null;
    
    LoggingService.info(
      'BootstrapTransactionManager resetado',
      tag: 'BootstrapTransactionManager',
    );
  }
}

/// Transação para uma fase específica de bootstrap
class BootstrapTransaction {
  final BootstrapPhase phase;
  final BootstrapTransactionManager manager;
  final List<TransactionCommand> _commands = [];
  bool _isCommitted = false;
  
  BootstrapTransaction({
    required this.phase,
    required this.manager,
  });
  
  /// Executa um comando dentro da transação
  Future<T> execute<T>(TransactionCommand<T> command) async {
    if (_isCommitted) {
      throw TransactionException('Transação já foi confirmada (committed)');
    }
    
    try {
      LoggingService.debug(
        'Executando comando: ${command.description}',
        tag: 'BootstrapTransaction',
      );
      
      final result = await command.execute();
      
      // Adiciona à lista de comandos executados
      _commands.add(command);
      manager._registerExecutedCommand(command);
      
      LoggingService.debug(
        'Comando executado com sucesso: ${command.description}',
        tag: 'BootstrapTransaction',
      );
      
      return result;
    } catch (e) {
      LoggingService.error(
        'Erro na execução do comando: ${command.description} - $e',
        tag: 'BootstrapTransaction',
      );
      rethrow;
    }
  }
  
  /// Marca transação como committed
  void _markCommitted() {
    _isCommitted = true;
    
    // Marca todos os comandos como committed
    for (final command in _commands) {
      command._markCommitted();
    }
  }
  
  /// Executa rollback de todos os comandos
  Future<void> _performRollback(RollbackResult result, {bool force = false}) async {
    final commandsToUndo = _getCommandsForRollback();
    
    for (final command in commandsToUndo) {
      try {
        if (command.canUndo && !command.isCommitted) {
          LoggingService.debug(
            'Desfazendo comando: ${command.description}',
            tag: 'BootstrapTransaction',
          );
          
          await command.undo();
          result.commandsUndone++;
          
          LoggingService.debug(
            'Comando desfeito com sucesso: ${command.description}',
            tag: 'BootstrapTransaction',
          );
        } else {
          result.commandsSkipped++;
          LoggingService.debug(
            'Comando pulado (${command.isCommitted ? 'committed' : 'não pode desfazer'}): ${command.description}',
            tag: 'BootstrapTransaction',
          );
        }
      } catch (e) {
        result.commandsFailed++;
        result.errors.add('Erro ao desfazer "${command.description}": $e');
        
        LoggingService.error(
          'Erro ao desfazer comando: ${command.description} - $e',
          tag: 'BootstrapTransaction',
        );
        
        if (!force) {
          throw TransactionException('Falha no rollback: $e');
        }
      }
    }
  }
  
  /// Obtém comandos em ordem reversa para rollback
  List<TransactionCommand> _getCommandsForRollback() {
    return _commands.reversed.toList();
  }
}

/// Comando abstrato com operação e desfazer
abstract class TransactionCommand<T> {
  final String description;
  final BootstrapPhase phase;
  bool _isCommitted = false;
  
  TransactionCommand({
    required this.description,
    required this.phase,
  });
  
  /// Executa a operação
  Future<T> execute();
  
  /// Operação de desfazer (undo)
  Future<void>? get undoOperation;
  
  /// Executa undo se disponível
  Future<void> undo() async {
    final undoOp = undoOperation;
    if (undoOp != null && canUndo) {
      await undoOp;
    }
  }
  
  /// Se o comando pode ser desfeito
  bool get canUndo => undoOperation != null && !_isCommitted;
  
  /// Se o comando foi committed
  bool get isCommitted => _isCommitted;
  
  /// Marca comando como committed (não pode mais ser desfeito)
  void _markCommitted() {
    _isCommitted = true;
  }
}

/// Comando específico para registrar dependência GetX
class RegisterDependencyCommand<T> extends TransactionCommand<T> {
  final String dependencyKey;
  final T Function() factory;
  final bool permanent;
  T? _registeredInstance;
  
  RegisterDependencyCommand({
    required this.dependencyKey,
    required this.factory,
    required super.phase,
    this.permanent = false,
  }) : super(
    description: 'Registrar dependência: $dependencyKey',
  );
  
  @override
  Future<T> execute() async {
    _registeredInstance = factory();
    // Registra no GetX com tag única
    if (_registeredInstance != null) {
      Get.put<T>(_registeredInstance as T, tag: dependencyKey, permanent: permanent);
    }
    return _registeredInstance!;
  }
  
  @override
  Future<void>? get undoOperation => _registeredInstance != null ? _undoOperation() : null;
  
  Future<void> _undoOperation() async {
    if (_registeredInstance != null) {
      // Remove do GetX
      if (Get.isRegistered<T>(tag: dependencyKey)) {
        Get.delete<T>(tag: dependencyKey, force: true);
      }
      
      // Tenta fazer dispose se suportado
      try {
        final dynamic instance = _registeredInstance;
        await instance.dispose?.call();
      } catch (e) {
        // Ignore se não suporta dispose
      }
      
      _registeredInstance = null;
    }
  }
}

/// Comando para inicializar serviço
class InitializeServiceCommand extends TransactionCommand<void> {
  final String serviceName;
  final Future<void> Function() initOperation;
  final Future<void> Function()? cleanupOperation;
  bool _wasInitialized = false;
  
  InitializeServiceCommand({
    required this.serviceName,
    required this.initOperation,
    required super.phase,
    this.cleanupOperation,
  }) : super(
    description: 'Inicializar serviço: $serviceName',
  );
  
  @override
  Future<void> execute() async {
    await initOperation();
    _wasInitialized = true;
  }
  
  @override
  Future<void>? get undoOperation => cleanupOperation != null && _wasInitialized
      ? _undoInitialization()
      : null;
      
  Future<void> _undoInitialization() async {
    if (cleanupOperation != null) {
      await cleanupOperation!();
      _wasInitialized = false;
    }
  }
}

/// Comando para registrar callback/listener
class RegisterCallbackCommand extends TransactionCommand<void> {
  final String callbackName;
  final void Function() registerCallback;
  final void Function() unregisterCallback;
  bool _isRegistered = false;
  
  RegisterCallbackCommand({
    required this.callbackName,
    required this.registerCallback,
    required this.unregisterCallback,
    required super.phase,
  }) : super(
    description: 'Registrar callback: $callbackName',
  );
  
  @override
  Future<void> execute() async {
    registerCallback();
    _isRegistered = true;
  }
  
  @override
  Future<void>? get undoOperation => _isRegistered ? _undoCallback() : null;
      
  Future<void> _undoCallback() async {
    unregisterCallback();
    _isRegistered = false;
  }
}

/// Resultado de rollback de uma fase
class RollbackResult {
  final BootstrapPhase phase;
  bool success = false;
  String? error;
  Duration duration = Duration.zero;
  int commandsUndone = 0;
  int commandsSkipped = 0;
  int commandsFailed = 0;
  List<String> errors = [];
  
  RollbackResult({required this.phase});
  
  RollbackResult.success({
    required this.phase, 
    required String message
  }) {
    success = true;
    errors = [message];
  }
  
  int get totalCommands => commandsUndone + commandsSkipped + commandsFailed;
}

/// Resultado de rollback completo
class CompleteRollbackResult {
  bool success = false;
  Duration duration = Duration.zero;
  Map<BootstrapPhase, RollbackResult> phaseResults = {};
  
  int get totalCommandsUndone => phaseResults.values.fold(0, (sum, r) => sum + r.commandsUndone);
  int get totalCommandsFailed => phaseResults.values.fold(0, (sum, r) => sum + r.commandsFailed);
}

/// Resultado de teste de rollback
class RollbackTestResult {
  final BootstrapPhase phase;
  final bool canRollback;
  final Duration estimatedDuration;
  final int commandsToUndo;
  final List<String> issues;
  
  RollbackTestResult({
    required this.phase,
    required this.canRollback,
    required this.estimatedDuration,
    required this.commandsToUndo,
    required this.issues,
  });
}

/// Exceção de transação
class TransactionException implements Exception {
  final String message;
  TransactionException(this.message);
  
  @override
  String toString() => 'TransactionException: $message';
}