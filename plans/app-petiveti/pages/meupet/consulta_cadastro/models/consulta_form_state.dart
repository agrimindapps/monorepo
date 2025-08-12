class ConsultaFormState {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, String?> fieldErrors;
  final bool isSubmitting;
  final bool hasChanges;

  const ConsultaFormState({
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.hasChanges = false,
  });

  ConsultaFormState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    Map<String, String?>? fieldErrors,
    bool? isSubmitting,
    bool? hasChanges,
  }) {
    return ConsultaFormState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      successMessage: successMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get hasFieldErrors =>
      fieldErrors.isNotEmpty &&
      fieldErrors.values.any((error) => error != null);
  bool get isReady => isInitialized && !isLoading;
  bool get canSubmit => isReady && !isSubmitting && !hasFieldErrors;

  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  ConsultaFormState setFieldError(String fieldName, String? error) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    if (error != null) {
      updatedErrors[fieldName] = error;
    } else {
      updatedErrors.remove(fieldName);
    }
    return copyWith(fieldErrors: updatedErrors);
  }

  ConsultaFormState setFieldErrors(Map<String, String?> errors) {
    return copyWith(fieldErrors: Map<String, String?>.from(errors));
  }

  ConsultaFormState clearFieldError(String fieldName) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    updatedErrors.remove(fieldName);
    return copyWith(fieldErrors: updatedErrors);
  }

  ConsultaFormState clearAllErrors() {
    return copyWith(
      errorMessage: null,
      fieldErrors: {},
    );
  }

  ConsultaFormState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  ConsultaFormState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  ConsultaFormState setSubmitting(bool submitting) {
    return copyWith(isSubmitting: submitting);
  }

  ConsultaFormState setError(String? error) {
    return copyWith(
      errorMessage: error,
      isLoading: false,
      isSubmitting: false,
    );
  }

  ConsultaFormState setSuccess(String message) {
    return copyWith(
      successMessage: message,
      isLoading: false,
      isSubmitting: false,
      hasChanges: false,
    );
  }

  ConsultaFormState setInitialized(bool initialized) {
    return copyWith(isInitialized: initialized);
  }

  ConsultaFormState setHasChanges(bool changes) {
    return copyWith(hasChanges: changes);
  }

  ConsultaFormState clearError() {
    return copyWith(errorMessage: null);
  }

  ConsultaFormState clearSuccess() {
    return copyWith(successMessage: null);
  }

  ConsultaFormState reset() {
    return const ConsultaFormState(isInitialized: true);
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
    };
  }

  factory ConsultaFormState.fromJson(Map<String, dynamic> json) {
    return ConsultaFormState(
      isLoading: json['isLoading'] ?? false,
      isInitialized: json['isInitialized'] ?? false,
      errorMessage: json['errorMessage'],
      successMessage: json['successMessage'],
      fieldErrors: Map<String, String?>.from(json['fieldErrors'] ?? {}),
      isSubmitting: json['isSubmitting'] ?? false,
      hasChanges: json['hasChanges'] ?? false,
    );
  }

  @override
  String toString() {
    return 'ConsultaFormState(isLoading: $isLoading, isInitialized: $isInitialized, '
        'hasError: $hasError, hasSuccess: $hasSuccess, hasFieldErrors: $hasFieldErrors, '
        'isSubmitting: $isSubmitting, hasChanges: $hasChanges)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConsultaFormState &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        _mapEquals(other.fieldErrors, fieldErrors) &&
        other.isSubmitting == isSubmitting &&
        other.hasChanges == hasChanges;
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
        hasChanges.hashCode;
  }

  // Factory constructors for common states
  factory ConsultaFormState.initial() {
    return const ConsultaFormState();
  }

  factory ConsultaFormState.loading() {
    return const ConsultaFormState(isLoading: true);
  }

  factory ConsultaFormState.ready() {
    return const ConsultaFormState(isInitialized: true);
  }

  factory ConsultaFormState.error(String error) {
    return ConsultaFormState(
      isInitialized: true,
      errorMessage: error,
    );
  }

  factory ConsultaFormState.success(String message) {
    return ConsultaFormState(
      isInitialized: true,
      successMessage: message,
    );
  }

  factory ConsultaFormState.submitting() {
    return const ConsultaFormState(
      isInitialized: true,
      isSubmitting: true,
    );
  }
}
