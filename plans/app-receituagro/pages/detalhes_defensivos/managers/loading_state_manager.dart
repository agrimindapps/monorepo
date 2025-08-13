// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

/// Estados de loading padronizados
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// Dados de um estado de loading específico
class LoadingStateData {
  final LoadingState state;
  final String? message;
  final dynamic error;
  final DateTime timestamp;

  LoadingStateData({
    required this.state,
    this.message,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isLoading => state == LoadingState.loading;
  bool get isSuccess => state == LoadingState.success;
  bool get isError => state == LoadingState.error;
  bool get isIdle => state == LoadingState.idle;

  LoadingStateData copyWith({
    LoadingState? state,
    String? message,
    dynamic error,
    DateTime? timestamp,
  }) {
    return LoadingStateData(
      state: state ?? this.state,
      message: message ?? this.message,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Gerenciador centralizado de estados de loading
class LoadingStateManager extends GetxController {
  // Mapa de estados por operação
  final RxMap<String, Rx<LoadingStateData>> _states =
      <String, Rx<LoadingStateData>>{}.obs;

  // Estados comuns predefinidos
  static const String dataLoading = 'data_loading';
  static const String favoriteToggle = 'favorite_toggle';
  static const String ttsOperation = 'tts_operation';
  static const String searchOperation = 'search_operation';
  static const String navigationOperation = 'navigation_operation';

  /// Obtém o estado de uma operação específica
  Rx<LoadingStateData> getState(String operation) {
    if (!_states.containsKey(operation)) {
      _states[operation] = LoadingStateData(state: LoadingState.idle).obs;
    }
    return _states[operation]!;
  }

  /// Define um estado para uma operação
  void setState(String operation, LoadingState state,
      {String? message, dynamic error}) {
    getState(operation).value = LoadingStateData(
      state: state,
      message: message,
      error: error,
    );
  }

  /// Inicia loading para uma operação
  void startLoading(String operation, {String? message}) {
    setState(operation, LoadingState.loading, message: message);
  }

  /// Marca operação como bem-sucedida
  void setSuccess(String operation, {String? message}) {
    setState(operation, LoadingState.success, message: message);
  }

  /// Marca operação com erro
  void setError(String operation, {String? message, dynamic error}) {
    setState(operation, LoadingState.error, message: message, error: error);
  }

  /// Reseta operação para idle
  void setIdle(String operation) {
    setState(operation, LoadingState.idle);
  }

  /// Verifica se alguma operação está carregando
  bool get hasAnyLoading {
    return _states.values.any((state) => state.value.isLoading);
  }

  /// Verifica se operação específica está carregando
  bool isLoading(String operation) {
    return getState(operation).value.isLoading;
  }

  /// Verifica se operação específica teve erro
  bool hasError(String operation) {
    return getState(operation).value.isError;
  }

  /// Obtém mensagem de erro de uma operação
  String? getErrorMessage(String operation) {
    final state = getState(operation).value;
    return state.isError ? (state.message ?? 'Erro desconhecido') : null;
  }

  /// Obtém todas as operações atualmente carregando
  List<String> get loadingOperations {
    return _states.entries
        .where((entry) => entry.value.value.isLoading)
        .map((entry) => entry.key)
        .toList();
  }

  /// Limpa todos os estados
  void clearAllStates() {
    _states.clear();
  }

  /// Limpa estado de uma operação específica
  void clearState(String operation) {
    _states.remove(operation);
  }

  /// Executa uma operação com gerenciamento automático de estado
  Future<T> executeOperation<T>(
    String operation,
    Future<T> Function() task, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      startLoading(operation, message: loadingMessage);
      final result = await task();
      setSuccess(operation, message: successMessage);
      return result;
    } catch (error) {
      setError(
        operation,
        message: errorMessage ?? 'Erro na operação $operation',
        error: error,
      );
      rethrow;
    }
  }

  /// Executa operação com timeout automático
  Future<T> executeWithTimeout<T>(
    String operation,
    Future<T> Function() task, {
    Duration timeout = const Duration(seconds: 30),
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    String? timeoutMessage,
  }) async {
    try {
      startLoading(operation, message: loadingMessage);
      final result = await task().timeout(timeout);
      setSuccess(operation, message: successMessage);
      return result;
    } on TimeoutException {
      setError(
        operation,
        message: timeoutMessage ?? 'Operação expirou',
        error: 'Timeout',
      );
      rethrow;
    } catch (error) {
      setError(
        operation,
        message: errorMessage ?? 'Erro na operação $operation',
        error: error,
      );
      rethrow;
    }
  }

  @override
  void onClose() {
    clearAllStates();
    super.onClose();
  }
}
