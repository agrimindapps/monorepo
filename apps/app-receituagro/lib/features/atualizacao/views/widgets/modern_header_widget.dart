import 'package:flutter/material.dart';
import '../../constants/atualizacao_design_tokens.dart';

/// Modern header widget for updates page
class ModernHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leftIcon;
  final bool isDark;
  final bool showBackButton;
  final bool showActions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onRightIconPressed;
  final IconData? rightIcon;

  const ModernHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leftIcon,
    required this.isDark,
    this.showBackButton = true,
    this.showActions = false,
    this.onBackPressed,
    this.onRightIconPressed,
    this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AtualizacaoDesignTokens.defaultPadding,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AtualizacaoDesignTokens.cardBorderRadius,
          ),
        ),
        child: Padding(
          padding: AtualizacaoDesignTokens.cardPadding,
          child: Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  tooltip: 'Voltar',
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AtualizacaoDesignTokens.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  leftIcon,
                  color: AtualizacaoDesignTokens.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (showActions && rightIcon != null) ...[
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(rightIcon),
                  onPressed: onRightIconPressed,
                  tooltip: 'Ação',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}