import 'package:core/core.dart';

import '../entities/user_entity.dart' as local_user;

/// Repository abstrato para operações de autenticação com Clean Architecture
///
/// Define contratos para todas as operações relacionadas à autenticação,
/// seguindo princípios de local-first com fallback para remote
abstract class AuthRepository {
  /// Autentica usuário com email e senha
  ///
  /// Retorna [local_user.UserEntity] em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, local_user.UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registra novo usuário no sistema
  ///
  /// Retorna [local_user.UserEntity] criado em caso de sucesso ou [Failure] em caso de erro
  Future<Either<Failure, local_user.UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Cria sessão anônima (guest user)
  ///
  /// Permite uso do app sem registro, com possibilidade de vincular conta depois
  Future<Either<Failure, local_user.UserEntity>> signInAnonymously();

  /// Vincula conta anônima com email/senha
  ///
  /// Converte usuário anônimo em usuário registrado permanente
  Future<Either<Failure, local_user.UserEntity>> linkAnonymousWithEmail({
    required String name,
    required String email,
    required String password,
  });

  /// Encerra sessão do usuário atual
  ///
  /// Limpa dados locais e invalida tokens
  Future<Either<Failure, void>> logout();

  /// Obtém usuário atualmente logado
  ///
  /// Retorna [local_user.UserEntity] se logado, null se não logado, ou [Failure] em caso de erro
  Future<Either<Failure, local_user.UserEntity?>> getCurrentUser();

  /// Atualiza dados do usuário (refresh)
  ///
  /// Sincroniza dados locais com servidor se possível
  Future<Either<Failure, local_user.UserEntity>> refreshUser({
    required String userId,
  });

  /// Verifica se há usuário logado
  ///
  Future<bool> isLoggedIn();

  /// Atualiza perfil do usuário
  ///
  /// Modifica dados do perfil mantendo consistência local-remote
  Future<Either<Failure, local_user.UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  });

  /// Altera senha do usuário
  ///
  /// Valida senha atual e aplica nova senha com segurança
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Solicita redefinição de senha
  ///
  /// Envia email de recuperação para o endereço fornecido
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Redefine senha usando token de recuperação
  ///
  /// Aplica nova senha usando token recebido por email
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Verifica se email já está em uso
  ///
  /// Útil para validação durante registro
  Future<Either<Failure, bool>> isEmailTaken({required String email});

  /// Obtém token de acesso atual
  ///
  /// Para integrações que necessitam do token
  Future<Either<Failure, String?>> getAccessToken();

  /// Atualiza token de acesso
  ///
  /// Renova token usando refresh token armazenado
  Future<Either<Failure, String>> refreshAccessToken();
}
