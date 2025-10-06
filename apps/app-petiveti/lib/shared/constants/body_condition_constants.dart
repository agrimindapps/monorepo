import 'package:flutter/material.dart';

/// Constants for the body condition calculator page dimensions, text, and UI elements
class BodyConditionConstants {
  BodyConditionConstants._();
  static const int tabCount = 3;
  static const EdgeInsets tabPadding = EdgeInsets.all(16.0);
  static const double emptyStateIconSize = 64.0;
  static const Color emptyStateIconColor = Colors.grey;
  static const double emptyStateTitleFontSize = 18.0;
  static const FontWeight emptyStateTitleWeight = FontWeight.bold;
  static const Color emptyStateDescriptionColor = Colors.grey;
  static const double emptyStateIconSpacing = 16.0;
  static const double emptyStateTitleSpacing = 8.0;
  static const double fabLoadingIndicatorSize = 16.0;
  static const double fabLoadingStrokeWidth = 2.0;
  static const Color fabLoadingColor = Colors.white;
  static const Color fabDisabled = Colors.grey;
  static const String appBarTitle = 'Condição Corporal (BCS)';
  static const String helpTooltip = 'Guia BCS';
  static const String emptyResultTitle = 'Nenhum resultado ainda';
  static const String emptyResultDescription = 'Preencha os dados na aba "Entrada" e toque em "Calcular"';
  static const String emptyHistoryTitle = 'Nenhum histórico ainda';
  static const String emptyHistoryDescription = 'Os resultados dos cálculos aparecerão aqui';
  static const String calculateButtonText = 'Calcular BCS';
  static const String calculatingButtonText = 'Calculando...';
  static const int inputTabIndex = 0;
  static const int resultTabIndex = 1;
  static const int historyTabIndex = 2;
}

/// Color constants for the body condition calculator page
class BodyConditionColors {
  BodyConditionColors._();
  static const Color emptyStateIcon = Colors.grey;
  static const Color emptyStateText = Colors.grey;
  static const Color fabDisabled = Colors.grey;
  static const Color fabLoadingIndicator = Colors.white;
  static const Color modalBackground = Colors.transparent;
}

/// Icon constants for the body condition calculator
class BodyConditionIcons {
  BodyConditionIcons._();
  static const IconData backIcon = Icons.arrow_back;
  static const IconData helpIcon = Icons.help_outline;
  static const IconData emptyResultIcon = Icons.analytics_outlined;
  static const IconData emptyHistoryIcon = Icons.history;
  static const IconData calculateIcon = Icons.calculate;
}

/// Text alignment constants
class BodyConditionTextAlign {
  BodyConditionTextAlign._();

  static const TextAlign centerAlign = TextAlign.center;
}

/// Layout constants for responsive design
class BodyConditionLayout {
  BodyConditionLayout._();
  static const TabBarIndicatorSize indicatorSize = TabBarIndicatorSize.tab;
  static const bool isScrollControlled = true;
}