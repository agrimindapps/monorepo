// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/services/logging_service.dart';
import 'bootstrap_phase.dart';

/// Registro de ações de limpeza para rollback real
/// Gerencia cleanup de recursos em ordem reversa à inicialização
class CleanupRegistry {
  static CleanupRegistry? _instance;
  static CleanupRegistry get instance => _instance ??= CleanupRegistry._();
  
  CleanupRegistry._();

  // Registro de ações de limpeza por fase
  final Map<BootstrapPhase, List<CleanupAction>> _cleanupActions = {};
  
  // Registro de recursos ativos
  final Map<String, dynamic> _activeResources = {};
  
  // Controle de estado
  bool _isCleaningUp = false;
  BootstrapPhase? _lastSuccessfulPhase;

  /// Registra uma ação de limpeza para uma fase específica
  /// 
  /// [phase] - Fase de inicialização associada
  /// [action] - Ação de limpeza a ser executada
  /// [description] - Descrição da ação para logs
  /// [priority] - Prioridade (maior = executa primeiro no rollback)
  void registerCleanup({
    required BootstrapPhase phase,
    required Future<void> Function() action,
    required String description,
    int priority = 0,
  }) {
    final cleanupAction = CleanupAction(
      action: action,
      description: description,
      priority: priority,
      phase: phase,
      registeredAt: DateTime.now(),
    );

    _cleanupActions.putIfAbsent(phase, () => []).add(cleanupAction);
    
    // Ordena por prioridade (maior primeiro)
    _cleanupActions[phase]!.sort((a, b) => b.priority.compareTo(a.priority));

    LoggingService.debug(
      'Cleanup registrado para ${phase.name}: $description (prioridade: $priority)',
      tag: 'CleanupRegistry'
    );
  }

  /// Registra um recurso ativo que precisa ser rastreado
  /// 
  /// [key] - Chave única para identificar o recurso
  /// [resource] - Recurso a ser rastreado
  /// [phase] - Fase em que foi criado
  void registerResource({
    required String key,
    required dynamic resource,
    required BootstrapPhase phase,
  }) {
    _activeResources[key] = ResourceInfo(
      resource: resource,
      phase: phase,
      createdAt: DateTime.now(),
    );

    LoggingService.debug(
      'Recurso registrado: $key na fase ${phase.name}',
      tag: 'CleanupRegistry'
    );
  }

  /// Remove um recurso do registro (quando limpo manualmente)
  /// 
  /// [key] - Chave do recurso
  void unregisterResource(String key) {
    if (_activeResources.remove(key) != null) {
      LoggingService.debug(
        'Recurso removido do registro: $key',
        tag: 'CleanupRegistry'
      );
    }
  }

  /// Obtém recurso registrado
  /// 
  /// [key] - Chave do recurso
  T? getResource<T>(String key) {
    final info = _activeResources[key] as ResourceInfo?;
    return info?.resource as T?;
  }

  /// Executa rollback completo até uma fase específica
  /// 
  /// [fromPhase] - Fase a partir da qual fazer rollback (inclusive)
  /// [force] - Se deve forçar limpeza mesmo com erros
  Future<RollbackResult> performRollback({
    BootstrapPhase? fromPhase,
    bool force = false,
  }) async {
    if (_isCleaningUp) {
      LoggingService.warning('Rollback já em andamento', tag: 'CleanupRegistry');
      return RollbackResult.alreadyInProgress();
    }

    _isCleaningUp = true;
    final startTime = DateTime.now();
    final result = RollbackResult();

    try {
      LoggingService.info(
        'Iniciando rollback${fromPhase != null ? ' a partir de ${fromPhase.name}' : ' completo'}',
        tag: 'CleanupRegistry'
      );

      // Determina fases para limpeza
      final phasesToClean = _getPhasesToClean(fromPhase);
      
      // Executa limpeza em ordem reversa
      for (final phase in phasesToClean) {
        final phaseResult = await _cleanupPhase(phase, force);
        result.phaseResults[phase] = phaseResult;
        
        if (!phaseResult.success && !force) {
          LoggingService.error(
            'Rollback falhou na fase ${phase.name}. Parando.',
            tag: 'CleanupRegistry'
          );
          break;
        }
      }

      // Limpeza final de recursos órfãos
      await _cleanupOrphanedResources(force);

      // Limpeza do GetX
      await _cleanupGetX();

      result.success = result.phaseResults.values.every((r) => r.success) || force;
      result.duration = DateTime.now().difference(startTime);

      LoggingService.info(
        'Rollback ${result.success ? 'concluído' : 'falhou'} em ${result.duration.inMilliseconds}ms',
        tag: 'CleanupRegistry'
      );

      return result;

    } catch (e, stackTrace) {
      result.success = false;
      result.error = e.toString();
      result.duration = DateTime.now().difference(startTime);

      LoggingService.error(
        'Erro durante rollback',
        tag: 'CleanupRegistry',
        error: e,
        stackTrace: stackTrace
      );

      return result;

    } finally {
      _isCleaningUp = false;
      
      // Limpa registro de ações (começar do zero na próxima inicialização)
      _cleanupActions.clear();
      _activeResources.clear();
      _lastSuccessfulPhase = null;
    }
  }

