import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Serviço de captura de erros para plataforma Web
///
/// Captura erros automaticamente via FlutterError.onError e runZonedGuarded,
/// com deduplicação por hash, rate limiting e batch upload para Firestore.
class WebErrorCaptureService {
  WebErrorCaptureService({
    FirebaseErrorLogService? errorLogService,
    this.maxErrorsPerMinute = 10,
    this.batchUploadInterval = const Duration(seconds: 30),
    this.enableDeduplication = true,
  }) : _errorLogService = errorLogService ?? FirebaseErrorLogService();

  final FirebaseErrorLogService _errorLogService;

  /// Máximo de erros por minuto (rate limiting)
  final int maxErrorsPerMinute;

  /// Intervalo de upload em lote
  final Duration batchUploadInterval;

  /// Habilita deduplicação por hash
  final bool enableDeduplication;

  /// Fila de erros para upload em lote
  final List<ErrorLogEntity> _errorQueue = [];

  /// Contador de erros no último minuto
  int _errorsInLastMinute = 0;

  /// Timestamp do último reset do contador
  DateTime _lastRateLimitReset = DateTime.now();

  /// Timer para batch upload
  Timer? _batchTimer;

  /// Hashes de erros já registrados (para deduplicação)
  final Set<String> _registeredHashes = {};

  /// ID da sessão atual (anônimo)
  late final String _sessionId;

  /// Informações do navegador
  String? _browserInfo;

  /// User agent
  String? _userAgent;

  /// Tamanho da tela
  String? _screenSize;

  /// Versão do app
  String? _appVersion;

  /// URL atual (para contexto)
  String? _currentUrl;

  /// Game atual (se aplicável)
  String? _currentGameId;
  String? _currentGameName;

  /// Inicializa o serviço
  Future<void> initialize() async {
    // Gera ID de sessão único
    _sessionId = _generateSessionId();

    // Coleta informações do ambiente
    await _collectEnvironmentInfo();

    // Inicia timer de batch upload
    _startBatchTimer();

    debugPrint('[WebErrorCaptureService] Initialized with session: $_sessionId');
  }

  /// Configura os handlers globais de erro
  void setupErrorHandlers() {
    // Handler para erros Flutter (widgets, rendering, etc)
    FlutterError.onError = (FlutterErrorDetails details) {
      _captureFlutterError(details);
    };

    // Handler para erros não capturados em modo release
    PlatformDispatcher.instance.onError = (error, stack) {
      _captureError(
        error: error,
        stackTrace: stack,
        errorType: ErrorType.exception,
        fatal: true,
      );
      return true;
    };
  }

  /// Captura erro de FlutterError
  void _captureFlutterError(FlutterErrorDetails details) {
    ErrorType errorType = ErrorType.exception;

    // Detecta tipo de erro baseado na exception
    if (details.exception is AssertionError) {
      errorType = ErrorType.assertion;
    } else if (details.library?.contains('rendering') == true) {
      errorType = ErrorType.render;
    } else if (details.library?.contains('widgets') == true) {
      errorType = ErrorType.state;
    } else if (details.library?.contains('navigator') == true ||
        details.library?.contains('router') == true) {
      errorType = ErrorType.navigation;
    }

    _captureError(
      error: details.exception,
      stackTrace: details.stack,
      errorType: errorType,
      context: details.context?.toDescription(),
      library: details.library,
      fatal: false,
    );
  }

  /// Captura um erro manualmente
  void captureError({
    required dynamic error,
    StackTrace? stackTrace,
    ErrorType errorType = ErrorType.exception,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? context,
    Map<String, dynamic>? extras,
  }) {
    _captureError(
      error: error,
      stackTrace: stackTrace,
      errorType: errorType,
      severity: severity,
      context: context,
      extras: extras,
      fatal: false,
    );
  }

  /// Captura erro de rede
  void captureNetworkError({
    required String url,
    required int statusCode,
    String? message,
    Map<String, dynamic>? extras,
  }) {
    final errorMessage =
        'Network Error: $statusCode - ${message ?? 'Unknown'} for $url';
    _captureError(
      error: errorMessage,
      errorType: ErrorType.network,
      severity: statusCode >= 500 ? ErrorSeverity.high : ErrorSeverity.medium,
      extras: {
        'requestUrl': url,
        'statusCode': statusCode,
        ...?extras,
      },
      fatal: false,
    );
  }

