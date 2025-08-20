/// Simple form model for basic form validation state management
/// Used by FormStateMixin for local widget state management
class VacinaFormModel {
  final Map<String, String?> fieldErrors;
  final Map<String, bool> fieldTouched;
  final bool isSubmitting;

  const VacinaFormModel({
    this.fieldErrors = const {},
    this.fieldTouched = const {},
    this.isSubmitting = false,
  });

  VacinaFormModel copyWith({
    Map<String, String?>? fieldErrors,
    Map<String, bool>? fieldTouched,
    bool? isSubmitting,
  }) {
    return VacinaFormModel(
      fieldErrors: fieldErrors ?? this.fieldErrors,
      fieldTouched: fieldTouched ?? this.fieldTouched,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  /// Check if form has any validation errors
  bool get isFormValid => fieldErrors.isEmpty;

  /// Check if a field has been touched
  bool isFieldTouched(String fieldName) => fieldTouched[fieldName] ?? false;

  /// Get error message for a field
  String? getFieldError(String fieldName) => fieldErrors[fieldName];

  /// Check if field should show error (touched and has error)
  bool shouldShowError(String fieldName) =>
      isFieldTouched(fieldName) && fieldErrors.containsKey(fieldName);

  /// Validate a single field (basic validation - override in subclasses for specific rules)
  VacinaFormModel validateField(String fieldName, String? value) {
    final newErrors = Map<String, String?>.from(fieldErrors);

    // Basic validation rules
    switch (fieldName) {
      case 'nomeVacina':
        if (value == null || value.trim().isEmpty) {
          newErrors[fieldName] = 'O nome da vacina é obrigatório';
        } else if (value.trim().length < 2) {
          newErrors[fieldName] =
              'O nome da vacina deve ter pelo menos 2 caracteres';
        } else if (value.trim().length > 100) {
          newErrors[fieldName] =
              'O nome da vacina deve ter no máximo 100 caracteres';
        } else {
          newErrors.remove(fieldName);
        }
        break;
      case 'observacoes':
        if (value != null && value.length > 500) {
          newErrors[fieldName] =
              'Observações devem ter no máximo 500 caracteres';
        } else {
          newErrors.remove(fieldName);
        }
        break;
      default:
        // No validation for unknown fields
        break;
    }

    return copyWith(fieldErrors: newErrors);
  }

  /// Mark a field as touched
  VacinaFormModel markFieldTouched(String fieldName) {
    final newTouched = Map<String, bool>.from(fieldTouched);
    newTouched[fieldName] = true;
    return copyWith(fieldTouched: newTouched);
  }

  /// Set specific field error
  VacinaFormModel setFieldError(String fieldName, String? error) {
    final newErrors = Map<String, String?>.from(fieldErrors);
    if (error != null) {
      newErrors[fieldName] = error;
    } else {
      newErrors.remove(fieldName);
    }
    return copyWith(fieldErrors: newErrors);
  }

  /// Clear all errors
  VacinaFormModel clearAllErrors() {
    return copyWith(fieldErrors: {});
  }

  /// Reset form to initial state
  VacinaFormModel reset() {
    return const VacinaFormModel();
  }
}
