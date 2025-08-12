// Dart imports:
import 'dart:developer' as dev;

/// Sanitizador de mensagens de erro para proteger informações sensíveis
///
/// Este serviço garante que erros técnicos não sejam expostos aos usuários finais,
/// mantendo logs detalhados para desenvolvimento e removendo informações sensíveis
/// do sistema que poderiam ser exploradas por atacantes.
class ErrorSanitizer {
  ErrorSanitizer._();

  /// ========================================
  /// CONFIGURATION
  /// ========================================

  /// Determina se estamos em modo de desenvolvimento
  static bool get _isDevelopmentMode =>
      const bool.fromEnvironment('dart.vm.product') == false;

  /// ========================================
  /// PUBLIC SANITIZATION METHODS
  /// ========================================

  /// Sanitiza erro para exibição ao usuário final
  static SanitizedError sanitizeForUser(
    dynamic error, {
    String? context,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final originalMessage = error.toString();

    // Log técnico completo (apenas desenvolvimento/logs internos)
    _logTechnicalError(error, context, severity);

    // Criar mensagem sanitizada para usuário
    final userMessage = _createUserFriendlyMessage(originalMessage, severity);

    // Criar código de erro para rastreamento
    final errorCode = _generateErrorCode(originalMessage, context);

    return SanitizedError(
      userMessage: userMessage,
      errorCode: errorCode,
      severity: severity,
      context: context,
      originalError: _isDevelopmentMode ? originalMessage : null,
    );
  }

  /// Sanitiza lista de erros de validação
  static List<String> sanitizeValidationErrors(List<String> errors) {
    return errors
        .map((error) => _sanitizeValidationMessage(error))
        .where((sanitized) => sanitized.isNotEmpty)
        .toList();
  }

  /// Sanitiza erros de repositório/banco de dados
  static SanitizedError sanitizeRepositoryError(
    dynamic error, {
    String? operation,
  }) {
    final originalMessage = error.toString().toLowerCase();

    // Log técnico
    _logTechnicalError(error, 'Repository: $operation', ErrorSeverity.high);

    String userMessage;

    // Classificar tipo de erro do repositório
    if (_isConnectionError(originalMessage)) {
      userMessage =
          'Erro de conexão com o banco de dados. Verifique sua conexão e tente novamente.';
    } else if (_isPermissionError(originalMessage)) {
      userMessage = 'Você não tem permissão para executar esta operação.';
    } else if (_isDataCorruptionError(originalMessage)) {
      userMessage =
          'Dados corrompidos detectados. Entre em contato com o suporte.';
    } else if (_isConstraintViolationError(originalMessage)) {
      userMessage = 'Operação violou regras de integridade dos dados.';
    } else {
      userMessage =
          'Erro interno do sistema. Tente novamente em alguns instantes.';
    }

    return SanitizedError(
      userMessage: userMessage,
      errorCode: _generateErrorCode(originalMessage, operation),
      severity: ErrorSeverity.high,
      context: operation,
      originalError: _isDevelopmentMode ? error.toString() : null,
    );
  }

  /// Sanitiza erros de rede/conectividade
  static SanitizedError sanitizeNetworkError(
    dynamic error, {
    String? endpoint,
  }) {
    _logTechnicalError(error, 'Network: $endpoint', ErrorSeverity.medium);

    final originalMessage = error.toString().toLowerCase();
    String userMessage;

    if (_isTimeoutError(originalMessage)) {
      userMessage =
          'Tempo limite excedido. Verifique sua conexão e tente novamente.';
    } else if (_isConnectionRefusedError(originalMessage)) {
      userMessage =
          'Não foi possível conectar ao servidor. Tente novamente mais tarde.';
    } else if (_isCertificateError(originalMessage)) {
      userMessage = 'Erro de segurança na conexão. Verifique sua rede.';
    } else {
      userMessage = 'Erro de rede. Verifique sua conexão de internet.';
    }

    return SanitizedError(
      userMessage: userMessage,
      errorCode: _generateErrorCode(originalMessage, endpoint),
      severity: ErrorSeverity.medium,
      context: endpoint,
      originalError: _isDevelopmentMode ? error.toString() : null,
    );
  }

  /// ========================================
  /// INTERNAL SANITIZATION LOGIC
  /// ========================================

  /// Cria mensagem amigável baseada no erro original
  static String _createUserFriendlyMessage(
      String originalMessage, ErrorSeverity severity) {
    final lowerMessage = originalMessage.toLowerCase();

    // Remover informações sensíveis primeiro
    String sanitized = _removeSensitiveInformation(originalMessage);

    // Mapear erros comuns para mensagens amigáveis
    if (_isValidationError(lowerMessage)) {
      return 'Alguns dados inseridos são inválidos. Verifique as informações e tente novamente.';
    }

    if (_isPermissionError(lowerMessage)) {
      return 'Você não tem permissão para executar esta ação.';
    }

    if (_isNetworkError(lowerMessage)) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }

    if (_isFileSystemError(lowerMessage)) {
      return 'Erro no sistema de arquivos. Tente novamente.';
    }

    if (_isBusinessRuleError(lowerMessage)) {
      return 'Esta ação não é permitida pelas regras do sistema.';
    }

    // Mensagem genérica baseada na severidade
    switch (severity) {
      case ErrorSeverity.low:
        return 'Algo não funcionou como esperado. Tente novamente.';
      case ErrorSeverity.medium:
        return 'Ocorreu um erro. Verifique os dados e tente novamente.';
      case ErrorSeverity.high:
        return 'Erro crítico detectado. Entre em contato com o suporte.';
      case ErrorSeverity.critical:
        return 'Erro crítico do sistema. Contacte o suporte imediatamente.';
    }
  }

