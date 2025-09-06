/// Design Tokens para Espaçamentos - ReceitUagro
///
/// Sistema padronizado de espaçamentos seguindo Material Design 3
/// e melhores práticas de UX para densidade de informação adequada
///
/// Baseado em múltiplos de 4dp para garantir consistência visual
/// e alinhamento perfeito em diferentes resoluções de tela
library spacing_tokens;

import 'package:flutter/material.dart';

/// Tokens de espaçamento padronizados para o app ReceitUagro
///
/// **Filosofia de Design:**
/// - Baseado em múltiplos de 4dp (padrão Material Design)
/// - Progressão matemática para hierarchy visual clara
/// - Nomes semânticos para facilitar uso correto
///
/// **Uso Recomendado:**
/// - `xs`: Espaçamentos mínimos entre elementos relacionados
/// - `sm`: **PADRÃO PARA ELEMENTOS EXTERNOS** - Padding de páginas, bordas da tela (8px)
/// - `md`: Padding interno de cards e componentes (12px)
/// - `lg`: Conteúdo interno e separação entre blocos (16px)
/// - `xl`: Separação entre seções principais (24px)
/// - `xxl`: Espaçamentos especiais (bottom nav, headers) (32px)
class SpacingTokens {
  SpacingTokens._();

  // === Core Spacing Values ===

  /// 4dp - Espaçamento mínimo entre elementos muito relacionados
  /// Uso: Separação entre ícone e texto, padding interno pequeno
  static const double xs = 4.0;

  /// 8dp - **PADRÃO PARA ELEMENTOS EXTERNOS**
  /// Uso: Padding de páginas, bordas da tela, containers principais
  static const double sm = 8.0;

  /// 12dp - Espaçamento interno de componentes
  /// Uso: Padding interno de cards, separação entre campos de form
  static const double md = 12.0;

  /// 16dp - Espaçamento para conteúdo interno
  /// Uso: Padding interno de conteúdo, separação entre grupos de informação
  static const double lg = 16.0;

  /// 24dp - Espaçamento entre blocos de conteúdo
  /// Uso: Separação entre seções principais, margin vertical grande
  static const double xl = 24.0;

  /// 32dp - Espaçamento para separação de seções principais
  /// Uso: Header spacing, separação entre áreas funcionais
  static const double xxl = 32.0;

  /// 80dp - Espaçamento especial para bottom navigation
  /// Uso: Bottom padding para evitar sobreposição com nav bar
  static const double bottomNavSpace = 80.0;

  // === EdgeInsets Helpers ===