  /// Captura erro de timeout
  void captureTimeoutError({
    required String operation,
    Duration? timeout,
    Map<String, dynamic>? extras,
  }) {
    final errorMessage =
        'Timeout: $operation${timeout != null ? ' after ${timeout.inSeconds}s' : ''}';
    _captureError(
      error: errorMessage,
      errorType: ErrorType.timeout,
      severity: ErrorSeverity.medium,
      extras: extras,
      fatal: false,
    );
  }

  /// Captura erro de parsing
  void captureParsingError({
    required String dataType,
    required String message,
    String? rawData,
    Map<String, dynamic>? extras,
  }) {
    final errorMessage = 'Parsing Error ($dataType): $message';
    _captureError(
      error: errorMessage,
      errorType: ErrorType.parsing,
      severity: ErrorSeverity.low,
      extras: {
        if (rawData != null && rawData.length < 500) 'rawData': rawData,
        ...?extras,
      },
      fatal: false,
    );
  }

  /// Define a URL/rota atual
  void setCurrentUrl(String url) {
    _currentUrl = url;
  }

  /// Define o game atual
  void setCurrentGame({String? id, String? name}) {
    _currentGameId = id;
    _currentGameName = name;
  }

  /// Processa captura de erro interno
  void _captureError({
    required dynamic error,
    StackTrace? stackTrace,
    required ErrorType errorType,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? context,
    String? library,
    Map<String, dynamic>? extras,
    required bool fatal,
  }) {
    // Rate limiting
    if (!_checkRateLimit()) {
      debugPrint('[WebErrorCaptureService] Rate limit exceeded, error dropped');
      return;
    }

    final message = _formatErrorMessage(error, context, library);
    final stackTraceStr = stackTrace?.toString();
    final hash = _generateErrorHash(message, stackTraceStr);

    // Deduplicação
    if (enableDeduplication && _registeredHashes.contains(hash)) {
      // Incrementa ocorrências no Firestore (assíncrono)
      _incrementOccurrences(hash);
      return;
    }

    // Adiciona hash ao set
    _registeredHashes.add(hash);

    // Cria entidade de erro
    final errorLog = ErrorLogEntity(
      id: '',
      errorType: errorType,
      message: message,
      stackTrace: _truncateStackTrace(stackTraceStr),
      url: _currentUrl,
      calculatorId: _currentGameId,
      calculatorName: _currentGameName,
      userAgent: _userAgent,
      appVersion: _appVersion,
      platform: 'web',
      browserInfo: _browserInfo,
      screenSize: _screenSize,
      severity: fatal ? ErrorSeverity.critical : severity,
      status: ErrorStatus.newError,
      createdAt: DateTime.now(),
      occurrences: 1,
      lastOccurrence: DateTime.now(),
      errorHash: hash,
      sessionId: _sessionId,
    );

    // Adiciona à fila
    _errorQueue.add(errorLog);

    debugPrint(
        '[WebErrorCaptureService] Error captured: ${errorType.name} - ${message.substring(0, message.length.clamp(0, 100))}');

    // Se for fatal ou fila está grande, faz upload imediato
    if (fatal || _errorQueue.length >= 5) {
      _flushQueue();
    }
  }

  /// Verifica rate limit
  bool _checkRateLimit() {
    final now = DateTime.now();

    // Reset contador a cada minuto
    if (now.difference(_lastRateLimitReset).inMinutes >= 1) {
      _errorsInLastMinute = 0;
      _lastRateLimitReset = now;
    }

    _errorsInLastMinute++;
    return _errorsInLastMinute <= maxErrorsPerMinute;
  }

  /// Formata mensagem de erro
  String _formatErrorMessage(dynamic error, String? context, String? library) {
    final buffer = StringBuffer();

    buffer.write(error.toString());

    if (context != null && context.isNotEmpty) {
      buffer.write(' | Context: $context');
    }

    if (library != null && library.isNotEmpty) {
      buffer.write(' | Library: $library');
    }

    return buffer.toString();
  }

