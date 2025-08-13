// Flutter imports:
import 'package:flutter/material.dart';

class PragaCulturaConstants {
  // UI Constants
  static const double cardElevation = 4;
  static const double itemElevation = 3;
  static const double borderRadius = 12;
  static const double searchFieldRadius = 16;
  static const double maxContentWidth = 1120;

  // Search Constants
  static const int minSearchLength = 0;
  static const String searchHintText = 'Buscar pragas...';
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  // Animation Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration scaleAnimationDuration = Duration(milliseconds: 400);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration itemDelayDuration = Duration(milliseconds: 50);
  static const double shimmerClampOffset = 0.3;

  // Grid Constants
  static const int minCrossAxisCount = 2;
  static const int maxCrossAxisCount = 5;
  static const double gridChildAspectRatio = 0.8;
  static const double gridMainCellCount = 1.3;
  static const double gridSpacing = 10;
  static const double gridTopPadding = 4;
  static const int gridCrossAxisCellCount = 1;

  // Image Constants
  static const double imageSize = 80;
  static const String imageBasePath = 'assets/imagens/bigsize/';
  static const String imageExtension = '.jpg';
  static const double defaultIconSize = 32;
  static const double emptyStateIconSize = 48;

  // Icon Sizes
  static const double searchIconSize = 20;
  static const double clearButtonIconSize = 18;
  static const double toggleButtonIconSize = 18;

  // Layout Constants
  static const double appBarToolbarHeight = 65;
  static const double dividerHeight = 24;
  static const double dividerWidth = 1;
  static const double shadowBlurRadius = 10;
  static const double shadowOffsetY = 3;
  static const double tabBarShadowBlurRadius = 5;
  static const double tabBarShadowOffsetY = 2;
  static const double toggleButtonBorderRadius = 20;
  static const double searchFieldBorderWidth = 1.5;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1100;
  static const int mobileCrossAxisCount = 2;
  static const int tabletCrossAxisCount = 3;
  static const int largeTabletCrossAxisCount = 4;
  static const int desktopCrossAxisCount = 5;

  // Spacing
  static const double smallSpacing = 4;
  static const double mediumSpacing = 8;
  static const double largeSpacing = 12;
  static const double extraLargeSpacing = 16;

  // Text sizes
  static const double smallTextSize = 12;
  static const double mediumTextSize = 14;
  static const double largeTextSize = 16;

  // Padding
  static const double smallPadding = 8;
  static const double mediumPadding = 12;
  static const double largePadding = 16;

  // Tab bar
  static const double tabBarHeight = 44.0;
  static const double tabIconSize = 16;
  static const double tabSpacing = 6;

  // Loading skeleton
  static const int skeletonItemCount = 6;
  static const double skeletonImageHeight = 120;
  static const double skeletonTextHeight = 16;
  static const double skeletonSubtextHeight = 12;
  static const double skeletonNameWidth = 200;
  static const double skeletonScientificWidth = 150;
  static const double skeletonTypeWidth = 100;
  static const double skeletonImageWidth = 120;
  static const double skeletonSmallImageWidth = 80;
  static const int skeletonSpacingMultiplier = 2;

  // Colors and opacity values
  static const double shadowOpacity = 0.3;
  static const double overlayOpacity = 0.15;
  static const double borderOpacity = 0.5;
  static const Color darkCardColor = Color(0xFF222228);
  static const Color darkContainerColor = Color(0xFF1E1E22);
  static const Color emptyStateIconColor = Color(0xFFAAAAAA);
  static const Color emptyStateTextColor = Color(0xFF777777);

  // Strings - UI Labels
  static const String defaultEmptyMessage = 'Nenhum resultado encontrado';
  static const String defaultPageTitle = 'Pragas';

  // Strings - Tab Titles
  static const String tabTitlePlantas = 'Plantas';
  static const String tabTitleDoencas = 'Doenças';
  static const String tabTitleInsetos = 'Insetos';

  // Strings - Empty State Messages
  static const String emptyStatePlantasMessage = 'Nenhuma planta invasora encontrada';
  static const String emptyStateDoencasMessage = 'Nenhuma doença encontrada';
  static const String emptyStateInsetosMessage = 'Nenhum inseto encontrado';
  static const String emptyStatePragasMessage = 'Nenhuma praga encontrada';

  // Strings - Loading Messages
  static const String loadingPlantasMessage = 'Carregando plantas invasoras...';
  static const String loadingDoencasMessage = 'Carregando doenças...';
  static const String loadingInsetosMessage = 'Carregando insetos...';
  static const String loadingPragasMessage = 'Carregando pragas...';

  // Strings - Record Count Messages
  static const String noRecordMessage = 'Nenhum registro';
  static const String singleRecordMessage = '1 Registro';
  static const String multipleRecordsMessage = 'Registros';

  // Strings - Error Messages
  static const String errorTitle = 'Erro';
  static const String errorLoadingPragasMessage = 'Erro ao carregar pragas da cultura';
  static const String errorLoadingDetailsMessage = 'Erro ao carregar detalhes da praga';

  // Strings - Debug Messages
  static const String debugNavigationPrefix = '✅ Navigation from';
  static const String debugNoArgumentsMessage = '⚠️ No navigation arguments provided, using legacy approach';
  static const String debugNavigationErrorPrefix = 'Error handling navigation arguments:';

  // Routes
  static const String routePragaDetails = '/receituagro/pragas/detalhes';

  // Data Keys
  static const String keyIdReg = 'idReg';
  static const String keyNomeComum = 'nomeComum';
  static const String keyNomeSecundario = 'nomeSecundario';
  static const String keyNomeCientifico = 'nomeCientifico';
  static const String keyTipoPraga = 'tipoPraga';
  static const String keyCulturaNome = 'culturaNome';
  static const String keyCulturaId = 'culturaId';

  // Hero Tag Prefixes
  static const String heroTagPrefix = 'pragas_por_cultura_';

  // Type Values
  static const String tipoPragaPlantas = '1';
  static const String tipoPragaDoencas = '2';
  static const String tipoPragaInsetos = '3';
}
