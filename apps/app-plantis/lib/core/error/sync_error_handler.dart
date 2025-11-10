import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Tipos de erros de sincronização com tratamento específico
enum SyncErrorType {
  network,
  server,
  storage,
  authentication,
  validation,
  conflict,
  timeout,
  quota,
  unknown,
}

/// Severidade dos erros para priorização do tratamento
enum SyncErrorSeverity {
  low, // Continuar operação normalmente
  medium, // Mostrar aviso mas continuar
  high, // Requer ação do usuário
  critical, // Bloquear operação
}

/// Estratégias de recuperação automática
enum SyncRecoveryStrategy {
  retry,
  fallbackOffline,
  skipItem,
  requireUserAction,
  none,
}

/// Dados do erro de sincronização
class SyncError {
  final String id;
  final SyncErrorType type;
  final SyncErrorSeverity severity;
  final String message;
  final String userMessage;
  final Object? originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final SyncRecoveryStrategy recoveryStrategy;

  const SyncError({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.userMessage,
    this.originalError,
    this.stackTrace,
    required this.timestamp,
    this.metadata,
    required this.recoveryStrategy,
  });

  factory SyncError.from({
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = DateTime.now();
    SyncErrorType type;
    SyncErrorSeverity severity;
    String userMessage;
    SyncRecoveryStrategy recovery;

    if (error is NetworkFailure) {
      type = SyncErrorType.network;
      severity = SyncErrorSeverity.medium;
      userMessage = 'Verifique sua conexão com a internet';
      recovery = SyncRecoveryStrategy.retry;
    } else if (error is ServerFailure) {
      type = SyncErrorType.server;
      severity = SyncErrorSeverity.medium;
      userMessage = 'Problema temporário no servidor';
      recovery = SyncRecoveryStrategy.retry;
    } else if (error is CacheFailure) {
      type = SyncErrorType.storage;
      severity = SyncErrorSeverity.high;
      userMessage = 'Erro ao salvar dados localmente';
      recovery = SyncRecoveryStrategy.requireUserAction;
    } else if (error.toString().contains('authentication') ||
        error.toString().contains('auth')) {
      type = SyncErrorType.authentication;
      severity = SyncErrorSeverity.high;
      userMessage = 'Faça login novamente para sincronizar';
      recovery = SyncRecoveryStrategy.requireUserAction;
    } else if (error is ValidationFailure) {
      type = SyncErrorType.validation;
      severity = SyncErrorSeverity.medium;
      userMessage = 'Dados inválidos encontrados';
      recovery = SyncRecoveryStrategy.skipItem;
    } else if (error.toString().contains('timeout')) {
      type = SyncErrorType.timeout;
      severity = SyncErrorSeverity.low;
      userMessage = 'Operação demorou mais que o esperado';
      recovery = SyncRecoveryStrategy.retry;
    } else if (error.toString().contains('quota') ||
        error.toString().contains('limit')) {
      type = SyncErrorType.quota;
      severity = SyncErrorSeverity.high;
      userMessage = 'Limite de armazenamento atingido';
      recovery = SyncRecoveryStrategy.requireUserAction;
    } else {
      type = SyncErrorType.unknown;
      severity = SyncErrorSeverity.medium;
      userMessage = 'Erro inesperado durante sincronização';
      recovery = SyncRecoveryStrategy.fallbackOffline;
    }

    return SyncError(
      id: id,
      type: type,
      severity: severity,
      message: error.toString(),
      userMessage: userMessage,
      originalError: error,
      stackTrace: stackTrace,
      timestamp: timestamp,
      metadata: metadata,
      recoveryStrategy: recovery,
    );
  }

  @override
  String toString() =>
      'SyncError(type: $type, severity: $severity, message: $message)';
}

/// Handler robusto para erros de sincronização
class SyncErrorHandler {
  static const int _maxRetries = 3;
  static const Duration _retryBaseDelay = Duration(seconds: 2);
  static final SyncErrorHandler _instance = SyncErrorHandler._();
  static SyncErrorHandler get instance => _instance;
  SyncErrorHandler._();
  final _errorController = StreamController<SyncError>.broadcast();
  final _recoveryController = StreamController<String>.broadcast();
  final Map<String, int> _retryCount = {};
  final List<SyncError> _errorHistory = [];
  final Set<String> _suppressedErrors = {};
  Timer? _cleanupTimer;
  Stream<SyncError> get errorStream => _errorController.stream;
  Stream<String> get recoveryStream => _recoveryController.stream;
  List<SyncError> get errorHistory => List.unmodifiable(_errorHistory);

  bool get hasRecentErrors =>
      _errorHistory
          .where((e) => DateTime.now().difference(e.timestamp).inMinutes < 5)
          .isNotEmpty;

  /// Inicializa o handler
  void initialize() {
    _setupCleanupTimer();
    developer.log('SyncErrorHandler inicializado', name: 'SyncErrorHandler');
  }

