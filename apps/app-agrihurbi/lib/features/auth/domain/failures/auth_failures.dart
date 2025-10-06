import 'package:core/core.dart';

/// Falhas específicas do domínio de autenticação
/// 
/// Seguindo padrão Clean Architecture para tratamento de erros específicos

/// Falha de credenciais inválidas
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([String message = 'Email ou senha inválidos'])
      : super(message: message);
}

/// Falha de email já em uso
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([String message = 'Email já está em uso'])
      : super(message: message);
}

/// Falha de usuário não encontrado
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'Usuário não encontrado'])
      : super(message: message);
}

/// Falha de token expirado
class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure([String message = 'Token de acesso expirado'])
      : super(message: message);
}

/// Falha de token inválido
class InvalidTokenFailure extends Failure {
  const InvalidTokenFailure([String message = 'Token de acesso inválido'])
      : super(message: message);
}

/// Falha de usuário inativo
class InactiveUserFailure extends Failure {
  const InactiveUserFailure([String message = 'Usuário está inativo'])
      : super(message: message);
}

/// Falha de senha fraca
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([String message = 'Senha não atende aos critérios de segurança'])
      : super(message: message);
}

/// Falha de senha atual incorreta
class WrongPasswordFailure extends Failure {
  const WrongPasswordFailure([String message = 'Senha atual incorreta'])
      : super(message: message);
}

/// Falha de email não verificado
class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure([String message = 'Email não foi verificado'])
      : super(message: message);
}

/// Falha de sessão expirada
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([String message = 'Sessão expirada, faça login novamente'])
      : super(message: message);
}

/// Falha de limite de tentativas excedido
class TooManyAttemptsFailure extends Failure {
  const TooManyAttemptsFailure([String message = 'Muitas tentativas de login. Tente novamente mais tarde'])
      : super(message: message);
}

/// Falha de token de reset inválido
class InvalidResetTokenFailure extends Failure {
  const InvalidResetTokenFailure([String message = 'Token de redefinição inválido ou expirado'])
      : super(message: message);
}

/// Falha de permissão negada
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([String message = 'Permissão negada para esta operação'])
      : super(message: message);
}

/// Falha de perfil incompleto
class IncompleteProfileFailure extends Failure {
  const IncompleteProfileFailure([String message = 'Perfil do usuário está incompleto'])
      : super(message: message);
}
