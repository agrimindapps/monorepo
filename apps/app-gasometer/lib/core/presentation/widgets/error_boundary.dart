import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../error/app_error.dart';
import '../../error/error_reporter.dart';
import '../theme/app_theme.dart';
import 'retry_button.dart';

/// Widget que captura e trata erros não esperados globalmente
///
/// Funciona como um "error boundary" similar ao React, capturando
/// erros que ocorrem em widgets filhos e exibindo uma UI de fallback.
/// Integra com ErrorReporter para logging automático.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final String? title;
  final String? message;
  final bool showDebugInfo;
  final String? context;
  final ErrorReporter? errorReporter;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.title,
    this.message,
    this.showDebugInfo = kDebugMode,
    this.context,
    this.errorReporter,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  void Function(FlutterErrorDetails)? _previousErrorHandler;

  @override
  void initState() {
    super.initState();

    // Save previous error handler and chain with ours
    _previousErrorHandler = FlutterError.onError;
    FlutterError.onError = _handleFlutterError;
  }

  @override
  void dispose() {
    // Restore previous error handler
    FlutterError.onError = _previousErrorHandler;
    super.dispose();
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    // Call previous error handler first
    _previousErrorHandler?.call(details);

    // Only handle if this widget is still mounted
    if (!mounted) return;

    try {
      // Defer setState to avoid "setState during build" error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = details.exception;
            _stackTrace = details.stack;
            _hasError = true;
          });
        }
      });

      // Chamar callback de erro se fornecido
      widget.onError?.call(details.exception, details.stack);

      // Report error to external services
      _reportError(details.exception, details.stack);

      // Log do erro para debugging
      debugPrint('🚨 ErrorBoundary capturou erro: ${details.exception}');
      if (widget.showDebugInfo) {
        debugPrint('Stack trace: ${details.stack}');
      }
    } catch (e) {
      // If setState fails, at least report the original error
      debugPrint('🚨 ErrorBoundary setState failed: $e');
      debugPrint('Original error was: ${details.exception}');
    }
  }

  /// Report error to external services
  void _reportError(Object error, StackTrace? stackTrace) {
    try {
      final appError = _convertToAppError(error);
      widget.errorReporter?.reportWidgetError(
        appError,
        widgetName: widget.runtimeType.toString(),
        parentWidget: widget.context,
      );
    } catch (e) {
      debugPrint('Failed to report error: $e');
    }
  }

  /// Convert exception to AppError
  AppError _convertToAppError(Object error) {
    if (error is AppError) {
      return error;
    }

    if (error is FlutterError) {
      return UnexpectedError(
        message: 'Widget error: ${error.message}',
        technicalDetails: error.toString(),
      );
    }

    return UnexpectedError(
      message: 'Unexpected widget error: ${error.toString()}',
      technicalDetails: error.toString(),
    );
  }

  /// Reseta o estado de erro para tentar renderizar novamente
  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      // Usar error builder customizado se fornecido
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }

      // Usar UI de fallback padrão
      return _buildDefaultErrorUI();
    }

    // Encapsular child em zona de erro para capturar exceções
    return _ErrorZone(
      onError: (error, stackTrace) {
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
            _hasError = true;
          });

          widget.onError?.call(error, stackTrace);
        }
      },
      child: widget.child,
    );
  }

  Widget _buildDefaultErrorUI() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 200,
        minHeight: 100,
        maxWidth: double.infinity,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      widget.title ?? 'Erro inesperado',
                      style: AppTheme.textStyles.titleSmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (widget.message != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  widget.message!,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: Colors.red[800],
                  ),
                ),
              ),
            ),
          ],

          // Informações de debug em desenvolvimento
          if (widget.showDebugInfo && _error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      'Detalhes técnicos:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      'Erro: ${_error.toString()}\n'
                      '${_stackTrace != null ? 'Stack: ${_stackTrace.toString()}' : ''}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RetryButton.compact(
                onRetry: _resetError,
                customLabel: 'Tentar Novamente',
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

/// Widget interno que encapsula o child em uma zona de erro
class _ErrorZone extends StatelessWidget {
  final Widget child;
  final void Function(Object error, StackTrace stackTrace) onError;

  const _ErrorZone({required this.child, required this.onError});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error, stackTrace) {
          // Capturar erros síncronos
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onError(error, stackTrace);
          });

          // Retornar widget vazio temporário
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Extension para adicionar error boundary facilmente a qualquer widget
extension ErrorBoundaryExtension on Widget {
  /// Envolve o widget com um ErrorBoundary
  Widget withErrorBoundary({
    Widget Function(Object error, StackTrace? stackTrace)? errorBuilder,
    void Function(Object error, StackTrace? stackTrace)? onError,
    String? title,
    String? message,
    bool showDebugInfo = kDebugMode,
    String? context,
    ErrorReporter? errorReporter,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: onError,
      title: title,
      message: message,
      showDebugInfo: showDebugInfo,
      context: context,
      errorReporter: errorReporter,
      child: this,
    );
  }

  /// Envolve widget com error boundary para páginas principais
  Widget withPageErrorBoundary({
    String? pageName,
    ErrorReporter? errorReporter,
  }) {
    return ErrorBoundary(
      title: 'Erro na página${pageName != null ? ' $pageName' : ''}',
      message:
          'Algo deu errado nesta página. Você pode tentar recarregar ou voltar para a tela anterior.',
      context: 'page_error',
      errorReporter: errorReporter,
      child: this,
    );
  }

  /// Envolve widget com error boundary para providers
  Widget withProviderErrorBoundary({
    String? providerName,
    ErrorReporter? errorReporter,
  }) {
    return ErrorBoundary(
      title:
          'Erro no carregamento de dados${providerName != null ? ' - $providerName' : ''}',
      message: 'Houve um problema ao carregar os dados. Tente novamente.',
      context: 'provider_error',
      errorReporter: errorReporter,
      child: this,
    );
  }
}

/// Wrapper específico para formulários com UI otimizada
class FormErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? formName;
  final void Function(Object error, StackTrace? stackTrace)? onFormError;

  const FormErrorBoundary({
    super.key,
    required this.child,
    this.formName,
    this.onFormError,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      title: 'Erro no formulário${formName != null ? ' $formName' : ''}',
      message:
          'Algo deu errado no formulário. Você pode tentar novamente ou voltar para a tela anterior.',
      onError: onFormError,
      errorBuilder: (error, stackTrace) => _buildFormErrorUI(context, error),
      child: child,
    );
  }

  Widget _buildFormErrorUI(BuildContext context, Object error) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Icon(
                Icons.edit_note_outlined,
                color: Colors.red[800],
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                'Erro no Formulário',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: Colors.red[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                'O formulário encontrou um erro inesperado. '
                'Todos os dados inseridos podem ter sido perdidos.',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: Colors.red[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Debug info em desenvolvimento
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    error.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('Voltar'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RetryButton.form(
                    onRetry: () {
                      // Recarregar a página
                      Navigator.of(context).pushReplacementNamed(
                        ModalRoute.of(context)?.settings.name ?? '/',
                      );
                    },
                    customLabel: 'Recarregar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
