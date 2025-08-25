import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/user_entity.dart';

/// Interface do repositório de autenticação
/// Define os contratos para operações de autenticação via Firebase
abstract class IAuthRepository {
  /// Retorna o usuário atualmente logado, se houver
  Stream<UserEntity?> get currentUser;

  /// Verifica se existe um usuário logado
  Future<bool> get isLoggedIn;

  /// Faz login com email e senha
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registra um novo usuário com email e senha
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Faz login com Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Faz login com Apple
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Faz login anônimo
  Future<Either<Failure, UserEntity>> signInAnonymously();

  /// Faz logout do usuário atual
  Future<Either<Failure, void>> signOut();

  /// Envia email de redefinição de senha
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Atualiza o perfil do usuário
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Atualiza o email do usuário
  Future<Either<Failure, UserEntity>> updateEmail({
    required String newEmail,
  });

  /// Atualiza a senha do usuário
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Deleta a conta do usuário
  Future<Either<Failure, void>> deleteAccount();

  /// Envia email de verificação
  Future<Either<Failure, void>> sendEmailVerification();

  /// Reautentica o usuário com a senha atual
  Future<Either<Failure, void>> reauthenticate({
    required String password,
  });

  /// Converte um usuário anônimo em conta permanente
  Future<Either<Failure, UserEntity>> linkWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Vincula conta com Google
  Future<Either<Failure, UserEntity>> linkWithGoogle();

  /// Vincula conta com Apple
  Future<Either<Failure, UserEntity>> linkWithApple();
}