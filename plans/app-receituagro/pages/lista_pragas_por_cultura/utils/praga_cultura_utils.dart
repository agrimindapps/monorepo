// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import 'praga_cultura_constants.dart';

class PragaCulturaUtils {
  // Tab configuration
  static const List<String> tabTitles = [
    PragaCulturaConstants.tabTitlePlantas,
    PragaCulturaConstants.tabTitleDoencas,
    PragaCulturaConstants.tabTitleInsetos
  ];
  static const List<String> tipoPragaValues = [
    PragaCulturaConstants.tipoPragaInsetos,
    PragaCulturaConstants.tipoPragaDoencas,
    PragaCulturaConstants.tipoPragaPlantas
  ];

  // Icon methods
  static IconData getIconForPragaType(String type) {
    switch (type) {
      case PragaCulturaConstants.tipoPragaPlantas:
        return FontAwesome.bug_solid;
      case PragaCulturaConstants.tipoPragaDoencas:
        return FontAwesome.virus_solid;
      case PragaCulturaConstants.tipoPragaInsetos:
        return FontAwesome.seedling_solid;
      default:
        return FontAwesome.leaf_solid;
    }
  }

  static IconData getTabIcon(int index) {
    switch (index) {
      case 0:
        return FontAwesome.seedling_solid;
      case 1:
        return FontAwesome.virus_solid;
      case 2:
        return FontAwesome.bug_solid;
      default:
        return FontAwesome.leaf_solid;
    }
  }

  // Title and message methods
  static String getTabTitle(int index) {
    if (index >= 0 && index < tabTitles.length) {
      return tabTitles[index];
    }
    return PragaCulturaConstants.defaultPageTitle;
  }

  static String getTipoPraga(int index) {
    if (index >= 0 && index < tipoPragaValues.length) {
      return tipoPragaValues[index];
    }
    return PragaCulturaConstants.tipoPragaPlantas;
  }

  static String getEmptyStateMessage(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return PragaCulturaConstants.emptyStatePlantasMessage;
      case 1:
        return PragaCulturaConstants.emptyStateDoencasMessage;
      case 2:
        return PragaCulturaConstants.emptyStateInsetosMessage;
      default:
        return PragaCulturaConstants.emptyStatePragasMessage;
    }
  }

  static String getLoadingMessage(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return PragaCulturaConstants.loadingPlantasMessage;
      case 1:
        return PragaCulturaConstants.loadingDoencasMessage;
      case 2:
        return PragaCulturaConstants.loadingInsetosMessage;
      default:
        return PragaCulturaConstants.loadingPragasMessage;
    }
  }

  // Search and filtering
  static bool isSearchValid(String? search) {
    return search != null && search.trim().length >= PragaCulturaConstants.minSearchLength;
  }

  static String sanitizeSearch(String search) {
    return search.trim().toLowerCase();
  }

  static bool matchesSearch(Map<String, dynamic> praga, String searchText) {
    final nomeComum = praga['nomeComum']?.toString().toLowerCase() ?? '';
    final nomeSecundario = praga['nomeSecundario']?.toString().toLowerCase() ?? '';
    final nomeCientifico = praga['nomeCientifico']?.toString().toLowerCase() ?? '';
    
    return nomeComum.contains(searchText) ||
        nomeSecundario.contains(searchText) ||
        nomeCientifico.contains(searchText);
  }

  // Grid calculation
  static int calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < PragaCulturaConstants.mobileBreakpoint) return PragaCulturaConstants.mobileCrossAxisCount;
    if (screenWidth < PragaCulturaConstants.tabletBreakpoint) return PragaCulturaConstants.tabletCrossAxisCount;
    if (screenWidth < PragaCulturaConstants.desktopBreakpoint) return PragaCulturaConstants.largeTabletCrossAxisCount;
    return PragaCulturaConstants.desktopCrossAxisCount;
  }

  // Image utilities
  static String getImagePath(String? nomeCientifico, String? nomeImagem) {
    final imageName = nomeCientifico ?? nomeImagem;
    if (imageName == null || imageName.isEmpty) return '';
    return '${PragaCulturaConstants.imageBasePath}$imageName${PragaCulturaConstants.imageExtension}';
  }

  // Validation helpers
  static bool hasValidId(Map<String, dynamic> item) {
    final id = item['idReg']?.toString();
    return id != null && id.isNotEmpty;
  }

  static bool hasValidName(Map<String, dynamic> item) {
    final name = item['nomeComum']?.toString();
    return name != null && name.isNotEmpty;
  }

  static bool isValidPragaItem(Map<String, dynamic> item) {
    return hasValidId(item) && hasValidName(item);
  }

  // Format utilities
  static String formatSubtitle(int totalCount) {
    if (totalCount == 0) return PragaCulturaConstants.noRecordMessage;
    if (totalCount == 1) return PragaCulturaConstants.singleRecordMessage;
    return '$totalCount ${PragaCulturaConstants.multipleRecordsMessage}';
  }

  // Animation helpers
  static Duration getItemDelay(int index) {
    return Duration(milliseconds: PragaCulturaConstants.itemDelayDuration.inMilliseconds * index);
  }

  static Curve getAnimationCurve(String type) {
    switch (type) {
      case 'elastic':
        return Curves.elasticOut;
      case 'ease':
        return Curves.easeInOut;
      case 'cubic':
        return Curves.easeOutCubic;
      default:
        return Curves.easeInOut;
    }
  }
}
