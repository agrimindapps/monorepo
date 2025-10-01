/// Extended validation results and utilities
/// 
/// This module provides extended validation result classes and utilities
/// following the Single Responsibility Principle.
library;

import '../architecture/i_form_validator.dart';

/// Extended validation result with additional metadata
class ExtendedValidationResult extends ValidationResult {
  
  const ExtendedValidationResult({
    required super.isValid,
    super.errorMessage,
    super.warningMessage,
    super.metadata,
    this.fieldName,
    required this.timestamp,
    this.validatorType,
    this.context = const {},
  });
  
  /// Create successful extended validation result
  factory ExtendedValidationResult.valid({
    String? fieldName,
    String? warningMessage,
    String? validatorType,
    Map<String, dynamic> context = const {},
  }) {
    return ExtendedValidationResult(
      isValid: true,
      fieldName: fieldName,
      timestamp: DateTime.now(),
      warningMessage: warningMessage,
      validatorType: validatorType,
      context: context,
    );
  }
  
  /// Create failed extended validation result
  factory ExtendedValidationResult.invalid({
    required String errorMessage,
    String? fieldName,
    String? validatorType,
    Map<String, dynamic> context = const {},
  }) {
    return ExtendedValidationResult(
      isValid: false,
      errorMessage: errorMessage,
      fieldName: fieldName,
      timestamp: DateTime.now(),
      validatorType: validatorType,
      context: context,
    );
  }
  final String? fieldName;
  final DateTime timestamp;
  final String? validatorType;
  final Map<String, dynamic> context;
  
  /// Convert to base ValidationResult
  ValidationResult toValidationResult() {
    return ValidationResult(
      isValid: isValid,
      errorMessage: errorMessage,
      warningMessage: warningMessage,
      metadata: {
        ...metadata,
        'fieldName': fieldName,
        'timestamp': timestamp.toIso8601String(),
        'validatorType': validatorType,
        ...context,
      },
    );
  }
  
  @override
  String toString() {
    final baseString = super.toString();
    final details = <String>[];
    
    if (fieldName != null) details.add('field: $fieldName');
    if (validatorType != null) details.add('validator: $validatorType');
    
    if (details.isEmpty) return baseString;
    return '$baseString (${details.join(', ')})';
  }
}

/// Validation result aggregator for combining multiple results
class ValidationResultAggregator {
  final List<ValidationResult> _results = [];
  
  /// Add a validation result
  void add(ValidationResult result) {
    _results.add(result);
  }
  
  /// Add multiple validation results
  void addAll(List<ValidationResult> results) {
    _results.addAll(results);
  }
  
  /// Get all results
  List<ValidationResult> get results => List.unmodifiable(_results);
  
  /// Check if all results are valid
  bool get isAllValid => _results.every((result) => result.isValid);
  
  /// Check if any result is invalid
  bool get hasErrors => _results.any((result) => !result.isValid);
  
  /// Check if any result has warnings
  bool get hasWarnings => _results.any((result) => result.warningMessage != null);
  
  /// Get all error messages
  List<String> get errorMessages {
    return _results
        .where((result) => !result.isValid && result.errorMessage != null)
        .map((result) => result.errorMessage!)
        .toList();
  }
  
  /// Get all warning messages
  List<String> get warningMessages {
    return _results
        .where((result) => result.warningMessage != null)
        .map((result) => result.warningMessage!)
        .toList();
  }
  
  /// Get first error message
  String? get firstError {
    final errors = errorMessages;
    return errors.isNotEmpty ? errors.first : null;
  }
  
  /// Get first warning message
  String? get firstWarning {
    final warnings = warningMessages;
    return warnings.isNotEmpty ? warnings.first : null;
  }
  
  /// Create a combined validation result
  ValidationResult toCombinedResult() {
    if (isAllValid) {
      final warning = firstWarning;
      return warning != null 
          ? ValidationResult.validWithWarning(warning)
          : ValidationResult.valid();
    }
    
    final error = firstError ?? 'Validation failed';
    return ValidationResult.invalid(error);
  }
  
