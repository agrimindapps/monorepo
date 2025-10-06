import 'package:flutter/material.dart';
import '../error/app_error.dart';
import '../providers/base_provider.dart';

/// Enhanced error widget with better UX and retry mechanisms
class EnhancedErrorWidget extends StatelessWidget {
  const EnhancedErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onGoBack,
    this.showRetryButton = true,
    this.showGoBackButton = false,
    this.customActionButton,
    this.customTitle,
    this.customMessage,
    this.isCompact = false,
  });

  /// Factory constructor for provider errors
  factory EnhancedErrorWidget.fromProvider(
    BaseProvider provider, {
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
    bool showGoBackButton = false,
    bool isCompact = false,
  }) {
    return EnhancedErrorWidget(
      error: provider.error!,
      onRetry: provider.canRetry ? (onRetry ?? provider.retry) : null,
      onGoBack: onGoBack,
      showRetryButton: provider.shouldShowRetry,
      showGoBackButton: showGoBackButton,
      isCompact: isCompact,
    );
  }

  /// Factory constructor for network errors
  factory EnhancedErrorWidget.network({
    VoidCallback? onRetry,
    String? customMessage,
    bool isCompact = false,
  }) {
    return EnhancedErrorWidget(
      error: NetworkError(
        message: 'Network connection failed',
        userFriendlyMessage:
            customMessage ?? 'Problemas de conexão. Verifique sua internet.',
      ),
      onRetry: onRetry,
      showRetryButton: onRetry != null,
      isCompact: isCompact,
    );
  }

  /// Factory constructor for validation errors
  factory EnhancedErrorWidget.validation(
    ValidationError validationError, {
    VoidCallback? onRetry,
    bool isCompact = false,
  }) {
    return EnhancedErrorWidget(
      error: validationError,
      onRetry: onRetry,
      showRetryButton: onRetry != null,
      isCompact: isCompact,
    );
  }
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final bool showRetryButton;
  final bool showGoBackButton;
  final Widget? customActionButton;
  final String? customTitle;
  final String? customMessage;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactError(context);
    }
    return _buildFullError(context);
  }

  Widget _buildCompactError(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getErrorColor(colorScheme).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getErrorColor(colorScheme).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getErrorIcon(),
                color: _getErrorColor(colorScheme),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customTitle ?? _getErrorTitle(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _getErrorColor(colorScheme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            customMessage ?? error.displayMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (error is ValidationError) ...[
            const SizedBox(height: 12),
            _buildValidationErrors(context, error as ValidationError),
          ],
          const SizedBox(height: 16),
          _buildCompactActions(context),
        ],
      ),
    );
  }

  Widget _buildFullError(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: _getErrorColor(colorScheme).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(),
                size: 64,
                color: _getErrorColor(colorScheme),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              customTitle ?? _getErrorTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              customMessage ?? error.displayMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (error is ValidationError) ...[
              const SizedBox(height: 24),
              _buildValidationErrors(context, error as ValidationError),
            ],
            const SizedBox(height: 32),
            _buildFullActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationErrors(
    BuildContext context,
    ValidationError validationError,
  ) {
    if (validationError.fieldErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: colorScheme.errorContainer.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Erros de validação:',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...validationError.fieldErrors.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 16, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ...entry.value.map(
                          (error) => Text(
                            error,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompactActions(BuildContext context) {
    final actions = <Widget>[];

    if (showRetryButton && onRetry != null && error.isRecoverable) {
      actions.add(
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Tentar Novamente'),
        ),
      );
    }

    if (customActionButton != null) {
      actions.add(customActionButton!);
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 8.0, children: actions);
  }

  Widget _buildFullActions(BuildContext context) {
    final actions = <Widget>[];

    // Primary action (retry or custom)
    if (showRetryButton && onRetry != null && error.isRecoverable) {
      actions.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar Novamente'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      );
    }

    // Secondary action (go back)
    if (showGoBackButton && onGoBack != null) {
      actions.add(
        OutlinedButton.icon(
          onPressed: onGoBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Voltar'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      );
    }

    // Custom action
    if (customActionButton != null) {
      actions.add(customActionButton!);
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (actions.length == 1) {
      return actions.first;
    }

    return Column(
      children: [
        actions.first,
        const SizedBox(height: 12),
        ...actions
            .skip(1)
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: action,
              ),
            ),
      ],
    );
  }

  IconData _getErrorIcon() {
    if (error is NetworkError || error is TimeoutError) {
      return Icons.wifi_off_outlined;
    }
    if (error is ServerError) {
      return Icons.dns_outlined;
    }
    if (error is ValidationError) {
      return Icons.warning_outlined;
    }
    if (error is AuthenticationError) {
      return Icons.lock_outlined;
    }
    if (error is PermissionError) {
      return Icons.security_outlined;
    }
    if (error is BusinessLogicError) {
      return Icons.info_outlined;
    }
    return Icons.error_outline;
  }

  String _getErrorTitle() {
    if (error is NetworkError || error is TimeoutError) {
      return 'Problema de Conexão';
    }
    if (error is ServerError) {
      return 'Erro do Servidor';
    }
    if (error is ValidationError) {
      return 'Dados Inválidos';
    }
    if (error is AuthenticationError) {
      return 'Erro de Autenticação';
    }
    if (error is PermissionError) {
      return 'Permissão Necessária';
    }
    if (error is BusinessLogicError) {
      return 'Aviso';
    }
    return 'Erro Inesperado';
  }

  Color _getErrorColor(ColorScheme colorScheme) {
    switch (error.severity) {
      case ErrorSeverity.warning:
        return Colors.orange.shade600;
      case ErrorSeverity.error:
      case ErrorSeverity.critical:
        return colorScheme.error;
      case ErrorSeverity.fatal:
        return Colors.red.shade800;
      default:
        return colorScheme.primary;
    }
  }
}

/// Loading state with error handling
class LoadingWithErrorWidget extends StatelessWidget {
  const LoadingWithErrorWidget({
    super.key,
    required this.isLoading,
    this.error,
    required this.child,
    this.onRetry,
    this.loadingText,
    this.showErrorInline = false,
  });
  final bool isLoading;
  final AppError? error;
  final Widget child;
  final VoidCallback? onRetry;
  final String? loadingText;
  final bool showErrorInline;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (loadingText != null) ...[
              const SizedBox(height: 16),
              Text(loadingText!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      );
    }

    if (error != null) {
      return EnhancedErrorWidget(
        error: error!,
        onRetry: onRetry,
        isCompact: showErrorInline,
      );
    }

    return child;
  }
}

/// Provider state builder with error handling
class ProviderStateBuilder extends StatelessWidget {
  const ProviderStateBuilder({
    super.key,
    required this.provider,
    required this.loadingBuilder,
    required this.emptyBuilder,
    required this.contentBuilder,
    this.errorBuilder,
    this.onRetry,
  });
  final BaseProvider provider;
  final Widget Function(BuildContext context) loadingBuilder;
  final Widget Function(BuildContext context) emptyBuilder;
  final Widget Function(BuildContext context) contentBuilder;
  final Widget Function(BuildContext context, AppError error)? errorBuilder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (provider.state) {
      case ProviderState.loading:
        return loadingBuilder(context);

      case ProviderState.empty:
        return emptyBuilder(context);

      case ProviderState.error:
        if (errorBuilder != null && provider.error != null) {
          return errorBuilder!(context, provider.error!);
        }
        return EnhancedErrorWidget.fromProvider(provider, onRetry: onRetry);

      case ProviderState.loaded:
        return contentBuilder(context);

      case ProviderState.initial:
        return const SizedBox.shrink();
    }
  }
}
