import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Card padrão para consistência visual em todo o app
///
/// Baseado no design system do GasOMeter, mantém padding,
/// border radius, elevação e estilos consistentes.
class StandardCard extends StatelessWidget {

  const StandardCard({
    super.key,
    this.padding,
    this.margin,
    this.onTap,
    this.hasElevation = false,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
    required this.child,
  });

  /// Factory para card com padding padrão
  factory StandardCard.standard({
    required Widget child,
    EdgeInsets? margin,
    VoidCallback? onTap,
    bool hasElevation = false,
    Color? backgroundColor,
    bool showBorder = true,
  }) {
    return StandardCard(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingCardPadding,
      ),
      margin: margin,
      onTap: onTap,
      hasElevation: hasElevation,
      backgroundColor: backgroundColor,
      showBorder: showBorder,
      child: child,
    );
  }

  /// Factory para card compacto
  factory StandardCard.compact({
    required Widget child,
    EdgeInsets? margin,
    VoidCallback? onTap,
    bool hasElevation = false,
    Color? backgroundColor,
    bool showBorder = true,
  }) {
    return StandardCard(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingMd,
      ),
      margin: margin,
      onTap: onTap,
      hasElevation: hasElevation,
      backgroundColor: backgroundColor,
      showBorder: showBorder,
      child: child,
    );
  }

  /// Factory para card com seção de formulário
  factory StandardCard.formSection({
    required Widget child,
    EdgeInsets? margin,
    VoidCallback? onTap,
    bool showBorder = true,
  }) {
    return StandardCard(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingCardPadding,
      ),
      margin:
          margin ?? const EdgeInsets.only(bottom: GasometerDesignTokens.spacingLg),
      onTap: onTap,
      hasElevation: false,
      showBorder: showBorder,
      child: child,
    );
  }
  /// Conteúdo do card
  final Widget child;

  /// Padding interno do card
  final EdgeInsets? padding;

  /// Margin externa do card
  final EdgeInsets? margin;

  /// Callback para quando o card é tocado
  final VoidCallback? onTap;

  /// Se o card deve ter uma sombra
  final bool hasElevation;

  /// Cor de fundo customizada
  final Color? backgroundColor;

  /// Border radius customizado
  final double? borderRadius;

  /// Se deve mostrar border ao redor do card
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final cardChild = padding != null ? Padding(padding: padding!, child: child) : child;

    return Container(
      margin: margin,
      child: Card(
        elevation:
            hasElevation
                ? GasometerDesignTokens.elevationCard
                : GasometerDesignTokens.elevationNone,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            borderRadius ?? GasometerDesignTokens.radiusCard,
          ),
          side:
              showBorder
                  ? BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1.0,
                  )
                  : BorderSide.none,
        ),
        child:
            onTap != null
                ? InkWell(
                  onTap: onTap,
                  borderRadius: GasometerDesignTokens.borderRadius(
                    borderRadius ?? GasometerDesignTokens.radiusCard,
                  ),
                  child: cardChild,
                )
                : cardChild,
      ),
    );
  }
}

/// Widget para título de seção dentro de um card
class CardSectionTitle extends StatelessWidget {

  const CardSectionTitle({
    super.key,
    this.icon,
    this.iconColor,
    this.trailing,
    required this.title,
  });
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GasometerDesignTokens.spacingMd),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: GasometerDesignTokens.iconSizeButton,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: GasometerDesignTokens.spacingSm),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeLg,
                fontWeight: GasometerDesignTokens.fontWeightSemiBold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Widget para informações em linha dentro de cards
class CardInfoRow extends StatelessWidget {

  const CardInfoRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      readOnly: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: GasometerDesignTokens.spacingXs,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: GasometerDesignTokens.iconSizeXs,
                color:
                    iconColor ??
                    Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: GasometerDesignTokens.opacitySecondary,
                    ),
              ),
              const SizedBox(width: GasometerDesignTokens.spacingXs + 2),
            ],
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                  alpha: GasometerDesignTokens.opacitySecondary,
                ),
                fontSize: GasometerDesignTokens.fontSizeMd,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: GasometerDesignTokens.fontWeightMedium,
                fontSize: GasometerDesignTokens.fontSizeMd,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
