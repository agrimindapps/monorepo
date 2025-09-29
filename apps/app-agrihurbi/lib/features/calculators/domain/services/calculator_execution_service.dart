import 'package:injectable/injectable.dart';

import '../entities/calculation_result.dart';
import '../entities/calculator_parameter.dart';
import '../interfaces/calculator_strategy.dart';
import '../registry/calculator_strategy_registry.dart';
import 'calculator_validation_service.dart';

/// Service especializado em execução de cálculos
/// 
/// Implementa Single Responsibility Principle (SRP) - foca apenas na execução.
/// Orquestra validação, seleção de estratégia e execução do cálculo.
@injectable
class CalculatorExecutionService {
  final CalculatorStrategyRegistry _strategyRegistry;
  final CalculatorValidationService _validationService;

  CalculatorExecutionService(
    this._strategyRegistry,
    this._validationService,
  );

  /// Executa cálculo usando estratégia específica
  Future<CalculationExecutionResult> executeWithStrategy(
    String strategyId,
    Map<String, dynamic> inputs, {
    bool skipValidation = false,
  }) async {
    try {
      // Buscar estratégia
      final strategy = _strategyRegistry.getStrategy(strategyId);
      if (strategy == null) {
        return CalculationExecutionResult.error(
          ExecutionError(
            type: ExecutionErrorType.strategyNotFound,
            message: 'Estratégia não encontrada: $strategyId',
            strategyId: strategyId,
            inputs: inputs,
          ),
        );
      }

      // Validação (se não foi pulada)
      if (!skipValidation) {
        final validationResult = await _validationService.validateWithStrategy(strategy, inputs);
        if (!validationResult.isValid) {
          return CalculationExecutionResult.validationError(
            ValidationError(
              type: ExecutionErrorType.validationFailed,
              message: 'Validação falhou',
              strategyId: strategyId,
              inputs: inputs,
              validationErrors: validationResult.errors,
              validationWarnings: validationResult.warnings,
            ),
          );
        }
        
        // Usar inputs sanitizados da validação
        inputs = validationResult.sanitizedInputs;
      }

      // Executar cálculo
      final calculationResult = await strategy.executeCalculation(inputs);
      
      // Pós-processamento (se necessário)
      final finalResult = await strategy.postProcessResults(calculationResult, inputs);

      return CalculationExecutionResult.success(
        ExecutionSuccess(
          result: finalResult,
          strategyId: strategyId,
          executionTime: DateTime.now(),
          inputsUsed: inputs,
        ),
      );

    } catch (e) {
      return CalculationExecutionResult.error(
        ExecutionError(
          type: ExecutionErrorType.executionFailed,
          message: 'Erro durante execução: ${e.toString()}',
          strategyId: strategyId,
          inputs: inputs,
          exception: e,
        ),
      );
    }
  }

  /// Executa cálculo com auto-seleção de estratégia
  Future<CalculationExecutionResult> executeWithAutoStrategy(
    Map<String, dynamic> inputs, {
    String? preferredStrategyType,
  }) async {
    try {
      // Buscar estratégia compatível
      final strategy = _findBestStrategy(inputs, preferredStrategyType);
      if (strategy == null) {
        return CalculationExecutionResult.error(
          ExecutionError(
            type: ExecutionErrorType.noCompatibleStrategy,
            message: 'Nenhuma estratégia compatível encontrada para os inputs fornecidos',
            inputs: inputs,
          ),
        );
      }

      // Executar usando a estratégia encontrada
      return await executeWithStrategy(strategy.strategyId, inputs);

    } catch (e) {
      return CalculationExecutionResult.error(
        ExecutionError(
          type: ExecutionErrorType.autoSelectionFailed,
          message: 'Erro na seleção automática de estratégia: ${e.toString()}',
          inputs: inputs,
          exception: e,
        ),
      );
    }
  }

  /// Executa múltiplos cálculos em batch
  Future<BatchExecutionResult> executeBatch(
    List<BatchCalculationRequest> requests,
  ) async {
    final results = <String, CalculationExecutionResult>{};
    final errors = <String, ExecutionError>{};
    int successCount = 0;

    for (final request in requests) {
      try {
        final result = await executeWithStrategy(
          request.strategyId,
          request.inputs,
          skipValidation: request.skipValidation,
        );

        results[request.id] = result;
        
        if (result.isSuccess) {
          successCount++;
        } else {
          errors[request.id] = result.error!;
        }

      } catch (e) {
        final error = ExecutionError(
          type: ExecutionErrorType.batchItemFailed,
          message: 'Erro no item ${request.id}: ${e.toString()}',
          strategyId: request.strategyId,
          inputs: request.inputs,
          exception: e,
        );
        
        errors[request.id] = error;
        results[request.id] = CalculationExecutionResult.error(error);
      }
    }

    return BatchExecutionResult(
      totalRequests: requests.length,
      successCount: successCount,
      errorCount: errors.length,
      results: results,
      errors: errors,
      executedAt: DateTime.now(),
    );
  }

