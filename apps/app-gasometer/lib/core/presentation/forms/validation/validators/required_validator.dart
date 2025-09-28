import '../../architecture/i_form_validator.dart';
import 'base_validator.dart';

/// Validator for required fields
/// 
/// This validator ensures that a field has a non-null, non-empty value.
/// It follows Single Responsibility Principle by focusing solely on
/// required field validation.
class RequiredValidator extends BaseFieldValidator {
  
  const RequiredValidator({
    super.errorMessage = 'Este campo é obrigatório',
    this.trimWhitespace = true,
    this.treatZeroAsEmpty = false,
    this.treatEmptyCollectionAsEmpty = true,
    super.metadata,
  });
  
  /// Create a required validator with custom message
  factory RequiredValidator.withMessage(String message) {
    return RequiredValidator(errorMessage: message);
  }
  
  /// Create a required validator for specific field
  factory RequiredValidator.forField(String fieldName) {
    return RequiredValidator(
      errorMessage: '$fieldName é obrigatório',
    );
  }
  
  /// Create a strict required validator (zero and empty collections are invalid)
  factory RequiredValidator.strict({String? errorMessage}) {
    return RequiredValidator(
      errorMessage: errorMessage ?? 'Este campo é obrigatório',
      treatZeroAsEmpty: true,
      treatEmptyCollectionAsEmpty: true,
    );
  }
  
  /// Create a lenient required validator (zero and empty collections are valid)
  factory RequiredValidator.lenient({String? errorMessage}) {
    return RequiredValidator(
      errorMessage: errorMessage ?? 'Este campo é obrigatório',
      treatZeroAsEmpty: false,
      treatEmptyCollectionAsEmpty: false,
    );
  }
  /// Whether to trim whitespace before validation (for strings)
  final bool trimWhitespace;
  
  /// Whether to consider zero as empty for numeric values
  final bool treatZeroAsEmpty;
  
  /// Whether to consider empty collections as invalid
  final bool treatEmptyCollectionAsEmpty;
  
  @override
  String get validatorType => 'required';
  
  @override
  ValidationResult handleNullOrEmpty(dynamic value) {
    // Null values are always invalid for required fields
    if (value == null) {
      return ValidationResult.invalid(errorMessage);
    }
    
    // Empty strings are invalid
    if (value is String) {
      final stringValue = trimWhitespace ? value.trim() : value;
      if (stringValue.isEmpty) {
        return ValidationResult.invalid(errorMessage);
      }
    }
    
    return ValidationResult.invalid(errorMessage);
  }
  
  @override
  ValidationResult performValidation(dynamic value) {
    // String validation
    if (value is String) {
      final stringValue = trimWhitespace ? value.trim() : value;
      if (stringValue.isEmpty) {
        return ValidationResult.invalid(errorMessage);
      }
      return ValidationResult.valid();
    }
    
    // Numeric validation
    if (value is num) {
      if (treatZeroAsEmpty && value == 0) {
        return ValidationResult.invalid(errorMessage);
      }
      return ValidationResult.valid();
    }
    
    // Collection validation
    if (value is Iterable || value is Map) {
      if (treatEmptyCollectionAsEmpty && getLength(value) == 0) {
        return ValidationResult.invalid(errorMessage);
      }
      return ValidationResult.valid();
    }
    
    // Boolean validation (false is considered valid)
    if (value is bool) {
      return ValidationResult.valid();
    }
    
    // Any other non-null value is considered valid
    return ValidationResult.valid();
  }
  
  /// Helper method to get collection length
  int getLength(dynamic value) {
    if (value is Iterable) return value.length;
    if (value is Map) return value.length;
    return 0;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RequiredValidator &&
           other.errorMessage == errorMessage &&
           other.trimWhitespace == trimWhitespace &&
           other.treatZeroAsEmpty == treatZeroAsEmpty &&
           other.treatEmptyCollectionAsEmpty == treatEmptyCollectionAsEmpty;
  }
  
  @override
  int get hashCode => Object.hash(
    validatorType,
    errorMessage,
    trimWhitespace,
    treatZeroAsEmpty,
    treatEmptyCollectionAsEmpty,
  );
}

/// Conditional required validator
/// 
/// This validator makes a field required based on a condition.
/// Useful for form fields that become required based on other field values.
class ConditionalRequiredValidator extends BaseFieldValidator {
  
  const ConditionalRequiredValidator({
    required this.isRequired,
    super.errorMessage = 'Este campo é obrigatório',
    this.trimWhitespace = true,
    super.metadata,
  });
  
  /// Create conditional required validator based on another field value
  factory ConditionalRequiredValidator.dependsOn({
    required dynamic Function() getValue,
    required dynamic requiredWhenValue,
    String? errorMessage,
  }) {
    return ConditionalRequiredValidator(
      isRequired: () => getValue() == requiredWhenValue,
      errorMessage: errorMessage ?? 'Este campo é obrigatório',
    );
  }
  
  /// Create conditional required validator based on multiple conditions
  factory ConditionalRequiredValidator.when({
    required bool Function() condition,
    String? errorMessage,
  }) {
    return ConditionalRequiredValidator(
      isRequired: condition,
      errorMessage: errorMessage ?? 'Este campo é obrigatório',
    );
  }
  /// Function that determines if the field should be required
  final bool Function() isRequired;
  
  /// Whether to trim whitespace before validation (for strings)
  final bool trimWhitespace;
  
  @override
  String get validatorType => 'conditional_required';
  
  @override
  bool shouldValidate(dynamic value) {
    return isRequired();
  }
  
  @override
  ValidationResult handleNullOrEmpty(dynamic value) {
    if (!isRequired()) {
      return ValidationResult.valid();
    }
    
    // Apply same logic as RequiredValidator
    return RequiredValidator(
      errorMessage: errorMessage,
      trimWhitespace: trimWhitespace,
    ).validate(value);
  }
  
  @override
  ValidationResult performValidation(dynamic value) {
    if (!isRequired()) {
      return ValidationResult.valid();
    }
    
    // Apply same logic as RequiredValidator
    return RequiredValidator(
      errorMessage: errorMessage,
      trimWhitespace: trimWhitespace,
    ).validate(value);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // Note: Cannot compare function equality, so we compare other properties
    return other is ConditionalRequiredValidator &&
           other.errorMessage == errorMessage &&
           other.trimWhitespace == trimWhitespace;
  }
  
  @override
  int get hashCode => Object.hash(
    validatorType,
    errorMessage,
    trimWhitespace,
  );
}

/// Required validator for collections with minimum count
class MinCountRequiredValidator extends CollectionValidator {
  
  const MinCountRequiredValidator({
    required this.minCount,
    String? errorMessage,
    super.metadata,
  }) : super(
    errorMessage: errorMessage ?? 'Selecione pelo menos $minCount item(s)',
  );
  
  /// Create validator with custom error message
  factory MinCountRequiredValidator.withMessage({
    required int minCount,
    required String errorMessage,
  }) {
    return MinCountRequiredValidator(
      minCount: minCount,
      errorMessage: errorMessage,
    );
  }
  final int minCount;
  
  @override
  String get validatorType => 'min_count_required';
  
  @override
  ValidationResult validateCollection(dynamic value, int length) {
    if (length < minCount) {
      return ValidationResult.invalid(errorMessage);
    }
    return ValidationResult.valid();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MinCountRequiredValidator &&
           other.minCount == minCount &&
           other.errorMessage == errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(validatorType, minCount, errorMessage);
}