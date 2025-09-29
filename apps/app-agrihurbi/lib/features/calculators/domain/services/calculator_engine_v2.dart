import 'package:injectable/injectable.dart';

import '../entities/calculation_result.dart';
import '../interfaces/calculator_strategy.dart';
import '../registry/calculator_strategy_registry.dart';
import 'calculator_execution_service.dart';
import 'calculator_formatting_service.dart';
import 'calculator_validation_service.dart';

/// Calculator Engine moderno v2.0
/// 
/// Implementa arquitetura SOLID usando composição de services especializados.
/// Substitui o engine monolítico anterior, seguindo Single Responsibility Principle.
@injectable
class CalculatorEngineV2 {
  final CalculatorStrategyRegistry _strategyRegistry;
  final CalculatorValidationService _validationService;
  final CalculatorExecutionService _executionService;
  final CalculatorFormattingService _formattingService;

  CalculatorEngineV2(
    this._strategyRegistry,
    this._validationService,
    this._executionService,
    this._formattingService,
  );

  /// Executa cálculo completo com estratégia específica
  Future<CompleteCalculationResult> calculateComplete({
    required String strategyId,
    required Map<String, dynamic> inputs,
    CalculationOptions? options,
  }) async {
    final opts = options ?? const CalculationOptions();
    final startTime = DateTime.now();

    try {
      // 1. Obter estratégia
      final strategy = _strategyRegistry.getStrategy(strategyId);
      if (strategy == null) {
        return CompleteCalculationResult.error(
          EngineError(
            type: EngineErrorType.strategyNotFound,
            message: 'Estratégia não encontrada: $strategyId',
            strategyId: strategyId,
            phase: CalculationPhase.initialization,
          ),
        );
      }

      // 2. Validação (se habilitada)
      ValidationResult? validationResult;
      if (opts.performValidation) {
        validationResult = await _validationService.validateWithStrategy(strategy, inputs);
        if (!validationResult.isValid && !opts.allowInvalidInputs) {
          return CompleteCalculationResult.error(
            EngineError(
              type: EngineErrorType.validationFailed,
              message: 'Validação falhou: ${validationResult.errors.join(', ')}',
              strategyId: strategyId,
              phase: CalculationPhase.validation,
              validationErrors: validationResult.errors,
            ),
          );
        }
      }

      // 3. Execução do cálculo
      final executionResult = await _executionService.executeWithStrategy(
        strategyId,
        validationResult?.sanitizedInputs ?? inputs,
        skipValidation: !opts.performValidation,
      );

      if (!executionResult.isSuccess) {
        return CompleteCalculationResult.error(
          EngineError(
            type: EngineErrorType.executionFailed,
            message: 'Execução falhou: ${executionResult.error?.message ?? 'Erro desconhecido'}',
            strategyId: strategyId,
            phase: CalculationPhase.execution,
            executionError: executionResult.error,
          ),
        );
      }

      // 4. Formatação dos resultados (se habilitada)
      FormattedCalculationResult? formattedResult;
      if (opts.formatResults) {
        formattedResult = await _formattingService.formatResult(
          executionResult.success!.result,
          strategy,
          options: opts.formattingOptions,
        );
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      return CompleteCalculationResult.success(
        CompleteCalculationSuccess(
          strategyId: strategyId,
          strategy: strategy,
          rawResult: executionResult.success!.result,
          formattedResult: formattedResult,
          validationResult: validationResult,
          executionTime: duration,
          metadata: CalculationMetadata(
            startTime: startTime,
            endTime: endTime,
            inputsUsed: validationResult?.sanitizedInputs ?? inputs,
            optionsUsed: opts,
          ),
        ),
      );

    } catch (e) {
      return CompleteCalculationResult.error(
        EngineError(
          type: EngineErrorType.unexpectedError,
          message: 'Erro inesperado: ${e.toString()}',
          strategyId: strategyId,
          phase: CalculationPhase.unknown,
          exception: e,
        ),
      );
    }
  }

  /// Executa cálculo com auto-seleção de estratégia
  Future<CompleteCalculationResult> calculateAuto({
    required Map<String, dynamic> inputs,
    String? preferredStrategyType,
    CalculationOptions? options,
  }) async {
    // Buscar estratégia compatível
    final compatibleStrategy = _findBestStrategy(inputs, preferredStrategyType);
    
    if (compatibleStrategy == null) {
      return CompleteCalculationResult.error(
        const EngineError(
          type: EngineErrorType.noCompatibleStrategy,
          message: 'Nenhuma estratégia compatível encontrada para os inputs fornecidos',
          phase: CalculationPhase.initialization,
        ),
      );
    }

    // Executar com a estratégia encontrada
    return await calculateComplete(
      strategyId: compatibleStrategy.strategyId,
      inputs: inputs,
      options: options,
    );
  }

  /// Executa múltiplos cálculos em batch
  Future<BatchCalculationResult> calculateBatch({
    required List<BatchCalculationRequest> requests,
    BatchOptions? options,
  }) async {
    final opts = options ?? const BatchOptions();
    final results = <String, CompleteCalculationResult>{};
    final startTime = DateTime.now();

    for (final request in requests) {
      try {
        final result = await calculateComplete(
          strategyId: request.strategyId,
          inputs: request.inputs,
          options: request.options,
        );
        
        results[request.id] = result;

        // Parar em caso de erro se configurado
        if (!result.isSuccess && opts.stopOnFirstError) {
          break;
        }
      } catch (e) {
        results[request.id] = CompleteCalculationResult.error(
          EngineError(
            type: EngineErrorType.batchItemFailed,
            message: 'Erro no item ${request.id}: ${e.toString()}',
            strategyId: request.strategyId,
            phase: CalculationPhase.execution,
            exception: e,
          ),
        );

        if (opts.stopOnFirstError) {
          break;
        }
      }
    }

    final endTime = DateTime.now();
    final successCount = results.values.where((r) => r.isSuccess).length;

    return BatchCalculationResult(
      totalRequests: requests.length,
      processedRequests: results.length,
      successCount: successCount,
      errorCount: results.length - successCount,
      results: results,
      executionTime: endTime.difference(startTime),
      metadata: BatchMetadata(
        startTime: startTime,
        endTime: endTime,
        options: opts,
      ),
    );
  }

  /// Valida inputs para uma estratégia específica
  Future<CalculationCompatibilityResult> validateForStrategy({
    required String strategyId,
    required Map<String, dynamic> inputs,
  }) async {
    final strategy = _strategyRegistry.getStrategy(strategyId);
    
    if (strategy == null) {
      return CalculationCompatibilityResult(
        isCompatible: false,
        strategyId: strategyId,
        errors: ['Estratégia não encontrada'],
      );
    }

    final canProcess = strategy.canProcess(inputs);
    if (!canProcess) {
      return CalculationCompatibilityResult(
        isCompatible: false,
        strategyId: strategyId,
        errors: ['Estratégia não pode processar os inputs fornecidos'],
      );
    }

    final validationResult = await _validationService.validateWithStrategy(strategy, inputs);
    
    return CalculationCompatibilityResult(
      isCompatible: validationResult.isValid,
      strategyId: strategyId,
      errors: validationResult.isValid ? [] : validationResult.errors,
      warnings: validationResult.warnings,
      strategy: strategy,
    );
  }

  /// Lista estratégias disponíveis
  List<StrategyInfo> getAvailableStrategies() {
    return _executionService.getAvailableStrategies();
  }

  /// Obtém estatísticas do engine
  EngineStatistics getStatistics() {
    final registryStats = _strategyRegistry.getStatistics();
    
    return EngineStatistics(
      totalStrategiesAvailable: registryStats.totalStrategies,
      registryInitialized: registryStats.isInitialized,
      serviceComponents: {
        'validation': _validationService.runtimeType.toString(),
        'execution': _executionService.runtimeType.toString(),
        'formatting': _formattingService.runtimeType.toString(),
        'registry': _strategyRegistry.runtimeType.toString(),
      },
    );
  }

  /// Verifica saúde do engine
  Future<EngineHealthCheck> performHealthCheck() async {
    final issues = <String>[];
    final warnings = <String>[];

    // Verificar registry
    final registryValidation = _strategyRegistry.validateRegistry();
    if (!registryValidation.isValid) {
      issues.addAll(registryValidation.errors);
    }
    warnings.addAll(registryValidation.warnings);

    // Verificar disponibilidade de estratégias
    final strategies = _strategyRegistry.getAllStrategies();
    if (strategies.isEmpty) {
      issues.add('Nenhuma estratégia registrada');
    }

    // Teste básico de cada componente
    try {
      _validationService.validateRequiredInputs([], {});
      _executionService.getAvailableStrategies();
      _formattingService.formatValue(100.0);
    } catch (e) {
      issues.add('Erro nos services: ${e.toString()}');
    }

    return EngineHealthCheck(
      isHealthy: issues.isEmpty,
      issues: issues,
      warnings: warnings,
      timestamp: DateTime.now(),
      statistics: getStatistics(),
    );
  }

  // ============= MÉTODOS PRIVADOS =============

  ICalculatorStrategy? _findBestStrategy(
    Map<String, dynamic> inputs,
    String? preferredType,
  ) {
    final allStrategies = _strategyRegistry.getAllStrategies();
    
    // Primeiro, tentar estratégias do tipo preferido
    if (preferredType != null) {
      final preferredStrategies = allStrategies
          .where((s) => s.runtimeType.toString().toLowerCase().contains(preferredType.toLowerCase()))
          .toList();
      
      for (final strategy in preferredStrategies) {
        if (strategy.canProcess(inputs)) {
          return strategy;
        }
      }
    }
    
    // Se não encontrou no tipo preferido, buscar em todas
    for (final strategy in allStrategies) {
      if (strategy.canProcess(inputs)) {
        return strategy;
      }
    }
    
    return null;
  }
}

// ============= CONFIGURATION CLASSES =============

class CalculationOptions {
  final bool performValidation;
  final bool allowInvalidInputs;
  final bool formatResults;
  final FormattingOptions? formattingOptions;

