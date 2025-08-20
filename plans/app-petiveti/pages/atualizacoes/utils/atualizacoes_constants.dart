// Flutter imports:
import 'package:flutter/material.dart';

class AtualizacoesConstants {
  // Layout
  static const double maxWidth = 1020;
  static const double cardElevation = 2;
  static const double cardBorderRadius = 12;
  static const double listItemSpacing = 8;

  // Padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(8.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listItemPadding = EdgeInsets.all(4.0);

  // Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Colors.white;
  static const Color importantColor = Color(0xFFFF5722);
  static const Color featureColor = Color(0xFF4CAF50);
  static const Color bugfixColor = Color(0xFFF44336);
  static const Color improvementColor = Color(0xFF2196F3);
  static const Color securityColor = Color(0xFF9C27B0);

  // Text styles
  static const TextStyle versionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle versionSubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const TextStyle releaseNoteStyle = TextStyle(
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle emptyStateStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  // Icons
  static const IconData versionIcon = Icons.new_releases;
  static const IconData importantIcon = Icons.priority_high;
  static const IconData featureIcon = Icons.star;
  static const IconData bugfixIcon = Icons.bug_report;
  static const IconData improvementIcon = Icons.trending_up;
  static const IconData securityIcon = Icons.security;
  static const IconData emptyIcon = Icons.update_disabled;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // Versioning
  static const String versionPrefix = 'v';
  static const String unknownVersion = 'Versão desconhecida';
  static const String noReleaseNotes = 'Sem notas de versão';

  // Filters
  static const String allCategoriesFilter = 'Todas';
  static const String importantOnlyFilter = 'Apenas importantes';

  // Messages
  static const String loadingMessage = 'Carregando atualizações...';
  static const String errorMessage = 'Erro ao carregar atualizações';
  static const String emptyMessage = 'Sem atualizações';
  static const String emptySubtitle = 'Nenhuma atualização disponível no momento';
  static const String refreshTooltip = 'Recarregar atualizações';
  static const String filterTooltip = 'Filtrar atualizações';

  // Search
  static const String searchHint = 'Pesquisar versões ou notas...';
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  // Limits
  static const int maxNotesPreview = 3;
  static const int maxVersionsDisplay = 100;

  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'feature':
      case 'funcionalidade':
        return featureColor;
      case 'bugfix':
      case 'correção':
        return bugfixColor;
      case 'improvement':
      case 'melhoria':
        return improvementColor;
      case 'security':
      case 'segurança':
        return securityColor;
      case 'important':
      case 'importante':
        return importantColor;
      default:
        return Colors.grey;
    }
  }

  static IconData getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'feature':
      case 'funcionalidade':
        return featureIcon;
      case 'bugfix':
      case 'correção':
        return bugfixIcon;
      case 'improvement':
      case 'melhoria':
        return improvementIcon;
      case 'security':
      case 'segurança':
        return securityIcon;
      case 'important':
      case 'importante':
        return importantIcon;
      default:
        return versionIcon;
    }
  }

  static TextStyle getVersionTextStyle({bool isLatest = false, bool isImportant = false}) {
    TextStyle baseStyle = versionTitleStyle;
    
    if (isLatest) {
      baseStyle = baseStyle.copyWith(color: featureColor);
    }
    
    if (isImportant) {
      baseStyle = baseStyle.copyWith(color: importantColor);
    }
    
    return baseStyle;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return const EdgeInsets.all(8.0);
    } else if (screenWidth < 1024) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  static double getResponsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return screenWidth * 0.95;
    } else if (screenWidth < 1024) {
      return screenWidth * 0.85;
    } else {
      return maxWidth;
    }
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
}
