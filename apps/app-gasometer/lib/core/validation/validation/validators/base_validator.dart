import '../../architecture/i_form_validator.dart';

/// Abstract base class for field validators implementing Template Method pattern
/// 
/// This class provides common functionality and structure for all validators
/// while allowing subclasses to implement specific validation logic.
/// Follows Single Responsibility Principle and Open/Closed Principle.
abstract class BaseFieldValidator implements IFieldValidator {
  
  const BaseFieldValidator({
    required String errorMessage,
    Map<String, dynamic> metadata = const {},
  }) : _errorMessage = errorMessage, _metadata = metadata;
  final String _errorMessage;
  final Map<String, dynamic> _metadata;
  
  @override
  String get errorMessage => _errorMessage;
  
  @override
  ValidationResult validate(dynamic value) {
    // Pre-validation checks
    if (!shouldValidate(value)) {
      return ValidationResult.valid();
    }
    
    // Null/empty value handling
    if (value == null || (value is String && value.isEmpty)) {
      return handleNullOrEmpty(value);
    }
    
    // Type validation
    if (!isValidType(value)) {
      return ValidationResult.invalid(getTypeErrorMessage(value));
    }
    
    // Actual validation logic
    return performValidation(value);
  }
  
  /// Check if this validator should run for the given value
  @override
  bool shouldValidate(dynamic value) => true;
  
  /// Handle null or empty values
  /// Override in subclasses if needed
  ValidationResult handleNullOrEmpty(dynamic value) {
    return ValidationResult.valid();
  }
  
  /// Check if the value is of the expected type
  /// Override in subclasses for type checking
  bool isValidType(dynamic value) => true;
  
  /// Get error message for type validation failures
  /// Override in subclasses for custom type error messages
  String getTypeErrorMessage(dynamic value) {
    return 'Tipo de valor inválido';
  }
  
  /// Perform the actual validation logic
  /// Must be implemented by subclasses
  ValidationResult performValidation(dynamic value);
  
  /// Get validator metadata
  Map<String, dynamic> get metadata => Map.unmodifiable(_metadata);
  
  /// Get metadata value by key
  T? getMetadata<T>(String key) {
    final value = _metadata[key];
    return value is T ? value : null;
  }
  
  /// Check if metadata contains a key
  bool hasMetadata(String key) => _metadata.containsKey(key);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseFieldValidator &&
           other.validatorType == validatorType &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(validatorType, errorMessage);
  
  @override
  String toString() => '$validatorType($errorMessage)';
}

/// Base class for validators that work with string values
abstract class StringValidator extends BaseFieldValidator {
  const StringValidator({
    required super.errorMessage,
    super.metadata,
  });
  
  @override
  bool isValidType(dynamic value) => value is String;
  
  @override
  String getTypeErrorMessage(dynamic value) {
    return 'Valor deve ser um texto';
  }
  
  /// Perform validation on string value
  ValidationResult validateString(String value);
  
  @override
  ValidationResult performValidation(dynamic value) {
    return validateString(value as String);
  }
}

/// Base class for validators that work with numeric values
abstract class NumericValidator extends BaseFieldValidator {
  const NumericValidator({
    required super.errorMessage,
    super.metadata,
  });
  
  @override
  bool isValidType(dynamic value) {
    if (value is num) return true;
    if (value is String) return num.tryParse(value) != null;
    return false;
  }
  
  @override
  String getTypeErrorMessage(dynamic value) {
    return 'Valor deve ser um número';
  }
  
  /// Convert value to number
  num parseNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.parse(value);
    throw ArgumentError('Cannot parse $value as number');
  }
  
  /// Perform validation on numeric value
  ValidationResult validateNumber(num value);
  
  @override
  ValidationResult performValidation(dynamic value) {
    final numValue = parseNumber(value);
    return validateNumber(numValue);
  }
}

/// Base class for validators that work with DateTime values
abstract class DateTimeValidator extends BaseFieldValidator {
  const DateTimeValidator({
    required super.errorMessage,
    super.metadata,
  });
  
