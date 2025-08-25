import '../entities/calculation_result.dart';
import '../entities/calculator_category.dart';
import '../entities/calculator_entity.dart';
import '../entities/calculator_parameter.dart';
import '../validation/parameter_validator.dart';
import 'calculator_error_handler.dart';
import 'result_formatter_service.dart';
import 'unit_conversion_service.dart';

/// Motor principal do sistema de calculadoras
/// 
/// Orquestra validação, conversão, cálculo e formatação
/// com tratamento robusto de erros e logging completo
class CalculatorEngine {
  static final CalculatorEngine _instance = CalculatorEngine._internal();
  factory CalculatorEngine() => _instance;
  CalculatorEngine._internal();

  final Map<String, CalculatorEntity> _registeredCalculators = {};
  final List<CalculationSession> _activeSessions = [];

  /// Registra uma calculadora no sistema
  void registerCalculator(CalculatorEntity calculator) {
    _registeredCalculators[calculator.id] = calculator;
  }

  /// Registra múltiplas calculadoras
  void registerCalculators(List<CalculatorEntity> calculators) {
    for (final calculator in calculators) {
      registerCalculator(calculator);
    }
  }

  /// Obtém calculadora registrada por ID
  CalculatorEntity? getCalculator(String calculatorId) {
    return _registeredCalculators[calculatorId];
  }

  /// Lista todas as calculadoras registradas
  List<CalculatorEntity> getAllCalculators() {
    return _registeredCalculators.values.toList();
  }

  /// Lista calculadoras por categoria
  List<CalculatorEntity> getCalculatorsByCategory(CalculatorCategory category) {
    return _registeredCalculators.values
        .where((calc) => calc.category == category)
        .toList();
  }

  /// Executa cálculo completo com validação e formatação
  Future<CalculationEngineResult> calculate({
    required String calculatorId,
    required Map<String, dynamic> parameters,
    Map<String, ParameterUnit>? preferredUnits,
    bool validateOnly = false,
  }) async {
    try {
      // Buscar calculadora
      final calculator = _registeredCalculators[calculatorId];
      if (calculator == null) {
        return CalculationEngineResult.error(
          CalculatorErrorHandler.handleConfigurationError(
            calculatorId,
            'Calculadora não encontrada',
          ),
        );
      }

      // Criar sessão de cálculo
      final session = CalculationSession(
        calculatorId: calculatorId,
        parameters: parameters,
        startTime: DateTime.now(),
      );
      _activeSessions.add(session);

      try {
        // 1. Validação de parâmetros
        final validationResult = await _validateParameters(
          calculator,
          parameters,
        );

        if (!validationResult.isValid) {
          session.complete(success: false, errors: validationResult.errors.values.toList());
          return CalculationEngineResult.validationError(validationResult);
        }

        // Se é apenas validação, retornar sucesso
        if (validateOnly) {
          session.complete(success: true);
          return CalculationEngineResult.validationSuccess(validationResult);
        }

        // 2. Conversão de unidades (se necessário)
        final convertedParameters = await _convertUnits(
          calculator,
          parameters,
          preferredUnits,
        );

        // 3. Execução do cálculo
        final calculationResult = await _executeCalculation(
          calculator,
          convertedParameters,
        );

        // 4. Formatação dos resultados
        final formattedResult = await _formatResults(
          calculator,
          calculationResult,
          preferredUnits,
        );

        session.complete(
          success: true,
          result: formattedResult,
        );

        return CalculationEngineResult.success(
          formattedResult,
          validationResult,
          session,
        );
      } catch (e) {
        final error = CalculatorErrorHandler.handleCalculationError(
          e is Exception ? e : Exception(e.toString()),
          calculatorId,
          parameters,
          operationContext: 'calculate',
        );

        session.complete(success: false, errors: [error.message]);
        return CalculationEngineResult.error(error);
      } finally {
        _activeSessions.remove(session);
      }
    } catch (e) {
      final error = CalculatorErrorHandler.handleCalculationError(
        e is Exception ? e : Exception(e.toString()),
        calculatorId,
        parameters,
        operationContext: 'engine_setup',
      );

      return CalculationEngineResult.error(error);
    }
  }

