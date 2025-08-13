// Constants for Home Pragas module
// This file centralizes all hardcoded values to improve maintainability and configuration

/// UI Constants - Dimensions, elevations, and visual properties
class UiConstants {
  // Card properties
  static const double cardElevation = 0.0;
  static const double cardBorderRadius = 12.0;

  // Padding and margins
  static const double standardPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 10.0;

  // Icon sizes
  static const double standardIconSize = 32.0;
  static const double largeIconSize = 40.0;
  static const double smallIconSize = 20.0;

  // Widget heights
  static const double carouselHeight = 200.0;
  static const double carouselSpacing = 10.0;
  static const double dotSpacing = 8.0;
  static const double dividerHeight = 1.0;
  static const double dividerIndent = 10.0;

  // Progress indicators
  static const double progressIndicatorStrokeWidth = 2.0;

  // Carousel settings
  static const int carouselPreloadRadius = 2;
}

/// Performance Constants - Lazy loading, caching, and optimization settings
class PerformanceConstants {
  // Multipliers for lazy loading calculations
  static const double loadThresholdMultiplier =
      0.7; // Load more when 70% viewed
  static const double preloadBufferMultiplier = 0.5; // Preload buffer size
  static const double scrollLoadThresholdMultiplier =
      0.8; // Load more at 80% scroll

  // Item limits for different sections
  static const int suggestedItemsMultiplier = 3; // _itemsPerPage * 3
  static const int recentItemsMultiplier = 4; // _itemsPerPage * 4

  // Memory management
  static const int maxStateTransitionLogEntries = 50;
  static const int stateLogRemovalIndex = 0; // Remove from beginning
}

/// Timeout Constants - Duration settings for various operations
class TimeoutConstants {
  // Initialization timeouts
  static const Duration initializationTimeout = Duration(seconds: 10);
  static const Duration dataLoadingTimeout = Duration(seconds: 30);
  static const Duration operationTimeout = Duration(seconds: 30);

  // Delays
  static const Duration repositoryInitDelay = Duration(seconds: 2);

  // Performance optimization timeouts
  static const Duration cacheCleanupInterval = Duration(minutes: 5);
  static const Duration debounceDelay = Duration(milliseconds: 300);
}

/// Page Constants - Pagination and item counts
class PageConstants {
  // Initial page values
  static const int initialPage = 0;

  // Step counters for initialization
  static const int initStep1 = 1;
  static const int initStep2 = 2;
  static const int initStep3 = 3;
  static const int initStep4 = 4;
  static const int initStep5 = 5;
}

/// Text Constants - Labels, messages, and string literals
class TextConstants {
  // Empty state messages
  static const String noRecentItemsMessage = 'Nenhum item recente encontrado';
  static const String noSuggestedItemsMessage = 'Nenhuma sugestão disponível';

  // Loading messages
  static const String loadingRecentItems = 'Carregando itens recentes...';
  static const String loadingSuggestedItems = 'Carregando sugestões...';

  // Error messages
  static const String initializationError = 'Erro na inicialização';
  static const String dataLoadingError = 'Erro ao carregar dados';

  // Section titles
  static const String recentSectionTitle = 'Recentes';
  static const String suggestedSectionTitle = 'Sugestões';
}

/// Navigation Constants - Route sources and navigation parameters
class NavigationConstants {
  // Source identifiers for navigation tracking
  static const String homePageSource = 'home_page';
  static const String carouselSource = 'carousel';
  static const String recentSectionSource = 'recent_section';
  static const String suggestedSectionSource = 'suggested_section';
  static const String menuCardSource = 'menu_card';
}

/// Validation Constants - Data validation thresholds and limits
class ValidationConstants {
  // ID validation
  static const int minValidId = 1;
  static const int maxValidId = 999999;

  // String validation
  static const int minNameLength = 1;
  static const int maxNameLength = 255;

  // Collection validation
  static const int minCollectionSize = 0;
  static const int maxCollectionSize = 1000;
}
