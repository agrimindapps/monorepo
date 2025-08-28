import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart'
    as local;
import '../../di/injection_container.dart';
import '../../error/app_error.dart';
import '../../error/error_reporter.dart';
import 'error_boundary.dart';
import 'retry_button.dart';

/// Global error boundary that wraps the entire application
/// Handles all uncaught errors and provides graceful degradation
class GlobalErrorBoundary extends StatefulWidget {
  final Widget child;
  final ErrorReporter? errorReporter;

  const GlobalErrorBoundary({
    super.key,
    required this.child,
    this.errorReporter,
  });

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  ErrorReporter? _errorReporter;
  Object? _lastError;
  StackTrace? _lastStackTrace;
  bool _hasGlobalError = false;

  @override
  void initState() {
    super.initState();
    _initializeErrorReporter();
    _setupGlobalErrorHandlers();
  }

  void _initializeErrorReporter() {
    try {
      _errorReporter = widget.errorReporter ?? sl<ErrorReporter>();
    } catch (e) {
      debugPrint('Failed to get ErrorReporter from service locator: $e');
      _errorReporter = null;
    }

    // Set user context if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserContext();
    });
  }

  void _updateUserContext() async {
    try {
      if (!mounted) return;

      final authProvider = context.read<local.AuthProvider>();
      await _errorReporter?.setUserContext(
        userId: authProvider.currentUser?.uid,
        isAnonymous: authProvider.isAnonymous,
        isPremium: false, // Would get from premium provider
      );
    } catch (e) {
      debugPrint('Failed to set user context: $e');
    }
  }

  void _setupGlobalErrorHandlers() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Handle isolate errors (not supported on web)
    if (!kIsWeb) {
      try {
        Isolate.current.addErrorListener(
          RawReceivePort((pair) async {
            final List<dynamic> errorAndStacktrace = pair as List<dynamic>;
            final error = errorAndStacktrace.first;
            final stackTrace = StackTrace.fromString(
              errorAndStacktrace.last.toString(),
            );

            await _handleIsolateError(error as Object, stackTrace);
          }).sendPort,
        );
      } catch (e) {
        debugPrint('Unable to set isolate error listener: $e');
      }
    }
  }

  Future<void> _handleFlutterError(FlutterErrorDetails details) async {
    // Don't show global error for overflow errors in debug mode
    if (kDebugMode && details.exception is FlutterError) {
      final flutterError = details.exception as FlutterError;
      if (flutterError.diagnostics.any(
        (node) =>
            node.toString().contains('RenderFlex overflowed') ||
            node.toString().contains('RenderBox was not laid out'),
      )) {
        FlutterError.presentError(details);
        return;
      }
    }

    final appError = _convertToAppError(details.exception);

    await _reportError(appError, details.stack, 'flutter_framework');

    // Only show global error for critical errors
    if (appError.severity.index >= ErrorSeverity.critical.index) {
      _showGlobalError(details.exception, details.stack);
    } else {
      // For less critical errors, just log them
      FlutterError.presentError(details);
    }
  }

  bool _handlePlatformError(Object error, StackTrace stack) {
    final appError = _convertToAppError(error);

    _reportError(appError, stack, 'platform');

    // Show global error for platform errors
    _showGlobalError(error, stack);

    return true;
  }

  Future<void> _handleIsolateError(Object error, StackTrace? stack) async {
    final appError = _convertToAppError(error);

    await _reportError(appError, stack, 'isolate');

    _showGlobalError(error, stack);
  }

  AppError _convertToAppError(Object error) {
    if (error is AppError) {
      return error;
    }

    if (error is FlutterError) {
      return UnexpectedError(
        message: 'Flutter framework error: ${error.message}',
        technicalDetails: error.toString(),
      );
    }

    if (error is Error) {
      return UnexpectedError(
        message: 'System error: ${error.toString()}',
        technicalDetails: error.toString(),
      );
    }

    return UnexpectedError(
      message: 'Unexpected error: ${error.toString()}',
      technicalDetails: error.toString(),
    );
  }

  Future<void> _reportError(
    AppError error,
    StackTrace? stackTrace,
    String context,
  ) async {
    try {
      await _errorReporter?.reportError(
        error,
        stackTrace: stackTrace,
        context: context,
        fatal: error.severity.index >= ErrorSeverity.critical.index,
      );

      await _errorReporter?.recordBreadcrumb(
        message: 'Global error occurred',
        category: context,
        data: {
          'error_type': error.runtimeType.toString(),
          'severity': error.severity.name,
        },
      );
    } catch (e) {
      debugPrint('Failed to report global error: $e');
    }
  }

  void _showGlobalError(Object error, StackTrace? stackTrace) {
    if (!mounted) return;

    // Defer setState to avoid "setState during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          setState(() {
            _lastError = error;
            _lastStackTrace = stackTrace;
            _hasGlobalError = true;
          });
        } catch (e) {
          debugPrint('🚨 GlobalErrorBoundary setState failed: $e');
          debugPrint('Original error was: $error');
        }
      }
    });
  }

  void _recoverFromError() {
    if (!mounted) return;

    try {
      setState(() {
        _lastError = null;
        _lastStackTrace = null;
        _hasGlobalError = false;
      });
    } catch (e) {
      debugPrint('🚨 GlobalErrorBoundary recovery setState failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasGlobalError && _lastError != null) {
      return MaterialApp(
        title: 'GasOMeter - Erro Global',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(body: _buildGlobalErrorScreen()),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return ErrorBoundary(
      title: 'Erro Global da Aplicação',
      message: 'Algo deu muito errado na aplicação. Vamos tentar recuperar.',
      context: 'global_boundary',
      errorReporter: _errorReporter,
      child: widget.child,
    );
  }

  Widget _buildGlobalErrorScreen() {
    final appError = _convertToAppError(_lastError!);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon and title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'GasOMeter',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Ops! Algo deu errado',
              style: const TextStyle(
                inherit: false,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              appError.displayMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                inherit: false,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Error details in debug mode
            if (kDebugMode && appError.technicalDetails != null) ...[
              ExpansionTile(
                title: const Text('Detalhes Técnicos'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appError.technicalDetails ??
                          'Nenhum detalhe técnico disponível',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: RetryButton(
                    onRetry: _recoverFromError,
                    label: 'Tentar Novamente',
                    semanticLabel: 'Tentar recuperar da aplicação',
                    semanticHint:
                        'Tenta voltar ao funcionamento normal da aplicação',
                    type: RetryButtonType.filled,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Restart the app completely
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // This would restart the app
                        _recoverFromError();
                      });
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar App'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Support message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Este erro foi automaticamente reportado',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nossa equipe foi notificada e está trabalhando para resolver o problema.',
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
