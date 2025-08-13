// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/application/dtos/defensivos_home_data_dto.dart';
import '../../../core/application/use_cases/get_defensivos_home_data_use_case.dart';
import '../../../core/application/use_cases/register_defensivo_access_use_case.dart';
import '../../../router.dart';
import '../models/loading_state.dart';

/// Controller refatorado seguindo Clean Architecture
/// 
/// Demonstra como usar UseCases ao invés de acessar repositories diretamente,
/// implementando dependency inversion e isolamento entre camadas
class CleanHomeDefensivosController extends GetxController {
  final GetDefensivosHomeDataUseCase _getHomeDataUseCase;
  final RegisterDefensivoAccessUseCase _registerAccessUseCase;

  // Estado reativo
  final _loadingState = LoadingState.initial.obs;
  final _homeData = DefensivosHomeDataDto.empty().obs;
  final _errorMessage = Rxn<String>();

  CleanHomeDefensivosController({
    required GetDefensivosHomeDataUseCase getHomeDataUseCase,
    required RegisterDefensivoAccessUseCase registerAccessUseCase,
  })  : _getHomeDataUseCase = getHomeDataUseCase,
        _registerAccessUseCase = registerAccessUseCase;

  // Getters para estado
  LoadingState get loadingState => _loadingState.value;
  bool get isLoading => _loadingState.value == LoadingState.loading;
  bool get isInitialized => _loadingState.value == LoadingState.success;
  bool get hasError => _loadingState.value == LoadingState.error;
  String? get errorMessage => _errorMessage.value;
  DefensivosHomeDataDto get homeData => _homeData.value;

  @override
  void onInit() {
    super.onInit();
    
    // Carrega dados apenas se não foram carregados anteriormente
    if (!isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHomeData();
      });
    }
  }

  /// Carrega os dados da home usando o UseCase
  Future<void> _loadHomeData() async {
    _setLoadingState(LoadingState.loading);
    _clearError();

    final result = await _getHomeDataUseCase.execute();

    if (result.isSuccess) {
      _homeData.value = result.valueOrNull!;
      _setLoadingState(LoadingState.success);
    } else {
      final error = result.errorOrNull!;
      _setErrorState('Erro ao carregar dados: ${error.message}');
    }
  }

  /// Navega para lista de defensivos por categoria
  /// 
  /// Implementa lógica de navegação sem conhecer detalhes de implementação
  void navigateToList(String category) {
    if (category == 'defensivos') {
      Get.toNamed(AppRoutes.defensivosListarNew, id: 1);
    } else {
      Get.toNamed(
        AppRoutes.defensivosAgrupados,
        id: 1,
        arguments: {
          'tipoAgrupamento': category,
          'textoFiltro': '',
        },
      );
    }
  }

  /// Navega para detalhes de um defensivo e registra o acesso
  /// 
  /// Usa o UseCase para registrar acesso, seguindo Single Responsibility Principle
  Future<void> onItemTap(String id) async {
    // Registra o acesso usando o UseCase
    final result = await _registerAccessUseCase.execute(id);
    
    if (result.isFailure) {
      // Log do erro, mas não bloqueia a navegação
      debugPrint('Erro ao registrar acesso: ${result.errorOrNull!.message}');
    }

    // Navega para os detalhes
    Get.toNamed(AppRoutes.defensivos, id: 1, arguments: id);
  }

  /// Refresh dos dados
  Future<void> refreshData() async {
    await _loadHomeData();
  }

  /// Retry em caso de erro
  Future<void> retryInitialization() async {
    if (hasError) {
      await _loadHomeData();
    }
  }

  // MÉTODOS PRIVADOS DE GERENCIAMENTO DE ESTADO

  void _setLoadingState(LoadingState newState) {
    if (_loadingState.value != newState) {
      _loadingState.value = newState;
    }
  }

  void _setErrorState(String errorMessage) {
    _errorMessage.value = errorMessage;
    _setLoadingState(LoadingState.error);
  }

  void _clearError() {
    _errorMessage.value = null;
  }

  // GETTERS PARA VALIDAÇÃO

  bool get canPerformOperations => isInitialized;
  
  String get currentStateDescription {
    switch (_loadingState.value) {
      case LoadingState.initial:
        return 'Aguardando inicialização';
      case LoadingState.loading:
        return 'Carregando dados...';
      case LoadingState.success:
        return 'Dados carregados com sucesso';
      case LoadingState.error:
        return 'Erro: ${_errorMessage.value ?? "Erro desconhecido"}';
    }
  }

  @override
  void onClose() {
    // Cleanup adequado - não há recursos específicos para limpar neste controller
    super.onClose();
  }
}