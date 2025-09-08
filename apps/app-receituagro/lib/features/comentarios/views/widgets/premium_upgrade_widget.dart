import 'package:flutter/material.dart';
import '../../constants/comentarios_design_tokens.dart';

class PremiumUpgradeWidget extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onUpgrade;
  final bool showIcon;

  const PremiumUpgradeWidget({
    super.key,
    required this.title,
    required this.description,
    this.buttonText = 'Desbloquear Agora',
    this.onUpgrade,
    this.showIcon = true,
  });

  factory PremiumUpgradeWidget.noPermission({
    VoidCallback? onUpgrade,
  }) {
    return PremiumUpgradeWidget(
      title: ComentariosDesignTokens.noPermissionTitle,
      description: ComentariosDesignTokens.noPermissionDescription,
      buttonText: ComentariosDesignTokens.unlockButtonText,
      onUpgrade: onUpgrade,
    );
  }

  factory PremiumUpgradeWidget.limitReached({
    required int current,
    required int max,
    VoidCallback? onUpgrade,
  }) {
    return PremiumUpgradeWidget(
      title: ComentariosDesignTokens.limitReachedTitle,
      description:
          'Você já adicionou $current de $max comentários disponíveis.\nPara adicionar mais comentários, assine o plano premium.',
      buttonText: ComentariosDesignTokens.upgradeToPremiumText,
      onUpgrade: onUpgrade,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(
            maxWidth: ComentariosDesignTokens.maxDialogWidth),
        margin: ComentariosDesignTokens.defaultPadding,
        padding: ComentariosDesignTokens.cardPadding,
        decoration: ComentariosDesignTokens.getWarningDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ComentariosDesignTokens.warningColor
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  ComentariosDesignTokens.diamondIcon,
                  size: 40,
                  color: ComentariosDesignTokens.warningColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: ComentariosDesignTokens.getWarningTextStyle(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ComentariosDesignTokens.warningTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(ComentariosDesignTokens.diamondIcon),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: ComentariosDesignTokens.warningColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
