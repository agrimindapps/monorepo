// Dart imports:
import 'dart:async';

/// Interface para definir aspectos que podem interceptar operações de repository
///
/// Implementa Aspect-Oriented Programming (AOP) pattern permitindo separar
/// cross-cutting concerns (logging, validation, statistics, caching) das
/// responsabilidades core dos repositories.
///
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
/// Este sistema permite externalizar concerns como:
/// - Logging de operações e erros
/// - Validação de dados de entrada
/// - Coleta de estatísticas e métricas
/// - Cache management e invalidação
/// - Security checks e authorization
/// - Performance monitoring
abstract class RepositoryAspect {
  /// Nome único do aspecto
  String get name;

  /// Prioridade de execução (menor número = maior prioridade)
  int get priority => 100;

  /// Indica se o aspecto está habilitado
  bool get enabled => true;

  /// Executado ANTES da operação do repository
  ///
  /// [operationName] nome da operação (ex: 'create', 'findById', 'update')
  /// [parameters] parâmetros da operação
  /// [context] contexto adicional da operação
  ///
  /// Retorna AdviceResult que pode:
  /// - Continuar com a operação normal
  /// - Modificar parâmetros da operação
  /// - Interromper execução e retornar valor customizado
  /// - Adicionar contexto para próximos aspectos
  Future<AdviceResult> beforeOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required OperationContext context,
  }) async {
    return AdviceResult.proceed();
  }

  /// Executado APÓS operação bem-sucedida
  ///
  /// [operationName] nome da operação
  /// [parameters] parâmetros originais da operação
  /// [result] resultado da operação
  /// [context] contexto da operação
  ///
  /// Retorna AdviceResult que pode:
  /// - Retornar o resultado original
  /// - Modificar o resultado
  /// - Adicionar side effects (logs, cache, etc.)
  Future<AdviceResult> afterOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic result,
    required OperationContext context,
  }) async {
    return AdviceResult.proceed(result: result);
  }

  /// Executado quando operação lança exception
  ///
  /// [operationName] nome da operação
  /// [parameters] parâmetros da operação
  /// [exception] exception lançada
  /// [stackTrace] stack trace da exception
  /// [context] contexto da operação
  ///
  /// Retorna AdviceResult que pode:
  /// - Re-lançar a exception original
  /// - Modificar a exception
  /// - Converter exception em resultado válido
  /// - Executar recovery logic
  Future<AdviceResult> onException({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic exception,
    required StackTrace stackTrace,
    required OperationContext context,
  }) async {
    return AdviceResult.throwException(exception);
  }

  /// Executado SEMPRE, independente de sucesso ou erro
  /// Similar ao bloco finally
  ///
  /// Usado para cleanup, logging final, métricas, etc.
  Future<void> finallyOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    dynamic result,
    dynamic exception,
    required OperationContext context,
  }) async {
    // Implementação padrão vazia
  }
}

/// Resultado de um advice de aspecto
///
/// Controla o fluxo de execução após interceptação de um aspecto
class AdviceResult {
  /// Tipo de ação a ser tomada
  final AdviceAction action;

  /// Resultado customizado (se action for RETURN)
  final dynamic result;

  /// Exception customizada (se action for THROW)
  final dynamic exception;

  /// Parâmetros modificados (se action for MODIFY_PARAMS)
  final Map<String, dynamic>? modifiedParameters;

  /// Contexto adicional para próximos aspectos
  final Map<String, dynamic>? additionalContext;

  const AdviceResult._({
    required this.action,
    this.result,
    this.exception,
    this.modifiedParameters,
    this.additionalContext,
  });

  /// Continua com a execução normal
  factory AdviceResult.proceed({
    dynamic result,
    Map<String, dynamic>? additionalContext,
  }) {
    return AdviceResult._(
      action: AdviceAction.proceed,
      result: result,
      additionalContext: additionalContext,
    );
  }

  /// Retorna um valor customizado, interrompendo a cadeia
  factory AdviceResult.returnValue(
    dynamic result, {
    Map<String, dynamic>? additionalContext,
  }) {
    return AdviceResult._(
      action: AdviceAction.returnValue,
      result: result,
      additionalContext: additionalContext,
    );
  }

  /// Lança uma exception customizada
  factory AdviceResult.throwException(
    dynamic exception, {
    Map<String, dynamic>? additionalContext,
  }) {
    return AdviceResult._(
      action: AdviceAction.throwException,
      exception: exception,
      additionalContext: additionalContext,
    );
  }

