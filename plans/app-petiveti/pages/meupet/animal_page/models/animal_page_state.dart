class AnimalPageState {
  final bool isLoading;
  final bool isPesosLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final bool hasError;
  final bool hasChanges;

  const AnimalPageState({
    this.isLoading = false,
    this.isPesosLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.hasError = false,
    this.hasChanges = false,
  });

  AnimalPageState copyWith({
    bool? isLoading,
    bool? isPesosLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    bool? hasError,
    bool? hasChanges,
  }) {
    return AnimalPageState(
      isLoading: isLoading ?? this.isLoading,
      isPesosLoading: isPesosLoading ?? this.isPesosLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      successMessage: successMessage,
      hasError: hasError ?? this.hasError,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  AnimalPageState setLoading(bool loading) {
    return copyWith(isLoading: loading, hasError: false);
  }

  AnimalPageState setPesosLoading(bool loading) {
    return copyWith(isPesosLoading: loading);
  }

  AnimalPageState setError(String? error) {
    return copyWith(
      errorMessage: error,
      hasError: error != null,
      isLoading: false,
      isPesosLoading: false,
    );
  }

  AnimalPageState setSuccess(String message) {
    return copyWith(
      successMessage: message,
      hasError: false,
      errorMessage: null,
      isLoading: false,
      isPesosLoading: false,
    );
  }

  AnimalPageState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
      hasError: false,
    );
  }

  AnimalPageState setInitialized(bool initialized) {
    return copyWith(isInitialized: initialized);
  }

  AnimalPageState setHasChanges(bool changes) {
    return copyWith(hasChanges: changes);
  }

  bool get isReady => isInitialized && !isLoading;
  bool get hasSuccess => successMessage != null;
  bool get canPerformActions => isReady && !hasError;

  @override
  String toString() {
    return 'AnimalPageState(isLoading: $isLoading, isPesosLoading: $isPesosLoading, '
        'isInitialized: $isInitialized, hasError: $hasError, hasSuccess: $hasSuccess)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimalPageState &&
        other.isLoading == isLoading &&
        other.isPesosLoading == isPesosLoading &&
        other.isInitialized == isInitialized &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        other.hasError == hasError &&
        other.hasChanges == hasChanges;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        isPesosLoading.hashCode ^
        isInitialized.hashCode ^
        errorMessage.hashCode ^
        successMessage.hashCode ^
        hasError.hashCode ^
        hasChanges.hashCode;
  }

  // Factory constructors for common states
  factory AnimalPageState.initial() {
    return const AnimalPageState();
  }

  factory AnimalPageState.loading() {
    return const AnimalPageState(isLoading: true);
  }

  factory AnimalPageState.ready() {
    return const AnimalPageState(isInitialized: true);
  }

  factory AnimalPageState.error(String error) {
    return AnimalPageState(
      isInitialized: true,
      errorMessage: error,
      hasError: true,
    );
  }

  factory AnimalPageState.success(String message) {
    return AnimalPageState(
      isInitialized: true,
      successMessage: message,
    );
  }
}
