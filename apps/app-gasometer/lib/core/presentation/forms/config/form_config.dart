import '../architecture/i_field_factory.dart';
import '../architecture/i_form_builder.dart' show FormValidationMode;
import '../architecture/i_form_validator.dart';

/// Abstract base class for form configurations following Template Method pattern
/// 
/// This class defines the structure for all form configurations while allowing
/// subclasses to provide specific implementations. It follows Open/Closed
/// Principle by being open for extension but closed for modification.
/// 
/// Example usage:
/// ```dart
/// class VehicleFormConfig extends FormConfig<VehicleData> {
///   @override
///   String get formId => 'vehicle_form';
///   
///   @override
///   List<FieldConfig> buildFields() => [
///     TextFieldConfig(key: 'name', label: 'Nome'),
///     TextFieldConfig(key: 'plate', label: 'Placa'),
///   ];
/// }
/// ```
abstract class FormConfig<T> {
  /// Unique identifier for this form configuration
  String get formId;
  
  /// Human-readable title for the form
  String get title;
  
  /// Optional subtitle or description
  String? get subtitle => null;
  
  /// Form validation mode
  FormValidationMode get validationMode => FormValidationMode.onInteraction;
  
  /// Whether to enable auto-save functionality
  bool get autoSaveEnabled => false;
  
  /// Auto-save interval in milliseconds
  int get autoSaveInterval => 30000; // 30 seconds
  
  /// Whether form can be submitted when offline
  bool get allowOfflineSubmission => false;
  
  /// Maximum number of retry attempts for submission
  int get maxRetryAttempts => 3;
  
  /// Form-specific metadata
  Map<String, dynamic> get metadata => const {};
  
  /// Build the list of field configurations
  List<FieldConfig> buildFields();
  
  /// Build validation rules for the form
  List<IFieldValidator> buildValidators() => [];
  
  /// Build cross-field validation rules
  List<FormCrossValidator<T>> buildCrossValidators() => [];
  
  /// Get field configuration by key
  FieldConfig? getFieldConfig(String fieldKey) {
    final fields = buildFields();
    try {
      return fields.firstWhere((field) => field.key == fieldKey);
    } catch (e) {
      return null;
    }
  }
  
  /// Get all field keys in order
  List<String> get fieldKeys {
    return buildFields().map((field) => field.key).toList();
  }
  
  /// Check if a field exists in this form
  bool hasField(String fieldKey) {
    return getFieldConfig(fieldKey) != null;
  }
  
  /// Get required field keys
  List<String> get requiredFields {
    return buildFields()
        .where((field) => field.isRequired)
        .map((field) => field.key)
        .toList();
  }
  
  /// Transform form data before validation
  T? transformDataForValidation(Map<String, dynamic> fieldValues) => null;
  
  /// Transform form data before submission
  Map<String, dynamic> transformDataForSubmission(T data) {
    // Default implementation returns empty map
    // Subclasses should override this method
    return {};
  }
  
  /// Handle form submission logic
  Future<FormSubmissionResult<T>> submitForm(T data) async {
    // Default implementation - subclasses should override
    throw UnimplementedError('Form submission must be implemented by subclass');
  }
  
  /// Handle form data loading (for edit mode)
  Future<T?> loadFormData(String? id) async {
    // Default implementation - subclasses can override
    return null;
  }
  
  /// Validate form configuration (called during development)
  List<String> validateConfiguration() {
    final errors = <String>[];
    
    // Check for duplicate field keys
    final fields = buildFields();
    final fieldKeys = fields.map((f) => f.key).toList();
    final uniqueKeys = fieldKeys.toSet();
    if (fieldKeys.length != uniqueKeys.length) {
      errors.add('Duplicate field keys found in form configuration');
    }
    
    // Check for empty field keys
    if (fields.any((f) => f.key.isEmpty)) {
      errors.add('Field keys cannot be empty');
    }
    
    // Check form ID
    if (formId.isEmpty) {
      errors.add('Form ID cannot be empty');
    }
    
    // Check title
    if (title.isEmpty) {
      errors.add('Form title cannot be empty');
    }
    
    return errors;
  }
  
  /// Create a copy of this configuration with modifications
  FormConfig<T> copyWith({
    FormValidationMode? validationMode,
    bool? autoSaveEnabled,
    int? autoSaveInterval,
    bool? allowOfflineSubmission,
    int? maxRetryAttempts,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormConfig<T> && other.formId == formId;
  }
  
  @override
  int get hashCode => formId.hashCode;
  
  @override
  String toString() => 'FormConfig(id: $formId, title: $title)';
}

/// Cross-field validator for complex validation rules
abstract class FormCrossValidator<T> {
  /// Validate across multiple fields
  ValidationResult validate(T data, Map<String, dynamic> fieldValues);
  
  /// Get validation error message
  String get errorMessage;
  
  /// Get fields involved in this validation
  List<String> get involvedFields;
}

/// Result of form submission
class FormSubmissionResult<T> {
  
  const FormSubmissionResult({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.metadata = const {},
  });
  
  /// Create successful submission result
  factory FormSubmissionResult.success(T data, {Map<String, dynamic>? metadata}) {
    return FormSubmissionResult<T>(
      isSuccess: true,
      data: data,
      metadata: metadata ?? {},
    );
  }
  
  /// Create failed submission result
  factory FormSubmissionResult.failure(String errorMessage, {Map<String, dynamic>? metadata}) {
    return FormSubmissionResult<T>(
      isSuccess: false,
      errorMessage: errorMessage,
      metadata: metadata ?? {},
    );
  }
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final Map<String, dynamic> metadata;
  
  @override
  String toString() {
    if (isSuccess) {
      return 'FormSubmissionResult.success(data: $data)';
    }
    return 'FormSubmissionResult.failure(error: $errorMessage)';
  }
}

