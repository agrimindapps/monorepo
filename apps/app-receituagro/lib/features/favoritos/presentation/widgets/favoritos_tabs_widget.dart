import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/favoritos_provider_simplified.dart';
import 'favoritos_defensivos_tab_widget.dart';
import 'favoritos_diagnosticos_tab_widget.dart';
import 'favoritos_pragas_tab_widget.dart';

/// Widget especializado para sistema de abas dos favoritos
/// Gerencia navegação entre diferentes tipos de favoritos
class FavoritosTabsWidget extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onReload;

  const FavoritosTabsWidget({
    super.key,
    required this.tabController,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        _buildTabBar(context, theme),
        Expanded(
          child: Consumer<FavoritosProviderSimplified>(
            builder: (context, provider, child) {
              return TabBarView(
                controller: tabController,
                children: [
                  FavoritosDefensivosTabWidget(
                    provider: provider,
                    onReload: onReload,
                  ),
                  FavoritosPragasTabWidget(
                    provider: provider,
                    onReload: onReload,
                  ),
                  FavoritosDiagnosticosTabWidget(
                    provider: provider,
                    onReload: onReload,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: tabController,
        tabs: const [
          Tab(
            icon: Icon(FontAwesomeIcons.shield),
            text: 'Defensivos',
          ),
          Tab(
            icon: Icon(FontAwesomeIcons.bug),
            text: 'Pragas',
          ),
          Tab(
            icon: Icon(FontAwesomeIcons.magnifyingGlass),
            text: 'Diagnósticos',
          ),
        ],
        labelColor: const Color(0xFF4CAF50),
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: const Color(0xFF4CAF50),
        indicatorWeight: 3.0,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}