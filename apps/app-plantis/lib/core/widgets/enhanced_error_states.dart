import 'package:flutter/material.dart';

/// Enhanced error states with better UX and recovery options
class EnhancedErrorStates {
  
  /// Adaptive error display with context-aware styling
  static Widget adaptiveError({
    required String title,
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
    String retryText = 'Tentar novamente',
    VoidCallback? onDismiss,
    ErrorSeverity severity = ErrorSeverity.warning,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final errorConfig = _getErrorConfig(severity, theme);
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? errorConfig.icon,
                size: 64,
                color: errorConfig.color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: errorConfig.color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onRetry != null) ...[
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(retryText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorConfig.color,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (onDismiss != null) const SizedBox(width: 12),
                  ],
                  if (onDismiss != null)
                    TextButton(
                      onPressed: onDismiss,
                      child: const Text('Dispensar'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Network error with specific network troubleshooting
  static Widget networkError({
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return adaptiveError(
      title: 'Sem conexão',
      message: 'Verifique sua conexão com a internet e tente novamente.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      onDismiss: onDismiss,
      severity: ErrorSeverity.error,
    );
  }

  /// Server error with technical details option
  static Widget serverError({
    String? errorCode,
    VoidCallback? onRetry,
    VoidCallback? onReportBug,
  }) {
    return adaptiveError(
      title: 'Erro no servidor',
      message: errorCode != null 
          ? 'Ocorreu um problema no servidor (Código: $errorCode). Tente novamente em alguns instantes.'
          : 'Ocorreu um problema no servidor. Tente novamente em alguns instantes.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      severity: ErrorSeverity.critical,
    );
  }

  /// Authentication error
  static Widget authError({
    VoidCallback? onLogin,
    VoidCallback? onDismiss,
  }) {
    return adaptiveError(
      title: 'Acesso expirado',
      message: 'Sua sessão expirou. Faça login novamente para continuar.',
      icon: Icons.lock_outline,
      onRetry: onLogin,
      retryText: 'Fazer login',
      onDismiss: onDismiss,
      severity: ErrorSeverity.warning,
    );
  }

  /// Permission error
  static Widget permissionError({
    required String permission,
    VoidCallback? onOpenSettings,
    VoidCallback? onDismiss,
  }) {
    return adaptiveError(
      title: 'Permissão necessária',
      message: 'Para usar esta funcionalidade, é necessário permitir o acesso $permission.',
      icon: Icons.security,
      onRetry: onOpenSettings,
      retryText: 'Abrir configurações',
      onDismiss: onDismiss,
      severity: ErrorSeverity.warning,
    );
  }

  /// Empty state error (no data found)
  static Widget emptyState({
    required String title,
    String? message,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null && actionText != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionText),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Inline error for form fields and smaller components
  static Widget inlineError({
    required String message,
    VoidCallback? onDismiss,
    bool canDismiss = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
            border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              if (canDismiss && onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Success message for positive feedback
  static Widget successState({
    required String title,
    String? message,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
    VoidCallback? onDismiss,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onAction != null && actionText != null) ...[
                    ElevatedButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(actionText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (onDismiss != null) const SizedBox(width: 12),
                  ],
                  if (onDismiss != null)
                    TextButton(
                      onPressed: onDismiss,
                      child: const Text('OK'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static _ErrorConfig _getErrorConfig(ErrorSeverity severity, ThemeData theme) {
    switch (severity) {
      case ErrorSeverity.info:
        return _ErrorConfig(
          color: theme.colorScheme.primary,
          icon: Icons.info_outline,
        );
      case ErrorSeverity.warning:
        return _ErrorConfig(
          color: Colors.orange,
          icon: Icons.warning_outlined,
        );
      case ErrorSeverity.error:
        return _ErrorConfig(
          color: theme.colorScheme.error,
          icon: Icons.error_outline,
        );
      case ErrorSeverity.critical:
        return _ErrorConfig(
          color: Colors.red,
          icon: Icons.dangerous_outlined,
        );
    }
  }
}

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

class _ErrorConfig {
  final Color color;
  final IconData icon;

  _ErrorConfig({required this.color, required this.icon});
}

/// Mixin for widgets with error states
mixin ErrorStateMixin<T extends StatefulWidget> on State<T> {
  String? _errorMessage;
  ErrorSeverity _errorSeverity = ErrorSeverity.error;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  ErrorSeverity get errorSeverity => _errorSeverity;

  /// Show error state
  void showError(String message, {ErrorSeverity severity = ErrorSeverity.error}) {
    setState(() {
      _errorMessage = message;
      _errorSeverity = severity;
    });
  }

  /// Clear error state
  void clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  /// Build error widget if needed
  Widget buildWithError({
    required Widget child,
    VoidCallback? onRetry,
  }) {
    if (hasError) {
      return EnhancedErrorStates.adaptiveError(
        title: 'Ops, algo deu errado',
        message: _errorMessage,
        severity: _errorSeverity,
        onRetry: onRetry,
        onDismiss: clearError,
      );
    }
    return child;
  }
}

/// Global error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(String error)? errorBuilder;
  final Function(String error)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          EnhancedErrorStates.adaptiveError(
            title: 'Erro inesperado',
            message: _error,
            onRetry: () => setState(() => _error = null),
          );
    }

    return widget.child;
  }

  void _handleError(String error) {
    setState(() => _error = error);
    widget.onError?.call(error);
  }
}