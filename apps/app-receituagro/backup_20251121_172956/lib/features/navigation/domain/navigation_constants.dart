import 'package:flutter/material.dart';

import '../../../core/theme/app_icons.dart';

/// Constantes para navegação
///
/// **Responsabilidade:** Single Responsibility Principle (SOLID)
/// - Centraliza índices, ícones e labels de navegação
/// - Evita magic numbers e strings hardcoded
/// - Facilita manutenção e mudanças
class NavigationConstants {
  NavigationConstants._(); // Private constructor prevents instantiation

  // ========== Índices de Navegação ==========
  static const int indexDefensivos = 0;
  static const int indexPragas = 1;
  static const int indexFavoritos = 2;
  static const int indexComentarios = 3;
  static const int indexConfiguracoes = 4;

  // ========== Labels ==========
  static const String labelDefensivos = 'Defensivos';
  static const String labelPragas = 'Pragas';
  static const String labelFavoritos = 'Favoritos';
  static const String labelComentarios = 'Comentários';
  static const String labelConfiguracoes = 'Config';

  // ========== Total de itens ==========
  static const int totalItems = 5;

  /// Retorna label por índice
  static String getLabelByIndex(int index) {
    switch (index) {
      case indexDefensivos:
        return labelDefensivos;
      case indexPragas:
        return labelPragas;
      case indexFavoritos:
        return labelFavoritos;
      case indexComentarios:
        return labelComentarios;
      case indexConfiguracoes:
        return labelConfiguracoes;
      default:
        return labelDefensivos;
    }
  }

  /// Retorna ícone por índice
  static IconData getIconByIndex(int index, {bool active = false}) {
    switch (index) {
      case indexDefensivos:
        return AppIcons.defensivos;
      case indexPragas:
        return AppIcons.pragas;
      case indexFavoritos:
        return active ? AppIcons.favoritosFill : AppIcons.favoritos;
      case indexComentarios:
        return active ? AppIcons.comentariosFill : AppIcons.comentarios;
      case indexConfiguracoes:
        return active ? AppIcons.configuracoesFill : AppIcons.configuracoes;
      default:
        return AppIcons.defensivos;
    }
  }
}
