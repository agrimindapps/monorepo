/// Interface for building forms following the Builder pattern
/// 
/// This interface enforces Single Responsibility Principle (SRP) by focusing 
/// solely on form construction. It follows Interface Segregation Principle (ISP)
/// by being small and specific.
/// 
/// Example usage:
/// ```dart
/// final builder = VehicleFormBuilder();
/// final form = await builder
///   .withConfig(vehicleConfig)
///   .withInitialData(vehicle)
///   .build();
/// ```
abstract class IFormBuilder<TConfig, TData> {
  /// Configure the form with specific settings
  /// Returns builder for method chaining
  IFormBuilder<TConfig, TData> withConfig(TConfig config);
  
  /// Set initial data for form fields
  /// Returns builder for method chaining
  IFormBuilder<TConfig, TData> withInitialData(TData? initialData);
  
  /// Set validation mode for the form
  /// Returns builder for method chaining
  IFormBuilder<TConfig, TData> withValidationMode(FormValidationMode mode);
  
  /// Enable or disable auto-save functionality
  /// Returns builder for method chaining
  IFormBuilder<TConfig, TData> withAutoSave(bool enabled);
  
  /// Build the configured form
  /// Returns the constructed form widget
  Future<FormResult> build();
}

/// Validation mode for forms
enum FormValidationMode {
  /// Validate on value change
  onChange,
  
  /// Validate on focus lost
  onFocusLost,
  
  /// Validate only on submit
  onSubmit,
  
  /// Validate on interaction (change + focus lost)
  onInteraction,
}

/// Result of form building operation
class FormResult {
  final dynamic formWidget;
  final String formId;
  final Map<String, dynamic> metadata;
  
  const FormResult({
    required this.formWidget,
    required this.formId,
    this.metadata = const {},
  });
  
  /// Create a successful form result
  factory FormResult.success({
    required dynamic formWidget,
    required String formId,
    Map<String, dynamic> metadata = const {},
  }) {
    return FormResult(
      formWidget: formWidget,
      formId: formId,
      metadata: metadata,
    );
  }
  
  /// Create a failed form result
  factory FormResult.failure({
    required String error,
    Map<String, dynamic> metadata = const {},
  }) {
    return FormResult(
      formWidget: null,
      formId: '',
      metadata: {'error': error, ...metadata},
    );
  }
  
  /// Check if form building was successful
  bool get isSuccess => formWidget != null && formId.isNotEmpty;
  
  /// Get error message if building failed
  String? get error => metadata['error'] as String?;
}