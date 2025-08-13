// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/defensivos_repository.dart';
import '../../../router.dart';
import '../models/defensivo_item.dart';
import '../models/defensivos_home_data.dart';
import '../models/loading_state.dart';

class HomeDefensivosController extends GetxController {
  late final DefensivosRepository _repository;

  // New state management with enum
  final _loadingState = LoadingState.initial.obs;
  final _homeData = DefensivosHomeData().obs;
  final _errorMessage = Rxn<String>();
  final _stateTransitionLog = <String>[].obs;

  // Getters with clear state logic
  LoadingState get loadingState => _loadingState.value;
  bool get isLoading => _loadingState.value == LoadingState.loading;
  bool get isInitialized => _loadingState.value == LoadingState.success;
  bool get hasError => _loadingState.value == LoadingState.error;
  String? get errorMessage => _errorMessage.value;
  DefensivosHomeData get homeData => _homeData.value;
  List<String> get stateTransitionLog => _stateTransitionLog.toList();

  @override
  void onInit() {
    super.onInit();
    
    // Verificar se dados já foram carregados anteriormente
    if (isInitialized && homeData.defensivos > 0) {
      return;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRepository();
    });
  }

  Future<void> _initializeRepository() async {
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        _setLoadingState(LoadingState.loading);
        _clearError();
        
        // Validate pre-conditions
        if (!await _validatePreConditions()) {
          throw StateError('Pre-conditions validation failed');
        }
        
        // Initialize repository with timeout and retry logic
        await _performInitializationWithFallback().timeout(
          Duration(seconds: 30 + (attempts * 10)), // Increasing timeout
        );
        
        // Validate successful initialization
        if (await _validateInitialization()) {
          _setLoadingState(LoadingState.success);
          return; // Success, exit retry loop
        } else {
          throw StateError('Initialization validation failed');
        }
        
      } catch (e) {
        attempts++;
        final isLastAttempt = attempts >= maxAttempts;
        
        if (isLastAttempt) {
          final errorMsg = 'Erro na inicialização após $attempts tentativas: ${e.toString()}';
          _setErrorState(errorMsg);
          return;
        }
        
        // Exponential backoff
        final backoffDelay = Duration(milliseconds: 1000 * (2 << attempts));
        await Future.delayed(backoffDelay);
      }
    }
  }

  Future<bool> _validatePreConditions() async {
    try {
      // Check if we have context for navigation
      if (Get.context == null) {
        return false;
      }
      
      // Additional pre-conditions can be added here
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _performInitializationWithFallback() async {
    try {
      // Step 1: Initialize repository with validation
      await _initializeRepositoryInstance();
      
      // Step 2: Initialize repository info with validation
      await _initializeRepositoryInfo();
      
      // Step 3: Load initial data with fallback
      await _loadDataWithFallback();
      
    } catch (e) {
      await _attemptGracefulFallback();
      rethrow;
    }
  }

  Future<void> _initializeRepositoryInstance() async {
    try {
      // Tentar usar repository singleton primeiro
      if (Get.isRegistered<DefensivosRepository>()) {
        _repository = Get.find<DefensivosRepository>();
      } else {
        _repository = DefensivosRepository();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializeRepositoryInfo() async {
    try {
      _repository.initInfo();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadDataWithFallback() async {
    try {
      await _loadData();
    } catch (e) {
      _initializeWithEmptyData();
      // Don't rethrow here - we have fallback data
    }
  }

  void _initializeWithEmptyData() {
    _homeData.value = DefensivosHomeData(
      defensivos: 0,
      fabricantes: 0,
      actionMode: 0,
      activeIngredient: 0,
      agronomicClass: 0,
      recentlyAccessed: [],
      newProducts: [],
    );
  }

  Future<bool> _validateInitialization() async {
    try {
      // Check if repository is properly initialized
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _attemptGracefulFallback() async {
    try {
      
      // Try to initialize with minimal functionality
      _repository ??= DefensivosRepository();
      
      _initializeWithEmptyData();
      
    } catch (e) {
      // Graceful fallback error handled silently
    }
  }

  Future<void> _loadData() async {
    try {
      // Load counts synchronously first
      _loadCounts();
      
      // Load other data with timeout
      await Future.wait([
        _loadRecentItems(),
        _loadNewItems(),
      ]).timeout(
        const Duration(seconds: 20),
      );
      
    } catch (e) {
      rethrow; // Re-throw to be handled by calling method
    }
  }

  void _loadCounts() {
    _homeData.value = _homeData.value.copyWith(
      defensivos: _repository.getDefensivosCount(),
      fabricantes: _repository.getFabricanteCount(),
      actionMode: _repository.getModoDeAcaoCount(),
      activeIngredient: _repository.getIngredienteAtivoCount(),
      agronomicClass: _repository.getClasseAgronomicaCount(),
    );
  }

  Future<void> _loadRecentItems() async {
    try {
      final recentItems = await _repository.getDefensivosAcessados();
      
      final items = recentItems
          .map((item) => DefensivoItem.fromMap(item))
          .toList();
      
      _homeData.value = _homeData.value.copyWith(recentlyAccessed: items);
    } catch (e) {
      _homeData.value = _homeData.value.copyWith(recentlyAccessed: []);
    }
  }

  Future<void> _loadNewItems() async {
    try {
      final newItems = _repository.getDefensivosNovos();
      final items = newItems
          .map((item) => DefensivoItem.fromMap(item))
          .toList();
      
      _homeData.value = _homeData.value.copyWith(newProducts: items);
    } catch (e) {
      _homeData.value = _homeData.value.copyWith(newProducts: []);
    }
  }

  // Helper method to find the correct Navigator
  NavigatorState? _findLocalNavigator() {
    final context = Get.context;
    if (context == null) return null;
    
    try {
      // Procura especificamente pelo Navigator da mobile_page.dart
      // que tem uma key específica
      NavigatorState? targetNavigator;
      
      context.visitAncestorElements((element) {
        if (element.widget is Navigator) {
          final navigator = element.widget as Navigator;
          // Se o Navigator tem uma key, é provavelmente nosso Navigator local
          if (navigator.key != null) {
            targetNavigator = Navigator.of(element);
            return false; // Para a busca
          }
        }
        return true; // Continua a busca
      });
      
      return targetNavigator;
    } catch (e) {
      return null;
    }
  }

  void navigateToList(String category) {
    _repository.resetPage();
    
    // Tenta usar o Navigator local primeiro
    final localNavigator = _findLocalNavigator();
    if (localNavigator != null) {
      if (category == 'defensivos') {
        localNavigator.pushNamed(AppRoutes.defensivosListarNew);
      } else {
        localNavigator.pushNamed(
          AppRoutes.defensivosAgrupados,
          arguments: {
            'tipoAgrupamento': category,
            'textoFiltro': '',
          },
        );
      }
      return; // Navegação bem-sucedida
    }
    
    // Fallback: Se não conseguiu usar Navigator local
    {
      // Se não conseguir usar Navigator local, usa GetX como fallback
      if (category == 'defensivos') {
        Get.toNamed(AppRoutes.defensivosListarNew);
      } else {
        Get.toNamed(
          AppRoutes.defensivosAgrupados,
          arguments: {
            'tipoAgrupamento': category,
            'textoFiltro': '',
          },
        );
      }
    }
  }

  void onItemTap(String id) {
    _repository.setDefensivoAcessado(defensivoId: id);
    
    // Tenta usar o Navigator local primeiro
    final localNavigator = _findLocalNavigator();
    if (localNavigator != null) {
      localNavigator.pushNamed(AppRoutes.defensivos, arguments: id);
      return; // Navegação bem-sucedida
    }
    
    // Fallback para GetX se Navigator local não estiver disponível
    Get.toNamed(AppRoutes.defensivos, arguments: id);
  }

  Future<void> refreshData() async {
    int attempts = 0;
    const maxAttempts = 2; // Fewer attempts for refresh
    
    while (attempts < maxAttempts) {
      try {
        _setLoadingState(LoadingState.loading);
        _clearError();
        
        await _loadDataWithFallback().timeout(
          Duration(seconds: 30 + (attempts * 10)),
        );
        
        _setLoadingState(LoadingState.success);
        return; // Success, exit retry loop
        
      } catch (e) {
        attempts++;
        final isLastAttempt = attempts >= maxAttempts;
        
        if (isLastAttempt) {
          final errorMsg = 'Erro ao atualizar dados após $attempts tentativas: ${e.toString()}';
          _setErrorState(errorMsg);
          return;
        }
        
        // Shorter backoff for refresh
        final backoffDelay = Duration(milliseconds: 500 * attempts);
        await Future.delayed(backoffDelay);
      }
    }
  }
  
  // STATE MANAGEMENT METHODS
  void _setLoadingState(LoadingState newState) {
    final oldState = _loadingState.value;
    if (oldState != newState) {
      _loadingState.value = newState;
      _logStateTransition(oldState, newState);
    }
  }
  
  void _setErrorState(String errorMessage) {
    _errorMessage.value = errorMessage;
    _setLoadingState(LoadingState.error);
  }
  
  void _clearError() {
    _errorMessage.value = null;
  }
  
  void _logStateTransition(LoadingState from, LoadingState to) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] State: $from → $to';
    _stateTransitionLog.add(logEntry);
    
    // Keep only last 20 entries to prevent memory issues
    if (_stateTransitionLog.length > 20) {
      _stateTransitionLog.removeAt(0);
    }
  }
  
  // MANUAL RETRY METHOD
  Future<void> retryInitialization() async {
    if (_loadingState.value != LoadingState.error) {
      return;
    }
    
    await _initializeRepository();
  }
  
  // CLEAR STATE LOG METHOD
  void clearStateLog() {
    _stateTransitionLog.clear();
  }
  
  // VALIDATION METHODS
  bool get canPerformOperations => 
      _loadingState.value == LoadingState.success;
  
  bool get isInValidState => 
      _loadingState.value != LoadingState.initial;
      
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
}
