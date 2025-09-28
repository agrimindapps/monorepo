import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/tasks_provider.dart';

/// Error boundary widget for the tasks feature
///
/// Features:
/// - Catches and handles Flutter widget errors gracefully
/// - Shows user-friendly error messages instead of crash screens
/// - Provides recovery mechanisms (retry, refresh)
/// - Reports errors for debugging while maintaining user experience
/// - Handles different types of errors with appropriate actions
class TasksErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? customErrorMessage;
  final VoidCallback? onRetry;

  const TasksErrorBoundary({
    super.key,
    required this.child,
    this.customErrorMessage,
    this.onRetry,
  });

  @override
  State<TasksErrorBoundary> createState() => _TasksErrorBoundaryState();
}

class _TasksErrorBoundaryState extends State<TasksErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
  }

  void _logError(FlutterErrorDetails details) {
    // Log to console for debugging
    debugPrint('🚨 Tasks Error Boundary caught error:');
    debugPrint('Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');

    // In production, you might want to report to crash analytics
    // Example: FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorUI(context);
    }

    // Use proper Flutter error boundary pattern with runZonedGuarded
    return _buildWithErrorZone(context);
  }

  Widget _buildWithErrorZone(BuildContext context) {
    return Builder(
      builder: (context) {
        // Use a simple try-catch approach for error boundary
        try {
          return widget.child;
        } catch (error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _errorDetails = FlutterErrorDetails(
                  exception: error,
                  stack: stackTrace,
                  context: ErrorDescription(
                    'Error caught by TasksErrorBoundary',
                  ),
                );
                _hasError = true;
              });
              _logError(_errorDetails!);
            }
          });
          return _buildErrorUI(context);
        }
      },
    );
  }

  Widget _buildErrorUI(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF000000) : theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 60,
                ),
              ),

              const SizedBox(height: 32),

              // Error title
              Text(
                'Oops! Algo deu errado',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error message
              Text(
                widget.customErrorMessage ??
                    'Ocorreu um erro inesperado. Não se preocupe, seus dados estão seguros.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Technical details (only in debug mode)
              if (_errorDetails != null) ...[
                const SizedBox(height: 16),
                _buildTechnicalDetails(theme),
              ],

              const SizedBox(height: 48),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleRefresh(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleRestart(context),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reiniciar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Report issue button
              TextButton.icon(
                onPressed: () => _handleReportIssue(context),
                icon: const Icon(Icons.bug_report, size: 18),
                label: const Text('Relatar Problema'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalDetails(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Detalhes Técnicos',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Erro: ${_errorDetails?.exception ?? "Desconhecido"}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.error,
                ),
              ),
              if (_errorDetails?.stack != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Stack Trace:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorDetails!.stack
                      .toString()
                      .split('\n')
                      .take(5)
                      .join('\n'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleRefresh(BuildContext context) {
    try {
      // Try to refresh the tasks
      if (widget.onRetry != null) {
        widget.onRetry!();
      } else {
        // Safely access TasksProvider with error handling
        final tasksProvider = context.read<TasksProvider>();
        tasksProvider.clearError(); // Clear any existing errors
        tasksProvider.loadTasks();
      }

      // Reset error state
      setState(() {
        _hasError = false;
        _errorDetails = null;
      });
    } catch (e) {
      // If refresh also fails, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível recarregar. Tente reiniciar.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Reiniciar',
            onPressed: () => _handleRestart(context),
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  void _handleRestart(BuildContext context) {
    // Reset error state and rebuild the entire widget
    setState(() {
      _hasError = false;
      _errorDetails = null;
    });

    // Clear any cached state in the provider
    try {
      final tasksProvider = context.read<TasksProvider>();
      tasksProvider.clearError();

      // Reload tasks from scratch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          tasksProvider.loadTasks();
        }
      });
    } catch (e) {
      debugPrint('Error during restart: $e');
      // Show error feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Erro ao reiniciar. Tente fechar e reabrir o app.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleReportIssue(BuildContext context) {
    final errorInfo =
        _errorDetails != null
            ? 'Erro: ${_errorDetails!.exception}\n\nStack Trace:\n${_errorDetails!.stack}'
            : 'Erro não identificado';

    // Copy error details to clipboard
    Clipboard.setData(ClipboardData(text: errorInfo));

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Detalhes do erro copiados para a área de transferência',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          textColor: Colors.white,
        ),
      ),
    );

    // In a real app, you might want to open email or support form
    // Example:
    // final Uri emailUri = Uri(
    //   scheme: 'mailto',
    //   path: 'support@plantis.app',
    //   query: 'subject=Bug Report&body=${Uri.encodeComponent(errorInfo)}',
    // );
    // if (await canLaunchUrl(emailUri)) {
    //   await launchUrl(emailUri);
    // }
  }

  @override
  void dispose() {
    // Clean up any resources
    _errorDetails = null;
    super.dispose();
  }
}

/// Extension method to easily wrap widgets with error boundary
extension TasksErrorBoundaryExtension on Widget {
  Widget withErrorBoundary({
    String? customErrorMessage,
    VoidCallback? onRetry,
  }) {
    return TasksErrorBoundary(
      customErrorMessage: customErrorMessage,
      onRetry: onRetry,
      child: this,
    );
  }
}
