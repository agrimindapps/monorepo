import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../tokens/list_item_design_tokens.dart';

/// Tipos de badge disponíveis
enum BadgeType {
  /// Badge para tipo de combustível
  fuel,
  /// Badge para tipo de despesa
  expense,
  /// Badge para tipo de manutenção
  maintenance,
  /// Badge para categoria geral
  category,
  /// Badge para status
  status,
}

/// Widget padronizado para exibição de badges/tags em list items
/// 
/// Usado para mostrar categorias, tipos e status de forma consistente
/// em todos os tipos de list items.
class TypeBadgeWidget extends StatelessWidget {
  /// Texto do badge
  final String label;
  
  /// Tipo do badge (afeta cores e estilos)
  final BadgeType type;
  
  /// Cor customizada de fundo
  final Color? backgroundColor;
  
  /// Cor customizada do texto
  final Color? textColor;
  
  /// Ícone opcional
  final IconData? icon;
  
  /// Tamanho compacto
  final bool compact;
  
  /// Se deve mostrar apenas o ícone (sem texto)
  final bool iconOnly;

  const TypeBadgeWidget({
    super.key,
    required this.label,
    required this.type,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.compact = false,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final padding = compact 
        ? const EdgeInsets.symmetric(
            horizontal: GasometerDesignTokens.spacingXs,
            vertical: 2.0,
          )
        : const EdgeInsets.symmetric(
            horizontal: GasometerDesignTokens.spacingSm,
            vertical: GasometerDesignTokens.spacingXs,
          );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.background,
        borderRadius: ListItemDesignTokens.badgeBorderRadius,
        border: Border.all(
          color: colors.border,
          width: 0.5,
        ),
      ),
      child: iconOnly 
          ? _buildIconOnly(colors)
          : _buildWithText(colors),
    );
  }

  Widget _buildIconOnly(_BadgeColors colors) {
    if (icon == null) return const SizedBox.shrink();
    
    return Icon(
      icon,
      size: compact ? 12 : 14,
      color: textColor ?? colors.text,
    );
  }

  Widget _buildWithText(_BadgeColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[ 
          Icon(
            icon,
            size: compact ? 12 : 14,
            color: textColor ?? colors.text,
          ),
          const SizedBox(width: GasometerDesignTokens.spacingXs),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 10 : 12,
            fontWeight: GasometerDesignTokens.fontWeightMedium,
            color: textColor ?? colors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  _BadgeColors _getColors() {
    switch (type) {
      case BadgeType.fuel:
        return _BadgeColors(
          background: GasometerDesignTokens.colorPrimaryLight.withValues(alpha: 0.1),
          text: GasometerDesignTokens.colorPrimary,
          border: GasometerDesignTokens.colorPrimary.withValues(alpha: 0.3),
        );
      case BadgeType.expense:
        return _BadgeColors(
          background: GasometerDesignTokens.colorError.withValues(alpha: 0.1),
          text: GasometerDesignTokens.colorError,
          border: GasometerDesignTokens.colorError.withValues(alpha: 0.3),
        );
      case BadgeType.maintenance:
        return _BadgeColors(
          background: GasometerDesignTokens.colorWarning.withValues(alpha: 0.1),
          text: GasometerDesignTokens.colorWarning,
          border: GasometerDesignTokens.colorWarning.withValues(alpha: 0.3),
        );
      case BadgeType.category:
        return _BadgeColors(
          background: GasometerDesignTokens.colorSurface,
          text: GasometerDesignTokens.colorTextSecondary,
          border: GasometerDesignTokens.colorNeutral300,
        );
      case BadgeType.status:
        return _BadgeColors(
          background: GasometerDesignTokens.colorSuccess.withValues(alpha: 0.1),
          text: GasometerDesignTokens.colorSuccess,
          border: GasometerDesignTokens.colorSuccess.withValues(alpha: 0.3),
        );
    }
  }
  
  /// Factory para criar badge de combustível
  factory TypeBadgeWidget.fuel({
    required String fuelType,
    IconData? icon,
    bool compact = false,
  }) {
    return TypeBadgeWidget(
      label: fuelType,
      type: BadgeType.fuel,
      icon: icon ?? Icons.local_gas_station,
      compact: compact,
    );
  }
  
  /// Factory para criar badge de despesa
  factory TypeBadgeWidget.expense({
    required String expenseType,
    IconData? icon,
    bool compact = false,
  }) {
    return TypeBadgeWidget(
      label: expenseType,
      type: BadgeType.expense,
      icon: icon ?? Icons.receipt_long,
      compact: compact,
    );
  }
  
  /// Factory para criar badge de manutenção
  factory TypeBadgeWidget.maintenance({
    required String maintenanceType,
    IconData? icon,
    bool compact = false,
  }) {
    return TypeBadgeWidget(
      label: maintenanceType,
      type: BadgeType.maintenance,
      icon: icon ?? Icons.build,
      compact: compact,
    );
  }
  
  /// Factory para criar badge de categoria
  factory TypeBadgeWidget.category({
    required String category,
    IconData? icon,
    bool compact = false,
  }) {
    return TypeBadgeWidget(
      label: category,
      type: BadgeType.category,
      icon: icon ?? Icons.category,
      compact: compact,
    );
  }
  
  /// Factory para criar badge de status
  factory TypeBadgeWidget.status({
    required String status,
    IconData? icon,
    bool compact = false,
    Color? customColor,
  }) {
    return TypeBadgeWidget(
      label: status,
      type: BadgeType.status,
      icon: icon ?? Icons.check_circle,
      compact: compact,
      textColor: customColor,
    );
  }
  
  /// Factory para criar badge apenas com ícone
  factory TypeBadgeWidget.iconOnly({
    required IconData icon,
    required BadgeType type,
    bool compact = true,
    Color? customColor,
  }) {
    return TypeBadgeWidget(
      label: '',
      type: type,
      icon: icon,
      compact: compact,
      iconOnly: true,
      textColor: customColor,
    );
  }
}

/// Classe auxiliar para cores do badge
class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.text,
    required this.border,
  });

  final Color background;
  final Color text;
  final Color border;
}