  /// Valida se uma estratégia pode processar os inputs
  Future<StrategyCompatibilityResult> checkStrategyCompatibility(
    String strategyId,
    Map<String, dynamic> inputs,
  ) async {
    final strategy = _strategyRegistry.getStrategy(strategyId);
    
    if (strategy == null) {
      return StrategyCompatibilityResult(
        isCompatible: false,
        strategyId: strategyId,
        reason: 'Estratégia não encontrada',
      );
    }

    final canProcess = strategy.canProcess(inputs);
    if (!canProcess) {
      return StrategyCompatibilityResult(
        isCompatible: false,
        strategyId: strategyId,
        reason: 'Estratégia não pode processar os inputs fornecidos',
      );
    }

    // Validação adicional
    final validationResult = await _validationService.validateWithStrategy(strategy, inputs);
    
    return StrategyCompatibilityResult(
      isCompatible: validationResult.isValid,
      strategyId: strategyId,
      reason: validationResult.isValid 
          ? 'Compatível' 
          : 'Falha na validação: ${validationResult.errors.join(', ')}',
      validationWarnings: validationResult.warnings,
    );
  }

  /// Lista estratégias disponíveis com metadados
  List<StrategyInfo> getAvailableStrategies() {
    final strategies = _strategyRegistry.getAllStrategies();
    
    return strategies.map((strategy) => StrategyInfo(
      id: strategy.strategyId,
      name: strategy.strategyName,
      description: strategy.description,
      parameters: strategy.parameters,
      metadata: strategy.metadata,
    )).toList();
  }

  /// Obtém estatísticas de execução
  ExecutionStatistics getExecutionStatistics() {
    final stats = _strategyRegistry.getStatistics();
    
    return ExecutionStatistics(
      totalStrategiesAvailable: stats.totalStrategies,
      strategyTypes: stats.typeDistribution,
      registryInitialized: stats.isInitialized,
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

// ============= RESULT CLASSES =============

class CalculationExecutionResult {
  final bool isSuccess;
  final ExecutionSuccess? success;
  final ExecutionError? error;
  final ValidationError? validationError;

  const CalculationExecutionResult._({
    required isSuccess,
    success,
    error,
    validationError,
  });

  factory CalculationExecutionResult.success(ExecutionSuccess success) {
    return CalculationExecutionResult._(
      isSuccess: true,
      success: success,
    );
  }

  factory CalculationExecutionResult.error(ExecutionError error) {
    return CalculationExecutionResult._(
      isSuccess: false,
      error: error,
    );
  }

  factory CalculationExecutionResult.validationError(ValidationError validationError) {
    return CalculationExecutionResult._(
      isSuccess: false,
      validationError: validationError,
    );
  }
}

class ExecutionSuccess {
  final CalculationResult result;
  final String strategyId;
  final DateTime executionTime;
  final Map<String, dynamic> inputsUsed;

  const ExecutionSuccess({
    required result,
    required strategyId,
    required executionTime,
    required inputsUsed,
  });
}

class ExecutionError {
  final ExecutionErrorType type;
  final String message;
  final String? strategyId;
  final Map<String, dynamic>? inputs;
  final Object? exception;

  const ExecutionError({
    required type,
    required message,
    strategyId,
    inputs,
    exception,
  });
}

class ValidationError extends ExecutionError {
  final List<String> validationErrors;
  final List<String> validationWarnings;

  const ValidationError({
    required super.type,
    required super.message,
    super.strategyId,
    super.inputs,
    required validationErrors,
    required validationWarnings,
  });
}

enum ExecutionErrorType {
  strategyNotFound,
  validationFailed,
  executionFailed,
  noCompatibleStrategy,
  autoSelectionFailed,
  batchItemFailed,
}

class BatchCalculationRequest {
  final String id;
  final String strategyId;
  final Map<String, dynamic> inputs;
  final bool skipValidation;

  const BatchCalculationRequest({
    required id,
    required strategyId,
    required inputs,
    skipValidation = false,
  });
}

class BatchExecutionResult {
  final int totalRequests;
  final int successCount;
  final int errorCount;
  final Map<String, CalculationExecutionResult> results;
  final Map<String, ExecutionError> errors;
  final DateTime executedAt;

  const BatchExecutionResult({
    required totalRequests,
    required successCount,
    required errorCount,
    required results,
    required errors,
    required executedAt,
  });

  double get successRate => totalRequests > 0 ? successCount / totalRequests : 0.0;
  bool get hasErrors => errorCount > 0;
  bool get allSuccessful => errorCount == 0;
}

class StrategyCompatibilityResult {
  final bool isCompatible;
  final String strategyId;
  final String reason;
  final List<String>? validationWarnings;

  const StrategyCompatibilityResult({
    required isCompatible,
    required strategyId,
    required reason,
    validationWarnings,
  });
}

class StrategyInfo {
  final String id;
  final String name;
  final String description;
  final List<CalculatorParameter> parameters;
  final StrategyMetadata metadata;

  const StrategyInfo({
    required id,
    required name,
    required description,
    required parameters,
    required metadata,
  });
}

class ExecutionStatistics {
  final int totalStrategiesAvailable;
  final Map<String, int> strategyTypes;
  final bool registryInitialized;

  const ExecutionStatistics({
    required totalStrategiesAvailable,
    required strategyTypes,
    required registryInitialized,
  });
}