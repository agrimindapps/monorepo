import 'package:flutter/foundation.dart';

import '../interfaces/i_navigation_extension.dart';
import '../models/navigation_state.dart';

/// Service for managing navigation configurations across the application
class NavigationConfigurationService implements INavigationConfiguration {
  final Map<String, NavigationConfiguration> _configurations = {};
  final Map<String, NavigationConfiguration> _defaultConfigurations = {};

  NavigationConfigurationService() {
    _initializeDefaultConfigurations();
  }

  @override
  NavigationConfiguration getDefaultConfiguration(String pageType) {
    return _defaultConfigurations[pageType] ??
        _defaultConfigurations['default'] ??
        const NavigationConfiguration();
  }

  @override
  void updateConfiguration(String pageType, NavigationConfiguration config) {
    _configurations[pageType] = config;
    debugPrint('Updated configuration for pageType: $pageType');
  }

  @override
  Map<String, NavigationConfiguration> getBulkConfiguration(
    List<String> pageTypes,
  ) {
    final result = <String, NavigationConfiguration>{};

    for (final pageType in pageTypes) {
      result[pageType] = getConfiguration(pageType);
    }

    return result;
  }

  @override
  void resetConfiguration() {
    _configurations.clear();
    debugPrint('Navigation configurations reset to defaults');
  }

  @override
  Map<String, dynamic> exportConfiguration() {
    final export = <String, dynamic>{};

    export['custom'] = _configurations.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    export['defaults'] = _defaultConfigurations.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    export['exportDate'] = DateTime.now().toIso8601String();

    return export;
  }

  @override
  void importConfiguration(Map<String, dynamic> config) {
    try {
      // Import custom configurations
      final custom = config['custom'] as Map<String, dynamic>?;
      if (custom != null) {
        _configurations.clear();
        custom.forEach((key, value) {
          _configurations[key] = NavigationConfiguration.fromJson(
            value as Map<String, dynamic>,
          );
        });
      }

      // Import default configurations if provided
      final defaults = config['defaults'] as Map<String, dynamic>?;
      if (defaults != null) {
        defaults.forEach((key, value) {
          _defaultConfigurations[key] = NavigationConfiguration.fromJson(
            value as Map<String, dynamic>,
          );
        });
      }

      debugPrint('Navigation configuration imported successfully');
    } catch (error) {
      debugPrint('Failed to import navigation configuration: $error');
    }
  }

  /// Get configuration for a specific page type
  NavigationConfiguration getConfiguration(String pageType) {
    return _configurations[pageType] ?? getDefaultConfiguration(pageType);
  }

  /// Set default configuration for a page type
  void setDefaultConfiguration(
    String pageType,
    NavigationConfiguration config,
  ) {
    _defaultConfigurations[pageType] = config;
    debugPrint('Set default configuration for pageType: $pageType');
  }

  /// Remove configuration for a page type
  void removeConfiguration(String pageType) {
    _configurations.remove(pageType);
    debugPrint('Removed configuration for pageType: $pageType');
  }

  /// Check if page type has custom configuration
  bool hasCustomConfiguration(String pageType) {
    return _configurations.containsKey(pageType);
  }

  /// Get all configured page types
  List<String> getConfiguredPageTypes() {
    return _configurations.keys.toList();
  }

  /// Get configuration statistics
  Map<String, dynamic> getConfigurationStats() {
    return {
      'customConfigurations': _configurations.length,
      'defaultConfigurations': _defaultConfigurations.length,
      'totalPageTypes':
          {..._configurations.keys, ..._defaultConfigurations.keys}.length,
    };
  }

  /// Initialize default configurations for common page types
  void _initializeDefaultConfigurations() {
    // Default configuration for all pages
    _defaultConfigurations['default'] = const NavigationConfiguration(
      showBottomNavigation: true,
      showBackButton: true,
      canGoBack: true,
      showAppBar: true,
      showLoading: false,
    );

    // Settings pages - typically no bottom nav
    _defaultConfigurations['settings'] = const NavigationConfiguration(
      showBottomNavigation: false,
      showBackButton: true,
      canGoBack: true,
      showAppBar: true,
    );

    // Modal pages - no bottom nav, custom back handling
    _defaultConfigurations['modal'] = const NavigationConfiguration(
      showBottomNavigation: false,
      showBackButton: true,
      canGoBack: true,
      showAppBar: false,
    );

    // Detail pages - standard configuration
    _defaultConfigurations['detail'] = const NavigationConfiguration(
      showBottomNavigation: false,
      showBackButton: true,
      canGoBack: true,
      showAppBar: true,
    );

    // List pages - show bottom nav
    _defaultConfigurations['list'] = const NavigationConfiguration(
      showBottomNavigation: true,
      showBackButton: true,
      canGoBack: true,
      showAppBar: true,
    );

    // Loading pages - show loading state
    _defaultConfigurations['loading'] = const NavigationConfiguration(
      showBottomNavigation: false,
      showBackButton: false,
      canGoBack: false,
      showAppBar: false,
      showLoading: true,
    );

    // Full screen pages - minimal UI
    _defaultConfigurations['fullscreen'] = const NavigationConfiguration(
      showBottomNavigation: false,
      showBackButton: false,
      canGoBack: true,
      showAppBar: false,
    );

    // Premium pages - special handling
    _defaultConfigurations['premium'] = const NavigationConfiguration(
      showBottomNavigation: false,
      showBackButton: true,
      canGoBack: true,
      showAppBar: true,
    );

    debugPrint('Default navigation configurations initialized');
  }
}