  /// Marca uma fase como concluída com sucesso
  /// 
  /// [phase] - Fase concluída
  void markPhaseCompleted(BootstrapPhase phase) {
    _lastSuccessfulPhase = phase;
    LoggingService.debug('Fase marcada como concluída: ${phase.name}', tag: 'CleanupRegistry');
  }

  /// Obtém estatísticas do registro
  Map<String, dynamic> getStats() {
    final totalActions = _cleanupActions.values.fold<int>(0, (sum, list) => sum + list.length);
    
    return {
      'isCleaningUp': _isCleaningUp,
      'totalCleanupActions': totalActions,
      'activeResources': _activeResources.length,
      'lastSuccessfulPhase': _lastSuccessfulPhase?.name,
      'phasesCovered': _cleanupActions.keys.map((p) => p.name).toList(),
    };
  }

  /// Obtém relatório detalhado
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('🧹 RELATÓRIO DE CLEANUP REGISTRY');
    buffer.writeln('═══════════════════════════════════════');
    
    // Status geral
    buffer.writeln('Status: ${_isCleaningUp ? "Em limpeza" : "Inativo"}');
    buffer.writeln('Última fase bem-sucedida: ${_lastSuccessfulPhase?.name ?? "Nenhuma"}');
    buffer.writeln('Recursos ativos: ${_activeResources.length}');
    buffer.writeln('');

    // Ações por fase
    buffer.writeln('📋 AÇÕES DE LIMPEZA REGISTRADAS:');
    if (_cleanupActions.isEmpty) {
      buffer.writeln('Nenhuma ação registrada');
    } else {
      for (final entry in _cleanupActions.entries) {
        buffer.writeln('${entry.key.name}: ${entry.value.length} ações');
        for (final action in entry.value) {
          buffer.writeln('  • ${action.description} (prioridade: ${action.priority})');
        }
      }
    }
    buffer.writeln('');

    // Recursos ativos
    buffer.writeln('🔧 RECURSOS ATIVOS:');
    if (_activeResources.isEmpty) {
      buffer.writeln('Nenhum recurso ativo');
    } else {
      for (final entry in _activeResources.entries) {
        final info = entry.value as ResourceInfo;
        buffer.writeln('${entry.key}: ${info.resource.runtimeType} (fase: ${info.phase.name})');
      }
    }

