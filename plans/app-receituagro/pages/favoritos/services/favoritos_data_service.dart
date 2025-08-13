// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/favoritos_repository.dart';
import '../../../services/premium_service.dart';
import '../models/favoritos_data.dart';

/// Service responsible for data loading and management
/// Follows Single Responsibility Principle by handling only data operations
class FavoritosDataService extends GetxService {
  // =========================================================================
  // Dependencies
  // =========================================================================
  FavoritosRepository? _repository;
  PremiumService? _premiumService;

  // =========================================================================
  // Observable State
  // =========================================================================
  final _favoritosData = FavoritosData().obs;
  final _isLoading = true.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  // =========================================================================
  // Getters
  // =========================================================================
  FavoritosData get favoritosData => _favoritosData.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isPremium => _premiumService?.isPremium ?? false;

  // Verifica se há favoritos salvos
  bool get hasAnyFavorites =>
      favoritosData.defensivos.isNotEmpty ||
      favoritosData.pragas.isNotEmpty ||
      favoritosData.diagnosticos.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
  }

  // =========================================================================
  // Dependency Initialization
  // =========================================================================
  void _initDependencies() {
    try {
      // Para repositórios, verificar se já estão registrados globalmente
      if (!Get.isRegistered<FavoritosRepository>()) {
        debugPrint('FavoritosRepository não está registrado. Registrando...');
        Get.put<FavoritosRepository>(FavoritosRepository(), permanent: true);
      }

      _repository = Get.find<FavoritosRepository>();

      // Para PremiumService, tentar diferentes estratégias
      try {
        if (Get.isRegistered<PremiumService>()) {
          _premiumService = Get.find<PremiumService>();
        } else {
          debugPrint('PremiumService não registrado, criando novo...');
          _premiumService = Get.put<PremiumService>(PremiumService());
          _premiumService?.init();
        }
      } catch (e) {
        debugPrint('Erro ao obter PremiumService: $e');
        // Fallback: criar uma instância simples
        _premiumService = PremiumService();
        _premiumService?.init();
      }

    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = 'Erro ao inicializar dependências: $e';
    }
  }

  // =========================================================================
  // Public Data Loading Methods
  // =========================================================================
  
  /// Loads all favorites data with performance monitoring
  Future<void> loadAllFavorites() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _isLoading.value = true; // Mantém estado interno, UI não mostra loading
      _hasError.value = false;
      _errorMessage.value = '';

      await _premiumService?.verificarStatusPremium();

      // Executar carregamentos em paralelo para máxima performance
      await Future.wait([
        _carregarFavoritosDefensivos(),
        _carregarFavoritosPragas(),
        _carregarFavoritosDiagnosticos()
      ]);
      
      stopwatch.stop();
      
    } catch (e) {
      stopwatch.stop();
      _hasError.value = true;
      _errorMessage.value = 'Erro ao carregar favoritos: $e';
    } finally {
      _isLoading.value = false; // Finaliza estado interno
    }
  }

  /// Public method to refresh all favorites data
  /// Useful when the user marks/unmarks favorites in other pages
  Future<void> refreshFavorites() async {
    await loadAllFavorites();
  }

  /// Retry initialization after error
  Future<void> retryInitialization() async {
    _hasError.value = false;
    _errorMessage.value = '';
    await loadAllFavorites();
  }

  // =========================================================================
  // Private Data Loading Methods
  // =========================================================================

  Future<void> _carregarFavoritosDefensivos() async {
    try {
      final dados = await _repository?.getFavoritosDefensivos() ?? [];
      _favoritosData.value = _favoritosData.value.copyWith(
        defensivos: dados,
      );
    } catch (e) {
      // Error loading defensivos favorites - continue with empty list
    }
  }

  Future<void> _carregarFavoritosPragas() async {
    try {
      final dados = await _repository?.getFavoritosPragas() ?? [];
      _favoritosData.value = _favoritosData.value.copyWith(
        pragas: dados,
      );
    } catch (e) {
      // Error loading pragas favorites - continue with empty list
    }
  }

  Future<void> _carregarFavoritosDiagnosticos() async {
    try {
      if (_premiumService?.isPremium != true) {
        debugPrint('⚠️ FavoritosDataService: Usuário não premium, pulando diagnósticos');
        return;
      }

      final dados = await _repository?.getFavoritosDiagnosticos() ?? [];
      _favoritosData.value = _favoritosData.value.copyWith(
        diagnosticos: dados,
      );
    } catch (e) {
      // Error loading diagnosticos favorites - continue with empty list
    }
  }

  // =========================================================================
  // Data Update Methods
  // =========================================================================

  /// Updates favorites data with new filters
  void updateFavoritosData(FavoritosData newData) {
    _favoritosData.value = newData;
  }

  /// Updates specific filter
  void updateDefensivosFilter(String filter) {
    _favoritosData.value = _favoritosData.value.copyWith(
      defensivosFilter: filter,
    );
  }

  void updatePragasFilter(String filter) {
    _favoritosData.value = _favoritosData.value.copyWith(
      pragasFilter: filter,
    );
  }

  void updateDiagnosticosFilter(String filter) {
    _favoritosData.value = _favoritosData.value.copyWith(
      diagnosticosFilter: filter,
    );
  }
}
