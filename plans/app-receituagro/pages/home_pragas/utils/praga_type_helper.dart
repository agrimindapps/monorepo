// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

class PragaTypeHelper {
  static String getTipoText(String codigoTipo) {
    switch (codigoTipo) {
      case '1':
        return 'Inseto';
      case '2':
        return 'Doença';
      case '3':
        return 'Planta';
      default:
        return 'Cultura';
    }
  }

  static IconData getTipoIcon(String tipo) {
    switch (tipo) {
      case '1':
        return FontAwesome.bug_solid;
      case '2':
        return FontAwesome.virus_solid;
      case '3':
        return FontAwesome.seedling_solid;
      default:
        return FontAwesome.wheat_awn_solid;
    }
  }

  static Color getTipoColor(String tipo) {
    switch (tipo) {
      case '1':
        return const Color(0xFFE0F2E9);
      case '2':
        return const Color(0xFFC8E6C9);
      case '3':
        return const Color(0xFF81C784);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  static Color getTipoAvatarColor(String tipo) {
    return getTipoColor(tipo);
  }

  static Color getTipoCardColor(String tipo) {
    return getTipoColor(tipo);
  }
}
