import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/entities/user_entity.dart' as core_entities;
import '../../../shared/utils/failure.dart';
import 'auth_mapper_service.dart';

/// Serviço especializado em gerenciamento de conta
///
/// Responsabilidades:
/// - Atualização de perfil (displayName, photoUrl)
/// - Atualização de email
/// - Atualização de senha
/// - Exclusão de conta
/// - Envio de verificação de email
/// - Envio de reset de senha
/// - Re-autenticação
class AuthAccountService {
  final FirebaseAuth _firebaseAuth;
  final AuthMapperService _mapper;

  AuthAccountService({
    required FirebaseAuth firebaseAuth,
    required AuthMapperService mapper,
  })  : _firebaseAuth = firebaseAuth,
        _mapper = mapper;

  /// Atualiza o perfil do usuário (displayName e/ou photoUrl)
  Future<Either<Failure, core_entities.UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;

      if (updatedUser == null) {
        return const Left(AuthFailure('Erro ao atualizar perfil'));
      }

      return Right(_mapper.mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Atualiza o email do usuário (envia verificação)
  Future<Either<Failure, core_entities.UserEntity>> updateEmail({
    required String newEmail,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      await user.verifyBeforeUpdateEmail(newEmail);
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;

      if (updatedUser == null) {
        return const Left(AuthFailure('Erro ao atualizar email'));
      }

      return Right(_mapper.mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Atualiza a senha do usuário (requer re-autenticação)
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Exclui a conta do usuário
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      await user.delete();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Envia email de verificação
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      await user.sendEmailVerification();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Envia email de reset de senha
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Re-autentica o usuário (necessário para operações sensíveis)
  Future<Either<Failure, void>> reauthenticate({
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }
}
