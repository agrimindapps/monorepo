/// Agricultural-specific page types for ReceitaAgro navigation
enum AgriculturalPageType {
  home('home'),
  dashboard('dashboard'),
  listaDefensivos('lista_defensivos'),
  defensivosAgrupados('defensivos_agrupados'),
  defensivosCategoria('defensivos_categoria'),
  detalheDefensivo('detalhe_defensivo'),
  defensivosSearch('defensivos_search'),
  defensivosAdvancedSearch('defensivos_advanced_search'),
  listaPragas('lista_pragas'),
  pragasAgrupadas('pragas_agrupadas'),
  pragasCategoria('pragas_categoria'),
  detalhePraga('detalhe_praga'),
  pragasSearch('pragas_search'),
  pragasAdvancedSearch('pragas_advanced_search'),
  listaCulturas('lista_culturas'),
  culturasAgrupadas('culturas_agrupadas'),
  detalheCultura('detalhe_cultura'),
  culturasSearch('culturas_search'),
  listaDiagnosticos('lista_diagnosticos'),
  detalheDiagnostico('detalhe_diagnostico'),
  diagnosticoWizard('diagnostico_wizard'),
  diagnosticoResult('diagnostico_result'),
  favoritos('favoritos'),
  favoritosDefensivos('favoritos_defensivos'),
  favoritosPragas('favoritos_pragas'),
  favoritosCulturas('favoritos_culturas'),
  settings('settings'),
  profile('profile'),
  notifications('notifications'),
  about('about'),
  help('help'),
  premium('premium'),
  subscription('subscription'),
  cropManagement('crop_management'),
  pestTreatment('pest_treatment'),
  seasonalPlanning('seasonal_planning'),
  fieldOperations('field_operations'),
  globalSearch('global_search'),
  advancedFilters('advanced_filters'),
  loading('loading'),
  error('error'),
  offline('offline'),
  modal('modal'),
  popup('popup'),
  webView('web_view'),
  external('external');

  const AgriculturalPageType(this.value);

  final String value;

  @override
  String toString() => value;

  /// Get page type from string value
  static AgriculturalPageType? fromString(String value) {
    for (final type in AgriculturalPageType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }

  /// Check if page type is related to defensivos
  bool get isDefensivoPage {
    return [
      listaDefensivos,
      defensivosAgrupados,
      defensivosCategoria,
      detalheDefensivo,
      defensivosSearch,
      defensivosAdvancedSearch,
      favoritosDefensivos,
    ].contains(this);
  }

  /// Check if page type is related to pragas
  bool get isPragaPage {
    return [
      listaPragas,
      pragasAgrupadas,
      pragasCategoria,
      detalhePraga,
      pragasSearch,
      pragasAdvancedSearch,
      favoritosPragas,
    ].contains(this);
  }

  /// Check if page type is related to culturas
  bool get isCulturaPage {
    return [
      listaCulturas,
      culturasAgrupadas,
      detalheCultura,
      culturasSearch,
      favoritosCulturas,
    ].contains(this);
  }

  /// Check if page type is a detail page
  bool get isDetailPage {
    return [
      detalheDefensivo,
      detalhePraga,
      detalheCultura,
      detalheDiagnostico,
    ].contains(this);
  }

  /// Check if page type is a list page
  bool get isListPage {
    return [
      listaDefensivos,
      listaPragas,
      listaCulturas,
      listaDiagnosticos,
    ].contains(this);
  }

  /// Check if page type is a search page
  bool get isSearchPage {
    return [
      defensivosSearch,
      defensivosAdvancedSearch,
      pragasSearch,
      pragasAdvancedSearch,
      culturasSearch,
      globalSearch,
      advancedFilters,
    ].contains(this);
  }

  /// Check if page type should show bottom navigation
  bool get shouldShowBottomNavigation {
    return [
      home,
      dashboard,
      listaDefensivos,
      listaPragas,
      listaCulturas,
      favoritos,
      settings,
    ].contains(this);
  }

  /// Check if page type allows back navigation
  bool get canGoBack {
    return ![
      home,
      dashboard,
      loading,
    ].contains(this);
  }

  /// Get default page title
  String get defaultTitle {
    switch (this) {
      case home:
        return 'ReceitaAgro';
      case dashboard:
        return 'Dashboard';
      case listaDefensivos:
        return 'Defensivos';
      case defensivosAgrupados:
        return 'Defensivos por Categoria';
      case detalheDefensivo:
        return 'Detalhes do Defensivo';
      case listaPragas:
        return 'Pragas';
      case pragasAgrupadas:
        return 'Pragas por Categoria';
      case detalhePraga:
        return 'Detalhes da Praga';
      case listaCulturas:
        return 'Culturas';
      case detalheCultura:
        return 'Detalhes da Cultura';
      case listaDiagnosticos:
        return 'Diagnósticos';
      case detalheDiagnostico:
        return 'Detalhes do Diagnóstico';
      case favoritos:
        return 'Favoritos';
      case settings:
        return 'Configurações';
      case profile:
        return 'Perfil';
      case premium:
        return 'Premium';
      case globalSearch:
        return 'Buscar';
      default:
        return value.replaceAll('_', ' ').split(' ')
            .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }
}

/// Agricultural navigation categories for grouping related page types
enum AgriculturalNavigationCategory {
  main,
  defensivos,
  pragas,
  culturas,
  diagnosticos,
  favorites,
  settings,
  premium,
  workflows,
  search,
  system,
}

/// Extension methods for agricultural page type categorization
extension AgriculturalPageTypeExtension on AgriculturalPageType {
  /// Get the navigation category for this page type
  AgriculturalNavigationCategory get category {
    if (isDefensivoPage) return AgriculturalNavigationCategory.defensivos;
    if (isPragaPage) return AgriculturalNavigationCategory.pragas;
    if (isCulturaPage) return AgriculturalNavigationCategory.culturas;
    if (isSearchPage) return AgriculturalNavigationCategory.search;

    switch (this) {
      case AgriculturalPageType.home:
      case AgriculturalPageType.dashboard:
        return AgriculturalNavigationCategory.main;

      case AgriculturalPageType.listaDiagnosticos:
      case AgriculturalPageType.detalheDiagnostico:
      case AgriculturalPageType.diagnosticoWizard:
      case AgriculturalPageType.diagnosticoResult:
        return AgriculturalNavigationCategory.diagnosticos;

      case AgriculturalPageType.favoritos:
      case AgriculturalPageType.favoritosDefensivos:
      case AgriculturalPageType.favoritosPragas:
      case AgriculturalPageType.favoritosCulturas:
        return AgriculturalNavigationCategory.favorites;

      case AgriculturalPageType.settings:
      case AgriculturalPageType.profile:
      case AgriculturalPageType.notifications:
      case AgriculturalPageType.about:
      case AgriculturalPageType.help:
        return AgriculturalNavigationCategory.settings;

      case AgriculturalPageType.premium:
      case AgriculturalPageType.subscription:
        return AgriculturalNavigationCategory.premium;

      case AgriculturalPageType.cropManagement:
      case AgriculturalPageType.pestTreatment:
      case AgriculturalPageType.seasonalPlanning:
      case AgriculturalPageType.fieldOperations:
        return AgriculturalNavigationCategory.workflows;

      default:
        return AgriculturalNavigationCategory.system;
    }
  }
}
