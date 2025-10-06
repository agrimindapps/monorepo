import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import 'agricultural_page_types.dart';

/// Agricultural navigation extension for ReceitaAgro domain-specific navigation
class AgriculturalNavigationExtension implements INavigationExtension {
  static const String _extensionId = 'receituagro_agricultural';
  static const String _extensionName = 'ReceitaAgro Agricultural Navigation';

  AgriculturalNavigationExtension();

  @override
  String get extensionId => _extensionId;

  @override
  String get extensionName => _extensionName;

  @override
  Future<NavigationConfiguration?> processNavigationRequest(
    String pageType,
    Map<String, dynamic>? arguments,
  ) async {
    final agriculturalPageType = AgriculturalPageType.fromString(pageType);
    if (agriculturalPageType == null) {
      return null; // Not an agricultural page type
    }
    return NavigationConfiguration(
      showBottomNavigation: agriculturalPageType.shouldShowBottomNavigation,
      showBackButton: agriculturalPageType.canGoBack,
      canGoBack: agriculturalPageType.canGoBack,
      customAppBarTitle: _getCustomTitle(agriculturalPageType, arguments),
      showAppBar: _shouldShowAppBar(agriculturalPageType),
      showLoading: _shouldShowLoading(agriculturalPageType),
      extensionData: {
        'agricultural_page_type': agriculturalPageType.value,
        'category': agriculturalPageType.category.toString(),
        'is_detail_page': agriculturalPageType.isDetailPage,
        'is_search_page': agriculturalPageType.isSearchPage,
      },
    );
  }

  @override
  Future<bool> handleCustomNavigation(
    String pageType,
    Map<String, dynamic>? arguments,
  ) async {
    final agriculturalPageType = AgriculturalPageType.fromString(pageType);
    if (agriculturalPageType == null) {
      return false;
    }
    switch (agriculturalPageType) {
      case AgriculturalPageType.detalheDefensivo:
        return await _handleDefensivoDetailNavigation(arguments);

      case AgriculturalPageType.detalhePraga:
        return await _handlePragaDetailNavigation(arguments);

      case AgriculturalPageType.detalheCultura:
        return await _handleCulturaDetailNavigation(arguments);

      case AgriculturalPageType.diagnosticoWizard:
        return await _handleDiagnosticoWizardNavigation(arguments);

      case AgriculturalPageType.premium:
        return await _handlePremiumNavigation(arguments);

      default:
        return false; // Let core service handle
    }
  }

  @override
  String? getCustomPageTitle(
    String pageType,
    Map<String, dynamic>? arguments,
  ) {
    final agriculturalPageType = AgriculturalPageType.fromString(pageType);
    if (agriculturalPageType == null) {
      return null;
    }

    return _getCustomTitle(agriculturalPageType, arguments);
  }

  @override
  bool validateNavigationArguments(
    String pageType,
    Map<String, dynamic>? arguments,
  ) {
    final agriculturalPageType = AgriculturalPageType.fromString(pageType);
    if (agriculturalPageType == null) {
      return true; // Not our responsibility
    }
    switch (agriculturalPageType) {
      case AgriculturalPageType.detalheDefensivo:
        return _validateDefensivoArguments(arguments);

      case AgriculturalPageType.detalhePraga:
        return _validatePragaArguments(arguments);

      case AgriculturalPageType.detalheCultura:
        return _validateCulturaArguments(arguments);

      case AgriculturalPageType.defensivosCategoria:
      case AgriculturalPageType.pragasCategoria:
        return arguments?.containsKey('categoria') ?? false;

      case AgriculturalPageType.diagnosticoWizard:
        return _validateDiagnosticoArguments(arguments);

      default:
        return true; // Most pages don't need special validation
    }
  }

  @override
  Map<String, dynamic>? getAnalyticsMetadata(
    String pageType,
    Map<String, dynamic>? arguments,
  ) {
    final agriculturalPageType = AgriculturalPageType.fromString(pageType);
    if (agriculturalPageType == null) {
      return null;
    }

    final metadata = <String, dynamic>{
      'agricultural_page_type': agriculturalPageType.value,
      'category': agriculturalPageType.category.toString(),
      'is_detail_page': agriculturalPageType.isDetailPage,
      'is_list_page': agriculturalPageType.isListPage,
      'is_search_page': agriculturalPageType.isSearchPage,
    };
    if (agriculturalPageType.isDefensivoPage && arguments != null) {
      metadata['defensivo_name'] = arguments['defensivoName'];
      metadata['defensivo_id'] = arguments['defensivoId'];
      metadata['categoria'] = arguments['categoria'];
    }

    if (agriculturalPageType.isPragaPage && arguments != null) {
      metadata['praga_name'] = arguments['pragaName'];
      metadata['praga_scientific_name'] = arguments['pragaScientificName'];
      metadata['categoria'] = arguments['categoria'];
    }

    if (agriculturalPageType.isCulturaPage && arguments != null) {
      metadata['cultura_name'] = arguments['culturaName'];
      metadata['cultura_id'] = arguments['culturaId'];
    }

    return metadata;
  }

