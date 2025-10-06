import '../architecture/i_form_validator.dart';

/// Configuration for form validation rules and behavior
/// 
/// This class centralizes validation configuration and follows Single
/// Responsibility Principle by focusing solely on validation setup.
/// 
/// Example usage:
/// ```dart
/// final validationConfig = ValidationConfig()
///   .addRule('email', EmailValidator())
///   .addRule('password', LengthValidator(min: 8))
///   .setMode(ValidationMode.onInteraction);
/// ```
class ValidationConfig {
  final Map<String, List<IFieldValidator>> _fieldValidators = {};
  final List<CrossFieldValidationRule> _crossFieldRules = [];
  ValidationMode _mode = ValidationMode.onInteraction;
  bool _stopOnFirstError = false;
  bool _showWarnings = true;
  
  /// Add a validator for a specific field
  ValidationConfig addRule(String fieldKey, IFieldValidator validator) {
    _fieldValidators.putIfAbsent(fieldKey, () => []).add(validator);
    return this;
  }
  
  /// Add multiple validators for a field
  ValidationConfig addRules(String fieldKey, List<IFieldValidator> validators) {
    _fieldValidators.putIfAbsent(fieldKey, () => []).addAll(validators);
    return this;
  }
  
  /// Add a cross-field validation rule
  ValidationConfig addCrossFieldRule(CrossFieldValidationRule rule) {
    _crossFieldRules.add(rule);
    return this;
  }
  
  /// Set validation mode
  ValidationConfig setMode(ValidationMode mode) {
    _mode = mode;
    return this;
  }
  
  /// Set whether to stop validation on first error
  ValidationConfig stopOnFirstError([bool stop = true]) {
    _stopOnFirstError = stop;
    return this;
  }
  
  /// Set whether to show warnings
  ValidationConfig showWarnings([bool show = true]) {
    _showWarnings = show;
    return this;
  }
  
  /// Remove all validators for a field
  ValidationConfig clearField(String fieldKey) {
    _fieldValidators.remove(fieldKey);
    return this;
  }
  
  /// Remove a specific validator from a field
  ValidationConfig removeRule(String fieldKey, IFieldValidator validator) {
    _fieldValidators[fieldKey]?.remove(validator);
    if (_fieldValidators[fieldKey]?.isEmpty ?? false) {
      _fieldValidators.remove(fieldKey);
    }
    return this;
  }
  
  /// Get validators for a field
  List<IFieldValidator> getFieldValidators(String fieldKey) {
    return _fieldValidators[fieldKey] ?? [];
  }
  
  /// Get all cross-field rules
  List<CrossFieldValidationRule> get crossFieldRules => 
      List.unmodifiable(_crossFieldRules);
  
  /// Get validation mode
  ValidationMode get mode => _mode;
  
  /// Get stop on first error setting
  bool get shouldStopOnFirstError => _stopOnFirstError;
  
  /// Get show warnings setting
  bool get shouldShowWarnings => _showWarnings;
  
  /// Get all configured field keys
  Set<String> get configuredFields => _fieldValidators.keys.toSet();
  
  /// Check if a field has validators
  bool hasValidators(String fieldKey) {
    return _fieldValidators.containsKey(fieldKey) && 
           _fieldValidators[fieldKey]!.isNotEmpty;
  }
  
  /// Create a copy of this configuration
  ValidationConfig copy() {
    final copy = ValidationConfig()
      .setMode(_mode)
      .stopOnFirstError(_stopOnFirstError)
      .showWarnings(_showWarnings);
    for (final entry in _fieldValidators.entries) {
      copy._fieldValidators[entry.key] = List.from(entry.value);
    }
    copy._crossFieldRules.addAll(_crossFieldRules);
    
    return copy;
  }
  
  /// Merge with another validation configuration
  ValidationConfig merge(ValidationConfig other) {
    final merged = copy();
    for (final entry in other._fieldValidators.entries) {
      merged._fieldValidators.putIfAbsent(entry.key, () => [])
          .addAll(entry.value);
    }
    merged._crossFieldRules.addAll(other._crossFieldRules);
    
    return merged;
  }
  
