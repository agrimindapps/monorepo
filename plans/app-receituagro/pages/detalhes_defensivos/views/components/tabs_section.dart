// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../constants/detalhes_defensivos_design_tokens.dart';
import '../../controller/detalhes_defensivos_controller.dart';

class TabsSectionWidget extends StatelessWidget {
  final DetalhesDefensivosController controller;

  const TabsSectionWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetalhesDefensivosController>(
      builder: (controller) {
        final isDark = controller.isDark;
        
        return Container(
          height: DetalhesDefensivosDesignTokens.largeSpacing * 2.75, // ~44px
          margin: const EdgeInsets.only(
            top: DetalhesDefensivosDesignTokens.defaultSpacing,
            bottom: DetalhesDefensivosDesignTokens.smallSpacing,
            left: DetalhesDefensivosDesignTokens.defaultSpacing,
            right: DetalhesDefensivosDesignTokens.defaultSpacing,
          ),
          decoration: _buildGradientTabBarDecoration(isDark),
          child: TabBar(
            controller: controller.tabController,
            tabs: _buildTabsWithIcons(context, isDark),
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
      },
    );
  }

  List<Widget> _buildTabsWithIcons(BuildContext context, bool isDark) {
    final tabData = [
      {'icon': FontAwesome.info_solid, 'text': 'Info'},
      {'icon': FontAwesome.magnifying_glass_solid, 'text': 'Diagnóstico'},
      {'icon': FontAwesome.spray_can_sparkles_solid, 'text': 'Aplicação'},
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
                    const SizedBox(width: DetalhesDefensivosDesignTokens.smallSpacing),
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
      borderRadius: BorderRadius.circular(DetalhesDefensivosDesignTokens.defaultBorderRadius),
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
      borderRadius: BorderRadius.circular(DetalhesDefensivosDesignTokens.defaultSpacing),
    );
  }
}
