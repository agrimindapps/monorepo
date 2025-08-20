// Flutter imports:
import 'package:flutter/material.dart';

/// Funções utilitárias para a calculadora de diabetes e insulina
class DiabetesInsulinaUtils {
  /// Valida um número decimal
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Digite um número válido';
    }
    if (double.parse(value.replaceAll(',', '.')) <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  /// Valida um número inteiro
  static String? validateIntNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'Digite um número inteiro válido';
    }
    if (int.parse(value) <= 0) {
      return 'O valor deve ser maior que zero';
    }
    return null;
  }

  /// Retorna o status da glicemia com base no valor e na espécie
  static String getGlicemiaStatus(int glicemia, String? especie) {
    if (glicemia < 50) {
      return 'EMERGÊNCIA: Hipoglicemia severa';
    } else if (glicemia < 70) {
      return 'ALERTA: Hipoglicemia';
    } else if (especie == 'Cão' && glicemia >= 70 && glicemia <= 120) {
      return 'Normal';
    } else if (especie == 'Gato' && glicemia >= 70 && glicemia <= 150) {
      return 'Normal';
    } else if (glicemia > 400) {
      return 'ALERTA: Hiperglicemia severa';
    } else if (glicemia > 250) {
      return 'Hiperglicemia';
    } else if (glicemia > 200) {
      return 'Levemente elevada';
    }
    return 'Valor atípico';
  }

  /// Retorna a cor com base no valor da glicemia
  static Color getGlicemiaColor(int glicemia) {
    if (glicemia > 250 || glicemia < 70) {
      return Colors.red;
    } else if (glicemia < 100 || glicemia > 200) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
