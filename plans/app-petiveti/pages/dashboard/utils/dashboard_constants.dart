// Flutter imports:
import 'package:flutter/material.dart';

class DashboardConstants {
  // Layout
  static const double maxWidth = 1120;
  static const double cardElevation = 2;
  static const double cardBorderRadius = 16;
  static const double petSelectorHeight = 100;
  static const double petImageSize = 80;

  // Chart constants
  static const double pieChartRadius = 50;
  static const double weightChartHeight = 250;
  static const double pieChartHeight = 200;

  // Grid
  static const int smallScreenColumns = 2;
  static const int largeScreenColumns = 4;
  static const double gridSpacing = 16;
  static const double smallScreenAspectRatio = 1.2;
  static const double largeScreenAspectRatio = 1.4;

  // Action buttons
  static const double actionButtonWidth = 110;
  static const double actionButtonIconSize = 28;

  // Colors for expense categories
  static const Map<String, Color> categoryColors = {
    'Consulta': Colors.blue,
    'Medicamento': Colors.red,
    'Ração': Colors.orange,
    'Brinquedos': Colors.green,
    'Outros': Colors.purple,
    'Vacina': Colors.purple,
  };

  // Health insight colors
  static const Color healthGoodColor = Colors.green;
  static const Color healthWarningColor = Colors.orange;
  static const Color healthDangerColor = Colors.red;

  // Vaccination status colors
  static const Color vaccinationCompleteColor = Colors.green;
  static const Color vaccinationPendingColor = Colors.orange;
  static const Color vaccinationOverdueColor = Colors.red;

  static Color getCategoryColor(String categoria) {
    return categoryColors[categoria] ?? Colors.grey;
  }

  static Color getHealthColor(double percentage) {
    if (percentage >= 80) {
      return healthGoodColor;
    } else if (percentage >= 60) {
      return healthWarningColor;
    } else {
      return healthDangerColor;
    }
  }

  static IconData getPetIcon(String especie) {
    switch (especie.toLowerCase()) {
      case 'cachorro':
        return Icons.pets;
      case 'gato':
        return Icons.catching_pokemon;
      case 'ave':
        return Icons.flutter_dash;
      case 'peixe':
        return Icons.water;
      default:
        return Icons.pets;
    }
  }
}