  const CalculationOptions({
    this.performValidation = true,
    this.allowInvalidInputs = false,
    this.formatResults = true,
    this.formattingOptions,
  });
}

class BatchOptions {
  final bool stopOnFirstError;
  final int? maxConcurrentCalculations;
  final Duration? timeout;

  const BatchOptions({
    this.stopOnFirstError = false,
    this.maxConcurrentCalculations,
    this.timeout,
  });
}

// ============= RESULT CLASSES =============

class CompleteCalculationResult {
  final bool isSuccess;
  final CompleteCalculationSuccess? success;
  final EngineError? error;

  const CompleteCalculationResult._({
    required this.isSuccess,
    this.success,
    this.error,
  });

  factory CompleteCalculationResult.success(CompleteCalculationSuccess success) {
    return CompleteCalculationResult._(isSuccess: true, success: success);
  }

  factory CompleteCalculationResult.error(EngineError error) {
    return CompleteCalculationResult._(isSuccess: false, error: error);
  }
}

class CompleteCalculationSuccess {
  final String strategyId;
  final ICalculatorStrategy strategy;
  final CalculationResult rawResult;
  final FormattedCalculationResult? formattedResult;
  final ValidationResult? validationResult;
  final Duration executionTime;
  final CalculationMetadata metadata;

