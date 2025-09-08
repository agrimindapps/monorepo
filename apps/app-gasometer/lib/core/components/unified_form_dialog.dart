import 'package:flutter/material.dart';

import '../design/unified_design_tokens.dart';

/// Container de diálogo unificado para formulários responsivos
/// 
/// Características:
/// - Design responsivo para mobile, tablet e desktop
/// - Header padronizado com ícone e título
/// - Footer com botões de ação consistentes
/// - Estados de loading integrados
/// - Suporte a validação global do formulário
/// - Comportamento de teclado otimizado
class UnifiedFormDialog extends StatelessWidget {
  const UnifiedFormDialog({
    super.key,
    required this.title,
    required this.content,
    this.subtitle,
    this.headerIcon,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
    this.canConfirm = true,
    this.barrierDismissible = true,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final IconData? headerIcon;
  final Widget content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool canConfirm;
  final bool barrierDismissible;
  final bool scrollable;

  /// Mostra o diálogo usando o padrão Material 3
  static Future<T?> show<T>({
    required BuildContext context,
    required UnifiedFormDialog dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible && dialog.barrierDismissible,
      builder: (context) => dialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = UnifiedDesignTokens.isTablet(context);
    final isDesktop = UnifiedDesignTokens.isDesktop(context);
    
    // Definir largura responsiva
    double dialogWidth;
    if (isDesktop) {
      dialogWidth = 600;
    } else if (isTablet) {
      dialogWidth = screenSize.width * 0.7;
    } else {
      dialogWidth = screenSize.width * 0.9;
    }
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: UnifiedDesignTokens.responsiveSpacing(context),
        vertical: UnifiedDesignTokens.spacingXL,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: screenSize.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusDialog),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, theme),
            
            // Content
            if (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UnifiedDesignTokens.spacingDialogPadding),
                  child: content,
                ),
              )
            else
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(UnifiedDesignTokens.spacingDialogPadding),
                  child: content,
                ),
              ),
            
            // Actions
            if (onConfirm != null || onCancel != null)
              _buildActions(context, theme),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UnifiedDesignTokens.spacingDialogPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UnifiedDesignTokens.radiusDialog),
          topRight: Radius.circular(UnifiedDesignTokens.radiusDialog),
        ),
      ),
      child: Row(
        children: [
          // Ícone do header
          if (headerIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(UnifiedDesignTokens.spacingSM),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusSM),
              ),
              child: Icon(
                headerIcon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: UnifiedDesignTokens.spacingMD),
          ],
          
          // Título e subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: UnifiedDesignTokens.fontWeightSemiBold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: UnifiedDesignTokens.spacingXS),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Botão de fechar se barrierDismissible
          if (barrierDismissible && onCancel != null)
            IconButton(
              onPressed: isLoading ? null : onCancel,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(UnifiedDesignTokens.spacingDialogPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão cancelar
          if (onCancel != null) ...[
            TextButton(
              onPressed: isLoading ? null : onCancel,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(
                  horizontal: UnifiedDesignTokens.spacingXL,
                  vertical: UnifiedDesignTokens.spacingMD,
                ),
              ),
              child: Text(cancelText ?? 'Cancelar'),
            ),
            const SizedBox(width: UnifiedDesignTokens.spacingMD),
          ],
          
          // Botão confirmar
          if (onConfirm != null)
            FilledButton(
              onPressed: (isLoading || !canConfirm) ? null : onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                padding: const EdgeInsets.symmetric(
                  horizontal: UnifiedDesignTokens.spacingXL,
                  vertical: UnifiedDesignTokens.spacingMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusButton),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(confirmText ?? 'Confirmar'),
            ),
        ],
      ),
    );
  }
}

/// Extension para facilitar o uso do UnifiedFormDialog
extension UnifiedFormDialogExtension on BuildContext {
  /// Mostra um diálogo de formulário unificado
  Future<T?> showUnifiedFormDialog<T>({
    required String title,
    required Widget content,
    String? subtitle,
    IconData? headerIcon,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isLoading = false,
    bool canConfirm = true,
    bool barrierDismissible = true,
    bool scrollable = true,
  }) {
    return UnifiedFormDialog.show<T>(
      context: this,
      dialog: UnifiedFormDialog(
        title: title,
        subtitle: subtitle,
        headerIcon: headerIcon,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isLoading: isLoading,
        canConfirm: canConfirm,
        barrierDismissible: barrierDismissible,
        scrollable: scrollable,
      ),
    );
  }
}