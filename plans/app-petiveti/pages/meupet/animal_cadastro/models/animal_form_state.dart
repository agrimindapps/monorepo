/// Represents the current state of the form submission process
enum FormSubmissionState {
  /// Form is idle, ready for user input
  idle,

  /// Form is being validated
  validating,

  /// Form is being submitted to the server
  loading,

  /// Form submission completed successfully
  success,

  /// Form submission failed with an error
  error
}

class AnimalFormState {
  final FormSubmissionState submissionState;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, String?> fieldErrors;
  final bool hasChanges;
  final bool isEditMode;

  const AnimalFormState({
    this.submissionState = FormSubmissionState.idle,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.fieldErrors = const {},
    this.hasChanges = false,
    this.isEditMode = false,
  });

  AnimalFormState copyWith({
    FormSubmissionState? submissionState,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    Map<String, String?>? fieldErrors,
    bool? hasChanges,
    bool? isEditMode,
  }) {
    return AnimalFormState(
      submissionState: submissionState ?? this.submissionState,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      successMessage: successMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      hasChanges: hasChanges ?? this.hasChanges,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  // Getters for common state checks
  bool get isIdle => submissionState == FormSubmissionState.idle;
  bool get isValidating => submissionState == FormSubmissionState.validating;
  bool get isSubmitting => submissionState == FormSubmissionState.loading;
  bool get isSuccess => submissionState == FormSubmissionState.success;
  bool get isError => submissionState == FormSubmissionState.error;
  bool get hasError => errorMessage != null || isError;
  bool get hasSuccess => successMessage != null || isSuccess;
  bool get hasFieldErrors =>
      fieldErrors.isNotEmpty &&
      fieldErrors.values.any((error) => error != null);
  bool get isReady => isInitialized && !isLoading;
  bool get canSubmit => isReady && !hasFieldErrors && hasChanges;

  // State management methods
  AnimalFormState setSubmissionState(FormSubmissionState state) {
    return copyWith(submissionState: state);
  }

  AnimalFormState setLoading(bool loading) {
    return copyWith(
      isLoading: loading,
      submissionState:
          loading ? FormSubmissionState.loading : FormSubmissionState.idle,
    );
  }

  AnimalFormState setValidating(bool validating) {
    return copyWith(
      submissionState: validating
          ? FormSubmissionState.validating
          : FormSubmissionState.idle,
    );
  }

  AnimalFormState setError(String? error) {
    return copyWith(
      errorMessage: error,
      submissionState:
          error != null ? FormSubmissionState.error : FormSubmissionState.idle,
      isLoading: false,
    );
  }

  AnimalFormState setSuccess(String message) {
    return copyWith(
      successMessage: message,
      submissionState: FormSubmissionState.success,
      isLoading: false,
      hasChanges: false,
    );
  }

  AnimalFormState setInitialized(bool initialized) {
    return copyWith(isInitialized: initialized);
  }

  AnimalFormState setHasChanges(bool changes) {
    return copyWith(hasChanges: changes);
  }

  AnimalFormState setEditMode(bool editMode) {
    return copyWith(isEditMode: editMode);
  }

  AnimalFormState setFieldError(String fieldName, String? error) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    if (error != null) {
      updatedErrors[fieldName] = error;
    } else {
      updatedErrors.remove(fieldName);
    }
    return copyWith(fieldErrors: updatedErrors);
  }

  AnimalFormState setFieldErrors(Map<String, String?> errors) {
    return copyWith(fieldErrors: Map<String, String?>.from(errors));
  }

  AnimalFormState clearFieldError(String fieldName) {
    final updatedErrors = Map<String, String?>.from(fieldErrors);
    updatedErrors.remove(fieldName);
    return copyWith(fieldErrors: updatedErrors);
  }

  AnimalFormState clearAllErrors() {
    return copyWith(
      errorMessage: null,
      fieldErrors: {},
      submissionState: FormSubmissionState.idle,
    );
  }

  AnimalFormState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  AnimalFormState reset() {
    return const AnimalFormState(isInitialized: true);
  }

  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionState': submissionState.toString(),
      'isLoading': isLoading,
      'isInitialized': isInitialized,
      'errorMessage': errorMessage,
      'successMessage': successMessage,
      'fieldErrors': fieldErrors,
      'hasChanges': hasChanges,
      'isEditMode': isEditMode,
    };
  }

  factory AnimalFormState.fromJson(Map<String, dynamic> json) {
    return AnimalFormState(
      submissionState: FormSubmissionState.values.firstWhere(
        (e) => e.toString() == json['submissionState'],
        orElse: () => FormSubmissionState.idle,
      ),
      isLoading: json['isLoading'] ?? false,
      isInitialized: json['isInitialized'] ?? false,
      errorMessage: json['errorMessage'],
      successMessage: json['successMessage'],
      fieldErrors: Map<String, String?>.from(json['fieldErrors'] ?? {}),
      hasChanges: json['hasChanges'] ?? false,
      isEditMode: json['isEditMode'] ?? false,
    );
  }

  @override
  String toString() {
    return 'AnimalFormState(submissionState: $submissionState, isLoading: $isLoading, '
        'isInitialized: $isInitialized, hasError: $hasError, hasSuccess: $hasSuccess, '
        'hasFieldErrors: $hasFieldErrors, hasChanges: $hasChanges, isEditMode: $isEditMode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimalFormState &&
        other.submissionState == submissionState &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        _mapEquals(other.fieldErrors, fieldErrors) &&
        other.hasChanges == hasChanges &&
        other.isEditMode == isEditMode;
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
    return submissionState.hashCode ^
        isLoading.hashCode ^
        isInitialized.hashCode ^
        errorMessage.hashCode ^
        successMessage.hashCode ^
        fieldErrors.hashCode ^
        hasChanges.hashCode ^
        isEditMode.hashCode;
  }

  // Factory constructors for common states
  factory AnimalFormState.initial() {
    return const AnimalFormState();
  }

  factory AnimalFormState.loading() {
    return const AnimalFormState(
      submissionState: FormSubmissionState.loading,
      isLoading: true,
    );
  }

  factory AnimalFormState.ready() {
    return const AnimalFormState(isInitialized: true);
  }

  factory AnimalFormState.error(String error) {
    return AnimalFormState(
      isInitialized: true,
      errorMessage: error,
      submissionState: FormSubmissionState.error,
    );
  }

  factory AnimalFormState.success(String message) {
    return AnimalFormState(
      isInitialized: true,
      successMessage: message,
      submissionState: FormSubmissionState.success,
    );
  }

  factory AnimalFormState.validating() {
    return const AnimalFormState(
      isInitialized: true,
      submissionState: FormSubmissionState.validating,
    );
  }

  factory AnimalFormState.editing() {
    return const AnimalFormState(
      isInitialized: true,
      isEditMode: true,
    );
  }
}
