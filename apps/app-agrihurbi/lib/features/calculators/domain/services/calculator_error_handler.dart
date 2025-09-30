import 'dart:developer' as developer;

/// Serviço centralizado de tratamento de erros para calculadoras
///
/// Implementa handling robusto com categorização, logging e recovery
/// para garantir experiência estável mesmo com falhas
class CalculatorErrorHandler {
  CalculatorErrorHandler._();

  static const String _loggerName = 'CalculatorErrorHandler';

  /// Trata erro de cálculo com contexto
  static CalculatorError handleCalculationError(
    Exception exception,
    String calculatorId,
    Map<String, dynamic> parameters, {
    String? operationContext,
  }) {
    final error = _categorizeError(exception, calculatorId);
    
    _logError(
      error,
      calculatorId: calculatorId,
      parameters: parameters,
      operationContext: operationContext,
    );

    return error;
  }

  /// Trata erro de validação de parâmetros
  static CalculatorError handleValidationError(
    String parameterId,
    String message,
    dynamic value, {
    String? calculatorId,
  }) {
    final error = CalculatorError(
      code: CalculatorErrorCode.validationError,
      message: message,
      userMessage: _getUserFriendlyMessage(CalculatorErrorCode.validationError, message),
      details: {
        'parameter_id': parameterId,
        'invalid_value': value?.toString(),
        'calculator_id': calculatorId,
      },
      severity: ErrorSeverity.warning,
      isRecoverable: true,
    );

    _logError(error, calculatorId: calculatorId);
    return error;
  }

  /// Trata erro de conversão de unidades
  static CalculatorError handleConversionError(
    String fromUnit,
    String toUnit,
    dynamic value,
    Exception exception,
  ) {
    final error = CalculatorError(
      code: CalculatorErrorCode.conversionError,
      message: 'Erro na conversão de $fromUnit para $toUnit: ${exception.toString()}',
      userMessage: 'Não foi possível converter entre as unidades selecionadas',
      details: {
        'from_unit': fromUnit,
        'to_unit': toUnit,
        'value': value?.toString(),
        'exception': exception.toString(),
      },
      severity: ErrorSeverity.error,
      isRecoverable: true,
    );

    _logError(error);
    return error;
  }

  /// Trata erro de parâmetro faltante
  static CalculatorError handleMissingParameterError(
    String parameterId,
    String parameterName,
    String calculatorId,
  ) {
    final error = CalculatorError(
      code: CalculatorErrorCode.missingParameter,
      message: 'Parâmetro obrigatório não fornecido: $parameterId',
      userMessage: 'O campo "$parameterName" é obrigatório',
      details: {
        'parameter_id': parameterId,
        'parameter_name': parameterName,
        'calculator_id': calculatorId,
      },
      severity: ErrorSeverity.warning,
      isRecoverable: true,
    );

    _logError(error, calculatorId: calculatorId);
    return error;
  }

  /// Trata erro de cálculo matemático
  static CalculatorError handleMathError(
    String operation,
    List<double> operands,
    Exception exception,
    String calculatorId,
  ) {
    final error = CalculatorError(
      code: CalculatorErrorCode.mathematicalError,
      message: 'Erro matemático na operação $operation: ${exception.toString()}',
      userMessage: 'Erro no cálculo. Verifique os valores inseridos',
      details: {
        'operation': operation,
        'operands': operands.map((e) => e.toString()).toList(),
        'calculator_id': calculatorId,
        'exception': exception.toString(),
      },
      severity: ErrorSeverity.error,
      isRecoverable: true,
    );

    _logError(error, calculatorId: calculatorId);
    return error;
  }

  /// Trata erro de configuração de calculadora
  static CalculatorError handleConfigurationError(
    String calculatorId,
    String configurationIssue,
  ) {
    final error = CalculatorError(
      code: CalculatorErrorCode.configurationError,
      message: 'Erro de configuração na calculadora $calculatorId: $configurationIssue',
      userMessage: 'Calculadora temporariamente indisponível',
      details: {
        'calculator_id': calculatorId,
        'configuration_issue': configurationIssue,
      },
      severity: ErrorSeverity.critical,
      isRecoverable: false,
    );

    _logError(error, calculatorId: calculatorId);
    return error;
  }

  /// Trata múltiplos erros em lote
  static List<CalculatorError> handleBatchErrors(
    Map<String, Exception> errors,
    String calculatorId,
  ) {
    final handledErrors = <CalculatorError>[];

    for (final entry in errors.entries) {
      final parameterId = entry.key;
      final exception = entry.value;
      
      final error = _categorizeError(exception, calculatorId, parameterId);
      handledErrors.add(error);
    }

    _logBatchErrors(handledErrors, calculatorId);
    return handledErrors;
  }

