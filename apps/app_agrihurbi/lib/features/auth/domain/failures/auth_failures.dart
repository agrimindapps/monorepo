import 'package:core/core.dart';

/// Falhas específicas do domínio de autenticação
/// 
/// Seguindo padrão Clean Architecture para tratamento de erros específicos

/// Falha de credenciais inválidas
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    super.message = 'Email ou senha inválidos',
  ]);
}

/// Falha de email já em uso
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([
    super.message = 'Email já está em uso',
  ]);
}

/// Falha de usuário não encontrado
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([
    super.message = 'Usuário não encontrado',
  ]);
}

/// Falha de token expirado
class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure([
    super.message = 'Token de acesso expirado',
  ]);
}

/// Falha de token inválido
class InvalidTokenFailure extends Failure {
  const InvalidTokenFailure([
    super.message = 'Token de acesso inválido',
  ]);
}

/// Falha de usuário inativo
class InactiveUserFailure extends Failure {
  const InactiveUserFailure([
    super.message = 'Usuário está inativo',
  ]);
}

/// Falha de senha fraca
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([
    super.message = 'Senha não atende aos critérios de segurança',
  ]);
}

/// Falha de senha atual incorreta
class WrongPasswordFailure extends Failure {
  const WrongPasswordFailure([
    super.message = 'Senha atual incorreta',
  ]);
}

/// Falha de email não verificado
class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure([
    super.message = 'Email não foi verificado',
  ]);
}

/// Falha de sessão expirada
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([
    super.message = 'Sessão expirada, faça login novamente',
  ]);
}

/// Falha de limite de tentativas excedido
class TooManyAttemptsFailure extends Failure {
  const TooManyAttemptsFailure([
    super.message = 'Muitas tentativas de login. Tente novamente mais tarde',
  ]);
}

/// Falha de token de reset inválido
class InvalidResetTokenFailure extends Failure {
  const InvalidResetTokenFailure([
    super.message = 'Token de redefinição inválido ou expirado',
  ]);
}

/// Falha de permissão negada
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([
    super.message = 'Permissão negada para esta operação',
  ]);
}

/// Falha de perfil incompleto
class IncompleteProfileFailure extends Failure {
  const IncompleteProfileFailure([
    super.message = 'Perfil do usuário está incompleto',
  ]);
}