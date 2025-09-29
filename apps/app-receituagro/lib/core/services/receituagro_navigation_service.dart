import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../navigation/agricultural_navigation_extension.dart';
import '../navigation/agricultural_page_types.dart';

/// Unified navigation service for ReceitaAgro that combines core navigation
/// with agricultural domain-specific functionality
class ReceitaAgroNavigationService {
  final EnhancedNavigationService _coreService;
  final AgriculturalNavigationExtension _agricExtension;

  ReceitaAgroNavigationService({
    required EnhancedNavigationService coreService,
    required AgriculturalNavigationExtension agricExtension,
  }) : _coreService = coreService,
       _agricExtension = agricExtension {
    // Register agricultural extension with core service
    _coreService.registerExtension(_agricExtension);
  }

  /// Current navigation state
  NavigationState? get currentState => _coreService.currentState;

  /// Stream of navigation state changes
  Stream<NavigationState> get navigationStateStream =>
      _coreService.navigationStateStream;

  /// Current navigation stack
  List<NavigationState> get navigationStack => _coreService.navigationStack;

  /// Navigation history
  List<NavigationHistoryEntry> get navigationHistory => _coreService.navigationHistory;

  /// Is currently navigating
  bool get isNavigating => _coreService.isNavigating;

  /// Dispose resources
  void dispose() {
    _coreService.unregisterExtension(_agricExtension.extensionId);
    _coreService.dispose();
  }

  // ==========================================================================
  // DEFENSIVOS NAVIGATION (Migrated from AppNavigationProvider)
  // ==========================================================================

  /// Navigate to defensivos list
  Future<void> navigateToListaDefensivos({
    String? categoria,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/defensivos',
      pageType: AgriculturalPageType.listaDefensivos.value,
      arguments: {
        if (categoria != null) 'categoria': categoria,
        ...?extraData,
      },
    );
  }

  /// Navigate to defensivos grouped by category
  Future<void> navigateToDefensivosAgrupados({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/defensivos-agrupados',
      pageType: AgriculturalPageType.defensivosAgrupados.value,
      arguments: extraData,
    );
  }

  /// Navigate to defensivos by category
  Future<void> navigateToDefensivosCategoria({
    required String categoria,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/defensivos-categoria',
      pageType: AgriculturalPageType.defensivosCategoria.value,
      arguments: {
        'categoria': categoria,
        ...?extraData,
      },
    );
  }

  /// Navigate to defensivo detail
  Future<void> navigateToDetalheDefensivo({
    required String defensivoName,
    String? defensivoId,
    Map<String, dynamic>? extraData,
  }) async {
    debugPrint('=== RECEITA AGRO NAVIGATION SERVICE ===');
    debugPrint('Navegando para: /detalhe-defensivo');
    debugPrint('Defensivo Name: $defensivoName');
    debugPrint('Defensivo ID: $defensivoId');
    debugPrint('Extra Data: $extraData');
    
    final arguments = {
      'defensivoName': defensivoName,
      if (defensivoId != null) 'defensivoId': defensivoId,
      ...?extraData,
    };
    debugPrint('Arguments: $arguments');

    await _coreService.navigateTo<void>(
      '/detalhe-defensivo',
      pageType: AgriculturalPageType.detalheDefensivo.value,
      arguments: arguments,
    );
  }

  /// Navigate to defensivos search
  Future<void> navigateToDefensivosSearch({
    String? initialQuery,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/defensivos-search',
      pageType: AgriculturalPageType.defensivosSearch.value,
      arguments: {
        if (initialQuery != null) 'query': initialQuery,
        ...?extraData,
      },
    );
  }

  /// Navigate to defensivos advanced search
  Future<void> navigateToDefensivosAdvancedSearch({
    Map<String, dynamic>? filters,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/defensivos-advanced-search',
      pageType: AgriculturalPageType.defensivosAdvancedSearch.value,
      arguments: {
        if (filters != null) 'filters': filters,
        ...?extraData,
      },
    );
  }

  // ==========================================================================
  // PRAGAS NAVIGATION (Migrated from AppNavigationProvider)
  // ==========================================================================

  /// Navigate to pragas list
  Future<void> navigateToListaPragas({
    String? categoria,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/pragas',
      pageType: AgriculturalPageType.listaPragas.value,
      arguments: {
        if (categoria != null) 'categoria': categoria,
        ...?extraData,
      },
    );
  }

  /// Navigate to pragas grouped by category
  Future<void> navigateToPragasAgrupadas({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/pragas-agrupadas',
      pageType: AgriculturalPageType.pragasAgrupadas.value,
      arguments: extraData,
    );
  }

