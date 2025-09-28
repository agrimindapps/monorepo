import 'package:flutter/material.dart';

import '../design/unified_design_tokens.dart';

/// Tipos de estados de loading para diferentes contextos
enum LoadingType {
  initial,    // Loading inicial da tela/formulário
  refresh,    // Refresh/atualização de dados
  submit,     // Submissão de formulário
  inline,     // Loading inline/pequeno
}

/// Widget de loading unificado com diferentes estilos e contextos
class UnifiedLoadingView extends StatelessWidget {
  
  /// Loading inicial para telas/formulários
  factory UnifiedLoadingView.initial({String? message}) {
    return UnifiedLoadingView._(
      type: LoadingType.initial,
      message: message ?? 'Carregando...',
    );
  }
  
  /// Loading para refresh/atualização
  factory UnifiedLoadingView.refresh({String? message}) {
    return UnifiedLoadingView._(
      type: LoadingType.refresh,
      message: message ?? 'Atualizando...',
    );
  }
  
  /// Loading para submissão de formulários
  factory UnifiedLoadingView.submit({String? message}) {
    return UnifiedLoadingView._(
      type: LoadingType.submit,
      message: message ?? 'Processando...',
    );
  }
  
  /// Loading inline/pequeno
  factory UnifiedLoadingView.inline({
    double? size,
    Color? color,
  }) {
    return UnifiedLoadingView._(
      type: LoadingType.inline,
      size: size ?? 20,
      color: color,
    );
  }
  const UnifiedLoadingView._({
    required this.type,
    this.message,
    this.size,
    this.color,
  });

  final LoadingType type;
  final String? message;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (type == LoadingType.inline) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color ?? theme.colorScheme.primary,
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: UnifiedDesignTokens.spacingXL),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: UnifiedDesignTokens.fontWeightMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de erro unificado com ação de retry
class UnifiedErrorView extends StatelessWidget {
  const UnifiedErrorView({
    super.key,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon,
    this.showRetryButton = true,
  });

  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool showRetryButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UnifiedDesignTokens.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de erro
            Container(
              padding: const EdgeInsets.all(UnifiedDesignTokens.spacingLG),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusXXL),
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            
            const SizedBox(height: UnifiedDesignTokens.spacingXL),
            
            // Mensagem de erro
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: UnifiedDesignTokens.fontWeightMedium,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Botão de ação
            if (showRetryButton && onAction != null) ...[
              const SizedBox(height: UnifiedDesignTokens.spacingXL),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionText ?? 'Tentar Novamente'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UnifiedDesignTokens.spacingXL,
                    vertical: UnifiedDesignTokens.spacingMD,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de estado vazio unificado
class UnifiedEmptyView extends StatelessWidget {
  const UnifiedEmptyView({
    super.key,
    required this.message,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.icon,
  });

  final String message;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UnifiedDesignTokens.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de estado vazio
            Container(
              padding: const EdgeInsets.all(UnifiedDesignTokens.spacingLG),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusXXL),
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: UnifiedDesignTokens.spacingXL),
            
            // Mensagem principal
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: UnifiedDesignTokens.fontWeightSemiBold,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: UnifiedDesignTokens.spacingSM),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Botão de ação
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: UnifiedDesignTokens.spacingXL),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.outline),
                  padding: const EdgeInsets.symmetric(
                    horizontal: UnifiedDesignTokens.spacingXL,
                    vertical: UnifiedDesignTokens.spacingMD,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de overlay de loading para sobrepor conteúdo
class UnifiedLoadingOverlay extends StatelessWidget {
  const UnifiedLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
              child: UnifiedLoadingView.initial(message: message),
            ),
          ),
      ],
    );
  }
}

/// Widget para estados de loading de botões
class UnifiedLoadingButton extends StatelessWidget {
  const UnifiedLoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.loadingChild,
    this.style,
    this.type = _LoadingButtonType.filled,
  });

  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? loadingChild;
  final ButtonStyle? style;
  final _LoadingButtonType type;

  /// Botão filled com loading
  static UnifiedLoadingButton filled({
    required bool isLoading,
    required VoidCallback? onPressed,
    required Widget child,
    Widget? loadingChild,
    ButtonStyle? style,
  }) {
    return UnifiedLoadingButton(
      isLoading: isLoading,
      onPressed: onPressed,
      style: style,
      type: _LoadingButtonType.filled,
      loadingChild: loadingChild,
      child: child,
    );
  }

  /// Botão outlined com loading
  static UnifiedLoadingButton outlined({
    required bool isLoading,
    required VoidCallback? onPressed,
    required Widget child,
    Widget? loadingChild,
    ButtonStyle? style,
  }) {
    return UnifiedLoadingButton(
      isLoading: isLoading,
      onPressed: onPressed,
      style: style,
      type: _LoadingButtonType.outlined,
      loadingChild: loadingChild,
      child: child,
    );
  }

  /// Botão text com loading
  static UnifiedLoadingButton text({
    required bool isLoading,
    required VoidCallback? onPressed,
    required Widget child,
    Widget? loadingChild,
    ButtonStyle? style,
  }) {
    return UnifiedLoadingButton(
      isLoading: isLoading,
      onPressed: onPressed,
      style: style,
      type: _LoadingButtonType.text,
      loadingChild: loadingChild,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonChild = isLoading
        ? loadingChild ?? UnifiedLoadingView.inline(
            size: 20,
            color: type == _LoadingButtonType.filled
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          )
        : child;

    switch (type) {
      case _LoadingButtonType.filled:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: buttonChild,
        );
      case _LoadingButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: buttonChild,
        );
      case _LoadingButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: buttonChild,
        );
    }
  }
}

enum _LoadingButtonType {
  filled,
  outlined,
  text,
}