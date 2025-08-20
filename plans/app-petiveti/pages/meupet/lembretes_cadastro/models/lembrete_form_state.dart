/// Form submission state enum (standardized pattern)
enum FormSubmissionState {
  idle,
  validating, 
  loading,
  success,
  error
}

class LembreteFormState {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, String?> fieldErrors;
  final bool isSubmitting;
  final bool hasChanges;
  final FormSubmissionState submissionState;

  const LembreteFormState({
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.hasChanges = false,
    this.submissionState = FormSubmissionState.idle,
  });

  LembreteFormState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    Map<String, String?>? fieldErrors,
    bool? isSubmitting,
    bool? hasChanges,
    FormSubmissionState? submissionState,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return LembreteFormState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasChanges: hasChanges ?? this.hasChanges,
      submissionState: submissionState ?? this.submissionState,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get hasFieldErrors => fieldErrors.isNotEmpty && fieldErrors.values.any((error) => error != null);
  bool get isReady => isInitialized && !isLoading;
  bool get canSubmit => isReady && !isSubmitting && !hasFieldErrors;

  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  LembreteFormState setFieldError(String fieldName, String? error) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    if (error != null) {
      updatedErrors[fieldName] = error;
    } else {
      updatedErrors.remove(fieldName);
    }
    return copyWith(fieldErrors: updatedErrors);
  }

  LembreteFormState clearFieldError(String fieldName) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    updatedErrors.remove(fieldName);
    return copyWith(fieldErrors: updatedErrors);
  }

  LembreteFormState clearAllErrors() {
    return copyWith(
      clearErrorMessage: true,
      fieldErrors: {},
    );
  }

  LembreteFormState clearMessages() {
    return copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  LembreteFormState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  LembreteFormState setSubmitting(bool submitting) {
    return copyWith(isSubmitting: submitting);
  }

  LembreteFormState setError(String error) {
    return copyWith(
      errorMessage: error,
      isLoading: false,
      isSubmitting: false,
      clearSuccessMessage: true,
    );
  }

  LembreteFormState setSuccess(String message) {
    return copyWith(
      successMessage: message,
      isLoading: false,
      isSubmitting: false,
      hasChanges: false,
      clearErrorMessage: true,
    );
  }

  LembreteFormState setInitialized(bool initialized) {
    return copyWith(isInitialized: initialized);
  }

  LembreteFormState setHasChanges(bool changes) {
    return copyWith(hasChanges: changes);
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'isInitialized': isInitialized,
      'errorMessage': errorMessage,
      'successMessage': successMessage,
      'fieldErrors': fieldErrors,
      'isSubmitting': isSubmitting,
      'hasChanges': hasChanges,
      'submissionState': submissionState.name,
    };
  }

  factory LembreteFormState.fromJson(Map<String, dynamic> json) {
    return LembreteFormState(
      isLoading: json['isLoading'] ?? false,
      isInitialized: json['isInitialized'] ?? false,
      errorMessage: json['errorMessage'],
      successMessage: json['successMessage'],
      fieldErrors: Map<String, String?>.from(json['fieldErrors'] ?? {}),
      isSubmitting: json['isSubmitting'] ?? false,
      hasChanges: json['hasChanges'] ?? false,
      submissionState: FormSubmissionState.values.firstWhere(
        (state) => state.name == json['submissionState'],
        orElse: () => FormSubmissionState.idle,
      ),
    );
  }

  @override
  String toString() {
    return 'LembreteFormState(isLoading: $isLoading, isInitialized: $isInitialized, '
           'hasError: $hasError, hasSuccess: $hasSuccess, hasFieldErrors: $hasFieldErrors, '
           'isSubmitting: $isSubmitting, hasChanges: $hasChanges, submissionState: $submissionState)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LembreteFormState &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        _mapEquals(other.fieldErrors, fieldErrors) &&
        other.isSubmitting == isSubmitting &&
        other.hasChanges == hasChanges &&
        other.submissionState == submissionState;
  }

  bool _mapEquals(Map<String, String?> map1, Map<String, String?> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        isInitialized.hashCode ^
        errorMessage.hashCode ^
        successMessage.hashCode ^
        fieldErrors.hashCode ^
        isSubmitting.hashCode ^
        hasChanges.hashCode ^
        submissionState.hashCode;
  }
}