  /// Trata um erro de sincronização
  Future<bool> handleError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    BuildContext? context,
  }) async {
    try {
      final syncError = SyncError.from(
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );
      _logError(syncError);
      _errorHistory.add(syncError);
      if (_errorHistory.length > 100) {
        _errorHistory.removeAt(0); // Manter apenas os 100 mais recentes
      }
      _errorController.add(syncError);
      final recovered = await _executeRecoveryStrategy(syncError, context);

      if (recovered) {
        _recoveryController.add(
          'Erro ${syncError.id} recuperado automaticamente',
        );
      }

      return recovered;
    } catch (e) {
      developer.log('Erro no SyncErrorHandler: $e', name: 'SyncErrorHandler');
      return false;
    }
  }

  /// Executa estratégia de recuperação baseada no tipo de erro
  Future<bool> _executeRecoveryStrategy(
    SyncError syncError,
    BuildContext? context,
  ) async {
    switch (syncError.recoveryStrategy) {
      case SyncRecoveryStrategy.retry:
        return await _attemptRetry(syncError);

      case SyncRecoveryStrategy.fallbackOffline:
        return _fallbackToOfflineMode(syncError);

      case SyncRecoveryStrategy.skipItem:
        return _skipItem(syncError);

      case SyncRecoveryStrategy.requireUserAction:
        if (context != null) {
          _showUserActionDialog(context, syncError);
        }
        return false;

      case SyncRecoveryStrategy.none:
        return false;
    }
  }

  /// Tenta retry com backoff exponencial
  Future<bool> _attemptRetry(SyncError syncError) async {
    final retries = _retryCount[syncError.id] ?? 0;

    if (retries >= _maxRetries) {
      developer.log(
        'Máximo de tentativas atingido para erro ${syncError.id}',
        name: 'SyncErrorHandler',
      );
      return false;
    }

    _retryCount[syncError.id] = retries + 1;
    final delay = _retryBaseDelay * (2 << retries);
    await Future<void>.delayed(delay);

    developer.log(
      'Tentativa ${retries + 1}/$_maxRetries para erro ${syncError.id}',
      name: 'SyncErrorHandler',
    );
    if (syncError.type == SyncErrorType.network ||
        syncError.type == SyncErrorType.timeout) {
      return retries > 0;
    }

    return false;
  }

  /// Fallback para modo offline
  bool _fallbackToOfflineMode(SyncError syncError) {
    developer.log(
      'Fallback para modo offline devido ao erro ${syncError.id}',
      name: 'SyncErrorHandler',
    );
    _recoveryController.add('Operação continuando offline');

    return true; // Considera recuperado pois continuará offline
  }

  /// Pula item problemático
  bool _skipItem(SyncError syncError) {
    developer.log(
      'Item pulado devido ao erro ${syncError.id}',
      name: 'SyncErrorHandler',
    );

    _recoveryController.add('Item com problema foi ignorado');

    return true; // Considera recuperado pois continuará sem o item
  }

  /// Mostra dialog para ação do usuário
  void _showUserActionDialog(BuildContext context, SyncError syncError) {
    if (_suppressedErrors.contains(syncError.id)) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildErrorDialog(context, syncError),
    );
  }

  /// Constrói dialog de erro para usuário
  Widget _buildErrorDialog(BuildContext context, SyncError syncError) {
    return AlertDialog(
      icon: Icon(
        _getErrorIcon(syncError.type),
        color: _getErrorColor(syncError.severity),
        size: 32,
      ),
      title: Text(_getErrorTitle(syncError.type)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(syncError.userMessage),
          const SizedBox(height: 12),
          if (syncError.type == SyncErrorType.authentication)
            const Text(
              'Você será redirecionado para fazer login novamente.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          if (syncError.type == SyncErrorType.quota)
            const Text(
              'Considere fazer limpeza de dados antigos ou atualizar seu plano.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _suppressError(syncError.id);
            Navigator.of(context).pop();
          },
          child: const Text('Ignorar'),
        ),
        if (syncError.recoveryStrategy == SyncRecoveryStrategy.retry)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _attemptRetry(syncError);
            },
            child: const Text('Tentar Novamente'),
          ),
        if (syncError.type == SyncErrorType.authentication)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: const Text('Fazer Login'),
          ),
      ],
    );
  }

  /// Obtém ícone baseado no tipo de erro
  IconData _getErrorIcon(SyncErrorType type) {
    switch (type) {
      case SyncErrorType.network:
        return Icons.wifi_off_rounded;
      case SyncErrorType.server:
        return Icons.cloud_off_rounded;
      case SyncErrorType.storage:
        return Icons.storage_rounded;
      case SyncErrorType.authentication:
        return Icons.account_circle_outlined;
      case SyncErrorType.validation:
        return Icons.warning_rounded;
      case SyncErrorType.conflict:
        return Icons.merge_type_rounded;
      case SyncErrorType.timeout:
        return Icons.timer_off_rounded;
      case SyncErrorType.quota:
        return Icons.storage_rounded;
      case SyncErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  /// Obtém cor baseada na severidade
  Color _getErrorColor(SyncErrorSeverity severity) {
    switch (severity) {
      case SyncErrorSeverity.low:
        return Colors.blue;
      case SyncErrorSeverity.medium:
        return Colors.orange;
      case SyncErrorSeverity.high:
        return Colors.red;
      case SyncErrorSeverity.critical:
        return Colors.red.shade800;
    }
  }

  /// Obtém título baseado no tipo
  String _getErrorTitle(SyncErrorType type) {
    switch (type) {
      case SyncErrorType.network:
        return 'Problema de Conexão';
      case SyncErrorType.server:
        return 'Erro do Servidor';
      case SyncErrorType.storage:
        return 'Erro de Armazenamento';
      case SyncErrorType.authentication:
        return 'Autenticação Necessária';
      case SyncErrorType.validation:
        return 'Dados Inválidos';
      case SyncErrorType.conflict:
        return 'Conflito de Sincronização';
      case SyncErrorType.timeout:
        return 'Tempo Esgotado';
      case SyncErrorType.quota:
        return 'Limite Atingido';
      case SyncErrorType.unknown:
        return 'Erro de Sincronização';
    }
  }

  /// Log estruturado do erro
  void _logError(SyncError syncError) {
    final logLevel = _getLogLevel(syncError.severity);

    developer.log(
      'Erro de sincronização: ${syncError.message}',
      name: 'SyncErrorHandler',
      level: logLevel,
      error: syncError.originalError,
      stackTrace: syncError.stackTrace,
    );
    if (kDebugMode) {
      developer.log(
        'Detalhes: type=${syncError.type}, severity=${syncError.severity}, '
        'recovery=${syncError.recoveryStrategy}, metadata=${syncError.metadata}',
        name: 'SyncErrorHandler',
      );
    }
  }

  /// Obtém nível de log baseado na severidade
  int _getLogLevel(SyncErrorSeverity severity) {
    switch (severity) {
      case SyncErrorSeverity.low:
        return 800; // INFO
      case SyncErrorSeverity.medium:
        return 900; // WARNING
      case SyncErrorSeverity.high:
        return 1000; // SEVERE
      case SyncErrorSeverity.critical:
        return 1200; // SHOUT
    }
  }

  /// Suprime um erro específico
  void _suppressError(String errorId) {
    _suppressedErrors.add(errorId);
    developer.log(
      'Erro $errorId suprimido pelo usuário',
      name: 'SyncErrorHandler',
    );
  }

  /// Limpa histórico de erros antigos
  void _cleanupOldErrors() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    _errorHistory.removeWhere((error) => error.timestamp.isBefore(cutoff));
    _retryCount.removeWhere(
      (id, _) => !_errorHistory.any((error) => error.id == id),
    );
    _suppressedErrors.removeWhere(
      (id) => !_errorHistory.any((error) => error.id == id),
    );
  }

  /// Configura timer de limpeza
  void _setupCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupOldErrors(),
    );
  }

  /// Obtém estatísticas de erro
  Map<String, dynamic> getErrorStats() {
    final now = DateTime.now();
    final last24h =
        _errorHistory
            .where((e) => now.difference(e.timestamp).inHours < 24)
            .toList();

    final byType = <SyncErrorType, int>{};
    final bySeverity = <SyncErrorSeverity, int>{};

    for (final error in last24h) {
      byType[error.type] = (byType[error.type] ?? 0) + 1;
      bySeverity[error.severity] = (bySeverity[error.severity] ?? 0) + 1;
    }

    return {
      'total_errors': _errorHistory.length,
      'errors_24h': last24h.length,
      'by_type': byType.map((k, v) => MapEntry(k.name, v)),
      'by_severity': bySeverity.map((k, v) => MapEntry(k.name, v)),
      'active_retries': _retryCount.length,
      'suppressed_count': _suppressedErrors.length,
    };
  }

  /// Limpa todos os dados (útil para testes)
  void clear() {
    _retryCount.clear();
    _errorHistory.clear();
    _suppressedErrors.clear();
    developer.log('SyncErrorHandler limpo', name: 'SyncErrorHandler');
  }

  /// Dispose dos recursos
  void dispose() {
    _cleanupTimer?.cancel();
    _errorController.close();
    _recoveryController.close();
    clear();
    developer.log('SyncErrorHandler disposed', name: 'SyncErrorHandler');
  }
}

/// Extension para facilitar o uso
extension SyncErrorHandlerExtension on Object {
  /// Trata este objeto como um erro de sincronização
  Future<bool> handleAsSyncError({
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
    BuildContext? context,
  }) {
    return SyncErrorHandler.instance.handleError(
      this,
      stackTrace: stackTrace,
      metadata: metadata,
      context: context,
    );
  }
}