  /// Gera hash único para deduplicação
  String _generateErrorHash(String message, String? stackTrace) {
    final content =
        '$message|${stackTrace?.split('\n').take(5).join('\n') ?? ''}';
    return md5.convert(utf8.encode(content)).toString();
  }

  /// Trunca stack trace para não exceder limites do Firestore
  String? _truncateStackTrace(String? stackTrace) {
    if (stackTrace == null) return null;

    final lines = stackTrace.split('\n');
    if (lines.length <= 30) return stackTrace;

    return '${lines.take(30).join('\n')}\n... (truncated)';
  }

  /// Incrementa ocorrências de erro existente
  Future<void> _incrementOccurrences(String hash) async {
    try {
      await _errorLogService.incrementOccurrences(hash);
      debugPrint(
          '[WebErrorCaptureService] Incremented occurrences for hash: ${hash.substring(0, 8)}');
    } catch (e) {
      debugPrint('[WebErrorCaptureService] Failed to increment occurrences: $e');
    }
  }

  /// Inicia timer de batch upload
  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(batchUploadInterval, (_) {
      _flushQueue();
    });
  }

  /// Faz upload da fila de erros
  Future<void> _flushQueue() async {
    if (_errorQueue.isEmpty) return;

    final errorsToUpload = List<ErrorLogEntity>.from(_errorQueue);
    _errorQueue.clear();

    debugPrint(
        '[WebErrorCaptureService] Uploading ${errorsToUpload.length} errors...');

    for (final error in errorsToUpload) {
      try {
        await _errorLogService.logError(error);
      } catch (e) {
        debugPrint('[WebErrorCaptureService] Failed to upload error: $e');
        // Re-adiciona à fila para retry (com limite)
        if (_errorQueue.length < 20) {
          _errorQueue.add(error);
        }
      }
    }
  }

  /// Gera ID de sessão único
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return md5.convert(utf8.encode('$timestamp-$random')).toString().substring(0, 16);
  }

  /// Coleta informações do ambiente
  Future<void> _collectEnvironmentInfo() async {
    try {
      // User agent via navegador
      _userAgent = _getUserAgent();

      // Informações do navegador
      _browserInfo = _detectBrowser(_userAgent);

      // Tamanho da tela
      _screenSize = _getScreenSize();

      // Versão do app
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        _appVersion = packageInfo.version;
      } catch (_) {
        _appVersion = 'unknown';
      }
    } catch (e) {
      debugPrint('[WebErrorCaptureService] Failed to collect environment info: $e');
    }
  }

  /// Obtém user agent (web)
  String? _getUserAgent() {
    // Em web, podemos acessar via window.navigator.userAgent
    // Mas para manter compatibilidade, usamos uma abordagem segura
    return 'Flutter Web';
  }

  /// Detecta navegador a partir do user agent
  String? _detectBrowser(String? userAgent) {
    if (userAgent == null) return null;

    if (userAgent.contains('Chrome')) return 'Chrome';
    if (userAgent.contains('Firefox')) return 'Firefox';
    if (userAgent.contains('Safari')) return 'Safari';
    if (userAgent.contains('Edge')) return 'Edge';
    if (userAgent.contains('Opera')) return 'Opera';

    return 'Unknown';
  }

  /// Obtém tamanho da tela
  String? _getScreenSize() {
    // Será preenchido quando o context estiver disponível
    return null;
  }

  /// Atualiza tamanho da tela (chamar do widget)
  void updateScreenSize(double width, double height) {
    _screenSize = '${width.toInt()}x${height.toInt()}';
  }

  /// Limpa recursos ao destruir
  void dispose() {
    _batchTimer?.cancel();
    _flushQueue(); // Upload final
    debugPrint('[WebErrorCaptureService] Disposed');
  }
}

/// Provider global do serviço (singleton para web)
WebErrorCaptureService? _webErrorCaptureServiceInstance;

/// Obtém instância do serviço
WebErrorCaptureService getWebErrorCaptureService() {
  _webErrorCaptureServiceInstance ??= WebErrorCaptureService();
  return _webErrorCaptureServiceInstance!;
}

/// Inicializa e configura o serviço globalmente
Future<WebErrorCaptureService> initializeWebErrorCapture() async {
  final service = getWebErrorCaptureService();
  await service.initialize();
  service.setupErrorHandlers();
  return service;
}
