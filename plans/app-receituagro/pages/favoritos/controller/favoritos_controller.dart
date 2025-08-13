// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/navigation/i_navigation_service.dart';
import '../../../models/favorito_model.dart';
import '../models/favoritos_data.dart';
import '../models/view_mode.dart';
import '../services/favoritos_data_service.dart';
import '../services/favoritos_search_service.dart';
import '../services/favoritos_ui_state_service.dart';

/// Refactored Controller following Single Responsibility Principle
/// Now acts as a coordinator between specialized services
class FavoritosController extends GetxController {
  // =========================================================================
  // Service Dependencies
  // =========================================================================
  late final FavoritosDataService _dataService;
  late final FavoritosSearchService _searchService;
  late final INavigationService _navigationService;
  late final FavoritosUIStateService _uiStateService;

  // =========================================================================
  // State Management
  // =========================================================================
  final _initialized = false.obs;

  // =========================================================================
  // Delegated Getters - Coordinating between services
  // =========================================================================

  // Data Service Delegates
  FavoritosData get favoritosData => _dataService.favoritosData;
  bool get isLoading => _dataService.isLoading;
  bool get hasError => _dataService.hasError;
  String get errorMessage => _dataService.errorMessage;
  bool get isPremium => _dataService.isPremium;
  bool get hasAnyFavorites => _dataService.hasAnyFavorites;

  // UI State Service Delegates
  ViewMode get currentViewMode => _uiStateService.currentViewMode;
  int get currentTabIndex => _uiStateService.currentTabIndex;
  List<String> get tabTitles => _uiStateService.tabTitles;

  // Search Service Delegates
  List<TextEditingController> get searchControllers =>
      _searchService.searchControllers;

  // Controller State
  @override
  bool get initialized => _initialized.value;

  @override
  void onInit() {
    super.onInit();
    try {
      _initServices();
      _initialized.value = true;
    } catch (e) {
      // Service initialization failed - continue with default state
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Delegate data loading to data service
    refreshFavorites();
  }

  @override
  void onClose() {
    // Dispose services to prevent memory leaks
    try {
      _searchService.dispose();
    } catch (e) {
      debugPrint('Error disposing search service: $e');
    }
    super.onClose();
  }

  // =========================================================================
  // Service Initialization
  // =========================================================================

  void _initServices() {
    try {
      // Find services that should be registered by binding
      _dataService = Get.find<FavoritosDataService>();
      _searchService = Get.find<FavoritosSearchService>();
      _navigationService = Get.find<INavigationService>();
      _uiStateService = Get.find<FavoritosUIStateService>();

    } catch (e) {
      rethrow;
    }
  }

  // =========================================================================
  // Data Loading Methods - Delegated to DataService
  // =========================================================================

  Future<void> loadAllFavorites() async {
    await _dataService.loadAllFavorites();
  }

  Future<void> refreshFavorites() async {
    await _dataService.refreshFavorites();
  }

  // =========================================================================
  // Filter Methods - Delegated to SearchService
  // =========================================================================

  void filtrarDefensivos(String query) =>
      _searchService.filtrarDefensivos(query);
  void filtrarPragas(String query) => _searchService.filtrarPragas(query);
  void filtrarDiagnosticos(String query) =>
      _searchService.filtrarDiagnosticos(query);
  void filterItems(int tabIndex, String query) =>
      _searchService.filterItems(tabIndex, query);

  // =========================================================================
  // Search Methods - Delegated to SearchService
  // =========================================================================

  void onSearchChanged(int tabIndex) =>
      _searchService.onSearchChanged(tabIndex);
  void clearSearch(int tabIndex) => _searchService.clearSearch(tabIndex);
  bool isSearchingForTab(int tabIndex) =>
      _searchService.isSearchingForTab(tabIndex);
  String getSearchTextForTab(int tabIndex) =>
      _searchService.getSearchTextForTab(tabIndex);

  // =========================================================================
  // View Mode Methods - Delegated to UIStateService
  // =========================================================================

  void toggleViewMode(ViewMode mode) => _uiStateService.toggleViewMode(mode);
  ViewMode getViewModeForTab(int tabIndex) =>
      _uiStateService.getViewModeForTab(tabIndex);

  // =========================================================================
  // Tab Navigation Methods - Delegated to UIStateService
  // =========================================================================

  void navigateToTab(int index) => _uiStateService.navigateToTab(index);

  // =========================================================================
  // Navigation Methods - Delegated to NavigationService
  // =========================================================================

  void goToDefensivoDetails(FavoritoDefensivoModel defensivo) =>
      _navigationService.navigateToDefensivoDetails(defensivo.id.toString());

  void goToPragaDetails(FavoritoPragaModel praga) =>
      _navigationService.navigateToPragaDetails(praga.id.toString());

  void goToDiagnosticoDetails(FavoritoDiagnosticoModel diagnostico) =>
      _navigationService.navigateToDiagnosticoDetails(diagnostico.id.toString());

  // =========================================================================
  // Error Handling - Delegated to DataService
  // =========================================================================

  void retryInitialization() => _dataService.retryInitialization();

  // =========================================================================
  // Helper Methods - Delegated to UIStateService
  // =========================================================================

  int getCrossAxisCount(BuildContext context) =>
      _uiStateService.getCrossAxisCount(context);
}
