/// Interface for form validation following Single Responsibility Principle
/// 
/// This interface is focused solely on validation logic and can be easily
/// extended or replaced (Open/Closed Principle and Liskov Substitution Principle).
/// 
/// Example usage:
/// ```dart
/// final validator = FormValidatorComposite();
/// final result = await validator.validateForm(formData);
/// if (!result.isValid) {
///   print('Errors: ${result.errors}');
/// }
/// ```
abstract class IFormValidator<T> {
  /// Validate a complete form with all its fields
  /// Returns comprehensive validation result
  Future<FormValidationResult> validateForm(T formData);
  
  /// Validate a single field value
  /// Returns field-specific validation result
  ValidationResult validateField(String fieldName, dynamic value);
  
  /// Validate multiple fields at once
  /// Returns map of field names to validation results
  Map<String, ValidationResult> validateFields(Map<String, dynamic> fieldValues);
  
  /// Check if a specific field is required
  bool isFieldRequired(String fieldName);
  
  /// Get all validation rules for a field
  List<IFieldValidator> getFieldValidators(String fieldName);
  
  /// Add a validator for a specific field
  void addFieldValidator(String fieldName, IFieldValidator validator);
  
  /// Remove a validator for a specific field
  void removeFieldValidator(String fieldName, IFieldValidator validator);
  
  /// Clear all validators for a field
  void clearFieldValidators(String fieldName);
}

/// Interface for individual field validators (Strategy pattern)
abstract class IFieldValidator {
  /// Validate a single field value
  ValidationResult validate(dynamic value);
  
  /// Get validation error message
  String get errorMessage;
  
  /// Get validator type for identification
  String get validatorType;
  
  /// Check if validator should run (can be conditional)
  bool shouldValidate(dynamic value) => true;
}

/// Validation result for individual fields
class ValidationResult {
  
  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
    this.metadata = const {},
  });
  
  /// Create a successful validation result
  factory ValidationResult.valid([String? warningMessage]) {
    return ValidationResult(
      isValid: true,
      warningMessage: warningMessage,
    );
  }
  
  /// Create a failed validation result
  factory ValidationResult.invalid(String errorMessage) {
    return ValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }
  
  /// Create a validation result with warning
  factory ValidationResult.validWithWarning(String warningMessage) {
    return ValidationResult(
      isValid: true,
      warningMessage: warningMessage,
    );
  }
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;
  final Map<String, dynamic> metadata;
  
  @override
  String toString() {
    if (isValid) {
      return warningMessage != null 
          ? 'Valid (Warning: $warningMessage)'
          : 'Valid';
    }
    return 'Invalid: $errorMessage';
  }
}

/// Comprehensive validation result for entire forms
class FormValidationResult {
  
  const FormValidationResult({
    required this.isValid,
    required this.fieldResults,
    this.globalErrors = const [],
    this.globalWarnings = const [],
    this.metadata = const {},
  });
  
  /// Create a successful form validation result
  factory FormValidationResult.valid({
    Map<String, ValidationResult> fieldResults = const {},
    List<String> warnings = const [],
  }) {
    return FormValidationResult(
      isValid: true,
      fieldResults: fieldResults,
      globalWarnings: warnings,
    );
  }
  
  /// Create a failed form validation result
  factory FormValidationResult.invalid({
    required Map<String, ValidationResult> fieldResults,
    List<String> globalErrors = const [],
  }) {
    return FormValidationResult(
      isValid: false,
      fieldResults: fieldResults,
      globalErrors: globalErrors,
    );
  }
  final bool isValid;
  final Map<String, ValidationResult> fieldResults;
  final List<String> globalErrors;
  final List<String> globalWarnings;
  final Map<String, dynamic> metadata;
  
  /// Get all error messages (field + global)
  List<String> get allErrors {
    final errors = <String>[];
    errors.addAll(globalErrors);
    
    for (final result in fieldResults.values) {
      if (!result.isValid && result.errorMessage != null) {
        errors.add(result.errorMessage!);
      }
    }
    
    return errors;
  }
  
  /// Get all warning messages (field + global)
  List<String> get allWarnings {
    final warnings = <String>[];
    warnings.addAll(globalWarnings);
    
    for (final result in fieldResults.values) {
      if (result.warningMessage != null) {
        warnings.add(result.warningMessage!);
      }
    }
    
    return warnings;
  }
  
  /// Get validation result for a specific field
  ValidationResult? getFieldResult(String fieldName) {
    return fieldResults[fieldName];
  }
  
  /// Check if a specific field is valid
  bool isFieldValid(String fieldName) {
    final result = fieldResults[fieldName];
    return result?.isValid ?? true;
  }
  
  /// Get error message for a specific field
  String? getFieldError(String fieldName) {
    return fieldResults[fieldName]?.errorMessage;
  }
  
  /// Get fields that have errors
  List<String> get invalidFields {
    return fieldResults.entries
        .where((entry) => !entry.value.isValid)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Get fields that have warnings
  List<String> get fieldsWithWarnings {
    return fieldResults.entries
        .where((entry) => entry.value.warningMessage != null)
        .map((entry) => entry.key)
        .toList();
  }
  
  @override
  String toString() {
    if (isValid) {
      final warningCount = allWarnings.length;
      return warningCount > 0 
          ? 'Valid ($warningCount warnings)'
          : 'Valid';
    }
    
    final errorCount = allErrors.length;
    return 'Invalid ($errorCount errors)';
  }
}