  /// Executa validação de parâmetros apenas
  Future<ValidationBatchResult> validateParameters({
    required String calculatorId,
    required Map<String, dynamic> parameters,
  }) async {
    final calculator = _registeredCalculators[calculatorId];
    if (calculator == null) {
      return const ValidationBatchResult(
        isValid: false,
        errors: {'calculator': 'Calculadora não encontrada'},
        warnings: {},
      );
    }

    return await _validateParameters(calculator, parameters);
  }

  /// Converte valores entre unidades
  Future<Map<String, ConversionResult>> convertUnits({
    required Map<String, double> values,
    required Map<String, ParameterUnit> fromUnits,
    required Map<String, ParameterUnit> toUnits,
  }) async {
    return UnitConversionService.convertBatch(
      values: values,
      fromUnits: fromUnits,
      toUnits: toUnits,
    );
  }

  /// Obtém estatísticas de uso do sistema
  CalculatorEngineStats getStats() {
    final totalCalculators = _registeredCalculators.length;
    final activeSessions = _activeSessions.length;
    
    final categoryStats = <CalculatorCategory, int>{};
    for (final calculator in _registeredCalculators.values) {
      categoryStats[calculator.category] = 
          (categoryStats[calculator.category] ?? 0) + 1;
    }

    return CalculatorEngineStats(
      totalCalculators: totalCalculators,
      activeSessions: activeSessions,
      categoryStats: categoryStats,
    );
  }

  /// Limpa sessões antigas
  void cleanupSessions({Duration? olderThan}) {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(hours: 1));
    _activeSessions.removeWhere((session) => session.startTime.isBefore(cutoff));
  }

  /// Métodos privados

  Future<ValidationBatchResult> _validateParameters(
    CalculatorEntity calculator,
    Map<String, dynamic> parameters,
  ) async {
    final calculatorParameters = calculator.parameters;
    return ParameterValidator.validateParameters(calculatorParameters, parameters);
  }

  Future<Map<String, dynamic>> _convertUnits(
    CalculatorEntity calculator,
    Map<String, dynamic> parameters,
    Map<String, ParameterUnit>? preferredUnits,
  ) async {
    if (preferredUnits == null || preferredUnits.isEmpty) {
      return parameters;
    }

    final convertedParameters = Map<String, dynamic>.from(parameters);

    for (final entry in preferredUnits.entries) {
      final parameterId = entry.key;
      final targetUnit = entry.value;
      
      final parameter = calculator.parameters
          .firstWhere((p) => p.id == parameterId, orElse: () => 
              throw ArgumentError('Parâmetro não encontrado: $parameterId'));

      final value = parameters[parameterId];
      if (value is num && parameter.unit != targetUnit) {
        final conversion = UnitConversionService.convert(
          value: value.toDouble(),
          fromUnit: parameter.unit,
          toUnit: targetUnit,
        );

        if (conversion.isSuccess) {
          convertedParameters[parameterId] = conversion.value;
        } else {
          throw Exception('Erro na conversão: ${conversion.errorMessage}');
        }
      }
    }

    return convertedParameters;
  }

  Future<CalculationResult> _executeCalculation(
    CalculatorEntity calculator,
    Map<String, dynamic> parameters,
  ) async {
    try {
      return calculator.calculate(parameters);
    } catch (e) {
      throw CalculatorErrorHandler.handleCalculationError(
        e is Exception ? e : Exception(e.toString()),
        calculator.id,
        parameters,
        operationContext: 'calculation_execution',
      );
    }
  }

  Future<FormattedCalculationResult> _formatResults(
    CalculatorEntity calculator,
    CalculationResult result,
    Map<String, ParameterUnit>? preferredUnits,
  ) async {
    final formattedResults = <FormattedResultValue>[];

    for (final resultValue in result.results) {
      String formattedValue;
      String displayUnit = resultValue.unit;

      // Aplicar unidades preferidas se especificadas
      if (preferredUnits != null && preferredUnits.containsKey(resultValue.label)) {
        final targetUnit = preferredUnits[resultValue.label]!;
        // Lógica de conversão e formatação com unidade preferida
        formattedValue = ResultFormatterService.formatPrimaryResult(resultValue);
        // displayUnit seria atualizado após conversão
      } else {
        formattedValue = ResultFormatterService.formatPrimaryResult(resultValue);
      }

      formattedResults.add(FormattedResultValue(
        label: resultValue.label,
        formattedValue: formattedValue,
        originalValue: resultValue.value as double,
        unit: displayUnit,
        description: resultValue.description ?? '',
      ));
    }

    final formattedRecommendations = result.recommendations?.isNotEmpty == true
        ? ResultFormatterService.formatRecommendations(result.recommendations!)
        : <String>[];

    return FormattedCalculationResult(
      calculatorId: calculator.id,
      calculatorName: calculator.name,
      results: formattedResults,
      recommendations: formattedRecommendations,
      additionalData: result.additionalData ?? {},
      timestamp: DateTime.now(),
    );
  }
}

