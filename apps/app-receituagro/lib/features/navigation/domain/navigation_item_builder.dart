import 'package:flutter/material.dart';

import '../../../core/theme/app_icons.dart';
import 'navigation_constants.dart';

/// Serviço para criar BottomNavigationBarItems
///
/// **Responsabilidade:** Single Responsibility Principle (SOLID)
/// - Centraliza criação de navigation items
/// - Evita duplicação de código entre widgets
/// - Facilita mudanças de estilo e comportamento
class NavigationItemBuilder {
  /// Cria todos os BottomNavigationBarItems
  static List<BottomNavigationBarItem> buildItems() {
    return [
      _buildItem(NavigationConstants.indexDefensivos),
      _buildItem(NavigationConstants.indexPragas),
      _buildItem(NavigationConstants.indexFavoritos),
      _buildItem(NavigationConstants.indexComentarios),
      _buildItem(NavigationConstants.indexConfiguracoes),
    ];
  }

  /// Cria um BottomNavigationBarItem por índice
  static BottomNavigationBarItem _buildItem(int index) {
    final icon = NavigationConstants.getIconByIndex(index);
    final activeIcon = NavigationConstants.getIconByIndex(index, active: true);
    final label = NavigationConstants.getLabelByIndex(index);

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }

  /// Cria items com estilo simplificado (sem padding)
  static List<BottomNavigationBarItem> buildSimpleItems() {
    return [
      _buildSimpleItem(
        AppIcons.defensivos,
        NavigationConstants.labelDefensivos,
      ),
      _buildSimpleItem(AppIcons.pragas, NavigationConstants.labelPragas),
      _buildSimpleItem(
        AppIcons.favoritos,
        NavigationConstants.labelFavoritos,
        activeIcon: AppIcons.favoritosFill,
      ),
      _buildSimpleItem(
        AppIcons.comentarios,
        NavigationConstants.labelComentarios,
        activeIcon: AppIcons.comentariosFill,
      ),
      _buildSimpleItem(
        AppIcons.configuracoes,
        NavigationConstants.labelConfiguracoes,
        activeIcon: AppIcons.configuracoesFill,
      ),
    ];
  }

  static BottomNavigationBarItem _buildSimpleItem(
    IconData icon,
    String label, {
    IconData? activeIcon,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon ?? icon),
      label: label,
    );
  }
}