  /// Padding interno mínimo para componentes pequenos
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);

  /// Padding interno padrão para a maioria dos componentes
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);

  /// Padding interno médio para cards e containers
  static const EdgeInsets paddingMD = EdgeInsets.all(md);

  /// Padding interno grande para seções importantes
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  /// Padding interno extra grande para containers principais
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // === Margins Helpers ===

  /// Margin mínimo entre elementos relacionados
  static const EdgeInsets marginXS = EdgeInsets.all(xs);

  /// Margin pequeno para componentes próximos
  static const EdgeInsets marginSM = EdgeInsets.all(sm);

  /// Margin médio para separação de cards
  static const EdgeInsets marginMD = EdgeInsets.all(md);

  /// Margin padrão entre seções
  static const EdgeInsets marginLG = EdgeInsets.all(lg);

  /// Margin grande entre blocos principais
  static const EdgeInsets marginXL = EdgeInsets.all(xl);

  // === External Element Spacing ===

  /// Padding para elementos externos (bordas da tela, containers principais)
  /// Valor otimizado de 8px para dar mais espaço ao conteúdo
  static const EdgeInsets externalPadding = EdgeInsets.all(sm);

  /// Padding para páginas principais e containers externos
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: sm, // 8px horizontal
    vertical: xs, // 4px vertical para economizar espaço
  );

  /// Padding para conteúdo de ScrollViews com bordas externas 8px
  static const EdgeInsets scrollPadding = EdgeInsets.only(
    top: xs, // 4px top
    left: sm, // 8px left
    right: sm, // 8px right
    bottom: bottomNavSpace, // Espaço para bottom nav
  );

  // === Internal Element Spacing ===

  /// Padding horizontal para conteúdo interno (mantém 16px)
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: lg, // 16px para conteúdo interno
    vertical: sm, // 8px vertical
  );

  /// Margin para TabBar containers (ajustado para elementos externos)
  static const EdgeInsets tabBarMargin = EdgeInsets.symmetric(
    horizontal: sm, // 8px horizontal para consistência externa
    vertical: sm, // 8px vertical
  );

  /// Margin para TabBar sem padding horizontal
  static const EdgeInsets tabBarMarginNoHorizontal = EdgeInsets.symmetric(
    horizontal: 0, // 0px horizontal
    vertical: sm, // 8px vertical
  );

  /// Padding interno de TabBar
  static const EdgeInsets tabBarPadding = EdgeInsets.all(xs);

  /// Margin para cards de informação
  static const EdgeInsets cardMargin = EdgeInsets.only(
    left: sm,
    right: sm,
    top: xs,
    bottom: sm,
  );

  /// Padding interno de cards
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Spacing entre elementos de lista
  static const EdgeInsets listItemSpacing = EdgeInsets.only(bottom: md);

  /// Spacing para separação de seções
  static const EdgeInsets sectionSpacing = EdgeInsets.only(bottom: xl);

  // === SizedBox Helpers ===

  /// SizedBox com altura mínima
  static const SizedBox gapXS = SizedBox(height: xs);

  /// SizedBox com altura pequena
  static const SizedBox gapSM = SizedBox(height: sm);

  /// SizedBox com altura média
  static const SizedBox gapMD = SizedBox(height: md);

  /// SizedBox com altura padrão
  static const SizedBox gapLG = SizedBox(height: lg);

  /// SizedBox com altura grande
  static const SizedBox gapXL = SizedBox(height: xl);

  /// SizedBox com altura extra grande
  static const SizedBox gapXXL = SizedBox(height: xxl);

  /// SizedBox horizontal mínimo
  static const SizedBox gapHorizontalXS = SizedBox(width: xs);

  /// SizedBox horizontal pequeno
  static const SizedBox gapHorizontalSM = SizedBox(width: sm);

  /// SizedBox horizontal médio
  static const SizedBox gapHorizontalMD = SizedBox(width: md);

  /// SizedBox horizontal padrão
  static const SizedBox gapHorizontalLG = SizedBox(width: lg);

  // === Responsive Helpers ===

  /// Retorna padding responsivo baseado no tamanho da tela
  static EdgeInsets responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) {
      // Desktop
      return const EdgeInsets.symmetric(horizontal: xxl, vertical: lg);
    } else if (screenWidth > 800) {
      // Tablet
      return const EdgeInsets.symmetric(horizontal: xl, vertical: lg);
    } else {
      // Mobile
      return contentPadding;
    }
  }

  /// Retorna margin responsivo para cards
  static EdgeInsets responsiveCardMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) {
      return const EdgeInsets.all(lg);
    } else if (screenWidth > 800) {
      return const EdgeInsets.all(md);
    } else {
      return cardMargin;
    }
  }

  /// Retorna espaçamento responsivo entre seções
  static double responsiveSectionGap(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 800) {
      return xxl;
    } else {
      return xl;
    }
  }
}

/// Extensões para facilitar o uso dos tokens de espaçamento
extension SpacingExtensions on Widget {
  /// Adiciona padding usando tokens padronizados
  Widget withPadding(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  /// Adiciona margin usando Container
  Widget withMargin(EdgeInsets margin) {
    return Container(margin: margin, child: this);
  }

  /// Adiciona padding responsivo
  Widget withResponsivePadding(BuildContext context) {
    return Padding(
      padding: SpacingTokens.responsivePadding(context),
      child: this,
    );
  }
}

/// Tokens específicos para tipos de componente
class ComponentSpacing {
  ComponentSpacing._();

  // === TabBar Spacing ===

  /// Altura padrão de TabBar
  static const double tabBarHeight = 44.0;

  /// Padding para tab indicador
  static const EdgeInsets tabIndicatorPadding =
      EdgeInsets.all(SpacingTokens.xs);

  /// Spacing entre ícone e texto em tabs
  static const double tabIconTextGap = 6.0;

  // === Card Spacing ===

  /// Border radius padrão para cards
  static const double cardBorderRadius = 12.0;

  /// Border radius para elementos internos de cards
  static const double cardInnerRadius = 8.0;

  /// Elevação padrão de cards
  static const double cardElevation = 2.0;

  // === Info Section Spacing ===

  /// Espaçamento entre seções de informação
  static const double infoSectionGap = SpacingTokens.xl;

  /// Espaçamento interno de seções
  static const EdgeInsets infoSectionPadding = EdgeInsets.all(SpacingTokens.md);

  /// Espaçamento entre header e conteúdo
  static const double headerContentGap = SpacingTokens.lg;

  // === List Spacing ===

  /// Espaçamento entre itens de lista
  static const double listItemGap = SpacingTokens.md;

  /// Padding para itens de lista
  static const EdgeInsets listItemPadding = EdgeInsets.all(SpacingTokens.md);

  // === Button Spacing ===

  /// Padding interno de botões
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: SpacingTokens.lg,
    vertical: SpacingTokens.sm,
  );

  /// Espaçamento entre botões
  static const double buttonGap = SpacingTokens.md;
}
