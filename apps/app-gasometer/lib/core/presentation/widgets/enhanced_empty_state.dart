import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Widget melhorado para estados vazios
/// 
/// Fornece interface mais engajante para quando não há dados
/// para exibir, com ícones, mensagens e ações customizáveis.
class EnhancedEmptyState extends StatelessWidget {
  /// Ícone principal do estado vazio
  final IconData icon;
  
  /// Título principal
  final String title;
  
  /// Descrição/subtítulo
  final String description;
  
  /// Texto do botão de ação principal
  final String? actionLabel;
  
  /// Callback do botão de ação
  final VoidCallback? onAction;
  
  /// Texto do botão de ação secundária
  final String? secondaryActionLabel;
  
  /// Callback do botão de ação secundária
  final VoidCallback? onSecondaryAction;
  
  /// Cor do ícone
  final Color? iconColor;
  
  /// Cor de fundo do container do ícone
  final Color? iconBackgroundColor;
  
  /// Tamanho do ícone
  final double? iconSize;
  
  /// Altura total do widget
  final double? height;

  const EnhancedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize,
    this.height,
  });

  /// Factory para manutenções vazias
  factory EnhancedEmptyState.maintenances({
    VoidCallback? onAddMaintenance,
    VoidCallback? onViewGuides,
  }) {
    return EnhancedEmptyState(
      icon: Icons.build_outlined,
      title: 'Nenhuma manutenção registrada',
      description: 'Comece registrando a primeira manutenção do seu veículo para acompanhar o histórico',
      actionLabel: 'Registrar Manutenção',
      onAction: onAddMaintenance,
      secondaryActionLabel: 'Ver Guias',
      onSecondaryAction: onViewGuides,
      height: 400,
    );
  }

  /// Factory para despesas vazias
  factory EnhancedEmptyState.expenses({
    VoidCallback? onAddExpense,
    VoidCallback? onViewTips,
  }) {
    return EnhancedEmptyState(
      icon: Icons.receipt_outlined,
      title: 'Nenhuma despesa registrada',
      description: 'Registre suas despesas para ter controle total dos gastos com seu veículo',
      actionLabel: 'Registrar Despesa',
      onAction: onAddExpense,
      secondaryActionLabel: 'Dicas de Economia',
      onSecondaryAction: onViewTips,
      height: 400,
    );
  }

  /// Factory para estado vazio genérico
  factory EnhancedEmptyState.generic({
    required IconData icon,
    required String title,
    required String description,
    String? actionLabel,
    VoidCallback? onAction,
    double? height,
  }) {
    return EnhancedEmptyState(
      icon: icon,
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      height: height ?? 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(context),
            SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
            _buildTitle(context),
            SizedBox(height: GasometerDesignTokens.spacingSm),
            _buildDescription(context),
            if (actionLabel != null || secondaryActionLabel != null)
              SizedBox(height: GasometerDesignTokens.spacingXxxl),
            if (actionLabel != null || secondaryActionLabel != null)
              _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(BuildContext context) {
    return Container(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingXxxl,
      ),
      decoration: BoxDecoration(
        color: iconBackgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor ??
            Theme.of(context).colorScheme.onSurface.withValues(
              alpha: GasometerDesignTokens.opacityHint,
            ),
        size: iconSize ?? GasometerDesignTokens.iconSizeXxxl + 16,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: GasometerDesignTokens.fontSizeXxl,
        fontWeight: GasometerDesignTokens.fontWeightBold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: GasometerDesignTokens.paddingHorizontal(
        GasometerDesignTokens.spacingXxxl,
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: GasometerDesignTokens.fontSizeMd,
          color: Theme.of(context).colorScheme.onSurface.withValues(
            alpha: GasometerDesignTokens.opacitySecondary,
          ),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (secondaryActionLabel != null && onSecondaryAction != null) {
      actions.add(
        Expanded(
          child: OutlinedButton(
            onPressed: onSecondaryAction,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              padding: GasometerDesignTokens.paddingVertical(
                GasometerDesignTokens.spacingLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusInput,
                ),
              ),
            ),
            child: Text(
              secondaryActionLabel!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: GasometerDesignTokens.fontSizeLg,
              ),
            ),
          ),
        ),
      );
    }

    if (actionLabel != null && onAction != null) {
      if (actions.isNotEmpty) {
        actions.add(SizedBox(width: GasometerDesignTokens.spacingLg));
      }
      
      actions.add(
        Expanded(
          flex: secondaryActionLabel != null ? 2 : 1,
          child: ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: GasometerDesignTokens.paddingVertical(
                GasometerDesignTokens.spacingLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusInput,
                ),
              ),
            ),
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontSize: GasometerDesignTokens.fontSizeLg,
                fontWeight: GasometerDesignTokens.fontWeightSemiBold,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: GasometerDesignTokens.paddingHorizontal(
        GasometerDesignTokens.spacingXxxl,
      ),
      child: Row(children: actions),
    );
  }
}