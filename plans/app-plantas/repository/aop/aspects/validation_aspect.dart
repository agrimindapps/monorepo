// Project imports:
import '../aspect_interface.dart';

/// Exceção de validação
class ValidationException implements Exception {
  final String repository;
  final String operation;
  final List<String> invalidFields;
  final Map<String, String> validationErrors;

  ValidationException({
    required this.repository,
    required this.operation,
    required this.invalidFields,
    required this.validationErrors,
  });

  @override
  String toString() {
    return 'ValidationException in $repository.$operation: ${validationErrors.values.join(', ')}';
  }
}

/// Configuração do aspecto de validação
class ValidationAspectConfig {
  final bool enabled;
  final bool validateIdFormat;
  final bool validateResults;
  final bool strictResultValidation;
  final List<String> requiredFields;

  ValidationAspectConfig({
    this.enabled = true,
    this.validateIdFormat = false,
    this.validateResults = false,
    this.strictResultValidation = false,
    this.requiredFields = const [],
  });
}

/// Aspecto de validação para repositories
class ValidationAspect implements RepositoryAspect {
  final String repositoryName;
  final ValidationAspectConfig config;

  ValidationAspect({
    required this.repositoryName,
    required this.config,
  });

  @override
  String get name => 'validation';

  @override
  int get priority => 10; // Alta prioridade para validação

  @override
  bool get enabled => config.enabled;

  @override
  Future<AdviceResult> beforeOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required OperationContext context,
  }) async {
    if (!config.enabled) {
      return AdviceResult.proceed();
    }

    // Validar campos obrigatórios
    for (final field in config.requiredFields) {
      if (!parameters.containsKey(field) || parameters[field] == null) {
        return AdviceResult.throwException(
          ValidationException(
            repository: repositoryName,
            operation: operationName,
            invalidFields: [field],
            validationErrors: {field: 'Campo obrigatório não fornecido'},
          ),
        );
      }
    }

    return AdviceResult.proceed();
  }

  @override
  Future<AdviceResult> afterOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic result,
    required OperationContext context,
  }) async {
    if (!config.enabled || !config.validateResults) {
      return AdviceResult.proceed(result: result);
    }

    try {
      await _validateResult(operationName, result, context);
      return AdviceResult.proceed(result: result);
    } catch (e) {
      return AdviceResult.throwException(e);
    }
  }

  @override
  Future<AdviceResult> onException({
    required String operationName,
    required Map<String, dynamic> parameters,
    required dynamic exception,
    required StackTrace stackTrace,
    required OperationContext context,
  }) async {
    if (exception is ValidationException) {
      return AdviceResult.throwException(exception);
    }

    return AdviceResult.throwException(
      ValidationException(
        repository: repositoryName,
        operation: operationName,
        invalidFields: ['operation'],
        validationErrors: {'operation': 'Erro na execução: $exception'},
      ),
    );
  }

  @override
  Future<void> finallyOperation({
    required String operationName,
    required Map<String, dynamic> parameters,
    dynamic result,
    dynamic exception,
    required OperationContext context,
  }) async {
    // Log final de validação se necessário
    if (exception is ValidationException) {
      context.addContext('validation_errors', exception.validationErrors);
      context.addContext('validation_failed_fields', exception.invalidFields);
    }
  }

  Future<void> _validateResult(
      String operationName, dynamic result, OperationContext context) async {
    // Validações básicas de resultado
    if (result == null) {
      throw ValidationException(
        repository: 'unknown',
        operation: operationName,
        invalidFields: ['result'],
        validationErrors: {'result': 'Resultado não pode ser nulo'},
      );
    }

    // Validação para listas
    if (result is List && result.isEmpty) {
      throw ValidationException(
        repository: 'unknown',
        operation: operationName,
        invalidFields: ['result'],
        validationErrors: {'result': 'Lista de resultados não pode ser vazia'},
      );
    }
  }
}