  /// Create a form validation result
  FormValidationResult toFormResult({
    Map<String, ValidationResult> fieldResults = const {},
    List<String> globalErrors = const [],
    List<String> globalWarnings = const [],
  }) {
    final allErrors = [...globalErrors, ...errorMessages];
    final allWarnings = [...globalWarnings, ...warningMessages];
    
    return FormValidationResult(
      isValid: isAllValid && allErrors.isEmpty,
      fieldResults: fieldResults,
      globalErrors: allErrors,
      globalWarnings: allWarnings,
    );
  }
  
  /// Clear all results
  void clear() {
    _results.clear();
  }
  
  /// Get count of results
  int get count => _results.length;
  
  /// Check if aggregator is empty
  bool get isEmpty => _results.isEmpty;
  
  /// Check if aggregator has results
  bool get isNotEmpty => _results.isNotEmpty;
  
  @override
  String toString() {
    if (isEmpty) return 'ValidationResultAggregator(empty)';
    
    final validCount = _results.where((r) => r.isValid).length;
    final invalidCount = _results.length - validCount;
    
    return 'ValidationResultAggregator(total: ${_results.length}, '
           'valid: $validCount, invalid: $invalidCount)';
  }
}

/// Validation result builder for complex validation scenarios
class ValidationResultBuilder {
  bool _isValid = true;
  String? _errorMessage;
  String? _warningMessage;
  String? _fieldName;
  String? _validatorType;
  final Map<String, dynamic> _metadata = {};
  final Map<String, dynamic> _context = {};
  
  /// Set validation as successful
  ValidationResultBuilder valid() {
    _isValid = true;
    return this;
  }
  
  /// Set validation as failed with error message
  ValidationResultBuilder invalid(String errorMessage) {
    _isValid = false;
    _errorMessage = errorMessage;
    return this;
  }
  
  /// Add a warning message
  ValidationResultBuilder warning(String warningMessage) {
    _warningMessage = warningMessage;
    return this;
  }
  
  /// Set field name
  ValidationResultBuilder forField(String fieldName) {
    _fieldName = fieldName;
    return this;
  }
  
  /// Set validator type
  ValidationResultBuilder fromValidator(String validatorType) {
    _validatorType = validatorType;
    return this;
  }
  
  /// Add metadata
  ValidationResultBuilder withMetadata(String key, dynamic value) {
    _metadata[key] = value;
    return this;
  }
  
  /// Add multiple metadata entries
  ValidationResultBuilder withMetadataMap(Map<String, dynamic> metadata) {
    _metadata.addAll(metadata);
    return this;
  }
  
  /// Add context information
  ValidationResultBuilder withContext(String key, dynamic value) {
    _context[key] = value;
    return this;
  }
  
  /// Add multiple context entries
  ValidationResultBuilder withContextMap(Map<String, dynamic> context) {
    _context.addAll(context);
    return this;
  }
  
  /// Build a basic validation result
  ValidationResult build() {
    return ValidationResult(
      isValid: _isValid,
      errorMessage: _errorMessage,
      warningMessage: _warningMessage,
      metadata: {
        ..._metadata,
        if (_fieldName != null) 'fieldName': _fieldName,
        if (_validatorType != null) 'validatorType': _validatorType,
        ..._context,
      },
    );
  }
  
  /// Build an extended validation result
  ExtendedValidationResult buildExtended() {
    return ExtendedValidationResult(
      isValid: _isValid,
      errorMessage: _errorMessage,
      warningMessage: _warningMessage,
      metadata: _metadata,
      fieldName: _fieldName,
      timestamp: DateTime.now(),
      validatorType: _validatorType,
      context: _context,
    );
  }
  
  /// Reset the builder for reuse
  ValidationResultBuilder reset() {
    _isValid = true;
    _errorMessage = null;
    _warningMessage = null;
    _fieldName = null;
    _validatorType = null;
    _metadata.clear();
    _context.clear();
    return this;
  }
}