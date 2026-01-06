import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/widgets/standard_tab_bar_widget.dart';
import 'favoritos_defensivos_tab_widget.dart';
import 'favoritos_diagnosticos_tab_widget.dart';
import 'favoritos_pragas_tab_widget.dart';

/// Widget especializado para sistema de abas dos favoritos
/// Gerencia navegação entre diferentes tipos de favoritos usando Riverpod
class FavoritosTabsWidget extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onReload;

  const FavoritosTabsWidget({
    super.key,
    required this.tabController,
    required this.onReload,
  });

  /// Tabs para Favoritos
  static List<StandardTabData> get favoritosTabs => [
    const StandardTabData(
      icon: FontAwesomeIcons.shield,
      text: 'Defensivos',
      semanticLabel: 'Defensivos favoritos',
    ),
    const StandardTabData(
      icon: FontAwesomeIcons.bug,
      text: 'Pragas',
      semanticLabel: 'Pragas favoritas',
    ),
    const StandardTabData(
      icon: FontAwesomeIcons.magnifyingGlass,
      text: 'Diagnósticos',
      semanticLabel: 'Diagnósticos favoritos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StandardTabBarWidget(
          tabController: tabController,
          tabs: favoritosTabs,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              FavoritosDefensivosTabWidget(
                onReload: onReload,
              ),
              FavoritosPragasTabWidget(
                onReload: onReload,
              ),
              FavoritosDiagnosticosTabWidget(
                onReload: onReload,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