  @override
  String toString() {
    return 'ValidationConfig(fields: ${_fieldValidators.length}, '
           'crossRules: ${_crossFieldRules.length}, mode: $_mode)';
  }
}

/// Validation mode enumeration
enum ValidationMode {
  /// Validate immediately when value changes
  onChange,
  
  /// Validate when field loses focus
  onFocusLost,
  
  /// Validate only on form submission
  onSubmit,
  
  /// Validate on both change and focus lost
  onInteraction,
  
  /// Manual validation only
  manual,
}

/// Cross-field validation rule
abstract class CrossFieldValidationRule {
  /// Fields involved in this validation
  List<String> get involvedFields;
  
  /// Validate across multiple field values
  ValidationResult validate(Map<String, dynamic> fieldValues);
  
  /// Get error message when validation fails
  String get errorMessage;
  
  /// Get rule identifier
  String get ruleId;
  
  /// Whether this rule should run (can be conditional)
  bool shouldRun(Map<String, dynamic> fieldValues) => true;
}

/// Pre-built cross-field validation rules
class CrossFieldRules {
  /// Confirm password validation
  static ConfirmPasswordRule confirmPassword({
    String passwordField = 'password',
    String confirmField = 'confirmPassword',
    String? errorMessage,
  }) {
    return ConfirmPasswordRule(
      passwordField: passwordField,
      confirmField: confirmField,
      errorMessage: errorMessage ?? 'As senhas não coincidem',
    );
  }
  
  /// Date range validation
  static DateRangeRule dateRange({
    required String startDateField,
    required String endDateField,
    String? errorMessage,
  }) {
    return DateRangeRule(
      startDateField: startDateField,
      endDateField: endDateField,
      errorMessage: errorMessage ?? 'Data final deve ser posterior à data inicial',
    );
  }
  
  /// Conditional required field
  static ConditionalRequiredRule conditionalRequired({
    required String targetField,
    required String conditionField,
    required dynamic conditionValue,
    String? errorMessage,
  }) {
    return ConditionalRequiredRule(
      targetField: targetField,
      conditionField: conditionField,
      conditionValue: conditionValue,
      errorMessage: errorMessage ?? 'Este campo é obrigatório',
    );
  }
  
  /// Numeric range validation
  static NumericRangeRule numericRange({
    required String minField,
    required String maxField,
    String? errorMessage,
  }) {
    return NumericRangeRule(
      minField: minField,
      maxField: maxField,
      errorMessage: errorMessage ?? 'Valor máximo deve ser maior que o mínimo',
    );
  }
}

/// Confirm password validation rule implementation
class ConfirmPasswordRule extends CrossFieldValidationRule {
  
  ConfirmPasswordRule({
    required this.passwordField,
    required this.confirmField,
    required String errorMessage,
  }) : _errorMessage = errorMessage;
  final String passwordField;
  final String confirmField;
  final String _errorMessage;
  
  @override
  List<String> get involvedFields => [passwordField, confirmField];
  
  @override
  ValidationResult validate(Map<String, dynamic> fieldValues) {
    final password = fieldValues[passwordField];
    final confirm = fieldValues[confirmField];
    
    if (password != null && confirm != null && password != confirm) {
      return ValidationResult.invalid(_errorMessage);
    }
    
    return ValidationResult.valid();
  }
  
  @override
  String get errorMessage => _errorMessage;
  
  @override
  String get ruleId => 'confirm_password_${passwordField}_$confirmField';
}

/// Date range validation rule implementation
class DateRangeRule extends CrossFieldValidationRule {
  
  DateRangeRule({
    required this.startDateField,
    required this.endDateField,
    required String errorMessage,
  }) : _errorMessage = errorMessage;
  final String startDateField;
  final String endDateField;
  final String _errorMessage;
  
  @override
  List<String> get involvedFields => [startDateField, endDateField];
  
  @override
  ValidationResult validate(Map<String, dynamic> fieldValues) {
    final startDate = fieldValues[startDateField] as DateTime?;
    final endDate = fieldValues[endDateField] as DateTime?;
    
    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      return ValidationResult.invalid(_errorMessage);
    }
    
    return ValidationResult.valid();
  }
  
  @override
  String get errorMessage => _errorMessage;
  
  @override
  String get ruleId => 'date_range_${startDateField}_$endDateField';
}

