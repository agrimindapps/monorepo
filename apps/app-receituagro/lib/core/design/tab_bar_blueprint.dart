/// Blueprint de Design para TabBars - ReceitUagro
///
/// Sistema padronizado de TabBars baseado na análise do padrão visual
/// e comportamental existente na TabBar de favoritos.
///
/// Este blueprint estabelece tokens de design, estruturas reutilizáveis
/// e comportamentos de animação consistentes para todas as TabBars do app.
///
/// **Áreas de Aplicação:**
/// 1. TabBar de Favoritos (implementado)
/// 2. Detalhes da Praga (target)
/// 3. Detalhes do Defensivo (target)
/// 4. Lista pragas por cultura (target)
library tab_bar_blueprint;

import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// # SPACING TOKENS
///
/// Sistema de espaçamento padronizado baseado em múltiplos de 4dp
class SpacingTokens {
  SpacingTokens._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Sistema de espaçamento específico para componentes
class ComponentSpacing {
  ComponentSpacing._();

  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets containerMargin = EdgeInsets.all(8.0);
  static const double cardBorderRadius = 12.0;
  static const double containerBorderRadius = 20.0;
  static const double tabBarHeight = 44.0;
}

/// # DESIGN TOKENS PARA TABBARS
///
/// Baseado na análise da TabBar de favoritos, estes tokens
/// definem a identidade visual padrão para todas as TabBars do app.
class TabBarDesignTokens {
  TabBarDesignTokens._();

  // === CORES ===

  /// Cor do indicador ativo (verde padrão do app)
  /// Extraído da implementação de favoritos: Color(0xFF4CAF50)
  static const Color indicatorActiveColor = Color(0xFF4CAF50);

  /// Cor de fundo do container da TabBar
  /// Extraído: theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
  static Color containerBackgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);

  /// Cor do texto ativo (branco sobre indicador verde)
  static const Color activeLabelColor = Colors.white;

  /// Cor do texto inativo
  /// Extraído: theme.colorScheme.onSurface.withValues(alpha: 0.6)
  static Color inactiveLabelColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

  /// Cor do ícone ativo
  static const Color activeIconColor = Colors.white;

  /// Cor do ícone inativo
  static Color inactiveIconColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

  // === DIMENSÕES E ESPAÇAMENTOS ===

  /// Altura padrão da TabBar
  static const double tabBarHeight = ComponentSpacing.tabBarHeight; // 44.0

  /// Raio do border do container principal
  static const double containerBorderRadius = 20.0;

  /// Raio do border do indicador ativo
  static const double indicatorBorderRadius = 16.0;

  /// Padding do indicador interno
  /// Extraído: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0)
  static const EdgeInsets indicatorPadding = EdgeInsets.symmetric(
    horizontal: 6.0,
    vertical: 4.0,
  );

  /// Padding entre tabs
  /// Extraído: EdgeInsets.symmetric(horizontal: 6.0)
  static const EdgeInsets labelPadding = EdgeInsets.symmetric(horizontal: 6.0);

  /// Margem do container principal
  /// Extraído: EdgeInsets.symmetric(horizontal: 0.0)
  static const EdgeInsets containerMargin =
      EdgeInsets.symmetric(horizontal: 0.0);

  /// Espaçamento entre ícone e texto
  /// Extraído: SizedBox(width: 6)
  static const double iconTextGap = 6.0;

  // === TIPOGRAFIA ===

  /// Estilo do texto ativo
  /// Extraído: fontSize: 11, fontWeight: FontWeight.w600
  static const TextStyle activeLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: activeLabelColor,
  );

  /// Estilo do texto inativo (oculto)
  /// Extraído: fontSize: 0 (para esconder texto em tabs inativas)
  static const TextStyle inactiveLabelStyle = TextStyle(
    fontSize: 0, // Oculta texto em tabs inativas
    fontWeight: FontWeight.w400,
  );

  /// Tamanho padrão dos ícones
  static const double iconSize = 16.0;

  /// Tamanho do texto inline (usado no AnimatedBuilder)
  static const double inlineTextSize = 11.0;

  /// Peso da fonte para texto inline
  static const FontWeight inlineTextWeight = FontWeight.w600;
}

/// # ESTRUTURA DE DADOS PARA TABS
///
/// Padroniza como definir informações para cada tab,
/// seguindo o padrão observado na implementação de favoritos.
class TabBarItemData {
  final IconData icon;
  final String text;
  final String? tooltip;

  const TabBarItemData({
    required this.icon,
    required this.text,
    this.tooltip,
  });
}