  /// Navigate to pragas by category
  Future<void> navigateToPragasCategoria({
    required String categoria,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/pragas-categoria',
      pageType: AgriculturalPageType.pragasCategoria.value,
      arguments: {
        'categoria': categoria,
        ...?extraData,
      },
    );
  }

  /// Navigate to praga detail
  Future<void> navigateToDetalhePraga({
    required String pragaName,
    String? pragaId,
    String? pragaScientificName,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/praga-detail',
      pageType: AgriculturalPageType.detalhePraga.value,
      arguments: {
        'pragaName': pragaName,
        if (pragaId != null) 'pragaId': pragaId,
        if (pragaScientificName != null) 'pragaScientificName': pragaScientificName,
        ...?extraData,
      },
    );
  }

  /// Navigate to pragas search
  Future<void> navigateToPragasSearch({
    String? initialQuery,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/pragas-search',
      pageType: AgriculturalPageType.pragasSearch.value,
      arguments: {
        if (initialQuery != null) 'query': initialQuery,
        ...?extraData,
      },
    );
  }

  /// Navigate to pragas advanced search
  Future<void> navigateToPragasAdvancedSearch({
    Map<String, dynamic>? filters,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/pragas-advanced-search',
      pageType: AgriculturalPageType.pragasAdvancedSearch.value,
      arguments: {
        if (filters != null) 'filters': filters,
        ...?extraData,
      },
    );
  }

  // ==========================================================================
  // CULTURAS NAVIGATION (Migrated from AppNavigationProvider)
  // ==========================================================================

  /// Navigate to culturas list
  Future<void> navigateToListaCulturas({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/culturas',
      pageType: AgriculturalPageType.listaCulturas.value,
      arguments: extraData,
    );
  }

  /// Navigate to culturas grouped
  Future<void> navigateToCulturasAgrupadas({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/culturas-agrupadas',
      pageType: AgriculturalPageType.culturasAgrupadas.value,
      arguments: extraData,
    );
  }

  /// Navigate to cultura detail
  Future<void> navigateToDetalheCultura({
    required String culturaName,
    String? culturaId,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/cultura-detail',
      pageType: AgriculturalPageType.detalheCultura.value,
      arguments: {
        'culturaName': culturaName,
        if (culturaId != null) 'culturaId': culturaId,
        ...?extraData,
      },
    );
  }

  /// Navigate to culturas search
  Future<void> navigateToCulturasSearch({
    String? initialQuery,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/culturas-search',
      pageType: AgriculturalPageType.culturasSearch.value,
      arguments: {
        if (initialQuery != null) 'query': initialQuery,
        ...?extraData,
      },
    );
  }

  // ==========================================================================
  // DIAGNOSTICOS NAVIGATION
  // ==========================================================================

  /// Navigate to diagnosticos list
  Future<void> navigateToListaDiagnosticos({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/diagnosticos',
      pageType: AgriculturalPageType.listaDiagnosticos.value,
      arguments: extraData,
    );
  }

  /// Navigate to diagnostico detail
  Future<void> navigateToDetalheDiagnostico({
    required String diagnosticoId,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/diagnostico-detail',
      pageType: AgriculturalPageType.detalheDiagnostico.value,
      arguments: {
        'diagnosticoId': diagnosticoId,
        ...?extraData,
      },
    );
  }

  /// Navigate to diagnostico wizard
  Future<void> navigateToDiagnosticoWizard({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/diagnostico-wizard',
      pageType: AgriculturalPageType.diagnosticoWizard.value,
      arguments: extraData,
    );
  }

  // ==========================================================================
  // FAVORITES NAVIGATION
  // ==========================================================================

  /// Navigate to favorites main page
  Future<void> navigateToFavoritos({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/favoritos',
      pageType: AgriculturalPageType.favoritos.value,
      arguments: extraData,
    );
  }

  /// Navigate to favorites defensivos
  Future<void> navigateToFavoritosDefensivos({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/favoritos-defensivos',
      pageType: AgriculturalPageType.favoritosDefensivos.value,
      arguments: extraData,
    );
  }

  /// Navigate to favorites pragas
  Future<void> navigateToFavoritosPragas({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/favoritos-pragas',
      pageType: AgriculturalPageType.favoritosPragas.value,
      arguments: extraData,
    );
  }

  /// Navigate to favorites culturas
  Future<void> navigateToFavoritosCulturas({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/favoritos-culturas',
      pageType: AgriculturalPageType.favoritosCulturas.value,
      arguments: extraData,
    );
  }

  // ==========================================================================
  // SETTINGS AND USER NAVIGATION
  // ==========================================================================