  /// Remove informações sensíveis da mensagem de erro
  static String _removeSensitiveInformation(String message) {
    String sanitized = message;

    // Remover paths de arquivos
    sanitized = sanitized.replaceAll(
        RegExp(r'\/[\/\w\-\.]+\/([\w\-\.]+)'), r'/.../\$1');

    // Remover IPs e ports
    sanitized = sanitized.replaceAll(
        RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d+)?\b'),
        '[IP_HIDDEN]');

    // Remover URLs completas, manter apenas domínio
    sanitized = sanitized.replaceAll(
        RegExp(r'https?://([^/\s]+)[^\s]*'), r'https://\$1/...');

    // Remover tokens e chaves
    sanitized = sanitized.replaceAll(
        RegExp(r'[Tt]oken[:\s]*[A-Za-z0-9+/=]{10,}'), 'Token: [HIDDEN]');
    sanitized = sanitized.replaceAll(
        RegExp(r'[Kk]ey[:\s]*[A-Za-z0-9+/=]{10,}'), 'Key: [HIDDEN]');

    // Remover credenciais
    sanitized = sanitized.replaceAll(
        RegExp(r'password[:\s]*\S+', caseSensitive: false),
        'password: [HIDDEN]');
    sanitized = sanitized.replaceAll(
        RegExp(r'username[:\s]*\S+', caseSensitive: false),
        'username: [HIDDEN]');

    // Remover stack traces detalhados
    sanitized = sanitized.replaceAll(
        RegExp(r'#\d+\s+.*\s+\(.*\)'), '[STACK_TRACE_HIDDEN]');

    // Remover informações de versão/build
    sanitized = sanitized.replaceAll(
        RegExp(r'version\s+\d+\.\d+\.\d+'), 'version [HIDDEN]');

