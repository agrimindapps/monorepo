// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import 'praga_constants.dart';

class PragaUtils {
  // Static data maps
  static const Map<String, String> titleTypes = {
    '1': 'Insetos',
    '2': 'Doenças',
    '3': 'Plantas Invasoras',
  };

  static final Map<String, List<String>> categoriasPorTipo = {
    '1': ['Todos', 'Lavoura', 'Horta', 'Frutíferas', 'Pastagem', 'Armazenados'],
    '2': ['Todas', 'Fúngicas', 'Bacterianas', 'Virais', 'Nematoides'],
    '3': ['Todas', 'Folha Larga', 'Folha Estreita', 'Trepadeiras', 'Aquáticas']
  };

  // Title methods
  static String getTitle(String type) {
    return titleTypes[type] ?? 'Pragas';
  }

  // Icon methods
  static IconData getIconForPragaType(String type) {
    switch (type) {
      case '1':
        return FontAwesome.bug_solid;
      case '2':
        return FontAwesome.disease_solid;
      case '3':
        return FontAwesome.seedling_solid;
      default:
        return FontAwesome.bug_solid;
    }
  }

  static IconData getEmptyStateIcon(String type) {
    switch (type) {
      case '1':
        return FontAwesome.bug_slash_solid;
      case '2':
        return FontAwesome.virus_slash_solid;
      case '3':
        return FontAwesome.seedling_solid;
      default:
        return Icons.search_off;
    }
  }

  // Message methods
  static String getEmptyStateMessage(String type) {
    switch (type) {
      case '1':
        return 'Nenhum inseto encontrado';
      case '2':
        return 'Nenhuma doença encontrada';
      case '3':
        return 'Nenhuma planta invasora encontrada';
      default:
        return 'Nenhuma praga encontrada';
    }
  }

  static String getLoadingMessage(String type) {
    switch (type) {
      case '1':
        return 'Carregando insetos...';
      case '2':
        return 'Carregando doenças...';
      case '3':
        return 'Carregando plantas invasoras...';
      default:
        return 'Carregando pragas...';
    }
  }

  static String getSearchHint(String type) {
    switch (type) {
      case '1':
        return 'Buscar insetos...';
      case '2':
        return 'Buscar doenças...';
      case '3':
        return 'Buscar plantas invasoras...';
      default:
        return 'Buscar pragas...';
    }
  }

  // Utility methods
  static List<String> getCategoriesForType(String type) {
    return categoriasPorTipo[type] ?? [];
  }

  static bool isValidPragaType(String type) {
    return titleTypes.containsKey(type);
  }

  static String getImagePath(String? imageName) {
    if (imageName == null || imageName.isEmpty) return '';
    return '${PragaConstants.imageBasePath}$imageName${PragaConstants.imageExtension}';
  }

  static String getSubtitle(int count, String type) {
    if (count == 0) return 'Nenhum registro';
    if (count == 1) return '1 registro';
    return '$count registros';
  }

  // Grid calculation
  static int calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < PragaConstants.mobileBreakpoint) return PragaConstants.mobileGridColumns;
    if (screenWidth < PragaConstants.tabletBreakpoint) return PragaConstants.tabletGridColumns;
    if (screenWidth < PragaConstants.desktopBreakpoint) return PragaConstants.largeTabletGridColumns;
    return PragaConstants.desktopGridColumns;
  }

  // Search validation
  static bool isSearchValid(String? search) {
    return search != null && search.trim().isNotEmpty;
  }

  static String sanitizeSearch(String search) {
    return search.trim().toLowerCase();
  }
}
