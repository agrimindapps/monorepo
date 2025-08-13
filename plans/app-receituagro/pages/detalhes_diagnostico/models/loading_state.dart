/// Enum para diferentes tipos de loading state
enum LoadingStateType {
  /// Estado inicial ou quando nenhuma operação está em andamento
  idle,
  
  /// Carregando dados principais do diagnóstico
  loadingDiagnostic,
  
  /// Carregando status de favorito
  loadingFavorite,
  
  /// Carregando dados premium
  loadingPremium,
  
  /// Operação de TTS em andamento
  loadingTts,
  
  /// Carregando dados de aplicação
  loadingApplication,
  
  /// Estado de sucesso
  success,
  
  /// Estado de erro
  error,
}

/// Classe para gerenciar estados de loading específicos
class LoadingState {
  final LoadingStateType type;
  final bool isLoading;
  final String? message;
  final dynamic error;

  const LoadingState({
    required this.type,
    required this.isLoading,
    this.message,
    this.error,
  });

  /// Estado idle
  factory LoadingState.idle() => const LoadingState(
        type: LoadingStateType.idle,
        isLoading: false,
      );

  /// Estado de loading com tipo específico
  factory LoadingState.loading(LoadingStateType type, {String? message}) =>
      LoadingState(
        type: type,
        isLoading: true,
        message: message,
      );

  /// Estado de sucesso
  factory LoadingState.success(LoadingStateType type, {String? message}) =>
      LoadingState(
        type: type,
        isLoading: false,
        message: message,
      );

  /// Estado de erro
  factory LoadingState.error(LoadingStateType type, dynamic error, {String? message}) =>
      LoadingState(
        type: type,
        isLoading: false,
        error: error,
        message: message,
      );

  /// Cria uma cópia com valores atualizados
  LoadingState copyWith({
    LoadingStateType? type,
    bool? isLoading,
    String? message,
    dynamic error,
  }) {
    return LoadingState(
      type: type ?? this.type,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadingState &&
        other.type == type &&
        other.isLoading == isLoading &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode {
    return type.hashCode ^ isLoading.hashCode ^ message.hashCode ^ error.hashCode;
  }

  @override
  String toString() {
    return 'LoadingState(type: $type, isLoading: $isLoading, message: $message, error: $error)';
  }
}

/// Manager para gerenciar múltiplos estados de loading
class LoadingStateManager {
  final Map<LoadingStateType, LoadingState> _states = {};

  /// Obtém o estado atual de um tipo específico
  LoadingState getState(LoadingStateType type) {
    return _states[type] ?? LoadingState.idle();
  }

  /// Atualiza o estado de um tipo específico
  void setState(LoadingStateType type, LoadingState state) {
    _states[type] = state;
  }

  /// Marca um tipo como loading
  void setLoading(LoadingStateType type, {String? message}) {
    setState(type, LoadingState.loading(type, message: message));
  }

  /// Marca um tipo como sucesso
  void setSuccess(LoadingStateType type, {String? message}) {
    setState(type, LoadingState.success(type, message: message));
  }

  /// Marca um tipo como erro
  void setError(LoadingStateType type, dynamic error, {String? message}) {
    setState(type, LoadingState.error(type, error, message: message));
  }

  /// Marca um tipo como idle
  void setIdle(LoadingStateType type) {
    setState(type, LoadingState.idle());
  }

  /// Verifica se algum tipo está carregando
  bool get hasAnyLoading {
    return _states.values.any((state) => state.isLoading);
  }

  /// Verifica se um tipo específico está carregando
  bool isLoading(LoadingStateType type) {
    return getState(type).isLoading;
  }

  /// Obtém todos os tipos que estão carregando
  List<LoadingStateType> get loadingTypes {
    return _states.entries
        .where((entry) => entry.value.isLoading)
        .map((entry) => entry.key)
        .toList();
  }

  /// Limpa todos os estados
  void clear() {
    _states.clear();
  }

  /// Obtém todos os estados
  Map<LoadingStateType, LoadingState> get allStates => Map.from(_states);
}