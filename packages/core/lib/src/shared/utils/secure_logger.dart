import 'package:flutter/foundation.dart';

/// Sistema de logging seguro que filtra informações sensíveis
///
/// Usado para registrar logs no desenvolvimento e produção, garantindo
/// que informações sensíveis sejam filtradas automaticamente.
class SecureLogger {
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  /// Palavras-chave que devem ser filtradas dos logs
  static const List<String> _sensitiveKeywords = [
    'password',
    'token',
    'secret',
    'key',
    'auth',
    'credential',
    'session',
    'jwt',
    'api_key',
    'database',
    'connection',
    'sql',
    'query',
    'supabase',
    'firebase',
  ];

  /// Log de debug - apenas em desenvolvimento
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (!_isProduction) {
      final sanitizedMessage = _sanitizeMessage(message);
      debugPrint('[DEBUG] $sanitizedMessage');
      if (error != null) {
        debugPrint('[DEBUG] Error: ${_sanitizeError(error)}');
      }
      if (stackTrace != null && !_isProduction) {
        debugPrint('[DEBUG] Stack trace: $stackTrace');
      }
    }
  }

  /// Log de informação - sempre exibido
  static void info(String message) {
    final sanitizedMessage = _sanitizeMessage(message);
    debugPrint('[INFO] $sanitizedMessage');
  }

  /// Log de warning - sempre exibido
  static void warning(String message, {Object? error}) {
    final sanitizedMessage = _sanitizeMessage(message);
    debugPrint('[WARNING] $sanitizedMessage');
    if (error != null) {
      debugPrint('[WARNING] Error: ${_sanitizeError(error)}');
    }
  }

  /// Log de erro - sempre exibido mas sanitizado
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    final sanitizedMessage = _sanitizeMessage(message);
    debugPrint('[ERROR] $sanitizedMessage');

    if (error != null) {
      final sanitizedError = _sanitizeError(error);
      debugPrint('[ERROR] Error details: $sanitizedError');
    }
    if (stackTrace != null && !_isProduction) {
      debugPrint('[ERROR] Stack trace: $stackTrace');
    }
  }

  /// Sanitiza mensagem removendo informações sensíveis
  static String _sanitizeMessage(String message) {
    String sanitized = message;

    for (String keyword in _sensitiveKeywords) {
      RegExp regex = RegExp(
        '$keyword[\\s]*[:=][\\s]*[\\S]+',
        caseSensitive: false,
      );
      sanitized = sanitized.replaceAll(regex, '$keyword: [FILTERED]');
    }
    RegExp urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    sanitized = sanitized.replaceAllMapped(urlRegex, (match) {
      String url = match.group(0)!;
      Uri uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}/[PATH_FILTERED]';
    });

    return sanitized;
  }

  /// Sanitiza objeto de erro
  static String _sanitizeError(Object error) {
    String errorString = error.toString();
    return _sanitizeMessage(errorString);
  }

  /// Retorna mensagem de erro user-friendly baseada no tipo de erro
  static String getUserFriendlyError(Object error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }

    if (errorString.contains('timeout')) {
      return 'Operação demorou muito para responder. Tente novamente.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Recurso não encontrado. Tente novamente mais tarde.';
    }

    if (errorString.contains('403') || errorString.contains('unauthorized')) {
      return 'Acesso negado. Você não tem permissão para esta operação.';
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Erro interno do servidor. Tente novamente mais tarde.';
    }

    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return 'Dados inválidos. Verifique as informações e tente novamente.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
  }
}

/// Extension para facilitar o uso do logger
extension SecureLoggerExtension on Object {
  void logError([String? message]) {
    SecureLogger.error(message ?? 'Erro ocorreu', error: this);
  }

  void logWarning([String? message]) {
    SecureLogger.warning(message ?? 'Aviso', error: this);
  }
}
