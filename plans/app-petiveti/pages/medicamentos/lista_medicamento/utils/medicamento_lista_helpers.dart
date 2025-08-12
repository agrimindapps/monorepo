// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'medicamento_lista_constants.dart';

class MedicamentoListaHelpers {
  static Color getTipoColor(String tipo) {
    return MedicamentoListaConstants.tiposCores[tipo] ?? 
           MedicamentoListaConstants.corPadrao;
  }

  static IconData getTipoIcon(String tipo) {
    return MedicamentoListaConstants.tiposIcones[tipo] ?? 
           MedicamentoListaConstants.iconePadrao;
  }

  static String formatResultCount(int count) {
    return '$count medicamentos encontrados';
  }

  static bool shouldShowGridView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600; // Tablet/Desktop
  }

  static double getListHeight(BuildContext context) {
    return MediaQuery.of(context).size.height - 220;
  }

  static BoxDecoration getTypeIconDecoration(String tipo) {
    return BoxDecoration(
      color: getTipoColor(tipo),
      borderRadius: BorderRadius.circular(8),
    );
  }

  static TextStyle getNameTextStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }

  static TextStyle getTypeTextStyle() {
    return TextStyle(
      color: Colors.grey[700],
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle getIndicationTextStyle() {
    return TextStyle(
      color: Colors.grey[600],
      fontSize: 12,
    );
  }

  static TextStyle getResultCountTextStyle() {
    return TextStyle(
      color: Colors.grey[600],
      fontStyle: FontStyle.italic,
    );
  }
}
