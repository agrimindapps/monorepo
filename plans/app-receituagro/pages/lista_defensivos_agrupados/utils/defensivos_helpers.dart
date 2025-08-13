// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../config/ui_constants.dart';
import 'defensivos_category.dart';

class DefensivosHelpers {
  static IconData getIconForCategory(DefensivosCategory category) {
    switch (category) {
      case DefensivosCategory.fabricantes:
        return FontAwesome.industry_solid;
      case DefensivosCategory.classeAgronomica:
        return FontAwesome.list_ul_solid;
      case DefensivosCategory.ingredienteAtivo:
        return FontAwesome.flask_solid;
      case DefensivosCategory.modoAcao:
        return FontAwesome.bolt_solid;
      default:
        return FontAwesome.shield_cat_solid;
    }
  }

  static int calculateCrossAxisCount(double screenWidth) {
    if (screenWidth <= ResponsiveConstants.smallScreenBreakpoint) {
      return ResponsiveConstants.twoColumnsGrid;
    } else if (screenWidth <= ResponsiveConstants.mediumScreenBreakpoint) {
      return ResponsiveConstants.threeColumnsGrid;
    } else if (screenWidth <= ResponsiveConstants.largeScreenBreakpoint) {
      return ResponsiveConstants.fourColumnsGrid;
    } else {
      return ResponsiveConstants.maxColumns;
    }
  }

  static Color getStandardGreen() => Colors.green.shade700;

  static Color getAvatarColor(bool isDark) {
    return isDark 
        ? getStandardGreen().withValues(alpha: AlphaConstants.darkModeBackground)
        : Colors.green.shade50;
  }

  static Color getBorderColor(bool isDark) {
    return isDark 
        ? getStandardGreen().withValues(alpha: AlphaConstants.darkModeBorder)
        : getStandardGreen().withValues(alpha: AlphaConstants.lightModeBorder);
  }

  static String getTitleWithFilter(DefensivosCategory category, String? filter) {
    if (filter == null || filter.isEmpty) {
      return category.title;
    }
    return '${category.title} - $filter';
  }
}