    return sanitized;
  }

  /// Sanitiza mensagem de validação individual
  static String _sanitizeValidationMessage(String message) {
    // Lista de mensagens que devem ser bloqueadas/modificadas
    final blockedPatterns = [
      RegExp(r'sql', caseSensitive: false),
      RegExp(r'database', caseSensitive: false),
      RegExp(r'table', caseSensitive: false),
      RegExp(r'column', caseSensitive: false),
      RegExp(r'constraint', caseSensitive: false),
      RegExp(r'foreign key', caseSensitive: false),
    ];

    // Se contém padrões sensíveis, retornar mensagem genérica
    if (blockedPatterns.any((pattern) => pattern.hasMatch(message))) {
      return 'Dados inválidos detectados';
    }

    return message;
  }

  /// ========================================
  /// ERROR CLASSIFICATION HELPERS
  /// ========================================

  static bool _isValidationError(String message) {
    return message.contains('validation') ||
        message.contains('invalid') ||
        message.contains('required') ||
        message.contains('format');
  }

  static bool _isPermissionError(String message) {
    return message.contains('permission') ||
        message.contains('unauthorized') ||
        message.contains('forbidden') ||
        message.contains('access denied');
  }

  static bool _isNetworkError(String message) {
    return message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('unreachable');
  }

  static bool _isConnectionError(String message) {
    return message.contains('connection') ||
        message.contains('connect') ||
        message.contains('hive') ||
        message.contains('database');
  }

  static bool _isTimeoutError(String message) {
    return message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('deadline exceeded');
  }

  static bool _isConnectionRefusedError(String message) {
    return message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('connection failed');
  }

  static bool _isCertificateError(String message) {
    return message.contains('certificate') ||
        message.contains('ssl') ||
        message.contains('tls') ||
        message.contains('handshake');
  }

  static bool _isFileSystemError(String message) {
    return message.contains('file') ||
        message.contains('directory') ||
        message.contains('storage') ||
        message.contains('permission denied');
  }

  static bool _isBusinessRuleError(String message) {
    return message.contains('business') ||
        message.contains('rule') ||
        message.contains('policy') ||
        message.contains('limit exceeded');
  }

  static bool _isDataCorruptionError(String message) {
    return message.contains('corrupt') ||
        message.contains('malformed') ||
        message.contains('invalid format') ||
        message.contains('parse error');
  }

  static bool _isConstraintViolationError(String message) {
    return message.contains('constraint') ||
        message.contains('unique') ||
        message.contains('foreign key') ||
        message.contains('integrity');
  }

  /// ========================================
  /// LOGGING AND TRACKING
  /// ========================================

  /// Log técnico completo para desenvolvimento
  static void _logTechnicalError(
    dynamic error,
    String? context,
    ErrorSeverity severity,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context ?? 'Unknown';

    // Log estruturado para desenvolvimento
    if (_isDevelopmentMode) {
      dev.log(
        'ERROR: $error',
        time: DateTime.now(),
        name: 'ErrorSanitizer',
        error: error,
        level: _severityToLogLevel(severity),
      );
    }

    // TODO: Em produção, enviar para serviço de logging (Firebase, Sentry, etc.)
    // _sendToLoggingService(error, context, severity, timestamp);
  }

  /// Converte severidade para nível de log
  static int _severityToLogLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 800; // Info
      case ErrorSeverity.medium:
        return 900; // Warning
      case ErrorSeverity.high:
        return 1000; // Error
      case ErrorSeverity.critical:
        return 1200; // Severe
    }
  }

  /// Gera código de erro único para rastreamento
  static String _generateErrorCode(String message, String? context) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hashCode = message.hashCode.abs();
    final contextHash = context?.hashCode.abs() ?? 0;

    return 'ERR-${timestamp.toString().substring(8)}-${hashCode.toString().padLeft(8, '0').substring(0, 4)}-${contextHash.toString().padLeft(4, '0').substring(0, 2)}';
  }
}

/// ========================================
/// SUPPORTING CLASSES
/// ========================================

/// Resultado de sanitização de erro
class SanitizedError {
  final String userMessage;
  final String errorCode;
  final ErrorSeverity severity;
  final String? context;
  final String? originalError;

  const SanitizedError({
    required this.userMessage,
    required this.errorCode,
    required this.severity,
    this.context,
    this.originalError,
  });

  /// Verifica se é um erro crítico
  bool get isCritical =>
      severity == ErrorSeverity.critical || severity == ErrorSeverity.high;

  /// Obtém ícone baseado na severidade
  String get severityIcon {
    switch (severity) {
      case ErrorSeverity.low:
        return 'ℹ️';
      case ErrorSeverity.medium:
        return '⚠️';
      case ErrorSeverity.high:
        return '❌';
      case ErrorSeverity.critical:
        return '🚨';
    }
  }

  /// Formata mensagem completa para o usuário
  String get formattedMessage {
    final buffer = StringBuffer();
    buffer.write(severityIcon);
    buffer.write(' ');
    buffer.write(userMessage);

    if (context != null && context!.isNotEmpty) {
      buffer.write('\n\nContexto: $context');
    }

    buffer.write('\n\nCódigo de erro: $errorCode');

    // Mostrar erro original apenas em desenvolvimento
    if (originalError != null && originalError!.isNotEmpty) {
      buffer.write('\n\n[DEV] Erro original: $originalError');
    }

    return buffer.toString();
  }

  @override
  String toString() => 'SanitizedError($errorCode: $userMessage)';
}

/// Níveis de severidade de erro
enum ErrorSeverity {
  low, // Informativo, não bloqueia operação
  medium, // Aviso, pode afetar funcionalidade
  high, // Erro, bloqueia operação
  critical, // Crítico, pode afetar sistema
}

/// Extension para facilitar uso de ErrorSeverity
extension ErrorSeverityExtension on ErrorSeverity {
  /// Nome amigável da severidade
  String get displayName {
    switch (this) {
      case ErrorSeverity.low:
        return 'Informação';
      case ErrorSeverity.medium:
        return 'Aviso';
      case ErrorSeverity.high:
        return 'Erro';
      case ErrorSeverity.critical:
        return 'Crítico';
    }
  }

  /// Cor associada à severidade
  String get colorCode {
    switch (this) {
      case ErrorSeverity.low:
        return '#2196F3'; // Azul
      case ErrorSeverity.medium:
        return '#FF9800'; // Laranja
      case ErrorSeverity.high:
        return '#F44336'; // Vermelho
      case ErrorSeverity.critical:
        return '#9C27B0'; // Roxo
    }
  }
}
