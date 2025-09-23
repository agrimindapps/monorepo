import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Header padronizado para seções de formulário
///
/// Substitui o método _buildSectionWithoutPadding duplicado em
/// múltiplos formulários, centralizando a lógica de exibição
/// de seções com título, ícone e conteúdo.
///
/// Características:
/// - Layout consistente com título e ícone
/// - Espaçamento padronizado
/// - Suporte a conteúdo personalizado
/// - Design tokens unificados
///
/// Exemplo de uso:
/// ```dart
/// FormSectionHeader(
///   title: 'Informações Básicas',
///   icon: Icons.info,
///   child: Column(children: [...]),
/// )
/// ```
class FormSectionHeader extends StatelessWidget {
  /// Título da seção
  final String title;

  /// Ícone da seção
  final IconData icon;

  /// Conteúdo da seção
  final Widget child;

  /// Padding customizado para o conteúdo (opcional)
  final EdgeInsets? contentPadding;

  /// Cor do ícone (opcional - usa cor padrão se não fornecida)
  final Color? iconColor;

  /// Tamanho do ícone (opcional - usa tamanho padrão se não fornecido)
  final double? iconSize;

  /// Estilo do texto do título (opcional)
  final TextStyle? titleStyle;

  /// Se deve aplicar padding vertical no header
  final bool applyVerticalPadding;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.contentPadding,
    this.iconColor,
    this.iconSize,
    this.titleStyle,
    this.applyVerticalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com título e ícone
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: applyVerticalPadding ? GasometerDesignTokens.spacingMd : 0,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: iconSize ?? GasometerDesignTokens.iconSizeSm,
                color: iconColor ?? Colors.grey.shade600,
              ),
              SizedBox(width: GasometerDesignTokens.spacingSm),
              Text(
                title,
                style: titleStyle ?? TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeLg,
                  fontWeight: GasometerDesignTokens.fontWeightMedium,
                  color: GasometerDesignTokens.colorTextPrimary,
                ),
              ),
            ],
          ),
        ),

        // Conteúdo da seção
        Padding(
          padding: contentPadding ?? EdgeInsets.zero,
          child: child,
        ),
      ],
    );
  }
}

/// Variação compacta do FormSectionHeader para casos específicos
class CompactFormSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;

  const CompactFormSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return FormSectionHeader(
      title: title,
      icon: icon,
      child: child,
      iconColor: iconColor,
      iconSize: GasometerDesignTokens.iconSizeXs,
      applyVerticalPadding: false,
      titleStyle: TextStyle(
        fontSize: GasometerDesignTokens.fontSizeBody,
        fontWeight: GasometerDesignTokens.fontWeightMedium,
        color: GasometerDesignTokens.colorTextSecondary,
      ),
    );
  }
}

/// Extensão para facilitar o uso do FormSectionHeader
extension FormSectionHeaderExtensions on Widget {
  /// Adiciona um FormSectionHeader acima do widget atual
  Widget withSectionHeader({
    required String title,
    required IconData icon,
    EdgeInsets? contentPadding,
    Color? iconColor,
    double? iconSize,
    TextStyle? titleStyle,
    bool applyVerticalPadding = true,
  }) {
    return FormSectionHeader(
      title: title,
      icon: icon,
      child: this,
      contentPadding: contentPadding,
      iconColor: iconColor,
      iconSize: iconSize,
      titleStyle: titleStyle,
      applyVerticalPadding: applyVerticalPadding,
    );
  }

  /// Adiciona um CompactFormSectionHeader acima do widget atual
  Widget withCompactSectionHeader({
    required String title,
    required IconData icon,
    Color? iconColor,
  }) {
    return CompactFormSectionHeader(
      title: title,
      icon: icon,
      child: this,
      iconColor: iconColor,
    );
  }
}