  const CompleteCalculationSuccess({
    required this.strategyId,
    required this.strategy,
    required this.rawResult,
    this.formattedResult,
    this.validationResult,
    required this.executionTime,
    required this.metadata,
  });
}

class EngineError {
  final EngineErrorType type;
  final String message;
  final String? strategyId;
  final CalculationPhase phase;
  final List<String>? validationErrors;
  final ExecutionError? executionError;
  final Object? exception;

  const EngineError({
    required this.type,
    required this.message,
    this.strategyId,
    required this.phase,
    this.validationErrors,
    this.executionError,
    this.exception,
  });
}

class CalculationMetadata {
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic> inputsUsed;
  final CalculationOptions optionsUsed;

  const CalculationMetadata({
    required this.startTime,
    required this.endTime,
    required this.inputsUsed,
    required this.optionsUsed,
  });
}

class BatchCalculationRequest {
  final String id;
  final String strategyId;
  final Map<String, dynamic> inputs;
  final CalculationOptions? options;

  const BatchCalculationRequest({
    required this.id,
    required this.strategyId,
    required this.inputs,
    this.options,
  });
}

class BatchCalculationResult {
  final int totalRequests;
  final int processedRequests;
  final int successCount;
  final int errorCount;
  final Map<String, CompleteCalculationResult> results;
  final Duration executionTime;
  final BatchMetadata metadata;

  const BatchCalculationResult({
    required this.totalRequests,
    required this.processedRequests,
    required this.successCount,
    required this.errorCount,
    required this.results,
    required this.executionTime,
    required this.metadata,
  });

  double get successRate => processedRequests > 0 ? successCount / processedRequests : 0.0;
  bool get hasErrors => errorCount > 0;
  bool get allProcessed => processedRequests == totalRequests;
}

class BatchMetadata {
  final DateTime startTime;
  final DateTime endTime;
  final BatchOptions options;

  const BatchMetadata({
    required this.startTime,
    required this.endTime,
    required this.options,
  });
}

class CalculationCompatibilityResult {
  final bool isCompatible;
  final String strategyId;
  final List<String> errors;
  final List<String>? warnings;
  final ICalculatorStrategy? strategy;

  const CalculationCompatibilityResult({
    required this.isCompatible,
    required this.strategyId,
    required this.errors,
    this.warnings,
    this.strategy,
  });
}

class EngineStatistics {
  final int totalStrategiesAvailable;
  final bool registryInitialized;
  final Map<String, String> serviceComponents;

  const EngineStatistics({
    required this.totalStrategiesAvailable,
    required this.registryInitialized,
    required this.serviceComponents,
  });
}

class EngineHealthCheck {
  final bool isHealthy;
  final List<String> issues;
  final List<String> warnings;
  final DateTime timestamp;
  final EngineStatistics statistics;

  const EngineHealthCheck({
    required this.isHealthy,
    required this.issues,
    required this.warnings,
    required this.timestamp,
    required this.statistics,
  });
}

// ============= ENUMS =============

enum EngineErrorType {
  strategyNotFound,
  validationFailed,
  executionFailed,
  noCompatibleStrategy,
  batchItemFailed,
  unexpectedError,
}

enum CalculationPhase {
  initialization,
  validation,
  execution,
  formatting,
  unknown,
}