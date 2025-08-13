// Dart imports:
import 'dart:core';

/// Result pattern para operações que podem falhar
/// Permite handling explícito de success/error sem exceptions
abstract class Result<T> {
  const Result();

  /// Cria resultado de sucesso
  factory Result.success(T value) = Success<T>;

  /// Cria resultado de erro
  factory Result.error(ValidationError error) = Error<T>;

  /// Retorna true se operação foi bem sucedida
  bool get isSuccess;

  /// Retorna true se operação falhou
  bool get isError => !isSuccess;

  /// Obtém valor em caso de sucesso, throw em caso de erro
  T get value;

  /// Obtém erro em caso de falha, null em caso de sucesso
  ValidationError? get error;

  /// Mapeia resultado para outro tipo
  Result<U> map<U>(U Function(T) mapper);

  /// Mapeia erro para outro tipo
  Result<T> mapError(ValidationError Function(ValidationError) mapper);

  /// Executa função apenas se for sucesso
  Result<U> flatMap<U>(Result<U> Function(T) mapper);

  /// Executa função baseada no resultado
  U fold<U>(U Function(T) onSuccess, U Function(ValidationError) onError);
}

/// Implementação de resultado bem sucedido
class Success<T> extends Result<T> {
  final T _value;

  const Success(this._value);

  @override
  bool get isSuccess => true;

  @override
  T get value => _value;

  @override
  ValidationError? get error => null;

  @override
  Result<U> map<U>(U Function(T) mapper) {
    return Result.success(mapper(_value));
  }

  @override
  Result<T> mapError(ValidationError Function(ValidationError) mapper) {
    return this;
  }

  @override
  Result<U> flatMap<U>(Result<U> Function(T) mapper) {
    return mapper(_value);
  }

  @override
  U fold<U>(U Function(T) onSuccess, U Function(ValidationError) onError) {
    return onSuccess(_value);
  }

  @override
  String toString() => 'Success($_value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}

/// Implementação de resultado com erro
class Error<T> extends Result<T> {
  final ValidationError _error;

  const Error(this._error);

  @override
  bool get isSuccess => false;

  @override
  T get value => throw _error;

  @override
  ValidationError get error => _error;

  @override
  Result<U> map<U>(U Function(T) mapper) {
    return Result.error(_error);
  }

  @override
  Result<T> mapError(ValidationError Function(ValidationError) mapper) {
    return Result.error(mapper(_error));
  }

  @override
  Result<U> flatMap<U>(Result<U> Function(T) mapper) {
    return Result.error(_error);
  }

  @override
  U fold<U>(U Function(T) onSuccess, U Function(ValidationError) onError) {
    return onError(_error);
  }

  @override
  String toString() => 'Error($_error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> &&
          runtimeType == other.runtimeType &&
          _error == other._error;

  @override
  int get hashCode => _error.hashCode;
}

/// Classe base para erros de validação
abstract class ValidationError implements Exception {
  /// Mensagem do erro
  final String message;

  /// Campo que causou o erro (opcional)
  final String? field;

  /// Código do erro para internacionalização
  final String code;

  const ValidationError(this.message, this.code, {this.field});

  // Factory methods para facilitar criação
  factory ValidationError.requiredField(String field) = RequiredFieldError;
  factory ValidationError.invalidFormat(String field, String format) =
      InvalidFormatError;
  factory ValidationError.outOfRange(String field, String range) =
      OutOfRangeError;
  factory ValidationError.duplicateEntry(String message) = _DuplicateEntryError;
  factory ValidationError.invalidState(String message) = _InvalidStateError;
  factory ValidationError.invalidReference(String field, String entity) =
      InvalidReferenceError;

