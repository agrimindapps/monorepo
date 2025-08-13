// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

class PragaConstants {
  // ═══════════════════════════════════════════════════════════════════════════════
  // 📐 UI LAYOUT CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  // View modes
  static const String gridViewMode = 'grid';
  static const String listViewMode = 'list';

  // App Bar
  static const double appBarHeight = 65;
  static const double appBarToolbarHeight = 65;

  // Basic UI dimensions
  static const double maxContentWidth = 1120;
  static const double cardElevation = 4;
  static const double itemElevation = 3;
  static const double emptyStateElevation = 2;
  static const double borderRadius = 12;
  static const double smallBorderRadius = 8;
  static const double searchFieldRadius = 16;
  static const double toggleButtonRadius = 20;
  
  // Layout spacing and padding
  static const double listTopPadding = 4;
  static const double gridTopPadding = 4;
  static const double pageHorizontalPadding = 8;
  static const double pageBottomPadding = 8;
  
  // Specific widget dimensions
  static const double dividerHeight = 24;
  static const double dividerWidth = 1;
  static const double loadingStrokeWidth = 3;
  static const double searchFieldBorderWidth = 1.5;
  static const double itemSpacingHeight = 2;

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🎯 RESPONSIVE DESIGN CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  // Screen breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1100;

  // Grid configuration by breakpoint
  static const int minGridColumns = 2;
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 3;
  static const int largeTabletGridColumns = 4;
  static const int maxGridColumns = 5;
  static const int desktopGridColumns = 5;
  
  static const double gridItemAspectRatio = 1.3;
  static const double gridSpacing = 10;
  static const int gridCrossAxisCellCount = 1;

  // List configuration
  static const double listItemHeight = 80;
  static const double listItemSpacing = 6;

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🖼️ IMAGE & MEDIA CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  static const double imageSize = 80;
  static const String imageBasePath = 'assets/imagens/bigsize/';
  static const String imageExtension = '.jpg';

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🔍 SEARCH & FILTER CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  static const int minSearchLength = 1;
  static const Duration searchDebounce = Duration(milliseconds: 300);

  // ═══════════════════════════════════════════════════════════════════════════════
  // ⏱️ ANIMATION & TIMING CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  static const Duration loadingDelay = Duration(milliseconds: 100);

  // ═══════════════════════════════════════════════════════════════════════════════
  // 🎨 VISUAL STYLING CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  // Colors with alpha values
  static const double shadowOpacity = 0.3;
  static const double overlayOpacity = 0.15;
  static const double borderOpacity = 0.5;

  // Dark theme colors
  static const Color darkContainerColor = Color(0xFF1E1E22);
  static const Color darkCardColor = Color(0xFF222228);

  // Icon sizes
  static const double iconSize = 32;
  static const double smallIconSize = 18;
  static const double mediumIconSize = 20;
  static const double largeIconSize = 48;

  // Text sizes  
  static const double smallTextSize = 12;
  static const double mediumTextSize = 13;
  static const double regularTextSize = 14;
  static const double searchTextSize = 15;
  static const double largeTextSize = 16;

  // Spacing system
  static const double smallSpacing = 4;
  static const double mediumSpacing = 8;
  static const double largeSpacing = 16;
  static const double extraLargeSpacing = 32;
  static const double spacingAdjustment = 4; // For mediumSpacing + 4

  // Padding system
  static const double smallPadding = 8;
  static const double mediumPadding = 12;
  static const double largePadding = 16;
  static const double extraLargePadding = 32;

  // Shadow and elevation
  static const double shadowBlurRadius = 10;
  static const Offset shadowOffset = Offset(0, 3);

  // ═══════════════════════════════════════════════════════════════════════════════
  // 📝 STRING CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  // User Interface Messages
  static const String emptyStateMessage = 'Tente usar termos diferentes na sua busca';
  static const String sortTooltip = 'Ordenar registros';

  // Error Messages
  static const String errorTitle = 'Erro';
  static const String errorLoadingPragas = 'Erro ao carregar pragas. Tente novamente.';
  static const String errorLoadingPragasLog = 'Erro ao carregar pragas:';
  static const String errorSearchingPragaLog = 'Erro ao buscar praga por ID:';

  // Navigation and Data Keys
  static const String pragaIdKey = 'pragaId';
  static const String tipoPragaKey = 'tipoPraga';

  // JSON Field Keys
  static const String idRegKey = 'idReg';
  static const String nomeComumKey = 'nomeComum';
  static const String nomeSecundarioKey = 'nomeSecundario';
  static const String nomeCientificoKey = 'nomeCientifico';
  static const String nomeImagemKey = 'nomeImagem';
  static const String categoriaKey = 'categoria';
  static const String tipoKey = 'tipo';

  // Hero Tag Prefixes
  static const String gridItemHeroPrefix = 'lista_pragas_grid_';

  // Default Values
  static const String defaultPragaType = '1';
  static const String defaultSearchText = '';

  // ═══════════════════════════════════════════════════════════════════════════════
  // ⚙️ CONFIGURATION CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════════

  // SnackBar Configuration
  static const SnackPosition defaultSnackPosition = SnackPosition.BOTTOM;

  // Edge Insets Presets
  static const EdgeInsets appBarPadding = EdgeInsets.all(8.0);
  static const EdgeInsets searchFieldPadding = EdgeInsets.fromLTRB(8, 8, 8, 12);
  static const EdgeInsets searchFieldInnerPadding = EdgeInsets.fromLTRB(16, 0, 8, 0);
  static const EdgeInsets toggleButtonPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  static const EdgeInsets textFieldPadding = EdgeInsets.symmetric(vertical: 14);
  static const EdgeInsets clearButtonPadding = EdgeInsets.all(8.0);
  static const EdgeInsets dividerMargin = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets snackBarMargin = EdgeInsets.all(8);
  static const EdgeInsetsDirectional pageMainPadding = EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8);
  static const EdgeInsets emptyStateSpacing = EdgeInsets.only(top: 8); // smallSpacing * 2
}
