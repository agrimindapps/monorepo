import 'package:flutter/material.dart';
import '../theme/spacing_tokens.dart';

/// Widget wrapper que centraliza o conteúdo e aplica largura máxima de 1120px
/// para melhorar a experiência em telas maiores
///
/// PÁGINAS INCLUÍDAS (com limitação de largura):
/// - Todas as páginas principais (Defensivos, Pragas, Favoritos, Comentários, Settings)
/// - Páginas de detalhes (Detalhe Defensivos, Detalhe Pragas, etc.)
///
/// PÁGINAS EXCLUÍDAS (sem limitação de largura):
/// - Páginas de subscription/promocionais (mantém largura total para conversão)
/// - Páginas de login (não existentes no app atual)
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool applyMaxWidth;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1120.0,
    this.padding,
    this.applyMaxWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!applyMaxWidth) {
      return child;
    }

    // Usa padding externo padrão se não especificado
    final effectivePadding = padding ?? SpacingTokens.externalPadding;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }
}

/// Extension para facilitar o uso do wrapper
extension ResponsiveWrapperExtension on Widget {
  /// Aplica o wrapper responsivo com largura máxima de 1120px
  Widget withResponsiveWrapper({
    double maxWidth = 1120.0,
    EdgeInsetsGeometry? padding,
    bool applyMaxWidth = true,
  }) {
    return ResponsiveContentWrapper(
      maxWidth: maxWidth,
      padding: padding,
      applyMaxWidth: applyMaxWidth,
      child: this,
    );
  }
}
