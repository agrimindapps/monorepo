// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../constants/veiculos_page_constants.dart';
import '../models/veiculos_page_model.dart';
import '../services/error_handler.dart';
import '../services/veiculo_index.dart';
import '../services/veiculos_export_service.dart';
import '../services/veiculos_ui_state_service.dart';
import '../use_cases/veiculos_use_cases.dart';
import '../widgets/loading_states.dart';

// Dart

// Flutter

// External packages

// Internal dependencies

// Local imports

/// Controller focused on orchestration only
class VeiculosPageController extends GetxController {
  final _model = VeiculosPageModel();

  // Core dependencies
  late final VeiculosUseCases _useCases;
  late final VeiculosExportService _exportService;
  late final VeiculoIndex _indexService;

  // Modern contextual loading states
  final Rx<LoadingState> currentLoadingState = LoadingState.idle.obs;
  final RxDouble loadingProgress = 0.0.obs;
  final RxString loadingMessage = ''.obs;

  // Legacy state (for backward compatibility)
  final RxBool isLoadingInternal = false.obs;
  final RxString errorInternal = ''.obs;
  final Rx<VeiculoCar?> selectedVeiculo = Rx<VeiculoCar?>(null);

  // UI State for specific sections
  final RxBool gridLoading = false.obs;
  final RxBool headerLoading = false.obs;

  // Workers for reactive programming
  Worker? _gridLoadingWorker;
  Worker? _veiculosWorker;

  // Getters for model properties (single source of truth)
  VeiculosPageModel get model => _model;
  List<VeiculoCar> get veiculos => _model.veiculos;
  RxList<VeiculoCar> get veiculosRx => _model.veiculosRx;
  bool get isLoading => _model.isLoading;
  RxBool get isLoadingRx => _model.isLoadingRx;
  bool get hasError => _model.hasError;
  String get errorMessage => _model.errorMessage;
  bool get isEmpty => _model.isEmpty;
  bool get isNotEmpty => _model.isNotEmpty;
  int get length => _model.length;

