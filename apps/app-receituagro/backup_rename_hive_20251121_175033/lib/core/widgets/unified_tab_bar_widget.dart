/// Widget TabBar Unificado - ReceitUagro
///
/// Substitui as implementações inconsistentes de CustomTabBarWidget
/// nas páginas de pragas e defensivos, criando uma interface unificada
/// e consistente com os design tokens padronizados.
///
/// **Características:**
/// - Design baseado em Material Design 3
/// - Suporte a ícones e texto
/// - Animações fluidas e responsivas
/// - Configuração flexível para diferentes contextos
/// - Acessibilidade total (screen readers, keyboard navigation)
library;

import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../theme/spacing_tokens.dart';

/// Dados de configuração para cada tab
class TabData {
  final IconData icon;
  final String text;
  final String? tooltip;

  const TabData({
    required this.icon,
    required this.text,
    this.tooltip,
  });
}

/// Widget TabBar unificado para uso em páginas de detalhes
///
/// **Features:**
/// - Design consistente baseado em tokens
/// - Suporte a diferentes contextos (pragas, defensivos, etc.)
/// - Animações suaves entre estados
/// - Responsive design para diferentes tamanhos de tela
/// - Acessibilidade completa
class UnifiedTabBarWidget extends StatelessWidget {
  final TabController tabController;
  final List<TabData> tabs;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool showIconOnly;
  final double? height;
  final EdgeInsets? margin;

  const UnifiedTabBarWidget({
    super.key,
    required this.tabController,
    required this.tabs,
    this.primaryColor,
    this.backgroundColor,
    this.showIconOnly = false,
    this.height,
    this.margin,
  });

  /// Factory para tabs de página de pragas
  factory UnifiedTabBarWidget.forPragas({
    required TabController tabController,
  }) {
    return UnifiedTabBarWidget(
      tabController: tabController,
      tabs: const [
        TabData(
          icon: Icons.info_outline,
          text: 'Informações',
          tooltip: 'Informações básicas sobre a praga',
        ),
        TabData(
          icon: Icons.search,
          text: 'Diagnóstico',
          tooltip: 'Diagnósticos relacionados',
        ),
        TabData(
          icon: Icons.comment_outlined,
          text: 'Comentários',
          tooltip: 'Comentários e observações',
        ),
      ],
    );
  }

  /// Factory para tabs de página de defensivos
  factory UnifiedTabBarWidget.forDefensivos({
    required TabController tabController,
  }) {
    return UnifiedTabBarWidget(
      tabController: tabController,
      tabs: const [
        TabData(
          icon: FontAwesomeIcons.info,
          text: 'Informações',
          tooltip: 'Informações técnicas do defensivo',
        ),
        TabData(
          icon: FontAwesomeIcons.magnifyingGlass,
          text: 'Diagnóstico',
          tooltip: 'Diagnósticos com este defensivo',
        ),
        TabData(
          icon: FontAwesomeIcons.gear,
          text: 'Tecnologia',
          tooltip: 'Dados tecnológicos e aplicação',
        ),
        TabData(
          icon: FontAwesomeIcons.comment,
          text: 'Comentários',
          tooltip: 'Comentários e avaliações',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectivePrimaryColor = primaryColor ?? colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.primaryContainer;

    return Container(
      height: height ?? ComponentSpacing.tabBarHeight,
      margin: margin ?? SpacingTokens.tabBarMarginNoHorizontal,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(ComponentSpacing.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: effectivePrimaryColor,
          borderRadius: BorderRadius.circular(ComponentSpacing.cardInnerRadius),
        ),
        indicatorPadding: ComponentSpacing.tabIndicatorPadding,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: effectivePrimaryColor,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: InkRipple.splashFactory,
        tabs: _buildTabs(context),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    return tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tabData = entry.value;

      return Tab(
        height: height ?? ComponentSpacing.tabBarHeight,
        child: _TabContent(
          tabData: tabData,
          tabController: tabController,
          tabIndex: index,
          showIconOnly: showIconOnly,
        ),
      );
    }).toList();
  }
}

/// Widget interno para conteúdo animado da tab
class _TabContent extends StatelessWidget {
  final TabData tabData;
  final TabController tabController;
  final int tabIndex;
  final bool showIconOnly;

  const _TabContent({
    required this.tabData,
    required this.tabController,
    required this.tabIndex,
    required this.showIconOnly,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final isActive = _isTabActive();
        final animationValue = _getAnimationValue();

        return Tooltip(
          message: tabData.tooltip ?? tabData.text,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _buildTabLayout(context, isActive, animationValue),
          ),
        );
      },
    );
  }

  bool _isTabActive() {
    return tabController.index == tabIndex;
  }

  double _getAnimationValue() {
    if (!tabController.indexIsChanging) {
      return tabController.index == tabIndex ? 1.0 : 0.0;
    }

    final animationValue =
        tabController.animation?.value ?? tabController.index.toDouble();
    final distance = (animationValue - tabIndex).abs();
    return (1.0 - distance).clamp(0.0, 1.0);
  }

  Widget _buildTabLayout(
      BuildContext context, bool isActive, double animationValue) {
    if (showIconOnly) {
      return _buildIconOnlyLayout(isActive, animationValue, context);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final shouldShowText = screenWidth > 400 || isActive;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIcon(isActive, animationValue, context),
        if (shouldShowText) ...[
          const SizedBox(width: ComponentSpacing.tabIconTextGap),
          _buildText(isActive, animationValue, context),
        ],
      ],
    );
  }

  Widget _buildIconOnlyLayout(bool isActive, double animationValue, BuildContext context) {
    return _buildIcon(isActive, animationValue, context);
  }

  Widget _buildIcon(bool isActive, double animationValue, BuildContext context) {
    final iconSize = 16.0 + (2.0 * animationValue);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: Icon(
        tabData.icon,
        size: iconSize,
        color: isActive 
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.primary,
        semanticLabel: tabData.text,
      ),
    );
  }

  Widget _buildText(
      bool isActive, double animationValue, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String displayText = tabData.text;
    if (screenWidth < 600 && tabData.text.length > 8) {
      final words = tabData.text.split(' ');
      if (words.length > 1) {
        displayText = '${words[0]}${words[0].length < 6 ? '...' : ''}';
      } else if (tabData.text.length > 8) {
        displayText = '${tabData.text.substring(0, 6)}...';
      }
    }

    return Flexible(
      child: AnimatedOpacity(
        opacity: 0.7 + (0.3 * animationValue),
        duration: const Duration(milliseconds: 200),
        child: Text(
          displayText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

/// Utilitários para criar variantes de TabBar para contextos específicos
mixin TabBarVariants {
  static const _defaultTabHeight = ComponentSpacing.tabBarHeight;

  /// TabBar compacto para telas pequenas
  static UnifiedTabBarWidget compact({
    required TabController tabController,
    required List<TabData> tabs,
  }) {
    return UnifiedTabBarWidget(
      tabController: tabController,
      tabs: tabs,
      height: _defaultTabHeight - 8,
      showIconOnly: true,
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
    );
  }

  /// TabBar para tablet/desktop com mais espaço
  static UnifiedTabBarWidget expanded({
    required TabController tabController,
    required List<TabData> tabs,
  }) {
    return UnifiedTabBarWidget(
      tabController: tabController,
      tabs: tabs,
      height: _defaultTabHeight + 8,
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xl,
        vertical: SpacingTokens.md,
      ),
    );
  }
}