/// Conditional required field validation rule
class ConditionalRequiredRule extends CrossFieldValidationRule {
  
  ConditionalRequiredRule({
    required this.targetField,
    required this.conditionField,
    required this.conditionValue,
    required String errorMessage,
  }) : _errorMessage = errorMessage;
  final String targetField;
  final String conditionField;
  final dynamic conditionValue;
  final String _errorMessage;
  
  @override
  List<String> get involvedFields => [targetField, conditionField];
  
  @override
  ValidationResult validate(Map<String, dynamic> fieldValues) {
    final condition = fieldValues[conditionField];
    final target = fieldValues[targetField];
    
    if (condition == conditionValue && (target == null || target.toString().isEmpty)) {
      return ValidationResult.invalid(_errorMessage);
    }
    
    return ValidationResult.valid();
  }
  
  @override
  String get errorMessage => _errorMessage;
  
  @override
  String get ruleId => 'conditional_required_${targetField}_$conditionField';
  
  @override
  bool shouldRun(Map<String, dynamic> fieldValues) {
    return fieldValues[conditionField] == conditionValue;
  }
}

/// Numeric range validation rule
class NumericRangeRule extends CrossFieldValidationRule {
  
  NumericRangeRule({
    required this.minField,
    required this.maxField,
    required String errorMessage,
  }) : _errorMessage = errorMessage;
  final String minField;
  final String maxField;
  final String _errorMessage;
  
  @override
  List<String> get involvedFields => [minField, maxField];
  
  @override
  ValidationResult validate(Map<String, dynamic> fieldValues) {
    final minValue = _parseNumber(fieldValues[minField]);
    final maxValue = _parseNumber(fieldValues[maxField]);
    
    if (minValue != null && maxValue != null && maxValue <= minValue) {
      return ValidationResult.invalid(_errorMessage);
    }
    
    return ValidationResult.valid();
  }
  
  @override
  String get errorMessage => _errorMessage;
  
  @override
  String get ruleId => 'numeric_range_${minField}_$maxField';
  
  num? _parseNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

/// Validation configuration builder for fluent API
class ValidationConfigBuilder {
  ValidationConfig _config = ValidationConfig();
  
  /// Start building validation for a field
  FieldValidationBuilder field(String fieldKey) {
    return FieldValidationBuilder(_config, fieldKey);
  }
  
  /// Add a cross-field rule
  ValidationConfigBuilder crossField(CrossFieldValidationRule rule) {
    _config.addCrossFieldRule(rule);
    return this;
  }
  
  /// Set validation mode
  ValidationConfigBuilder mode(ValidationMode mode) {
    _config.setMode(mode);
    return this;
  }
  
  /// Configure behavior
  ValidationConfigBuilder behavior({
    bool? stopOnFirstError,
    bool? showWarnings,
  }) {
    if (stopOnFirstError != null) {
      _config.stopOnFirstError(stopOnFirstError);
    }
    if (showWarnings != null) {
      _config.showWarnings(showWarnings);
    }
    return this;
  }
  
  /// Build the final configuration
  ValidationConfig build() {
    return _config;
  }
}

/// Field validation builder for fluent API
class FieldValidationBuilder {
  
  FieldValidationBuilder(this._config, this._fieldKey);
  final ValidationConfig _config;
  final String _fieldKey;
  
  /// Add a validator to this field
  FieldValidationBuilder addValidator(IFieldValidator validator) {
    _config.addRule(_fieldKey, validator);
    return this;
  }
  
  /// Add multiple validators to this field
  FieldValidationBuilder addValidators(List<IFieldValidator> validators) {
    _config.addRules(_fieldKey, validators);
    return this;
  }
  
  /// Continue building other fields
  FieldValidationBuilder field(String fieldKey) {
    return FieldValidationBuilder(_config, fieldKey);
  }
  
  /// Add cross-field rule
  ValidationConfigBuilder crossField(CrossFieldValidationRule rule) {
    _config.addCrossFieldRule(rule);
    return ValidationConfigBuilder().._config = _config;
  }
  
  /// Build the final configuration
  ValidationConfig build() {
    return _config;
  }
}
