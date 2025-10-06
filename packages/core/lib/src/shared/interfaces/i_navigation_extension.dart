import '../models/navigation_state.dart';

/// Interface for domain-specific navigation extensions
abstract class INavigationExtension {
  /// Extension identifier
  String get extensionId;

  /// Extension name for debugging
  String get extensionName;

  /// Process navigation request and return configuration
  Future<NavigationConfiguration?> processNavigationRequest(
    String pageType,
    Map<String, dynamic>? arguments,
  );

  /// Handle custom navigation logic for domain-specific pages
  Future<bool> handleCustomNavigation(
    String pageType,
    Map<String, dynamic>? arguments,
  );

  /// Get custom page titles for domain-specific pages
  String? getCustomPageTitle(
    String pageType,
    Map<String, dynamic>? arguments,
  );

  /// Validate navigation arguments for domain-specific pages
  bool validateNavigationArguments(
    String pageType,
    Map<String, dynamic>? arguments,
  );

  /// Get analytics metadata for domain-specific navigation
  Map<String, dynamic>? getAnalyticsMetadata(
    String pageType,
    Map<String, dynamic>? arguments,
  );

  /// Handle back navigation for domain-specific logic
  Future<bool> handleBackNavigation(NavigationState currentState);

  /// Get supported page types for this extension
  List<String> getSupportedPageTypes();

  /// Clean up resources when extension is disposed
  void dispose();
}

/// Interface for navigation configuration management
abstract class INavigationConfiguration {
  /// Get default configuration for a page type
  NavigationConfiguration getDefaultConfiguration(String pageType);

  /// Update configuration for a specific page type
  void updateConfiguration(String pageType, NavigationConfiguration config);

  /// Get configuration for multiple page types
  Map<String, NavigationConfiguration> getBulkConfiguration(List<String> pageTypes);

  /// Reset configuration to defaults
  void resetConfiguration();

  /// Export configuration for backup/restore
  Map<String, dynamic> exportConfiguration();

  /// Import configuration from backup
  void importConfiguration(Map<String, dynamic> config);
}

/// Interface for navigation analytics tracking
abstract class INavigationAnalytics {
  /// Track page view
  Future<void> trackPageView(
    String pageType,
    Map<String, dynamic>? parameters,
  );

  /// Track navigation path
  Future<void> trackNavigationPath(List<String> path);

  /// Track navigation performance
  Future<void> trackNavigationPerformance(
    String action,
    Duration duration,
  );

  /// Track navigation error
  Future<void> trackNavigationError(
    String pageType,
    String error,
    Map<String, dynamic>? context,
  );

  /// Track user navigation patterns
  Future<void> trackNavigationPattern(
    String pattern,
    Map<String, dynamic> metadata,
  );

  /// Get navigation analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary(
    DateTime startDate,
    DateTime endDate,
  );
}
