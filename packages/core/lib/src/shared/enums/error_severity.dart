/// Severidade do erro para todo o sistema (AppError e ErrorLog)
enum ErrorSeverity {
  /// Avisos, informações não críticas
  low,

  /// Erros que não impedem o funcionamento
  medium,

  /// Erros críticos que afetam funcionalidades
  high,

  /// Erros que podem causar crash ou perda de dados
  critical;

  String get displayName {
    switch (this) {
      case ErrorSeverity.low:
        return 'Baixa';
      case ErrorSeverity.medium:
        return 'Média';
      case ErrorSeverity.high:
        return 'Alta';
      case ErrorSeverity.critical:
        return 'Crítica';
    }
  }

  String get emoji {
    switch (this) {
      case ErrorSeverity.low:
        return '🟢';
      case ErrorSeverity.medium:
        return '🟡';
      case ErrorSeverity.high:
        return '🟠';
      case ErrorSeverity.critical:
        return '🔴';
    }
  }
}