  /// Modifica parâmetros da operação
  factory AdviceResult.modifyParameters(
    Map<String, dynamic> modifiedParameters, {
    Map<String, dynamic>? additionalContext,
  }) {
    return AdviceResult._(
      action: AdviceAction.modifyParameters,
      modifiedParameters: modifiedParameters,
      additionalContext: additionalContext,
    );
  }
}

/// Ações possíveis para um AdviceResult
enum AdviceAction {
  proceed, // Continua execução normal
  returnValue, // Retorna valor customizado
  throwException, // Lança exception customizada
  modifyParameters, // Modifica parâmetros da operação
}

/// Contexto de uma operação sendo interceptada
///
/// Carrega informações sobre a operação atual e permite
/// comunicação entre diferentes aspectos
class OperationContext {
  /// Nome do repository executando a operação
  final String repositoryName;

  /// Timestamp do início da operação
  final DateTime startTime;

  /// ID único da operação (para tracking)
  final String operationId;

  /// Contexto customizado compartilhado entre aspectos
  final Map<String, dynamic> context;

  /// Métricas da operação
  final Map<String, dynamic> metrics;

  OperationContext({
    required this.repositoryName,
    required this.operationId,
    DateTime? startTime,
    Map<String, dynamic>? context,
    Map<String, dynamic>? metrics,
  })  : startTime = startTime ?? DateTime.now(),
        context = context ?? {},
        metrics = metrics ?? {};

  /// Adiciona valor ao contexto
  void addContext(String key, dynamic value) {
    context[key] = value;
  }

  /// Obtém valor do contexto
  T? getContext<T>(String key) {
    return context[key] as T?;
  }

  /// Adiciona métrica
  void addMetric(String key, dynamic value) {
    metrics[key] = value;
  }

  /// Obtém métrica
  T? getMetric<T>(String key) {
    return metrics[key] as T?;
  }

  /// Duração da operação até agora
  Duration get elapsed => DateTime.now().difference(startTime);