  @override
  String toString() {
    if (field != null) {
      return 'ValidationError[$code]: $message (field: $field)';
    }
    return 'ValidationError[$code]: $message';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          field == other.field &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ field.hashCode ^ code.hashCode;
}

/// Erro de campo obrigatório
class RequiredFieldError extends ValidationError {
  const RequiredFieldError(String field)
      : super('Campo obrigatório não informado', 'REQUIRED_FIELD',
            field: field);
}

/// Erro de formato inválido
class InvalidFormatError extends ValidationError {
  const InvalidFormatError(String field, String expectedFormat)
      : super('Formato inválido. Esperado: $expectedFormat', 'INVALID_FORMAT',
            field: field);
}

/// Erro de valor fora do range
class OutOfRangeError extends ValidationError {
  const OutOfRangeError(String field, String range)
      : super('Valor fora do range permitido: $range', 'OUT_OF_RANGE',
            field: field);
}

/// Erro de valor duplicado
class DuplicateValueError extends ValidationError {
  const DuplicateValueError(String field, dynamic value)
      : super('Valor já existe: $value', 'DUPLICATE_VALUE', field: field);
}

/// Erro de referência inválida
class InvalidReferenceError extends ValidationError {
  const InvalidReferenceError(String field, String referencedEntity)
      : super('Referência inválida para $referencedEntity', 'INVALID_REFERENCE',
            field: field);
}

/// Erro de data inválida
class InvalidDateError extends ValidationError {
  const InvalidDateError(String field, String reason)
      : super('Data inválida: $reason', 'INVALID_DATE', field: field);
}

/// Erro de estado inválido
class InvalidStateError extends ValidationError {
  const InvalidStateError(String field, String validStates)
      : super('Estado inválido. Estados válidos: $validStates', 'INVALID_STATE',
            field: field);
}

/// Erro de comprimento inválido
class InvalidLengthError extends ValidationError {
  const InvalidLengthError(String field, int min, int max)
      : super('Comprimento deve estar entre $min e $max caracteres',
            'INVALID_LENGTH',
            field: field);
}

/// Erro de dependência não atendida
class DependencyNotMetError extends ValidationError {
  const DependencyNotMetError(String field, String dependency)
      : super('Dependência não atendida: $dependency', 'DEPENDENCY_NOT_MET',
            field: field);
}

/// Erro de entrada duplicada
class _DuplicateEntryError extends ValidationError {
  const _DuplicateEntryError(String message)
      : super(message, 'DUPLICATE_ENTRY');
}

/// Erro de estado inválido genérico
class _InvalidStateError extends ValidationError {
  const _InvalidStateError(String message)
      : super(message, 'INVALID_STATE_GENERIC');
}

/// Utilitários para trabalhar com múltiplos resultados
class ResultUtils {
  /// Combina múltiplos resultados em um único resultado
  /// Retorna erro se qualquer um dos resultados for erro
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> values = [];

    for (final result in results) {
      if (result.isError) {
        return Result.error(result.error!);
      }
      values.add(result.value);
    }

    return Result.success(values);
  }

  /// Coleta todos os erros de uma lista de resultados
  static List<ValidationError> collectErrors<T>(List<Result<T>> results) {
    return results.where((r) => r.isError).map((r) => r.error!).toList();
  }

  /// Coleta todos os valores bem sucedidos de uma lista de resultados
  static List<T> collectSuccesses<T>(List<Result<T>> results) {
    return results.where((r) => r.isSuccess).map((r) => r.value).toList();
  }

  /// Valida se pelo menos um resultado é bem sucedido
  static bool hasAnySuccess<T>(List<Result<T>> results) {
    return results.any((r) => r.isSuccess);
  }

  /// Valida se todos os resultados são bem sucedidos
  static bool allSuccessful<T>(List<Result<T>> results) {
    return results.every((r) => r.isSuccess);
  }
}

/// Extensions para facilitar uso do Result pattern
extension ResultExtensions<T> on Result<T> {
  /// Executa ação apenas se resultado for sucesso
  void ifSuccess(void Function(T) action) {
    if (isSuccess) {
      action(value);
    }
  }

  /// Executa ação apenas se resultado for erro
  void ifError(void Function(ValidationError) action) {
    if (isError) {
      action(error!);
    }
  }

  /// Retorna valor ou valor padrão em caso de erro
  T orElse(T defaultValue) {
    return isSuccess ? value : defaultValue;
  }

  /// Retorna valor ou resultado de função em caso de erro
  T orElseGet(T Function() defaultValueProvider) {
    return isSuccess ? value : defaultValueProvider();
  }

  /// Converte Result<T> em T?, retornando null em caso de erro
  T? toNullable() {
    return isSuccess ? value : null;
  }

  /// Converte para Future<T> que falha com exception em caso de erro
  Future<T> toFuture() async {
    if (isSuccess) {
      return value;
    }
    throw error!;
  }
}
