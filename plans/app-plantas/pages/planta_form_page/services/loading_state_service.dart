// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

/// Estados de loading específicos para diferentes operações
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// Contexto da operação sendo executada
enum LoadingOperation {
  savingPlant,
  loadingSpaces,
  creatingSpace,
  selectingImage,
  validatingForm,
  initializingServices,
}

/// Modelo para representar estado de loading detalhado
class LoadingStatus {
  final LoadingState state;
  final LoadingOperation operation;
  final String? message;
  final double? progress;

  const LoadingStatus({
    required this.state,
    required this.operation,
    this.message,
    this.progress,
  });

  bool get isLoading => state == LoadingState.loading;
  bool get isIdle => state == LoadingState.idle;
  bool get isSuccess => state == LoadingState.success;
  bool get isError => state == LoadingState.error;

  LoadingStatus copyWith({
    LoadingState? state,
    LoadingOperation? operation,
    String? message,
    double? progress,
  }) {
    return LoadingStatus(
      state: state ?? this.state,
      operation: operation ?? this.operation,
      message: message ?? this.message,
      progress: progress ?? this.progress,
    );
  }
}

/// Service para gerenciar estados de loading de forma centralizada
class LoadingStateService extends GetxService {
  static LoadingStateService get instance => Get.find<LoadingStateService>();

  // Estado global de loading (qualquer operação ativa)
  final _globalLoading = false.obs;
  bool get isGlobalLoading => _globalLoading.value;

  // Estados específicos por operação
  final _loadingStates = <LoadingOperation, Rx<LoadingStatus>>{};

  // Histórico de operações para debug
  final _operationHistory = <LoadingStatus>[];

  @override
  void onInit() {
    super.onInit();
    _initializeStates();
    debugPrint('📊 LoadingStateService initialized');
  }

  void _initializeStates() {
    for (final operation in LoadingOperation.values) {
      _loadingStates[operation] = LoadingStatus(
        state: LoadingState.idle,
        operation: operation,
      ).obs;
    }
  }

  /// Inicia operação de loading
  void startLoading(
    LoadingOperation operation, {
    String? message,
    double? progress,
  }) {
    final status = LoadingStatus(
      state: LoadingState.loading,
      operation: operation,
      message: message ?? _getDefaultMessage(operation),
      progress: progress,
    );

    _loadingStates[operation]?.value = status;
    _operationHistory.add(status);
    _updateGlobalLoading();

    debugPrint('🔄 Loading started: ${operation.name} - ${status.message}');
  }

  /// Atualiza progresso da operação
  void updateProgress(
    LoadingOperation operation,
    double progress, {
    String? message,
  }) {
    final currentStatus = _loadingStates[operation]?.value;
    if (currentStatus?.isLoading == true) {
      final updatedStatus = currentStatus!.copyWith(
        progress: progress,
        message: message,
      );

      _loadingStates[operation]?.value = updatedStatus;
      _operationHistory.add(updatedStatus);

      debugPrint(
          '📈 Progress updated: ${operation.name} - ${progress.toStringAsFixed(1)}%');
    }
  }