  /// Cria cópia com contexto adicional
  OperationContext copyWith({
    Map<String, dynamic>? additionalContext,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return OperationContext(
      repositoryName: repositoryName,
      operationId: operationId,
      startTime: startTime,
      context: {
        ...context,
        if (additionalContext != null) ...additionalContext,
      },
      metrics: {
        ...metrics,
        if (additionalMetrics != null) ...additionalMetrics,
      },
    );
  }

  /// Converte para Map para debugging/logging
  Map<String, dynamic> toMap() {
    return {
      'repository_name': repositoryName,
      'operation_id': operationId,
      'start_time': startTime.toIso8601String(),
      'elapsed_ms': elapsed.inMilliseconds,
      'context': context,
      'metrics': metrics,
    };
  }
}

/// Mixin para repositories que suportam aspectos
///
/// Facilita a integração do sistema de AOP nos repositories existentes
mixin AspectAwareRepository {
  /// Lista de aspectos aplicados a este repository
  List<RepositoryAspect> get aspects => [];

  /// Nome do repository para contexto dos aspectos
  String get repositoryName;

  /// Executa operação com interceptação de aspectos
  Future<T> executeWithAspects<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, dynamic> parameters = const {},
    Map<String, dynamic> initialContext = const {},
  }) async {
    // Se não há aspectos, executa diretamente
    if (aspects.isEmpty) {
      return await operation();
    }

    final context = OperationContext(
      repositoryName: repositoryName,
      operationId: _generateOperationId(),
      context: Map<String, dynamic>.from(initialContext),
    );

    context.addMetric('aspects_count', aspects.length);

    // Ordenar aspectos por prioridade
    final sortedAspects = [...aspects]
      ..sort((a, b) => a.priority.compareTo(b.priority));

    // Filtrar apenas aspectos habilitados
    final enabledAspects =
        sortedAspects.where((aspect) => aspect.enabled).toList();

    Map<String, dynamic> currentParameters =
        Map<String, dynamic>.from(parameters);
    dynamic result;
    dynamic exception;

    try {
      // FASE 1: Before advice
      for (final aspect in enabledAspects) {
        try {
          final advice = await aspect.beforeOperation(
            operationName: operationName,
            parameters: currentParameters,
            context: context,
          );

          // Processar resultado do advice
          switch (advice.action) {
            case AdviceAction.proceed:
              // Adicionar contexto adicional se fornecido
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;

            case AdviceAction.returnValue:
              // Aspecto decidiu retornar valor sem executar operação
              await _executeFinally(enabledAspects, operationName,
                  currentParameters, context, advice.result, null);
              return advice.result;

            case AdviceAction.throwException:
              // Aspecto decidiu lançar exception sem executar operação
              await _executeFinally(enabledAspects, operationName,
                  currentParameters, context, null, advice.exception);
              throw advice.exception;

            case AdviceAction.modifyParameters:
              // Aspecto modificou parâmetros
              currentParameters.addAll(advice.modifiedParameters!);
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;
          }
        } catch (e) {
          // Se beforeAdvice falhar, continuar com outros aspectos
          context.addContext(
              'aspect_${aspect.name}_before_error', e.toString());
        }
      }

      // FASE 2: Executar operação principal
      context.addMetric('operation_start', DateTime.now().toIso8601String());
      result = await operation();
      context.addMetric(
          'operation_duration_ms', context.elapsed.inMilliseconds);

      // FASE 3: After advice
      for (final aspect in enabledAspects) {
        try {
          final advice = await aspect.afterOperation(
            operationName: operationName,
            parameters: currentParameters,
            result: result,
            context: context,
          );

          // Processar resultado do advice
          switch (advice.action) {
            case AdviceAction.proceed:
              // Manter resultado atual, adicionar contexto se fornecido
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;

            case AdviceAction.returnValue:
              // Aspecto modificou o resultado
              result = advice.result;
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;

            case AdviceAction.throwException:
              // Aspecto decidiu lançar exception mesmo com operação bem-sucedida
              await _executeFinally(enabledAspects, operationName,
                  currentParameters, context, result, advice.exception);
              throw advice.exception;

            case AdviceAction.modifyParameters:
              // Não faz sentido modificar parâmetros no after advice
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;
          }
        } catch (e) {
          // Se afterAdvice falhar, continuar com outros aspectos
          context.addContext('aspect_${aspect.name}_after_error', e.toString());
        }
      }
    } catch (e, stackTrace) {
      exception = e;
      context.addMetric('exception_type', e.runtimeType.toString());

      // FASE 4: Exception advice
      for (final aspect in enabledAspects) {
        try {
          final advice = await aspect.onException(
            operationName: operationName,
            parameters: currentParameters,
            exception: e,
            stackTrace: stackTrace,
            context: context,
          );

          // Processar resultado do advice
          switch (advice.action) {
            case AdviceAction.proceed:
            case AdviceAction.throwException:
              // Continuar com exception original ou lançar nova
              if (advice.exception != null) {
                exception = advice.exception;
              }
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;

            case AdviceAction.returnValue:
              // Aspecto converteu exception em resultado válido
              result = advice.result;
              exception = null; // Limpar exception
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;

            case AdviceAction.modifyParameters:
              // Não faz sentido no exception advice
              if (advice.additionalContext != null) {
                context.context.addAll(advice.additionalContext!);
              }
              break;
          }
        } catch (aspectException) {
          // Se exception advice falhar, continuar
          context.addContext('aspect_${aspect.name}_exception_error',
              aspectException.toString());
        }
      }

      // Se ainda há exception após advice, lançar
      if (exception != null) {
        await _executeFinally(enabledAspects, operationName, currentParameters,
            context, result, exception);
        throw exception;
      }
    } finally {
      // FASE 5: Finally advice (sempre executado)
      await _executeFinally(enabledAspects, operationName, currentParameters,
          context, result, exception);
    }

    return result;
  }

  /// Executa finally advice para todos os aspectos
  Future<void> _executeFinally(
    List<RepositoryAspect> aspects,
    String operationName,
    Map<String, dynamic> parameters,
    OperationContext context,
    dynamic result,
    dynamic exception,
  ) async {
    for (final aspect in aspects) {
      try {
        await aspect.finallyOperation(
          operationName: operationName,
          parameters: parameters,
          result: result,
          exception: exception,
          context: context,
        );
      } catch (e) {
        // Finally advice nunca deve falhar a operação principal
        context.addContext('aspect_${aspect.name}_finally_error', e.toString());
      }
    }
  }

  /// Gera ID único para operação
  String _generateOperationId() {
    return 'op_${DateTime.now().millisecondsSinceEpoch}_${repositoryName.hashCode.abs()}';
  }
}
