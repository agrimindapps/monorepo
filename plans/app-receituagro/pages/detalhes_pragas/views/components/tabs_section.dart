// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../../core/controllers/theme_controller.dart';
import '../../constants/detalhes_pragas_design_tokens.dart';
import '../../controller/detalhes_pragas_controller.dart';
import '../tabs/comentarios_tab.dart';
import '../tabs/diagnostico_tab.dart';
import '../tabs/informacoes_tab.dart';

/// Seção de abas para a página de detalhes de pragas
class TabsSection extends StatelessWidget {
  const TabsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => GetBuilder<DetalhesPragasController>(
        builder: (controller) {
          final isDark = themeController.isDark.value;
          return Column(
            children: [
              _buildTabBar(context, controller, isDark),
              Expanded(
                child: _buildTabBarView(context, controller, isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, DetalhesPragasController controller, bool isDark) {
    
    return Container(
      height: DetalhesPragasDesignTokens.largeSpacing * 2.75, // ~44px
      margin: const EdgeInsets.only(
        top: DetalhesPragasDesignTokens.defaultSpacing,
        bottom: DetalhesPragasDesignTokens.smallSpacing,
        left: DetalhesPragasDesignTokens.defaultSpacing,
        right: DetalhesPragasDesignTokens.defaultSpacing,
      ),
      decoration: _buildGradientTabBarDecoration(isDark),
      child: TabBar(
        controller: controller.tabController,
        tabs: _buildTabsWithIcons(context, isDark, controller),
        indicator: _buildGradientTabIndicator(),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.green.shade800,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context, DetalhesPragasController controller, bool isDark) {
    
    return Container(
      margin: const EdgeInsets.only(
        left: DetalhesPragasDesignTokens.defaultSpacing,
        right: DetalhesPragasDesignTokens.defaultSpacing,
        top: DetalhesPragasDesignTokens.smallSpacing,
        bottom: DetalhesPragasDesignTokens.defaultSpacing,
      ),
      decoration: BoxDecoration(
        color: _getCardColor(isDark),
        borderRadius: BorderRadius.circular(DetalhesPragasDesignTokens.mediumBorderRadius),
      ),
      child: TabBarView(
        controller: controller.tabController,
        children: [
          _wrapTabContent(const InformacoesTab(), 'informacoes'),
          _wrapTabContent(const DiagnosticoTab(), 'diagnostico'),
          _wrapTabContent(ComentariosTab(controller: controller), 'comentarios'),
        ],
      ),
    );
  }

  Widget _wrapTabContent(Widget content, String type) {
    return Container(
      key: ValueKey('$type-content'),
      child: content,
    );
  }

  List<Widget> _buildTabsWithIcons(BuildContext context, bool isDark, DetalhesPragasController controller) {
    final tabData = [
      {'icon': FontAwesome.info_solid, 'text': 'Info'},
      {'icon': FontAwesome.magnifying_glass_solid, 'text': 'Diagnóstico'},
      {'icon': FontAwesome.comment_solid, 'text': 'Comentários'},
    ];

    return tabData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      
      return Tab(
        child: AnimatedBuilder(
          animation: controller.tabController,
          builder: (context, _) {
            final isActive = controller.tabController.index == index;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? null : 40, // Tabs inativas ficam mais estreitas
              child: Row(
                mainAxisSize: isActive ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    data['icon'] as IconData,
                    size: isActive ? 18 : 16,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: DetalhesPragasDesignTokens.smallSpacing),
                    Flexible(
                      child: Text(
                        data['text'] as String,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    }).toList();
  }

  // Helper methods for styling
  Color _getCardColor(bool isDark) {
    return isDark ? const Color(0xFF1E1E22) : Colors.white;
  }



  /// Decoração com gradiente para o tabbar (inspirado em lista_pragas_por_cultura)
  BoxDecoration _buildGradientTabBarDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.green.shade100,
          Colors.green.shade200,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(DetalhesPragasDesignTokens.mediumBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.green.shade200.withValues(alpha: 0.5),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Indicador com gradiente para tab ativo
  BoxDecoration _buildGradientTabIndicator() {
    return BoxDecoration(
      color: Colors.green.shade700,
      borderRadius: BorderRadius.circular(DetalhesPragasDesignTokens.defaultSpacing),
    );
  }
}
