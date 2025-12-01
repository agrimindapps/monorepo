import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildTabBar(context, theme),
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

  Widget _buildTabBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: tabController,
        tabs: _buildCompactTabs(),
        labelColor: Colors.white,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50),
              const Color(0xFF43A047),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 0, // Hide text in inactive tabs
          fontWeight: FontWeight.w400,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        dividerColor: Colors.transparent,
      ),
    );
  }

  List<Widget> _buildCompactTabs() {
    final tabData = [
      {'icon': FontAwesomeIcons.shield, 'text': 'Defensivos'},
      {'icon': FontAwesomeIcons.bug, 'text': 'Pragas'},
      {'icon': FontAwesomeIcons.magnifyingGlass, 'text': 'Diagnósticos'},
    ];

    return tabData
        .map((data) => Tab(
              child: AnimatedBuilder(
                animation: tabController,
                builder: (context, child) {
                  final isActive = tabController.index == tabData.indexOf(data);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        data['icon'] as IconData,
                        size: 16,
                        color: isActive
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          data['text'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ))
        .toList();
  }
}