  /// Sugere ações de recovery baseadas no erro
  static List<RecoveryAction> suggestRecoveryActions(CalculatorError error) {
    final actions = <RecoveryAction>[];

    switch (error.code) {
      case CalculatorErrorCode.validationError:
        actions.add(RecoveryAction(
          type: RecoveryActionType.validateInput,
          description: 'Corrigir o valor inserido',
          parameterId: error.details['parameter_id'] as String?,
        ));
        break;

      case CalculatorErrorCode.missingParameter:
        actions.add(RecoveryAction(
          type: RecoveryActionType.provideInput,
          description: 'Preencher campo obrigatório',
          parameterId: error.details['parameter_id'] as String?,
        ));
        break;

      case CalculatorErrorCode.conversionError:
        actions.add(const RecoveryAction(
          type: RecoveryActionType.selectDifferentUnit,
          description: 'Selecionar unidade compatível',
        ));
        break;

      case CalculatorErrorCode.mathematicalError:
        actions.add(const RecoveryAction(
          type: RecoveryActionType.validateInput,
          description: 'Verificar valores numéricos',
        ));
        actions.add(const RecoveryAction(
          type: RecoveryActionType.useDefaultValues,
          description: 'Usar valores padrão',
        ));
        break;

      case CalculatorErrorCode.configurationError:
        actions.add(const RecoveryAction(
          type: RecoveryActionType.contactSupport,
          description: 'Entrar em contato com suporte',
        ));
        break;

      case CalculatorErrorCode.networkError:
        actions.add(const RecoveryAction(
          type: RecoveryActionType.retry,
          description: 'Tentar novamente',
        ));
        actions.add(const RecoveryAction(
          type: RecoveryActionType.useOfflineMode,
          description: 'Usar modo offline',
        ));
        break;

      case CalculatorErrorCode.unknownError:
        actions.add(const RecoveryAction(
          type: RecoveryActionType.retry,
          description: 'Tentar novamente',
        ));
        actions.add(const RecoveryAction(
          type: RecoveryActionType.reportIssue,
          description: 'Reportar problema',
        ));
        break;
    }

    return actions;
  }

  /// Métodos privados

  static CalculatorError _categorizeError(
    Exception exception,
    String calculatorId, [
    String? parameterId,
  ]) {
    if (exception is FormatException) {
      return CalculatorError(
        code: CalculatorErrorCode.validationError,
        message: 'Formato inválido: ${exception.message}',
        userMessage: 'Formato de dados inválido',
        details: {
          'calculator_id': calculatorId,
          'parameter_id': parameterId,
          'exception': exception.toString(),
        },
        severity: ErrorSeverity.warning,
        isRecoverable: true,
      );
    }

    if (exception is RangeError) {
      return CalculatorError(
        code: CalculatorErrorCode.validationError,
        message: 'Valor fora do range válido: ${exception.toString()}',
        userMessage: 'Valor fora dos limites permitidos',
        details: {
          'calculator_id': calculatorId,
          'parameter_id': parameterId,
          'exception': exception.toString(),
        },
        severity: ErrorSeverity.warning,
        isRecoverable: true,
      );
    }

    if (exception is UnsupportedError) {
      return CalculatorError(
        code: CalculatorErrorCode.configurationError,
        message: 'Operação não suportada: ${exception.toString()}',
        userMessage: 'Operação não disponível',
        details: {
          'calculator_id': calculatorId,
          'exception': exception.toString(),
        },
        severity: ErrorSeverity.error,
        isRecoverable: false,
      );
    }

    if (exception is ArgumentError) {
      return CalculatorError(
        code: CalculatorErrorCode.validationError,
        message: 'Argumento inválido: ${exception.toString()}',
        userMessage: 'Dados de entrada inválidos',
        details: {
          'calculator_id': calculatorId,
          'parameter_id': parameterId,
          'exception': exception.toString(),
        },
        severity: ErrorSeverity.warning,
        isRecoverable: true,
      );
    }

    // Erro genérico
    return CalculatorError(
      code: CalculatorErrorCode.unknownError,
      message: 'Erro inesperado: ${exception.toString()}',
      userMessage: 'Ocorreu um erro inesperado',
      details: {
        'calculator_id': calculatorId,
        'parameter_id': parameterId,
        'exception': exception.toString(),
      },
      severity: ErrorSeverity.error,
      isRecoverable: true,
    );
  }

