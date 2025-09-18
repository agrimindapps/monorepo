import 'package:flutter/material.dart';

/// Widget responsivo que centraliza conteúdo e aplica largura máxima de 1120px
/// para melhorar a experiência do usuário em desktop e tablets largos.
///
/// FUNCIONALIDADES:
/// - Largura máxima de 1120px para evitar interfaces muito largas
/// - Centralização horizontal do conteúdo
/// - Padding lateral automático em telas pequenas
/// - Preserva comportamento de scroll e outros comportamentos existentes
///
/// APLICAÇÃO:
/// - Usar em todas as páginas EXCETO login e páginas promocionais
/// - Mantém responsividade total para mobile
/// - Melhora experiência em desktop sem quebrar funcionalidades
class ResponsiveLayout extends StatelessWidget {
  /// Conteúdo a ser exibido dentro do layout responsivo
  final Widget child;

  /// Largura máxima do conteúdo (padrão 1120px)
  final double maxWidth;

  /// Padding horizontal para telas pequenas (padrão 16px)
  final double horizontalPadding;

  /// Se deve aplicar padding vertical (padrão false)
  final bool applyVerticalPadding;

  /// Padding vertical quando applyVerticalPadding é true
  final double verticalPadding;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 1120.0,
    this.horizontalPadding = 0,
    this.applyVerticalPadding = false,
    this.verticalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Se a tela é menor que maxWidth + padding, use a tela inteira com padding lateral
    // Se a tela é maior, centralize o conteúdo com largura máxima
    if (screenWidth <= maxWidth + (horizontalPadding * 2)) {
      // Mobile/Tablet - usar largura total com padding lateral
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: applyVerticalPadding ? verticalPadding : 0,
        ),
        child: child,
      );
    } else {
      // Desktop - centralizar com largura máxima
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: applyVerticalPadding ? verticalPadding : 0,
          ),
          child: child,
        ),
      );
    }
  }
}

/// Extension para facilitar o uso do ResponsiveLayout
///
/// Permite usar diretamente: myWidget.withResponsiveLayout()
extension ResponsiveLayoutExtension on Widget {
  /// Aplica o layout responsivo padrão ao widget
  Widget withResponsiveLayout({
    double maxWidth = 1120.0,
    double horizontalPadding = 8.0,
    bool applyVerticalPadding = false,
    double verticalPadding = 8.0,
  }) {
    return ResponsiveLayout(
      maxWidth: maxWidth,
      horizontalPadding: horizontalPadding,
      applyVerticalPadding: applyVerticalPadding,
      verticalPadding: verticalPadding,
      child: this,
    );
  }
}

/// Breakpoints responsivos para uso consistente em toda a aplicação
class ResponsiveBreakpoints {
  // Private constructor to prevent instantiation
  const ResponsiveBreakpoints._();

  /// Largura mínima para considerar desktop (1200px)
  static const double desktop = 1200.0;

  /// Largura mínima para considerar tablet (768px)
  static const double tablet = 768.0;

  /// Largura máxima do conteúdo principal (1120px)
  static const double maxContentWidth = 1120.0;

  /// Padding padrão para mobile (16px)
  static const double mobilePadding = 16.0;

  /// Padding padrão para tablet (24px)
  static const double tabletPadding = 24.0;

  /// Padding padrão para desktop (32px)
  static const double desktopPadding = 32.0;

  /// Retorna true se a tela é considerada desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Retorna true se a tela é considerada tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Retorna true se a tela é considerada mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  /// Retorna o padding horizontal apropriado para a tela atual
  static double getPaddingForScreen(BuildContext context) {
    if (isDesktop(context)) return desktopPadding;
    if (isTablet(context)) return tabletPadding;
    return mobilePadding;
  }
}

/// Widget helper para construir layouts adaptativos baseados em breakpoints
class AdaptiveLayout extends StatelessWidget {
  /// Layout para mobile (obrigatório)
  final Widget mobile;

  /// Layout para tablet (opcional, usa mobile se não fornecido)
  final Widget? tablet;

  /// Layout para desktop (opcional, usa tablet ou mobile se não fornecido)
  final Widget? desktop;

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context) && desktop != null) {
      return desktop!;
    }

    if (ResponsiveBreakpoints.isTablet(context) && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}
