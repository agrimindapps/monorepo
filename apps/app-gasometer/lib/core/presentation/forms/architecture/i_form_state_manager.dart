import 'i_form_validator.dart' show FormValidationResult;

/// Interface for managing form state following Command and Observer patterns
/// 
/// This interface handles state transitions and notifications while maintaining
/// immutability and type safety. It follows Single Responsibility Principle
/// by focusing solely on state management.
/// 
/// Example usage:
/// ```dart
/// final stateManager = FormStateManager<VehicleData>();
/// stateManager.addListener((state) => print('State changed: $state'));
/// await stateManager.updateField('name', 'New Vehicle');
/// ```
abstract class IFormStateManager<T> {
  /// Get current form state (immutable)
  FormState<T> get currentState;
  
  /// Stream of state changes for reactive updates
  Stream<FormState<T>> get stateStream;
  
  /// Update a single field value
  Future<void> updateField(String fieldName, dynamic value);
  
  /// Update multiple fields at once
  Future<void> updateFields(Map<String, dynamic> fieldUpdates);
  
  /// Set the entire form data
  Future<void> setFormData(T data);
  
  /// Reset form to initial state
  Future<void> reset();
  
  /// Mark form as dirty (has unsaved changes)
  Future<void> markDirty();
  
  /// Mark form as clean (no unsaved changes)
  Future<void> markClean();
  
  /// Set loading state
  Future<void> setLoading(bool isLoading);
  
  /// Set error state
  Future<void> setError(String? error);
  
  /// Set validation state
  Future<void> setValidationResult(FormValidationResult result);
  
  /// Save current state as snapshot
  void saveSnapshot(String key);
  
  /// Restore state from snapshot
  Future<void> restoreSnapshot(String key);
  
  /// Check if form can be submitted
  bool get canSubmit;
  
  /// Check if form has unsaved changes
  bool get hasUnsavedChanges;
  
  /// Add state change listener
  void addListener(FormStateChangeListener<T> listener);
  
  /// Remove state change listener
  void removeListener(FormStateChangeListener<T> listener);
  
  /// Dispose resources
  void dispose();
}

/// Immutable form state following Value Object pattern
class FormState<T> {
  final T? data;
  final Map<String, dynamic> fieldValues;
  final bool isLoading;
  final String? error;
  final FormValidationResult? validationResult;
  final bool isDirty;
  final DateTime lastModified;
  final Map<String, dynamic> metadata;
  
  const FormState({
    this.data,
    this.fieldValues = const {},
    this.isLoading = false,
    this.error,
    this.validationResult,
    this.isDirty = false,
    required this.lastModified,
    this.metadata = const {},
  });
  
  /// Create initial form state
  factory FormState.initial({T? initialData}) {
    return FormState<T>(
      data: initialData,
      lastModified: DateTime.now(),
    );
  }
  
  /// Create loading state
  FormState<T> toLoading() {
    return copyWith(
      isLoading: true,
      error: null,
    );
  }
  
  /// Create error state
  FormState<T> toError(String error) {
    return copyWith(
      isLoading: false,
      error: error,
    );
  }
  
  /// Create state with updated field
  FormState<T> withFieldUpdate(String fieldName, dynamic value) {
    final updatedFields = Map<String, dynamic>.from(fieldValues);
    updatedFields[fieldName] = value;
    
    return copyWith(
      fieldValues: updatedFields,
      isDirty: true,
      lastModified: DateTime.now(),
    );
  }
  
  /// Create state with multiple field updates
  FormState<T> withFieldUpdates(Map<String, dynamic> updates) {
    final updatedFields = Map<String, dynamic>.from(fieldValues);
    updatedFields.addAll(updates);
    
    return copyWith(
      fieldValues: updatedFields,
      isDirty: true,
      lastModified: DateTime.now(),
    );
  }
  
  /// Create state with validation result
  FormState<T> withValidation(FormValidationResult result) {
    return copyWith(
      validationResult: result,
      lastModified: DateTime.now(),
    );
  }
  
  /// Create clean state (no unsaved changes)
  FormState<T> toClean() {
    return copyWith(
      isDirty: false,
      lastModified: DateTime.now(),
    );
  }
  
  /// Copy state with modifications
  FormState<T> copyWith({
    T? data,
    Map<String, dynamic>? fieldValues,
    bool? isLoading,
    String? error,
    FormValidationResult? validationResult,
    bool? isDirty,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
  }) {
    return FormState<T>(
      data: data ?? this.data,
      fieldValues: fieldValues ?? this.fieldValues,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      validationResult: validationResult ?? this.validationResult,
      isDirty: isDirty ?? this.isDirty,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Get value for a specific field
  dynamic getFieldValue(String fieldName) {
    return fieldValues[fieldName];
  }
  
  /// Check if a field has a value
  bool hasFieldValue(String fieldName) {
    return fieldValues.containsKey(fieldName) && 
           fieldValues[fieldName] != null;
  }
  
  /// Check if form is valid
  bool get isValid {
    return validationResult?.isValid ?? true;
  }
  
  /// Check if form can be submitted
  bool get canSubmit {
    return !isLoading && 
           error == null && 
           isValid &&
           fieldValues.isNotEmpty;
  }
  
  /// Get validation error for a field
  String? getFieldError(String fieldName) {
    return validationResult?.getFieldError(fieldName);
  }
  
  /// Check if a field is valid
  bool isFieldValid(String fieldName) {
    return validationResult?.isFieldValid(fieldName) ?? true;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is FormState<T> &&
           other.data == data &&
           _mapEquals(other.fieldValues, fieldValues) &&
           other.isLoading == isLoading &&
           other.error == error &&
           other.validationResult == validationResult &&
           other.isDirty == isDirty &&
           other.lastModified == lastModified;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      data,
      fieldValues,
      isLoading,
      error,
      validationResult,
      isDirty,
      lastModified,
    );
  }
  
  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
  
  @override
  String toString() {
    return 'FormState(isLoading: $isLoading, isDirty: $isDirty, '
           'isValid: $isValid, fieldsCount: ${fieldValues.length})';
  }
}

/// Listener for form state changes
typedef FormStateChangeListener<T> = void Function(FormState<T> newState);

