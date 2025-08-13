/// Constantes de interface do usuário para o módulo Lista Defensivos Agrupados
/// Centraliza todos os valores de dimensões, estilos e layout
class UiConstants {
  UiConstants._();

  // DIMENSÕES GERAIS
  static const double maxContainerWidth = 1120;
  static const double cardElevation = 3;
  static const double standardBorderRadius = 12;
  static const double smallBorderRadius = 8;
  static const double largeBorderRadius = 16;
  static const double extraLargeBorderRadius = 20;

  // PADDING E MARGIN
  static const double standardPadding = 8;
  static const double mediumPadding = 12;
  static const double largePadding = 16;
  static const double verticalTextPadding = 14;
  static const double buttonPadding = 8;
  static const double badgePadding = 4;
  static const double categoryContainerPadding = 6;

  // TAMANHOS DE ÍCONES
  static const double smallIconSize = 14;
  static const double mediumIconSize = 18;
  static const double largeIconSize = 20;
  static const double extraLargeIconSize = 28;

  // TAMANHOS DE FONTE
  static const double smallFontSize = 9;
  static const double extraSmallFontSize = 10;
  static const double categoryFontSize = 10;
  static const double captionFontSize = 11;
  static const double subtitleFontSize = 13;
  static const double bodyFontSize = 14;
  static const double hintFontSize = 14;
  static const double titleFontSize = 16;

  // ALTURAS ESPECÍFICAS
  static const double appBarHeight = 65;
  static const double listItemHeight = 62;
  static const double dividerHeight = 24;

  // LARGURAS
  static const double borderWidth = 1;
  static const double thickBorderWidth = 1.5;
  static const double circularBorderWidth = 2;
  static const double dividerWidth = 1;

  // POSICIONAMENTO
  static const double badgeOffset = -5;
  static const double gridBadgeOffset = -10;
  static const double shadowOffset = 3;

  // SOMBRA
  static const double shadowBlurRadius = 10;
  static const double splashRadius = 20;

  // LIMITES DE TEXTO
  static const int maxTitleLines = 2;
  static const int maxSubtitleCharacters = 30;

  // ESPAÇAMENTOS
  static const double verticalSpacing = 8;
  static const double horizontalSpacing = 12;
  static const double smallVerticalSpacing = 4;
  static const double containerMargin = 8;
}

/// Constantes de transparência/alpha para cores
class AlphaConstants {
  AlphaConstants._();

  static const double darkModeBackground = 0.16;
  static const double darkModeBorder = 0.39;
  static const double lightModeBorder = 0.5;
  static const double darkModeShadow = 0.12;
  static const double lightModeShadow = 0.2;
  static const double mediumTransparency = 0.31;
}

/// Constantes de responsividade para breakpoints
class ResponsiveConstants {
  ResponsiveConstants._();

  static const double smallScreenBreakpoint = 480;
  static const double mediumScreenBreakpoint = 768;
  static const double largeScreenBreakpoint = 1024;
  
  static const int twoColumnsGrid = 2;
  static const int threeColumnsGrid = 3;
  static const int fourColumnsGrid = 4;
  static const int maxColumns = 5;
}

/// Constantes de performance e timeouts
class PerformanceConstants {
  PerformanceConstants._();

  static const int retryTimeoutMillis = 1000;
  static const int debugLogInterval = 10;
  static const int memoryCalculationModulo = 1000000;
  static const double memoryCalculationDivisor = 1000.0;
  static const int memoryTrendAnalysisWindow = 3;
}

/// Constantes de monitoramento
class MonitoringConstants {
  MonitoringConstants._();

  static const int memoryMonitoringIntervalSeconds = 30;
  static const int maxMemorySnapshots = 20;
  static const double memoryLeakThresholdMB = 50;
  static const int resourceLeakThresholdMinutes = 5;
}

/// Constantes específicas da página de defensivos
class DefensivosPageConstants {
  DefensivosPageConstants._();

  // Pagination and scrolling
  static const int itemsPerScroll = 50;
  static const double scrollThreshold = 200.0;
  static const int minSearchLength = 0;
  
  // Database loading
  static const int maxDatabaseLoadAttempts = 50;
  static const Duration databaseLoadDelay = Duration(milliseconds: 100);
  static const Duration initialDataDelay = Duration(milliseconds: 100);
  static const Duration retryDelay = Duration(milliseconds: 500);
  
  // UI specific margins and padding
  static const double horizontalBodyPadding = 8.0;
  static const double verticalBodyPadding = 0.0;
  static const double bottomBodyPadding = 10.0;
  static const double allCardPadding = 8.0;
}