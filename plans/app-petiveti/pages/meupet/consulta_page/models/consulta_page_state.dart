class ConsultaPageState {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String? successMessage;
  final bool isRefreshing;
  final bool isExporting;

  const ConsultaPageState({
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.successMessage,
    this.isRefreshing = false,
    this.isExporting = false,
  });

  ConsultaPageState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? successMessage,
    bool? isRefreshing,
    bool? isExporting,
  }) {
    return ConsultaPageState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isExporting: isExporting ?? this.isExporting,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get isReady => isInitialized && !isLoading;
  bool get isBusy => isLoading || isRefreshing || isExporting;

  ConsultaPageState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  ConsultaPageState setInitialized(bool initialized) {
    return copyWith(isInitialized: initialized);
  }

  ConsultaPageState setError(String? error) {
    return copyWith(
      errorMessage: error,
      isLoading: false,
      isRefreshing: false,
      isExporting: false,
    );
  }

  ConsultaPageState setSuccess(String message) {
    return copyWith(
      successMessage: message,
      isLoading: false,
      isRefreshing: false,
      isExporting: false,
    );
  }

  ConsultaPageState setRefreshing(bool refreshing) {
    return copyWith(isRefreshing: refreshing);
  }

  ConsultaPageState setExporting(bool exporting) {
    return copyWith(isExporting: exporting);
  }

  ConsultaPageState clearError() {
    return copyWith(errorMessage: null);
  }

  ConsultaPageState clearSuccess() {
    return copyWith(successMessage: null);
  }

  ConsultaPageState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'isInitialized': isInitialized,
      'errorMessage': errorMessage,
      'successMessage': successMessage,
      'isRefreshing': isRefreshing,
      'isExporting': isExporting,
    };
  }

  factory ConsultaPageState.fromJson(Map<String, dynamic> json) {
    return ConsultaPageState(
      isLoading: json['isLoading'] ?? false,
      isInitialized: json['isInitialized'] ?? false,
      errorMessage: json['errorMessage'],
      successMessage: json['successMessage'],
      isRefreshing: json['isRefreshing'] ?? false,
      isExporting: json['isExporting'] ?? false,
    );
  }

  @override
  String toString() {
    return 'ConsultaPageState(isLoading: $isLoading, isInitialized: $isInitialized, '
           'hasError: $hasError, hasSuccess: $hasSuccess, isRefreshing: $isRefreshing, '
           'isExporting: $isExporting)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ConsultaPageState &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        other.isRefreshing == isRefreshing &&
        other.isExporting == isExporting;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        isInitialized.hashCode ^
        errorMessage.hashCode ^
        successMessage.hashCode ^
        isRefreshing.hashCode ^
        isExporting.hashCode;
  }

  // Factory constructors for common states
  factory ConsultaPageState.initial() {
    return const ConsultaPageState();
  }

  factory ConsultaPageState.loading() {
    return const ConsultaPageState(isLoading: true);
  }

  factory ConsultaPageState.ready() {
    return const ConsultaPageState(isInitialized: true);
  }

  factory ConsultaPageState.error(String error) {
    return ConsultaPageState(
      isInitialized: true,
      errorMessage: error,
    );
  }

  factory ConsultaPageState.success(String message) {
    return ConsultaPageState(
      isInitialized: true,
      successMessage: message,
    );
  }

  factory ConsultaPageState.refreshing() {
    return const ConsultaPageState(
      isInitialized: true,
      isRefreshing: true,
    );
  }

  factory ConsultaPageState.exporting() {
    return const ConsultaPageState(
      isInitialized: true,
      isExporting: true,
    );
  }
}