  @override
  bool isValidType(dynamic value) {
    if (value is DateTime) return true;
    if (value is String) return DateTime.tryParse(value) != null;
    return false;
  }
  
  @override
  String getTypeErrorMessage(dynamic value) {
    return 'Valor deve ser uma data válida';
  }
  
  /// Convert value to DateTime
  DateTime parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    throw ArgumentError('Cannot parse $value as DateTime');
  }
  
  /// Perform validation on DateTime value
  ValidationResult validateDateTime(DateTime value);
  
  @override
  ValidationResult performValidation(dynamic value) {
    final dateTime = parseDateTime(value);
    return validateDateTime(dateTime);
  }
}

/// Base class for validators that work with collections
abstract class CollectionValidator extends BaseFieldValidator {
  const CollectionValidator({
    required super.errorMessage,
    super.metadata,
  });
  
  @override
  bool isValidType(dynamic value) {
    return value is Iterable || value is Map;
  }
  
  @override
  String getTypeErrorMessage(dynamic value) {
    return 'Valor deve ser uma coleção';
  }
  
  /// Get collection length
  int getLength(dynamic value) {
    if (value is Iterable) return value.length;
    if (value is Map) return value.length;
    throw ArgumentError('Value is not a collection');
  }
  
  /// Perform validation on collection
  ValidationResult validateCollection(dynamic value, int length);
  
  @override
  ValidationResult performValidation(dynamic value) {
    final length = getLength(value);
    return validateCollection(value, length);
  }
}

/// Composite validator that combines multiple validators
class CompositeValidator extends BaseFieldValidator {
  
  const CompositeValidator({
    required this.validators,
    this.stopOnFirstError = false,
    super.errorMessage = 'Validation failed',
    super.metadata,
  });
  final List<IFieldValidator> validators;
  final bool stopOnFirstError;
  
  @override
  String get validatorType => 'composite';
  
  @override
  ValidationResult performValidation(dynamic value) {
    final errors = <String>[];
    final warnings = <String>[];
    
    for (final validator in validators) {
      final result = validator.validate(value);
      
      if (!result.isValid && result.errorMessage != null) {
        errors.add(result.errorMessage!);
        if (stopOnFirstError) {
          return ValidationResult.invalid(result.errorMessage!);
        }
      }
      
      if (result.warningMessage != null) {
        warnings.add(result.warningMessage!);
      }
    }
    
    if (errors.isNotEmpty) {
      return ValidationResult.invalid(errors.join('; '));
    }
    
    if (warnings.isNotEmpty) {
      return ValidationResult.validWithWarning(warnings.join('; '));
    }
    
    return ValidationResult.valid();
  }
  
  /// Add a validator
  CompositeValidator addValidator(IFieldValidator validator) {
    return CompositeValidator(
      validators: [...validators, validator],
      stopOnFirstError: stopOnFirstError,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }
  
  /// Remove a validator
  CompositeValidator removeValidator(IFieldValidator validator) {
    return CompositeValidator(
      validators: validators.where((v) => v != validator).toList(),
      stopOnFirstError: stopOnFirstError,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompositeValidator &&
           _listEquals(other.validators, validators) &&
           other.stopOnFirstError == stopOnFirstError;
  }
  
  @override
  int get hashCode => Object.hash(validators, stopOnFirstError);
  
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Conditional validator that only runs when a condition is met
class ConditionalValidator extends BaseFieldValidator {
  
  const ConditionalValidator({
    required this.validator,
    required this.condition,
    super.errorMessage = 'Conditional validation failed',
    super.metadata,
  });
  final IFieldValidator validator;
  final bool Function(dynamic value) condition;
  
  @override
  String get validatorType => 'conditional_${validator.validatorType}';
  
  @override
  bool shouldValidate(dynamic value) {
    return condition(value);
  }
  
  @override
  ValidationResult performValidation(dynamic value) {
    return validator.validate(value);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConditionalValidator &&
           other.validator == validator;
  }
  
  @override
  int get hashCode => validator.hashCode;
}