    return buffer.toString();
  }

  // Métodos privados

  /// Determina quais fases devem ser limpas
  List<BootstrapPhase> _getPhasesToClean(BootstrapPhase? fromPhase) {
    final allPhases = BootstrapPhase.values.where((p) => 
        p != BootstrapPhase.notStarted && 
        p != BootstrapPhase.rollback &&
        p != BootstrapPhase.completed
    ).toList();

    if (fromPhase == null) {
      // Rollback completo - todas as fases em ordem reversa
      return allPhases.reversed.toList();
    }

    // Rollback a partir de uma fase específica
    final fromIndex = allPhases.indexOf(fromPhase);
    if (fromIndex == -1) return [];

    return allPhases.sublist(0, fromIndex + 1).reversed.toList();
  }

  /// Limpa uma fase específica
  Future<PhaseCleanupResult> _cleanupPhase(BootstrapPhase phase, bool force) async {
    final result = PhaseCleanupResult(phase: phase);
    final actions = _cleanupActions[phase] ?? [];

    if (actions.isEmpty) {
      result.success = true;
      return result;
    }

    LoggingService.debug('Limpando fase ${phase.name} (${actions.length} ações)', tag: 'CleanupRegistry');

    for (final action in actions) {
      try {
        await action.action();
        result.successfulActions++;
        
        LoggingService.debug(
          'Ação de limpeza executada: ${action.description}',
          tag: 'CleanupRegistry'
        );

      } catch (e, stackTrace) {
        result.failedActions++;
        result.errors.add('${action.description}: $e');
        
        LoggingService.error(
          'Erro na ação de limpeza: ${action.description}',
          tag: 'CleanupRegistry',
          error: e,
          stackTrace: stackTrace
        );

        if (!force) {
          result.success = false;
          break;
        }
      }
    }

    result.success = result.success && (result.failedActions == 0 || force);
    return result;
  }

  /// Limpa recursos órfãos (sem ação de limpeza específica)
  Future<void> _cleanupOrphanedResources(bool force) async {
    if (_activeResources.isEmpty) return;

    LoggingService.debug(
      'Limpando ${_activeResources.length} recursos órfãos',
      tag: 'CleanupRegistry'
    );

    final resourcesCopy = Map<String, dynamic>.from(_activeResources);
    
    for (final entry in resourcesCopy.entries) {
      try {
        final info = entry.value as ResourceInfo;
        await _disposeResource(entry.key, info.resource);
      } catch (e) {
        LoggingService.warning(
          'Erro ao limpar recurso órfão ${entry.key}: $e',
          tag: 'CleanupRegistry'
        );
        
        if (!force) rethrow;
      }
    }
  }

  /// Tenta descartar um recurso automaticamente
  Future<void> _disposeResource(String key, dynamic resource) async {
    if (resource == null) return;

    // Tenta diferentes padrões de dispose
    try {
      if (resource is StreamSubscription) {
        await resource.cancel();
      } else if (resource is Timer) {
        resource.cancel();
      } else if (resource.toString().contains('HttpClient')) {
        // HTTP clients geralmente têm close()
        await resource.close?.call();
      } else if (resource.toString().contains('Database')) {
        // Bancos de dados geralmente têm close()
        await resource.close?.call();
      } else {
        // Tenta método dispose genérico
        await resource.dispose?.call();
      }

      LoggingService.debug('Recurso automaticamente limpo: $key', tag: 'CleanupRegistry');
    } catch (e) {
      LoggingService.debug('Recurso $key não pôde ser limpo automaticamente: $e', tag: 'CleanupRegistry');
    }
  }

  /// Limpa registros do GetX
  Future<void> _cleanupGetX() async {
    try {
      // Limpa dependências não permanentes
      Get.reset();
      
      LoggingService.debug('GetX limpo (dependências não permanentes)', tag: 'CleanupRegistry');
    } catch (e) {
      LoggingService.warning('Erro ao limpar GetX: $e', tag: 'CleanupRegistry');
    }
  }

  /// Limpa instância (para testes)
  static void resetInstance() {
    _instance?._cleanupActions.clear();
    _instance?._activeResources.clear();
    _instance = null;
  }
}

/// Ação de limpeza registrada
class CleanupAction {
  final Future<void> Function() action;
  final String description;
  final int priority;
  final BootstrapPhase phase;
  final DateTime registeredAt;

  const CleanupAction({
    required this.action,
    required this.description,
    required this.priority,
    required this.phase,
    required this.registeredAt,
  });
}

/// Informações de um recurso registrado
class ResourceInfo {
  final dynamic resource;
  final BootstrapPhase phase;
  final DateTime createdAt;

  const ResourceInfo({
    required this.resource,
    required this.phase,
    required this.createdAt,
  });
}

/// Resultado de um rollback completo
class RollbackResult {
  bool success = true;
  String? error;
  Duration duration = Duration.zero;
  final Map<BootstrapPhase, PhaseCleanupResult> phaseResults = {};

  RollbackResult();

  RollbackResult.alreadyInProgress() {
    success = false;
    error = 'Rollback já em andamento';
  }

  @override
  String toString() {
    return 'RollbackResult(success: $success, duration: ${duration.inMilliseconds}ms, phases: ${phaseResults.length})';
  }
}

/// Resultado da limpeza de uma fase
class PhaseCleanupResult {
  final BootstrapPhase phase;
  bool success = true;
  int successfulActions = 0;
  int failedActions = 0;
  final List<String> errors = [];

  PhaseCleanupResult({required this.phase});

  int get totalActions => successfulActions + failedActions;
  double get successRate => totalActions > 0 ? successfulActions / totalActions : 1.0;

  @override
  String toString() {
    return 'PhaseCleanupResult(${phase.name}: $successfulActions/$totalActions actions, success: $success)';
  }
}