/// # COMPORTAMENTO DE ANIMAÇÃO PADRÃO
///
/// Implementa o comportamento observado na TabBar de favoritos:
/// - Texto aparece apenas na tab ativa
/// - Ícones sempre visíveis com cores dinâmicas
/// - Animações fluidas controladas por AnimatedBuilder
mixin TabBarAnimationBehavior {
  /// Constrói o conteúdo animado de uma tab seguindo o padrão de favoritos
  ///
  /// **Comportamento:**
  /// - Tab inativa: apenas ícone visível
  /// - Tab ativa: ícone + texto com animação fluida
  /// - Cores seguem os design tokens definidos
  static Widget buildAnimatedTabContent({
    required BuildContext context,
    required TabController tabController,
    required int tabIndex,
    required TabBarItemData tabData,
  }) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        final isActive = tabController.index == tabIndex;

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone sempre visível
            Icon(
              tabData.icon,
              size: TabBarDesignTokens.iconSize,
              color: isActive
                  ? TabBarDesignTokens.activeIconColor
                  : TabBarDesignTokens.inactiveIconColor(context),
            ),
            // Texto apenas em tab ativa
            if (isActive) ...[
              const SizedBox(width: TabBarDesignTokens.iconTextGap),
              Text(
                tabData.text,
                style: const TextStyle(
                  fontSize: TabBarDesignTokens.inlineTextSize,
                  fontWeight: TabBarDesignTokens.inlineTextWeight,
                  color: TabBarDesignTokens.activeLabelColor,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// # WIDGET BASE PARA TABBARS PADRONIZADAS
///
/// Implementa a estrutura visual padrão observada na TabBar de favoritos,
/// permitindo customização para diferentes contextos (pragas, defensivos, etc.)
class StandardTabBarWidget extends StatelessWidget {
  final TabController tabController;
  final List<TabBarItemData> tabs;
  final EdgeInsets? containerMargin;
  final Color? customIndicatorColor;
  final Color? customBackgroundColor;

  const StandardTabBarWidget({
    super.key,
    required this.tabController,
    required this.tabs,
    this.containerMargin,
    this.customIndicatorColor,
    this.customBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: containerMargin ?? TabBarDesignTokens.containerMargin,
      decoration: BoxDecoration(
        color: customBackgroundColor ??
            TabBarDesignTokens.containerBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(TabBarDesignTokens.containerBorderRadius),
      ),
      child: TabBar(
        controller: tabController,
        tabs: _buildTabs(context),
        labelColor: TabBarDesignTokens.activeLabelColor,
        unselectedLabelColor: TabBarDesignTokens.inactiveLabelColor(context),
        indicator: BoxDecoration(
          color:
              customIndicatorColor ?? TabBarDesignTokens.indicatorActiveColor,
          borderRadius:
              BorderRadius.circular(TabBarDesignTokens.indicatorBorderRadius),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TabBarDesignTokens.activeLabelStyle,
        unselectedLabelStyle: TabBarDesignTokens.inactiveLabelStyle,
        labelPadding: TabBarDesignTokens.labelPadding,
        indicatorPadding: TabBarDesignTokens.indicatorPadding,
        dividerColor: Colors.transparent,
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    return tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tabData = entry.value;

      return Tab(
        child: TabBarAnimationBehavior.buildAnimatedTabContent(
          context: context,
          tabController: tabController,
          tabIndex: index,
          tabData: tabData,
        ),
      );
    }).toList();
  }
}

/// # FACTORIES PARA CONTEXTOS ESPECÍFICOS
///
/// Pré-configurações para as TabBars específicas identificadas
/// como targets para padronização.
class TabBarFactories {
  TabBarFactories._();

  /// TabBar para Detalhes da Praga
  ///
  /// **Tabs previstas:**
  /// - Informações básicas
  /// - Diagnósticos relacionados
  /// - Comentários/observações
  static StandardTabBarWidget forPragaDetails({
    required TabController tabController,
  }) {
    return StandardTabBarWidget(
      tabController: tabController,
      containerMargin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      tabs: const [
        TabBarItemData(
          icon: Icons.info_outline,
          text: 'Informações',
          tooltip: 'Informações básicas sobre a praga',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.magnifyingGlass,
          text: 'Diagnósticos',
          tooltip: 'Diagnósticos relacionados à praga',
        ),
        TabBarItemData(
          icon: Icons.comment_outlined,
          text: 'Comentários',
          tooltip: 'Comentários e observações',
        ),
      ],
    );
  }

  /// TabBar para Detalhes do Defensivo
  ///
  /// **Tabs previstas:**
  /// - Informações técnicas
  /// - Diagnósticos relacionados
  /// - Dados de tecnologia/aplicação
  /// - Comentários/avaliações
  static StandardTabBarWidget forDefensivoDetails({
    required TabController tabController,
  }) {
    return StandardTabBarWidget(
      tabController: tabController,
      containerMargin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      tabs: const [
        TabBarItemData(
          icon: FontAwesomeIcons.info,
          text: 'Informações',
          tooltip: 'Informações técnicas do defensivo',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.magnifyingGlass,
          text: 'Diagnósticos',
          tooltip: 'Diagnósticos que usam este defensivo',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.gear,
          text: 'Tecnologia',
          tooltip: 'Dados tecnológicos e aplicação',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.comment,
          text: 'Comentários',
          tooltip: 'Comentários e avaliações',
        ),
      ],
    );
  }

  /// TabBar para Lista de Pragas por Cultura
  ///
  /// **Tabs previstas:**
  /// - Todas as pragas
  /// - Pragas principais/comuns
  /// - Favoritos da cultura
  static StandardTabBarWidget forPragasCultura({
    required TabController tabController,
  }) {
    return StandardTabBarWidget(
      tabController: tabController,
      containerMargin: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      tabs: const [
        TabBarItemData(
          icon: FontAwesomeIcons.list,
          text: 'Todas',
          tooltip: 'Todas as pragas da cultura',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.star,
          text: 'Principais',
          tooltip: 'Pragas mais comuns',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.heart,
          text: 'Favoritos',
          tooltip: 'Pragas favoritas desta cultura',
        ),
      ],
    );
  }

  /// TabBar de Favoritos (referência original)
  ///
  /// Mantém a implementação atual como referência
  static StandardTabBarWidget forFavoritos({
    required TabController tabController,
  }) {
    return StandardTabBarWidget(
      tabController: tabController,
      containerMargin: TabBarDesignTokens.containerMargin, // horizontal: 0.0
      tabs: const [
        TabBarItemData(
          icon: FontAwesomeIcons.shield,
          text: 'Defensivos',
          tooltip: 'Defensivos favoritos',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.bug,
          text: 'Pragas',
          tooltip: 'Pragas favoritas',
        ),
        TabBarItemData(
          icon: FontAwesomeIcons.magnifyingGlass,
          text: 'Diagnósticos',
          tooltip: 'Diagnósticos favoritos',
        ),
      ],
    );
  }
}

/// # VARIAÇÕES RESPONSIVAS
///
/// Adapta o comportamento da TabBar para diferentes tamanhos de tela
/// mantendo a consistência visual.
class ResponsiveTabBarVariants {
  ResponsiveTabBarVariants._();

  /// TabBar compacta para telas pequenas
  /// - Reduz espaçamentos
  /// - Pode usar apenas ícones se necessário
  static StandardTabBarWidget compact({
    required TabController tabController,
    required List<TabBarItemData> tabs,
  }) {
    return StandardTabBarWidget(
      tabController: tabController,
      tabs: tabs,
      containerMargin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
      ),
    );
  }

  /// TabBar expandida para tablets/desktop
  /// - Aumenta espaçamentos
  /// - Garante que texto seja sempre visível
  static StandardTabBarWidget expanded({
    required TabController tabController,
    required List<TabBarItemData> tabs,
  }) {
    return StandardTabBarWidget(
      tabController: tabController,
      tabs: tabs,
      containerMargin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xl,
      ),
    );
  }
}

/// # GUIA DE IMPLEMENTAÇÃO
///
/// ## Como usar este blueprint:
///
/// ### 1. Para TabBars simples:
/// ```dart
/// // Usar factory pré-configurada
/// TabBarFactories.forPragaDetails(
///   tabController: _tabController,
/// )
/// ```
///
/// ### 2. Para TabBars customizadas:
/// ```dart
/// StandardTabBarWidget(
///   tabController: _tabController,
///   tabs: [
///     TabBarItemData(
///       icon: Icons.custom_icon,
///       text: 'Custom Tab',
///       tooltip: 'Descrição do tooltip',
///     ),
///   ],
/// )
/// ```
///
/// ### 3. Para adaptação responsiva:
/// ```dart
/// // Em build method
/// final screenWidth = MediaQuery.of(context).size.width;
///
/// if (screenWidth < 600) {
///   return ResponsiveTabBarVariants.compact(
///     tabController: _tabController,
///     tabs: myTabs,
///   );
/// } else {
///   return ResponsiveTabBarVariants.expanded(
///     tabController: _tabController,
///     tabs: myTabs,
///   );
/// }
/// ```
///
/// ### 4. Para casos específicos com customização:
/// ```dart
/// StandardTabBarWidget(
///   tabController: _tabController,
///   tabs: myTabs,
///   customIndicatorColor: Colors.customColor,
///   customBackgroundColor: Colors.customBackground,
///   containerMargin: EdgeInsets.custom(),
/// )
/// ```
///
/// ## Benefícios da padronização:
///
/// ✅ **Consistência Visual**: Todas as TabBars seguem o mesmo padrão visual
/// ✅ **Manutenibilidade**: Mudanças no design são aplicadas centralmente
/// ✅ **Reutilização**: Componentes podem ser reusados em diferentes contextos
/// ✅ **Acessibilidade**: Padrões de acessibilidade aplicados consistentemente
/// ✅ **Performance**: AnimatedBuilder otimizado para melhor performance
/// ✅ **Developer Experience**: APIs claras e factories pré-configuradas
class TabBarImplementationGuide {
  TabBarImplementationGuide._();
}
