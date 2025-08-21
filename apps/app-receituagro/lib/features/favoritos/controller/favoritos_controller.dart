import 'package:flutter/material.dart';
import '../models/favoritos_data.dart';
import '../models/view_mode.dart';
import '../models/favorito_defensivo_model.dart';
import '../models/favorito_praga_model.dart';
import '../models/favorito_diagnostico_model.dart';
import '../services/favoritos_data_service.dart';
import '../services/favoritos_search_service.dart';
import '../services/favoritos_ui_state_service.dart';

abstract class INavigationService {
  void navigateToDefensivoDetails(String id);
  void navigateToPragaDetails(String id);
  void navigateToDiagnosticoDetails(String id);
}

abstract class IFavoritosNotificationService {
  void showSuccess(String message);
  void showError(String message);
  void showInfo(String message);
}

class FavoritosController extends ChangeNotifier with WidgetsBindingObserver {
  late final FavoritosDataService _dataService;
  late final FavoritosSearchService _searchService;
  late final FavoritosUIStateService _uiStateService;
  late final INavigationService? _navigationService;
  late final IFavoritosNotificationService? _notificationService;

  FavoritosController({
    required FavoritosDataService dataService,
    required FavoritosSearchService searchService,
    required FavoritosUIStateService uiStateService,
    INavigationService? navigationService,
    IFavoritosNotificationService? notificationService,
  }) : _dataService = dataService,
       _searchService = searchService,
       _uiStateService = uiStateService,
       _navigationService = navigationService,
       _notificationService = notificationService {
    
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
    
    // Listen to services changes
    _dataService.addListener(_notifyListeners);
    _searchService.addListener(_notifyListeners);
    _uiStateService.addListener(_notifyListeners);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  FavoritosData get favoritosData => _dataService.favoritosData;
  bool get isLoading => _dataService.isLoading;
  String get errorMessage => _dataService.errorMessage;
  bool get hasError => _dataService.hasError;

  ViewMode get currentViewMode => _uiStateService.currentViewMode;
  int get currentTabIndex => _uiStateService.currentTabIndex;

  Future<void> _initializeData() async {
    await _dataService.loadAllFavorites();
  }

  void onTabChanged(int tabIndex) {
    _uiStateService.setCurrentTab(tabIndex);
  }

  void toggleViewMode(ViewMode mode) {
    _uiStateService.toggleViewMode(mode);
  }

  ViewMode getViewModeForTab(int tabIndex) {
    return _uiStateService.getViewModeForTab(tabIndex);
  }

  TextEditingController getSearchControllerForTab(int tabIndex) {
    return _searchService.getControllerForTab(tabIndex);
  }

  void onSearchChanged(int tabIndex, String searchText) {
    _searchService.onSearchChanged(tabIndex, searchText);
  }

  void clearSearch(int tabIndex) {
    _searchService.clearSearch(tabIndex);
  }

  bool hasActiveSearch(int tabIndex) {
    return _searchService.hasActiveSearch(tabIndex);
  }

  String getSearchHintForTab(int tabIndex) {
    return _searchService.getHintForTab(tabIndex);
  }

  void goToDefensivoDetails(FavoritoDefensivoModel defensivo) {
    _navigationService?.navigateToDefensivoDetails(defensivo.idReg);
  }

  void goToPragaDetails(FavoritoPragaModel praga) {
    _navigationService?.navigateToPragaDetails(praga.idReg);
  }

  void goToDiagnosticoDetails(FavoritoDiagnosticoModel diagnostico) {
    _navigationService?.navigateToDiagnosticoDetails(diagnostico.idReg);
  }

  Future<void> removeFavoritoDefensivo(FavoritoDefensivoModel defensivo) async {
    try {
      await _dataService.removeFavoritoDefensivo(defensivo.id);
      final message = '${defensivo.displayName} foi removido dos favoritos';
      if (_notificationService != null) {
        _notificationService.showSuccess(message);
      } else {
        debugPrint('Removido: $message');
      }
    } catch (e) {
      const message = 'Não foi possível remover dos favoritos';
      if (_notificationService != null) {
        _notificationService.showError(message);
      } else {
        debugPrint('Erro: $message');
      }
    }
  }

  Future<void> removeFavoritoPraga(FavoritoPragaModel praga) async {
    try {
      await _dataService.removeFavoritoPraga(praga.id);
      final message = '${praga.displayName} foi removido dos favoritos';
      if (_notificationService != null) {
        _notificationService.showSuccess(message);
      } else {
        debugPrint('Removido: $message');
      }
    } catch (e) {
      const message = 'Não foi possível remover dos favoritos';
      if (_notificationService != null) {
        _notificationService.showError(message);
      } else {
        debugPrint('Erro: $message');
      }
    }
  }

  Future<void> removeFavoritoDiagnostico(FavoritoDiagnosticoModel diagnostico) async {
    try {
      await _dataService.removeFavoritoDiagnostico(diagnostico.id);
      final message = '${diagnostico.displayName} foi removido dos favoritos';
      if (_notificationService != null) {
        _notificationService.showSuccess(message);
      } else {
        debugPrint('Removido: $message');
      }
    } catch (e) {
      const message = 'Não foi possível remover dos favoritos';
      if (_notificationService != null) {
        _notificationService.showError(message);
      } else {
        debugPrint('Erro: $message');
      }
    }
  }

  Future<void> refreshFavorites() async {
    await _dataService.loadAllFavorites();
  }

  Future<void> retryInitialization() async {
    await _initializeData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshFavorites();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dataService.removeListener(_notifyListeners);
    _searchService.removeListener(_notifyListeners);
    _uiStateService.removeListener(_notifyListeners);
    super.dispose();
  }
}