  static String _getUserFriendlyMessage(
    CalculatorErrorCode code,
    String technicalMessage,
  ) {
    switch (code) {
      case CalculatorErrorCode.validationError:
        if (technicalMessage.toLowerCase().contains('obrigatório')) {
          return 'Este campo é obrigatório';
        }
        if (technicalMessage.toLowerCase().contains('formato')) {
          return 'Formato inválido';
        }
        return 'Valor inválido';

      case CalculatorErrorCode.missingParameter:
        return 'Campo obrigatório não preenchido';

      case CalculatorErrorCode.conversionError:
        return 'Erro na conversão de unidades';

      case CalculatorErrorCode.mathematicalError:
        return 'Erro no cálculo';

      case CalculatorErrorCode.configurationError:
        return 'Calculadora temporariamente indisponível';

      case CalculatorErrorCode.networkError:
        return 'Problema de conexão';

      case CalculatorErrorCode.unknownError:
        return 'Erro inesperado';
    }
  }

  static void _logError(
    CalculatorError error, {
    String? calculatorId,
    Map<String, dynamic>? parameters,
    String? operationContext,
  }) {
    final logLevel = _getLogLevel(error.severity);
    final logMessage = _buildLogMessage(
      error,
      calculatorId: calculatorId,
      parameters: parameters,
      operationContext: operationContext,
    );

    switch (logLevel) {
      case LogLevel.warning:
        developer.log(
          logMessage,
          name: _loggerName,
          level: 900, // Warning level
        );
        break;
      case LogLevel.error:
        developer.log(
          logMessage,
          name: _loggerName,
          level: 1000, // Error level
          error: error,
        );
        break;
      case LogLevel.critical:
        developer.log(
          logMessage,
          name: _loggerName,
          level: 1200, // Severe level
          error: error,
        );
        break;
    }
  }

  static void _logBatchErrors(
    List<CalculatorError> errors,
    String calculatorId,
  ) {
    final errorCount = errors.length;
    final criticalCount = errors.where((e) => e.severity == ErrorSeverity.critical).length;
    
    developer.log(
      'Múltiplos erros na calculadora $calculatorId: '
      '$errorCount erros ($criticalCount críticos)',
      name: _loggerName,
      level: criticalCount > 0 ? 1200 : 1000,
    );

    for (final error in errors) {
      _logError(error, calculatorId: calculatorId);
    }
  }

  static LogLevel _getLogLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.warning:
        return LogLevel.warning;
      case ErrorSeverity.error:
        return LogLevel.error;
      case ErrorSeverity.critical:
        return LogLevel.critical;
    }
  }

  static String _buildLogMessage(
    CalculatorError error, {
    String? calculatorId,
    Map<String, dynamic>? parameters,
    String? operationContext,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Calculator Error: ${error.code.name}');
    buffer.writeln('Message: ${error.message}');
    
    if (calculatorId != null) {
      buffer.writeln('Calculator: $calculatorId');
    }
    
    if (operationContext != null) {
      buffer.writeln('Context: $operationContext');
    }
    
    if (parameters != null && parameters.isNotEmpty) {
      buffer.writeln('Parameters: $parameters');
    }
    
    if (error.details.isNotEmpty) {
      buffer.writeln('Details: ${error.details}');
    }

    return buffer.toString();
  }
}

/// Códigos de erro específicos para calculadoras
enum CalculatorErrorCode {
  validationError,
  missingParameter,
  conversionError,
  mathematicalError,
  configurationError,
  networkError,
  unknownError,
}

/// Severidade do erro
enum ErrorSeverity {
  warning,
  error,
  critical,
}

/// Nível de log
enum LogLevel {
  warning,
  error,
  critical,
}

/// Tipos de ação de recovery
enum RecoveryActionType {
  validateInput,
  provideInput,
  selectDifferentUnit,
  useDefaultValues,
  retry,
  useOfflineMode,
  contactSupport,
  reportIssue,
}

/// Erro estruturado de calculadora
class CalculatorError implements Exception {
  final CalculatorErrorCode code;
  final String message;
  final String userMessage;
  final Map<String, dynamic> details;
  final ErrorSeverity severity;
  final bool isRecoverable;
  final DateTime timestamp;

  CalculatorError({
    required this.code,
    required this.message,
    required this.userMessage,
    required this.details,
    required this.severity,
    required this.isRecoverable,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'CalculatorError(${code.name}): $message';
}

/// Ação de recovery sugerida
class RecoveryAction {
  final RecoveryActionType type;
  final String description;
  final String? parameterId;
  final Map<String, dynamic> metadata;

  const RecoveryAction({
    required this.type,
    required this.description,
    this.parameterId,
    this.metadata = const {},
  });
}