class DefensivosConstants {
  static const int itemsPerScroll = 50;
  static const int minSearchLength = 0;
  static const double scrollThreshold = 200.0;
  static const int maxDatabaseLoadAttempts = 50;
  static const Duration databaseLoadDelay = Duration(milliseconds: 100);

  // Search Debounce - Delay para otimizar performance da busca
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  // Grid responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 960.0;

  // Grid cross axis counts
  static const int mobileCrossAxisCount = 2;
  static const int tabletCrossAxisCount = 3;
  static const int desktopCrossAxisCount = 4;

  // UI Layout Constants
  static const double listItemHeight = 60.0;
  static const int listItemAnimationDurationMs = 300;
  static const double listItemContentPaddingStart = 15.0;
  static const double listItemContentPaddingEnd = 10.0;
  static const double listItemDividerIndent = 65.0;

  // Font Sizes
  static const double titleFontSize = 14.0;
  static const double subtitleFontSize = 12.0;
  static const double tagFontSize = 10.0;

  // Icon Sizes
  static const double leadingIconSize = 18.0;
  static const double trailingIconSize = 14.0;
  static const double tagIconSize = 10.0;
  static const double gridIconSize = 36.0;

  // Splash and Border Radius
  static const double splashRadius = 20.0;
  static const double cardBorderRadius = 12.0;

  // Grid Layout
  static const double gridChildAspectRatio = 1.2;
  static const double gridCrossAxisSpacing = 10.0;
  static const double gridMainAxisSpacing = 10.0;
  static const double gridItemPadding = 8.0;

  // Spacing
  static const double smallSpacing = 4.0;
  static const double cardPadding = 8.0;
  static const double cardElevation = 3.0;

  // Page Layout
  static const double pageMaxWidth = 1120.0;
  static const double pageContentPadding = 8.0;
  static const double pageBottomPadding = 10.0;

  // Opacity Values
  static const double backgroundOpacity = 0.16;
}
