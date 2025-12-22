/// Configurações de desenvolvimento
/// 
/// Este arquivo contém configurações específicas para ambiente de desenvolvimento,
/// incluindo credenciais de teste para auto-login.
/// 
/// ⚠️ IMPORTANTE: Este arquivo NÃO deve ser commitado com credenciais reais!
/// Use apenas credenciais de teste/desenvolvimento.
class DevConfig {
  DevConfig._();

  /// Habilita auto-login no modo debug
  /// Quando true, o app tentará fazer login automaticamente com as credenciais abaixo
  static const bool enableAutoLogin = true;

  /// Email de teste para auto-login
  /// Altere para seu email de teste do Firebase
  static const String testEmail = 'teste@nebulalist.com';

  /// Senha de teste para auto-login
  /// Altere para a senha correspondente ao email de teste
  static const String testPassword = 'teste123';

  /// Usa login anônimo como fallback em caso de falha
  /// Se true, tentará login anônimo caso o auto-login com credenciais falhe
  static const bool useAnonymousFallback = true;

  /// Exibe logs detalhados de debug
  static const bool verboseLogs = true;
}
