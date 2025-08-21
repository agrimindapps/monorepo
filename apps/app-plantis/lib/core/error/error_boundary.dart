import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'error_handler.dart';

/// Widget que captura e trata erros não tratados na árvore de widgets
/// Fornece uma interface de fallback quando ocorrem erros críticos
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(AppError error)? errorWidgetBuilder;
  final void Function(AppError error)? onError;
  final bool enableInDebugMode;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidgetBuilder,
    this.onError,
    this.enableInDebugMode = false,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppError? _error;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      return widget.errorWidgetBuilder?.call(_error!) ??
          _buildDefaultErrorWidget(context, _error!);
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Captura erros de widgets em debug mode se habilitado
    if (widget.enableInDebugMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        _handleError(details);
        return _buildDefaultErrorWidget(
          context,
          _createErrorFromDetails(details),
        );
      };
    }
  }

  void _handleError(FlutterErrorDetails details) {
    final error = _createErrorFromDetails(details);

    setState(() {
      _error = error;
      _hasError = true;
    });

    // Chama o callback de erro se fornecido
    widget.onError?.call(error);

    // Log do erro
    ErrorHandler.instance.handleError(error);
  }

  AppError _createErrorFromDetails(FlutterErrorDetails details) {
    return UnknownError(
      message: 'Erro na interface: ${details.exception.toString()}',
      details: details.summary.toString(),
      stackTrace: details.stack,
      severity: ErrorSeverity.high,
      originalError: details.exception,
    );
  }

  Widget _buildDefaultErrorWidget(BuildContext context, AppError error) {
    final theme = Theme.of(context);

    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              'Oops! Algo deu errado',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _reportError,
                  child: const Text('Reportar erro'),
                ),
              ],
            ),
            if (error.details != null) ...[
              const SizedBox(height: 24),
              ExpansionTile(
                title: const Text('Detalhes técnicos'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.details!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _hasError = false;
    });
  }

  void _reportError() {
    if (_error != null) {
      ErrorHandler.instance.reportError(_error!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro reportado. Obrigado pelo feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Extension para facilitar o uso do ErrorBoundary
extension ErrorBoundaryExtension on Widget {
  /// Envolve o widget com um ErrorBoundary
  Widget withErrorBoundary({
    Widget Function(AppError error)? errorWidgetBuilder,
    void Function(AppError error)? onError,
    bool enableInDebugMode = false,
  }) {
    return ErrorBoundary(
      errorWidgetBuilder: errorWidgetBuilder,
      onError: onError,
      enableInDebugMode: enableInDebugMode,
      child: this,
    );
  }
}
