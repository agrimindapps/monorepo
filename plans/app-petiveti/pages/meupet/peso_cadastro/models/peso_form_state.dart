/// Form submission state enum (standardized pattern)
enum FormSubmissionState {
  idle,
  validating, 
  loading,
  success,
  error
}

class PesoFormState {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, String?> fieldErrors;
  final bool isSubmitting;
  final bool hasChanges;
  final FormSubmissionState submissionState;

  const PesoFormState({
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.hasChanges = false,
    this.submissionState = FormSubmissionState.idle,
  });

  PesoFormState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    Map<String, String?>? fieldErrors,
    bool? isSubmitting,
    bool? hasChanges,
    FormSubmissionState? submissionState,
  }) {
    return PesoFormState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      successMessage: successMessage,
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

  PesoFormState setFieldError(String fieldName, String? error) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    if (error != null) {
      updatedErrors[fieldName] = error;
    } else {
      updatedErrors.remove(fieldName);
    }
    return copyWith(fieldErrors: updatedErrors);
  }

  PesoFormState clearFieldError(String fieldName) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    updatedErrors.remove(fieldName);
    return copyWith(fieldErrors: updatedErrors);
  }

  PesoFormState clearAllErrors() {
    return copyWith(
      errorMessage: null,
      fieldErrors: {},
    );
  }

  PesoFormState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  PesoFormState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  PesoFormState setSubmitting(bool submitting) {
    return copyWith(isSubmitting: submitting);
  }

  PesoFormState setError(String error) {
    return copyWith(
      errorMessage: error,
      isLoading: false,
      isSubmitting: false,
    );
  }

  PesoFormState setSuccess(String message) {
    return copyWith(
      successMessage: message,
      isLoading: false,
      isSubmitting: false,
      hasChanges: false,
    );
  }

  PesoFormState setInitialized(bool initialized) {
    return copyWith(isInitialized: initialized);
  }

  PesoFormState setHasChanges(bool changes) {
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

  factory PesoFormState.fromJson(Map<String, dynamic> json) {
    return PesoFormState(
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
    return 'PesoFormState(isLoading: $isLoading, isInitialized: $isInitialized, '
           'hasError: $hasError, hasSuccess: $hasSuccess, hasFieldErrors: $hasFieldErrors, '
           'isSubmitting: $isSubmitting, hasChanges: $hasChanges, submissionState: $submissionState)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PesoFormState &&
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

  // Factory constructors for common states
  factory PesoFormState.initial() {
    return const PesoFormState();
  }

  factory PesoFormState.loading() {
    return const PesoFormState(isLoading: true);
  }

  factory PesoFormState.ready() {
    return const PesoFormState(isInitialized: true);
  }

  factory PesoFormState.error(String error) {
    return PesoFormState(
      isInitialized: true,
      errorMessage: error,
    );
  }

  factory PesoFormState.success(String message) {
    return PesoFormState(
      isInitialized: true,
      successMessage: message,
    );
  }

  factory PesoFormState.submitting() {
    return const PesoFormState(
      isInitialized: true,
      isSubmitting: true,
    );
  }
}