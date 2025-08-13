// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../design_tokens/plantas_design_tokens.dart';

/// Extensions para facilitar o acesso aos design tokens do app-plantas
extension PlantasThemeExtension on BuildContext {
  /// Acesso rápido às cores dos design tokens
  Map<String, Color> get plantasCores => PlantasDesignTokens.cores(this);

  /// Acesso rápido aos gradientes dos design tokens
  Map<String, LinearGradient> get plantasGradientes =>
      PlantasDesignTokens.gradientes(this);

  /// Acesso rápido aos text styles dos design tokens
  Map<String, TextStyle> get plantasTextStyles =>
      PlantasDesignTokens.textStyles(this);

  /// Acesso rápido às decorações dos design tokens
  Map<String, BoxDecoration> get plantasDecorations =>
      PlantasDesignTokens.decorations(this);

  /// Verificação se está em modo escuro
  bool get isDarkMode => PlantasDesignTokens.isDarkMode(this);

  /// Cores específicas para fácil acesso
  Color get plantasPrimary => PlantasDesignTokens.corPrimaria(this);
  Color get plantasBackground => PlantasDesignTokens.corFundo(this);
  Color get plantasText => PlantasDesignTokens.corTexto(this);
  Color get plantasSuccess => PlantasDesignTokens.corSucesso(this);
  Color get plantasError => PlantasDesignTokens.corErro(this);
  Color get plantasWarning => PlantasDesignTokens.corAviso(this);

  /// Cores para espaços (independente do tema)
  Map<String, Color> get plantasCoresEspacos =>
      PlantasDesignTokens.coresEspacos();

  /// Cores para status (independente do tema)
  Map<String, Color> get plantasCoresStatus =>
      PlantasDesignTokens.coresStatus();

  /// Dimensões dos design tokens
  Map<String, double> get plantasDimensoes => PlantasDesignTokens.dimensoes;
}

/// Extensions específicas para widgets de tema
extension ThemeWidgetExtensions on Widget {
  /// Envolve o widget com um Container com cor de fundo adaptável
  Widget withPlantasBackground(BuildContext context) {
    return Container(
      color: context.plantasBackground,
      child: this,
    );
  }

  /// Envolve o widget com um Container de card adaptável
  Widget withPlantasCard(BuildContext context) {
    return Container(
      decoration: context.plantasDecorations['card'],
      child: this,
    );
  }
}

/// Método de conveniência para SnackBars com tema
class PlantasSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: context.plantasCores['textoClaro']),
        ),
        backgroundColor: context.plantasSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(PlantasDesignTokens.dimensoes['radiusS']!),
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: context.plantasCores['textoClaro']),
        ),
        backgroundColor: context.plantasError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(PlantasDesignTokens.dimensoes['radiusS']!),
        ),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: context.plantasCores['textoClaro']),
        ),
        backgroundColor: context.plantasWarning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(PlantasDesignTokens.dimensoes['radiusS']!),
        ),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: context.plantasCores['textoClaro']),
        ),
        backgroundColor: context.plantasCores['info'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(PlantasDesignTokens.dimensoes['radiusS']!),
        ),
      ),
    );
  }
}

/// Helper para Get.snackbar com tema
class PlantasGetSnackbar {
  static void success(BuildContext context, String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.plantasSuccess,
      colorText: context.plantasCores['textoClaro'],
      borderRadius: PlantasDesignTokens.dimensoes['radiusS'],
      margin: EdgeInsets.all(PlantasDesignTokens.dimensoes['paddingM']!),
      icon: Icon(
        Icons.check_circle,
        color: context.plantasCores['textoClaro'],
      ),
    );
  }

  static void error(BuildContext context, String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.plantasError,
      colorText: context.plantasCores['textoClaro'],
      borderRadius: PlantasDesignTokens.dimensoes['radiusS'],
      margin: EdgeInsets.all(PlantasDesignTokens.dimensoes['paddingM']!),
      icon: Icon(
        Icons.error,
        color: context.plantasCores['textoClaro'],
      ),
    );
  }

  static void warning(BuildContext context, String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.plantasWarning,
      colorText: context.plantasCores['textoClaro'],
      borderRadius: PlantasDesignTokens.dimensoes['radiusS'],
      margin: EdgeInsets.all(PlantasDesignTokens.dimensoes['paddingM']!),
      icon: Icon(
        Icons.warning,
        color: context.plantasCores['textoClaro'],
      ),
    );
  }

  static void info(BuildContext context, String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.plantasCores['info'],
      colorText: context.plantasCores['textoClaro'],
      borderRadius: PlantasDesignTokens.dimensoes['radiusS'],
      margin: EdgeInsets.all(PlantasDesignTokens.dimensoes['paddingM']!),
      icon: Icon(
        Icons.info,
        color: context.plantasCores['textoClaro'],
      ),
    );
  }
}