  @override
  Future<bool> handleBackNavigation(NavigationState currentState) async {
    final agriculturalPageType = AgriculturalPageType.fromString(
      currentState.pageType,
    );

    if (agriculturalPageType == null) {
      return false;
    }
    switch (agriculturalPageType) {
      case AgriculturalPageType.diagnosticoWizard:
        return await _handleDiagnosticoWizardBack(currentState);

      case AgriculturalPageType.premium:
        return await _handlePremiumBack(currentState);

      default:
        return false; // Use default back navigation
    }
  }

  @override
  List<String> getSupportedPageTypes() {
    return AgriculturalPageType.values.map((type) => type.value).toList();
  }

  @override
  void dispose() {
    debugPrint('AgriculturalNavigationExtension disposed');
  }

  /// Get custom title for agricultural page types
  String? _getCustomTitle(
    AgriculturalPageType pageType,
    Map<String, dynamic>? arguments,
  ) {
    switch (pageType) {
      case AgriculturalPageType.detalheDefensivo:
        return (arguments?['defensivoName'] as String?) ?? pageType.defaultTitle;

      case AgriculturalPageType.detalhePraga:
        return (arguments?['pragaName'] as String?) ?? pageType.defaultTitle;

      case AgriculturalPageType.detalheCultura:
        return (arguments?['culturaName'] as String?) ?? pageType.defaultTitle;

      case AgriculturalPageType.defensivosCategoria:
        return 'Defensivos - ${arguments?['categoria'] ?? 'Categoria'}';

      case AgriculturalPageType.pragasCategoria:
        return 'Pragas - ${arguments?['categoria'] ?? 'Categoria'}';

      default:
        return pageType.defaultTitle;
    }
  }

  /// Check if app bar should be shown for page type
  bool _shouldShowAppBar(AgriculturalPageType pageType) {
    switch (pageType) {
      case AgriculturalPageType.loading:
      case AgriculturalPageType.modal:
      case AgriculturalPageType.popup:
        return false;
      default:
        return true;
    }
  }

  /// Check if loading state should be shown
  bool _shouldShowLoading(AgriculturalPageType pageType) {
    return pageType == AgriculturalPageType.loading;
  }

  /// Handle defensivo detail navigation
  Future<bool> _handleDefensivoDetailNavigation(
    Map<String, dynamic>? arguments,
  ) async {
    if (arguments == null) return false;

    final defensivoName = arguments['defensivoName'] as String?;
    if (defensivoName == null) return false;

    try {
      return false;
    } catch (error) {
      debugPrint('Failed to handle defensivo detail navigation: $error');
      return false;
    }
  }

  /// Handle praga detail navigation
  Future<bool> _handlePragaDetailNavigation(
    Map<String, dynamic>? arguments,
  ) async {
    if (arguments == null) return false;

    final pragaName = arguments['pragaName'] as String?;
    if (pragaName == null) return false;

    try {
      return false;
    } catch (error) {
      debugPrint('Failed to handle praga detail navigation: $error');
      return false;
    }
  }

  /// Handle cultura detail navigation
  Future<bool> _handleCulturaDetailNavigation(
    Map<String, dynamic>? arguments,
  ) async {
    if (arguments == null) return false;

    final culturaName = arguments['culturaName'] as String?;
    if (culturaName == null) return false;

    try {
      return false;
    } catch (error) {
      debugPrint('Failed to handle cultura detail navigation: $error');
      return false;
    }
  }

  /// Handle diagnostico wizard navigation
  Future<bool> _handleDiagnosticoWizardNavigation(
    Map<String, dynamic>? arguments,
  ) async {
    try {
      return false;
    } catch (error) {
      debugPrint('Failed to handle diagnostico wizard navigation: $error');
      return false;
    }
  }

  /// Handle premium navigation
  Future<bool> _handlePremiumNavigation(
    Map<String, dynamic>? arguments,
  ) async {
    return false;
  }

  /// Handle diagnostico wizard back navigation
  Future<bool> _handleDiagnosticoWizardBack(NavigationState currentState) async {
    return false;
  }

  /// Handle premium page back navigation
  Future<bool> _handlePremiumBack(NavigationState currentState) async {
    debugPrint('User exited premium page');
    return false; // Use default back navigation
  }

  /// Validate defensivo arguments
  bool _validateDefensivoArguments(Map<String, dynamic>? arguments) {
    if (arguments == null) return false;
    return arguments.containsKey('defensivoName') ||
           arguments.containsKey('defensivoId');
  }

  /// Validate praga arguments
  bool _validatePragaArguments(Map<String, dynamic>? arguments) {
    if (arguments == null) return false;
    return arguments.containsKey('pragaName') ||
           arguments.containsKey('pragaId');
  }

  /// Validate cultura arguments
  bool _validateCulturaArguments(Map<String, dynamic>? arguments) {
    if (arguments == null) return false;
    return arguments.containsKey('culturaName') ||
           arguments.containsKey('culturaId');
  }

  /// Validate diagnostico arguments
  bool _validateDiagnosticoArguments(Map<String, dynamic>? arguments) {
    return true;
  }
}
