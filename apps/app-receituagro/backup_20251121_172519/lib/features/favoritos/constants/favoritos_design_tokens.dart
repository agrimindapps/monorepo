import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

class FavoritosDesignTokens {
  FavoritosDesignTokens._(); // Private constructor prevents instantiation

  static const Color defensivosColor = Color(0xFF2E7D32);
  static const Color pragasColor = Color(0xFFD32F2F);
  static const Color diagnosticosColor = Color(0xFF1976D2);

  static const IconData defensivosIcon = FontAwesomeIcons.sprayCan;
  static const IconData pragasIcon = FontAwesomeIcons.bug;
  static const IconData diagnosticosIcon = FontAwesomeIcons.stethoscope;

  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  static const double headerHeight = 120.0;
  
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  static const double searchDebounceMs = 300.0;
  static const Duration animationDuration = Duration(milliseconds: 200);

  static Color getColorForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return defensivosColor;
      case 1:
        return pragasColor;
      case 2:
        return diagnosticosColor;
      default:
        return defensivosColor;
    }
  }

  static IconData getIconForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return defensivosIcon;
      case 1:
        return pragasIcon;
      case 2:
        return diagnosticosIcon;
      default:
        return defensivosIcon;
    }
  }

  static String getTabName(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Defensivos';
      case 1:
        return 'Pragas';
      case 2:
        return 'Diagnósticos';
      default:
        return 'Defensivos';
    }
  }

  static String getSearchHint(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Buscar defensivos favoritos...';
      case 1:
        return 'Buscar pragas favoritas...';
      case 2:
        return 'Buscar diagnósticos favoritos...';
      default:
        return 'Buscar...';
    }
  }
}