/// Resultado do motor de cálculo
class CalculationEngineResult {
  final bool isSuccess;
  final FormattedCalculationResult? result;
  final ValidationBatchResult? validation;
  final CalculationSession? session;
  final CalculatorError? error;

  const CalculationEngineResult._({
    required this.isSuccess,
    this.result,
    this.validation,
    this.session,
    this.error,
  });

  factory CalculationEngineResult.success(
    FormattedCalculationResult result,
    ValidationBatchResult validation,
    CalculationSession session,
  ) {
    return CalculationEngineResult._(
      isSuccess: true,
      result: result,
      validation: validation,
      session: session,
    );
  }

  factory CalculationEngineResult.validationError(
    ValidationBatchResult validation,
  ) {
    return CalculationEngineResult._(
      isSuccess: false,
      validation: validation,
    );
  }

  factory CalculationEngineResult.validationSuccess(
    ValidationBatchResult validation,
  ) {
    return CalculationEngineResult._(
      isSuccess: true,
      validation: validation,
    );
  }

  factory CalculationEngineResult.error(CalculatorError error) {
    return CalculationEngineResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Sessão de cálculo para tracking
class CalculationSession {
  final String calculatorId;
  final Map<String, dynamic> parameters;
  final DateTime startTime;
  DateTime? endTime;
  bool? success;
  FormattedCalculationResult? result;
  List<String> errors = [];

  CalculationSession({
    required this.calculatorId,
    required this.parameters,
    required this.startTime,
  });

  void complete({
    required bool success,
    FormattedCalculationResult? result,
    List<String>? errors,
  }) {
    endTime = DateTime.now();
    this.success = success;
    this.result = result;
    if (errors != null) {
      this.errors.addAll(errors);
    }
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}

/// Resultado formatado de cálculo
class FormattedCalculationResult {
  final String calculatorId;
  final String calculatorName;
  final List<FormattedResultValue> results;
  final List<String> recommendations;
  final Map<String, dynamic> additionalData;
  final DateTime timestamp;

  const FormattedCalculationResult({
    required this.calculatorId,
    required this.calculatorName,
    required this.results,
    required this.recommendations,
    required this.additionalData,
    required this.timestamp,
  });
}

/// Valor de resultado formatado
class FormattedResultValue {
  final String label;
  final String formattedValue;
  final double originalValue;
  final String unit;
  final String description;

  const FormattedResultValue({
    required this.label,
    required this.formattedValue,
    required this.originalValue,
    required this.unit,
    required this.description,
  });
}

/// Estatísticas do motor de cálculo
class CalculatorEngineStats {
  final int totalCalculators;
  final int activeSessions;
  final Map<CalculatorCategory, int> categoryStats;

  const CalculatorEngineStats({
    required this.totalCalculators,
    required this.activeSessions,
    required this.categoryStats,
  });
}