  /// Navigate to settings
  Future<void> navigateToSettings({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/settings',
      pageType: AgriculturalPageType.settings.value,
      arguments: extraData,
    );
  }

  /// Navigate to profile
  Future<void> navigateToProfile({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/profile',
      pageType: AgriculturalPageType.profile.value,
      arguments: extraData,
    );
  }

  /// Navigate to premium page (using core service)
  Future<void> navigateToPremium({
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateToPremium<void>();
  }

  // ==========================================================================
  // SEARCH NAVIGATION
  // ==========================================================================

  /// Navigate to global search
  Future<void> navigateToGlobalSearch({
    String? initialQuery,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/search',
      pageType: AgriculturalPageType.globalSearch.value,
      arguments: {
        if (initialQuery != null) 'query': initialQuery,
        ...?extraData,
      },
    );
  }

  /// Navigate to advanced filters
  Future<void> navigateToAdvancedFilters({
    Map<String, dynamic>? currentFilters,
    Map<String, dynamic>? extraData,
  }) async {
    await _coreService.navigateTo<void>(
      '/advanced-filters',
      pageType: AgriculturalPageType.advancedFilters.value,
      arguments: {
        if (currentFilters != null) 'currentFilters': currentFilters,
        ...?extraData,
      },
    );
  }

  // ==========================================================================
  // CORE NAVIGATION METHODS (Proxy to core service)
  // ==========================================================================

  /// Navigate to route with optional page type
  Future<T?> navigateTo<T>(
    String routeName, {
    Object? arguments,
    String? pageType,
    NavigationConfiguration? configuration,
  }) async {
    return await _coreService.navigateTo<T>(
      routeName,
      arguments: arguments,
      pageType: pageType,
      configuration: configuration,
    );
  }

  /// Push page to navigation stack
  Future<T?> push<T>(
    Widget page, {
    String? pageType,
    Map<String, dynamic>? arguments,
    NavigationConfiguration? configuration,
  }) async {
    return await _coreService.push<T>(
      page,
      pageType: pageType,
      arguments: arguments,
      configuration: configuration,
    );
  }

  /// Go back in navigation
  Future<T?> goBack<T>([T? result]) async {
    return await _coreService.goBack<T>(result);
  }

  /// Navigate and replace current page
  Future<T?> navigateAndReplace<T>(
    String routeName, {
    Object? arguments,
    String? pageType,
    NavigationConfiguration? configuration,
  }) async {
    return await _coreService.navigateAndReplace<T>(
      routeName,
      arguments: arguments,
      pageType: pageType,
      configuration: configuration,
    );
  }

  /// Navigate and clear all previous pages
  Future<T?> navigateAndClearStack<T>(
    String routeName, {
    Object? arguments,
    String? pageType,
    NavigationConfiguration? configuration,
  }) async {
    return await _coreService.navigateAndClearStack<T>(
      routeName,
      arguments: arguments,
      pageType: pageType,
      configuration: configuration,
    );
  }

  /// Check if can go back
  bool canGoBack() {
    return _coreService.canGoBack();
  }

  /// Get navigation path
  List<String> getNavigationPath() {
    return _coreService.getNavigationPath();
  }

  /// Get current page configuration
  NavigationConfiguration? getCurrentConfiguration() {
    return _coreService.getCurrentConfiguration();
  }

  /// Show snackbar (using core service)
  void showSnackBar(String message, {Color? backgroundColor}) {
    _coreService.showSnackBar(message, backgroundColor: backgroundColor);
  }

  /// Open external URL (using core service)
  Future<void> openUrl(String url) async {
    await _coreService.openUrl(url);
  }

  /// Get session analytics
  Map<String, dynamic> getSessionAnalytics() {
    return _coreService.getSessionAnalytics();
  }

  /// Clear navigation history
  void clearHistory() {
    _coreService.clearHistory();
  }

  // ==========================================================================
  // COMPATIBILITY METHODS (Migrated from AppNavigationProvider)
  // ==========================================================================

  /// Update bottom navigation visibility (stored in configuration)
  void updateBottomNavigationVisibility(bool visible) {
    // This functionality is now handled by NavigationConfiguration
    // in each page's configuration
  }

  /// Get bottom navigation visibility
  bool getBottomNavigationVisibility() {
    final config = getCurrentConfiguration();
    return config?.showBottomNavigation ?? true;
  }

  /// Show loading state
  Future<void> showLoading() async {
    await _coreService.navigateTo<void>(
      '/loading',
      pageType: AgriculturalPageType.loading.value,
    );
  }

  /// Hide loading state
  Future<void> hideLoading() async {
    if (canGoBack()) {
      await goBack<void>();
    }
  }
}