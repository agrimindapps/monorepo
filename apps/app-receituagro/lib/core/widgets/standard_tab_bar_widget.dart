import 'package:flutter/material.dart';

/// Widget padronizado para TabBars baseado no design do sistema de favoritos
/// Implementa o padrão visual consistente para todas as TabBars do app
///
/// Design Tokens Aplicados:
/// - borderRadius: 20
/// - background: primaryContainer.withAlpha(0.3)
/// - indicator: Color(0xFF4CAF50) com borderRadius 16
/// - labelColor: Colors.white
/// - unselectedLabelColor: onSurface.withAlpha(0.6)
/// - activeFontSize: 11, fontWeight: FontWeight.w600
/// - inactiveFontSize: 0 (oculta texto), fontWeight: FontWeight.w400
/// - iconSize: 16
/// - iconTextGap: 6px
class StandardTabBarWidget extends StatelessWidget {
  final TabController tabController;
  final List<StandardTabData> tabs;
  final VoidCallback? onTabTap;
  final EdgeInsets? margin;
  final Color? indicatorColor;
  final Color? backgroundColor;

  const StandardTabBarWidget({
    super.key,
    required this.tabController,
    required this.tabs,
    this.onTabTap,
    this.margin,
    this.indicatorColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: tabController,
        onTap: onTabTap != null ? (_) => onTabTap!() : null,
        tabs: _buildStandardTabs(theme),
        labelColor: Colors.white,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              indicatorColor ?? const Color(0xFF4CAF50),
              (indicatorColor ?? const Color(0xFF4CAF50)).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (indicatorColor ?? const Color(0xFF4CAF50))
                  .withValues(alpha: 0.4),
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
        indicatorPadding: const EdgeInsets.symmetric(
          horizontal: 6.0,
          vertical: 4.0,
        ),
        dividerColor: Colors.transparent,
      ),
    );
  }

  /// Constrói as tabs com o comportamento padrão de favoritos
  /// Tab Inativa: Apenas ícone visível (text fontSize: 0)
  /// Tab Ativa: Ícone + texto visível com AnimatedBuilder
  List<Widget> _buildStandardTabs(ThemeData theme) {
    return tabs
        .map((tabData) => Tab(
              child: AnimatedBuilder(
                animation: tabController,
                builder: (context, child) {
                  final isActive = tabController.index == tabs.indexOf(tabData);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabData.icon,
                        size: 16,
                        color: isActive
                            ? Colors.white
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          tabData.text,
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

/// Data class para configuração de uma tab
class StandardTabData {
  final IconData icon;
  final String text;
  final String? semanticLabel;

  const StandardTabData({
    required this.icon,
    required this.text,
    this.semanticLabel,
  });

  /// Factory methods para contextos específicos do app

  /// Para Detalhes da Praga
  static List<StandardTabData> get pragaDetailsTabs => [
        const StandardTabData(
          icon: Icons.info_outlined,
          text: 'Informações',
          semanticLabel: 'Informações da praga',
        ),
        const StandardTabData(
          icon: Icons.search_outlined,
          text: 'Diagnósticos',
          semanticLabel: 'Diagnósticos relacionados',
        ),
        const StandardTabData(
          icon: Icons.comment_outlined,
          text: 'Comentários',
          semanticLabel: 'Comentários e observações',
        ),
      ];

  /// Para Detalhes do Defensivo
  static List<StandardTabData> get defensivoDetailsTabs => [
        const StandardTabData(
          icon: Icons.info_outlined,
          text: 'Informações',
          semanticLabel: 'Informações do defensivo',
        ),
        const StandardTabData(
          icon: Icons.search_outlined,
          text: 'Diagnóstico',
          semanticLabel: 'Informações de diagnóstico',
        ),
        const StandardTabData(
          icon: Icons.settings_outlined,
          text: 'Tecnologia',
          semanticLabel: 'Informações técnicas',
        ),
        const StandardTabData(
          icon: Icons.comment_outlined,
          text: 'Comentários',
          semanticLabel: 'Comentários e observações',
        ),
      ];

  /// Para Pragas por Cultura
  static List<StandardTabData> get pragaCultureTabs => [
        const StandardTabData(
          icon: Icons.grass_outlined,
          text: 'Plantas Daninhas',
          semanticLabel: 'Pragas do tipo plantas daninhas',
        ),
        const StandardTabData(
          icon: Icons.coronavirus_outlined,
          text: 'Doenças',
          semanticLabel: 'Pragas do tipo doenças',
        ),
        const StandardTabData(
          icon: Icons.bug_report_outlined,
          text: 'Insetos',
          semanticLabel: 'Pragas do tipo insetos',
        ),
      ];
}
