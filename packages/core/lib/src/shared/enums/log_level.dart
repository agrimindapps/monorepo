/// Níveis de log disponíveis no sistema
enum LogLevel {
  /// Informações de trace detalhadas (desenvolvimento)
  trace,
  
  /// Informações detalhadas para desenvolvimento
  debug,
  
  /// Informações gerais da aplicação
  info,
  
  /// Avisos que requerem atenção
  warning,
  
  /// Erros que necessitam correção
  error,
  
  /// Erros críticos que podem causar falhas
  critical,
}