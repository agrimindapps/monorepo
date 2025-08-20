class DespesasPageState {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final bool isRefreshing;
  final DateTime? lastUpdated;

  const DespesasPageState({
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.isRefreshing = false,
    this.lastUpdated,
  });

  DespesasPageState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool? isRefreshing,
    DateTime? lastUpdated,
  }) {
    return DespesasPageState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // State modification methods removed - use copyWith() in controller instead
  // This ensures immutability and proper state management with GetX

  // Computed properties
  bool get hasError => errorMessage != null;
  bool get isReady => isInitialized && !isLoading;
  bool get canInteract => isReady && !isRefreshing;

  Duration? get timeSinceLastUpdate {
    if (lastUpdated == null) return null;
    return DateTime.now().difference(lastUpdated!);
  }

  bool get needsRefresh {
    final timeSince = timeSinceLastUpdate;
    if (timeSince == null) return true;
    return timeSince.inMinutes > 5; // Needs refresh after 5 minutes
  }

  String get statusDescription {
    if (isLoading) return 'Carregando...';
    if (isRefreshing) return 'Atualizando...';
    if (hasError) return 'Erro: $errorMessage';
    if (!isInitialized) return 'Não inicializado';
    return 'Pronto';
  }

  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'isInitialized': isInitialized,
      'errorMessage': errorMessage,
      'isRefreshing': isRefreshing,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory DespesasPageState.fromJson(Map<String, dynamic> json) {
    return DespesasPageState(
      isLoading: json['isLoading'] ?? false,
      isInitialized: json['isInitialized'] ?? false,
      errorMessage: json['errorMessage'],
      isRefreshing: json['isRefreshing'] ?? false,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  @override
  String toString() {
    return 'DespesasPageState(isLoading: $isLoading, isInitialized: $isInitialized, '
           'hasError: $hasError, isRefreshing: $isRefreshing, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DespesasPageState &&
        other.isLoading == isLoading &&
        other.isInitialized == isInitialized &&
        other.errorMessage == errorMessage &&
        other.isRefreshing == isRefreshing &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        isInitialized.hashCode ^
        errorMessage.hashCode ^
        isRefreshing.hashCode ^
        lastUpdated.hashCode;
  }

  // Factory constructors for common states
  factory DespesasPageState.initial() {
    return const DespesasPageState();
  }

  factory DespesasPageState.loading() {
    return const DespesasPageState(isLoading: true);
  }

  factory DespesasPageState.ready() {
    return DespesasPageState(
      isInitialized: true,
      lastUpdated: DateTime.now(),
    );
  }

  factory DespesasPageState.error(String error) {
    return DespesasPageState(
      isInitialized: true,
      errorMessage: error,
      lastUpdated: DateTime.now(),
    );
  }

  factory DespesasPageState.refreshing() {
    return DespesasPageState(
      isInitialized: true,
      isRefreshing: true,
      lastUpdated: DateTime.now(),
    );
  }
}