  // Modern loading state getters
  LoadingState get loadingState => currentLoadingState.value;
  bool get hasContextualLoading => currentLoadingState.value.isLoading;
  String get contextualMessage => loadingMessage.value.isEmpty
      ? currentLoadingState.value.userMessage
      : loadingMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _setupReactiveWorkers();
  }

  void _setupReactiveWorkers() {
    _gridLoadingWorker = debounce<bool>(gridLoading, (loading) => update(),
        time: VeiculosPageConstants.workerDebounceDelay);
    _veiculosWorker = ever<List<VeiculoCar>>(veiculosRx, (veiculos) {
      if (!gridLoading.value) {
        update([VeiculosPageConstants.vehicleListTag]);
      }
    });
  }

  void _initializeControllers() {
    try {
      // Verificação de dependências com timeout
      if (!Get.isRegistered<VeiculosUseCases>()) {
        throw Exception(
            'VeiculosUseCases não registrado. Verifique o binding.');
      }

      if (!Get.isRegistered<VeiculosExportService>()) {
        throw Exception(
            'VeiculosExportService não registrado. Verifique o binding.');
      }

      _useCases = Get.find<VeiculosUseCases>();
      _exportService = Get.find<VeiculosExportService>();
      _indexService = VeiculoIndex.instance;

      // Aguarda a próxima frame para evitar problemas de inicialização
      Future.delayed(Duration.zero, () async {
        try {
          await loadVeiculos();
          await carregarVeiculoSelecionado();
        } catch (e) {
          _model.setError(
              true, 'Erro ao carregar dados iniciais: ${e.toString()}');
        }
      });
    } catch (e) {
      final error =
          VeiculosErrorHandler.handleDependencyError(Exception(e.toString()));
      VeiculosErrorHandler.showErrorToUser(error);
      _model.setError(true, error.userMessage);
    }
  }

  // Core orchestration methods
  Future<void> loadVeiculos() async {
    await executeWithLoading(
      LoadingState.loadingVeiculos,
      () async {
        gridLoading.value = true;
        _model.setLoading(true);
        _model.clearError();

        try {
          final veiculos = await carregarVeiculos();
          _model.setVeiculos(veiculos);
          await _indexService.buildIndexes(veiculos);
        } catch (e) {
          final error = VeiculosErrorHandler.handleVehicleLoadError(
              Exception(e.toString()));
          VeiculosErrorHandler.showErrorToUser(error,
              onRetry: () => loadVeiculos());
          _model.setError(true, error.userMessage);
          rethrow;
        } finally {
          gridLoading.value = false;
          _model.setLoading(false);
        }
      },
      timeout: const Duration(seconds: 30),
    );
  }

  Future<void> refreshVeiculos() async {
    headerLoading.value = true;
    try {
      final veiculos = await carregarVeiculos();
      _model.setVeiculos(veiculos);
      await _indexService.buildIndexes(veiculos);
      VeiculosUIStateService.updateUI(this,
          ids: [VeiculosPageConstants.vehicleListTag]);
    } catch (e) {
      final error =
          VeiculosErrorHandler.handleVehicleLoadError(Exception(e.toString()));
      VeiculosErrorHandler.showErrorToUser(error,
          onRetry: () => refreshVeiculos());
      _model.setError(true, error.userMessage);
    } finally {
      headerLoading.value = false;
    }
  }

  // Business operations - delegate to use cases
  Future<List<VeiculoCar>> carregarVeiculos() async {
    try {
      final result = await _useCases.loadVehicles();
      _model.setVeiculos(result);
      return result;
    } catch (e) {
      debugPrint('VeiculosPageController: Erro ao carregar veículos: $e');
      if (e is VehicleOperationException) {
        errorInternal.value = e.message;
      } else {
        final error = VeiculosErrorHandler.handleVehicleLoadError(
            Exception(e.toString()));
        errorInternal.value = error.userMessage;
      }
      return [];
    }
  }

  Future<void> carregarVeiculoSelecionado() async {
    try {
      final veiculo = await _useCases.loadSelectedVehicle();
      selectedVeiculo.value = veiculo;
    } catch (e) {
      if (e is VehicleOperationException) {
        errorInternal.value = e.message;
      } else {
        final error = VeiculosErrorHandler.handleVehicleLoadError(
            Exception(e.toString()));
        errorInternal.value = error.userMessage;
      }
    }
  }

  Future<bool> removerVeiculo(VeiculoCar veiculo) async {
    try {
      final result = await _useCases.deleteVehicle(veiculo);
      if (result) {
        await carregarVeiculos();
        if (selectedVeiculo.value?.id == veiculo.id) {
          selectedVeiculo.value = null;
        }
      }
      return result;
    } catch (e) {
      if (e is VehicleOperationException) {
        errorInternal.value = e.message;
      } else {
        final error = VeiculosErrorHandler.handleVehicleDeleteError(
            Exception(e.toString()));
        errorInternal.value = error.userMessage;
      }
      return false;
    }
  }

  Future<bool> selecionarVeiculo(String id) async {
    try {
      final veiculo = await _useCases.selectVehicle(id);
      if (veiculo != null) {
        selectedVeiculo.value = veiculo;
        return true;
      }
      return false;
    } catch (e) {
      if (e is VehicleOperationException) {
        errorInternal.value = e.message;
      } else {
        final error = VeiculosErrorHandler.handleVehicleUpdateError(
            Exception(e.toString()));
        errorInternal.value = error.userMessage;
      }
      return false;
    }
  }

  // Vehicle creation validation
  Future<bool> handleVeiculoCreation(BuildContext context) async {
    try {
      final result = await _useCases.canCreateVehicle(_model.veiculos);

      if (!result.isAllowed) {
        VeiculosErrorHandler.showErrorToUser(
          StructuredError(
            type: ErrorType.business,
            severity: ErrorSeverity.medium,
            technicalMessage: 'Business rule violation: ${result.ruleViolated}',
            userMessage: result.getUserMessage(),
            context: 'Vehicle creation',
            suggestedAction: result.suggestedAction,
          ),
        );
        _model.setError(true, result.reason ?? 'Operação não permitida');
        return false;
      }

      return true;
    } catch (e) {
      final error = VeiculosErrorHandler.handleVehicleCreateError(
          Exception(e.toString()));
      VeiculosErrorHandler.showErrorToUser(error);
      _model.setError(true, error.userMessage);
      return false;
    }
  }

  // Export operation
  Future<String> exportarParaCsv() async {
    return await executeWithLoading(
      LoadingState.exportingData,
      () async {
        try {
          return await _exportService.exportToCsv();
        } catch (e) {
          final error =
              VeiculosErrorHandler.handleExportError(Exception(e.toString()));
          errorInternal.value = error.userMessage;
          return VeiculosPageConstants.emptyString;
        }
      },
    );
  }

  // Utility methods
  VeiculoCar? getVeiculoById(String id) => _model.getVeiculoById(id);
  void clearError() => _model.clearError();
  Future<bool> veiculoPossuiLancamentos(String veiculoId) async {
    return await _useCases.vehicleHasRecords(veiculoId);
  }

  void setLoadingState(LoadingState state,
      {String? customMessage, double? progress}) {
    currentLoadingState.value = state;
    loadingMessage.value = customMessage ?? '';
    if (progress != null) loadingProgress.value = progress;
  }

  void clearLoadingState() {
    currentLoadingState.value = LoadingState.idle;
    loadingMessage.value = '';
    loadingProgress.value = 0.0;
  }

  Future<T> executeWithLoading<T>(
    LoadingState state,
    Future<T> Function() operation, {
    String? customMessage,
    Duration? timeout,
  }) async {
    setLoadingState(state, customMessage: customMessage);

    try {
      if (timeout != null) {
        return await operation().timeout(timeout);
      } else {
        return await operation();
      }
    } catch (e) {
      if (e is TimeoutException) {
        final timeoutError = VeiculosErrorHandler.handleError(
          Exception('Operação excedeu tempo limite: ${state.userMessage}'),
          'Timeout na operação',
          forceType: ErrorType.network,
        );
        VeiculosErrorHandler.showErrorToUser(timeoutError);
      }
      rethrow;
    } finally {
      clearLoadingState();
    }
  }

  void updateLoadingProgress(double progress) {
    if (currentLoadingState.value.isLongRunning) {
      loadingProgress.value = progress.clamp(0.0, 1.0);
    }
  }

  void cancelCurrentOperation() {
    if (currentLoadingState.value.isCancellable) {
      clearLoadingState();
    }
  }

  // Cleanup
  @override
  void onClose() {
    _disposeAllObservables();
    super.onClose();
  }

  void _disposeAllObservables() {
    try {
      _gridLoadingWorker?.dispose();
      _veiculosWorker?.dispose();

      gridLoading.close();
      headerLoading.close();
      isLoadingInternal.close();
      errorInternal.close();
      selectedVeiculo.close();

      currentLoadingState.close();
      loadingProgress.close();
      loadingMessage.close();

      _model.dispose();
    } catch (e) {
      VeiculosErrorHandler.handleError(
        Exception(e.toString()),
        'Cleanup de observables',
        forceType: ErrorType.system,
      );
    }
  }
}
