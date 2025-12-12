/// Exceções específicas do domínio de settings
/// 
/// Centraliza todas as exceções relacionadas a configurações do usuário
/// seguindo padrões de Clean Architecture
library;

/// Exceção lançada quando um ID de usuário é inválido ou vazio
class InvalidUserIdException implements Exception {
  final String message;
  InvalidUserIdException(this.message);

  @override
  String toString() => 'InvalidUserIdException: $message';
}

/// Exceção lançada quando configurações não são encontradas
class SettingsNotFoundException implements Exception {
  final String message;
  SettingsNotFoundException(this.message);

  @override
  String toString() => 'SettingsNotFoundException: $message';
}

/// Exceção lançada quando há erro na validação de configurações
class SettingsValidationException implements Exception {
  final String message;
  SettingsValidationException(this.message);

  @override
  String toString() => 'SettingsValidationException: $message';
}

/// Exception thrown when update is invalid
class InvalidUpdateException implements Exception {
  final String message;
  InvalidUpdateException(this.message);

  @override
  String toString() => 'InvalidUpdateException: $message';
}

/// Exception thrown when language is not supported
class UnsupportedLanguageException implements Exception {
  final String message;
  UnsupportedLanguageException(this.message);

  @override
  String toString() => 'UnsupportedLanguageException: $message';
}

/// Exception thrown when settings are invalid
class InvalidSettingsException implements Exception {
  final String message;
  InvalidSettingsException(this.message);

  @override
  String toString() => 'InvalidSettingsException: $message';
}