  /// Finaliza operação com sucesso
  void setSuccess(LoadingOperation operation, {String? message}) {
    final status = LoadingStatus(
      state: LoadingState.success,
      operation: operation,
      message: message ?? _getSuccessMessage(operation),
    );

    _loadingStates[operation]?.value = status;
    _operationHistory.add(status);
    _updateGlobalLoading();

    debugPrint('✅ Loading success: ${operation.name} - ${status.message}');

    // Auto-reset para idle após um breve momento
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_loadingStates[operation]?.value.isSuccess == true) {
        _setIdle(operation);
      }
    });
  }

  /// Finaliza operação com erro
  void setError(LoadingOperation operation, {String? message}) {
    final status = LoadingStatus(
      state: LoadingState.error,
      operation: operation,
      message: message ?? _getErrorMessage(operation),
    );

    _loadingStates[operation]?.value = status;
    _operationHistory.add(status);
    _updateGlobalLoading();

    debugPrint('❌ Loading error: ${operation.name} - ${status.message}');

    // Auto-reset para idle após alguns segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (_loadingStates[operation]?.value.isError == true) {
        _setIdle(operation);
      }
    });
  }

  /// Define operação como idle
  void _setIdle(LoadingOperation operation) {
    final status = LoadingStatus(
      state: LoadingState.idle,
      operation: operation,
    );

    _loadingStates[operation]?.value = status;
    _updateGlobalLoading();

    debugPrint('💤 Loading idle: ${operation.name}');
  }

  /// Força reset de uma operação para idle
  void resetOperation(LoadingOperation operation) {
    _setIdle(operation);
  }

  /// Reset de todos os estados
  void resetAll() {
    for (final operation in LoadingOperation.values) {
      _setIdle(operation);
    }
    _operationHistory.clear();
    debugPrint('🔄 All loading states reset');
  }

  /// Obtém status de uma operação específica
  Rx<LoadingStatus> getStatus(LoadingOperation operation) {
    return _loadingStates[operation] ??
        LoadingStatus(state: LoadingState.idle, operation: operation).obs;
  }

  /// Verifica se uma operação específica está em loading
  bool isLoading(LoadingOperation operation) {
    return _loadingStates[operation]?.value.isLoading ?? false;
  }

  /// Verifica se alguma operação está em loading
  bool get hasAnyLoading => _globalLoading.value;

  /// Atualiza estado global baseado em operações individuais
  void _updateGlobalLoading() {
    final hasLoading =
        _loadingStates.values.any((status) => status.value.isLoading);
    _globalLoading.value = hasLoading;
  }

  /// Obtém mensagem padrão para cada operação
  String _getDefaultMessage(LoadingOperation operation) {
    switch (operation) {
      case LoadingOperation.savingPlant:
        return 'Salvando planta...';
      case LoadingOperation.loadingSpaces:
        return 'Carregando espaços...';
      case LoadingOperation.creatingSpace:
        return 'Criando espaço...';
      case LoadingOperation.selectingImage:
        return 'Processando imagem...';
      case LoadingOperation.validatingForm:
        return 'Validando dados...';
      case LoadingOperation.initializingServices:
        return 'Inicializando serviços...';
    }
  }

  /// Obtém mensagem de sucesso para cada operação
  String _getSuccessMessage(LoadingOperation operation) {
    switch (operation) {
      case LoadingOperation.savingPlant:
        return 'Planta salva com sucesso!';
      case LoadingOperation.loadingSpaces:
        return 'Espaços carregados!';
      case LoadingOperation.creatingSpace:
        return 'Espaço criado com sucesso!';
      case LoadingOperation.selectingImage:
        return 'Imagem selecionada!';
      case LoadingOperation.validatingForm:
        return 'Dados validados!';
      case LoadingOperation.initializingServices:
        return 'Serviços inicializados!';
    }
  }

  /// Obtém mensagem de erro para cada operação
  String _getErrorMessage(LoadingOperation operation) {
    switch (operation) {
      case LoadingOperation.savingPlant:
        return 'Erro ao salvar planta';
      case LoadingOperation.loadingSpaces:
        return 'Erro ao carregar espaços';
      case LoadingOperation.creatingSpace:
        return 'Erro ao criar espaço';
      case LoadingOperation.selectingImage:
        return 'Erro ao processar imagem';
      case LoadingOperation.validatingForm:
        return 'Erro na validação';
      case LoadingOperation.initializingServices:
        return 'Erro ao inicializar serviços';
    }
  }

  /// Obtém histórico de operações (útil para debug)
  List<LoadingStatus> get operationHistory =>
      List.unmodifiable(_operationHistory);

  /// Limpa histórico de operações
  void clearHistory() {
    _operationHistory.clear();
    debugPrint('🧹 Operation history cleared');
  }

  /// Método para executar operação com loading automático
  Future<T> executeWithLoading<T>(
    LoadingOperation operation,
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
    } catch (e) {
      setError(operation, message: errorMessage ?? e.toString());
      rethrow;
    }
  }

  @override
  void onClose() {
    debugPrint('📊 LoadingStateService disposed');
    super.onClose();
  }
}
