import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart' as core_entities;
import '../../domain/repositories/i_auth_repository.dart';
import '../../shared/utils/failure.dart';

/// Implementação concreta do repositório de autenticação usando Firebase Auth
class FirebaseAuthService implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<core_entities.UserEntity?> get currentUser {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUserToEntity(user) : null;
    });
  }

  @override
  Future<bool> get isLoggedIn async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Falha na autenticação'));
      }

      return Right(_mapFirebaseUserToEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Falha na criação da conta'));
      }

      // Atualizar o nome de exibição
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        return const Left(AuthFailure('Erro ao atualizar perfil'));
      }

      return Right(_mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInWithGoogle() async {
    try {
      // TODO: Implementar Google Sign In
      // Requer google_sign_in package
      return const Left(AuthFailure('Login com Google não implementado ainda'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInWithApple() async {
    try {
      // TODO: Implementar Apple Sign In
      // Requer sign_in_with_apple package
      return const Left(AuthFailure('Login com Apple não implementado ainda'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();

      if (credential.user == null) {
        return const Left(AuthFailure('Falha no login anônimo'));
      }

      return Right(_mapFirebaseUserToEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
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

      return Right(_mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
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

      return Right(_mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Reautenticar antes de alterar senha
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      await user.delete();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      await user.sendEmailVerification();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
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
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> linkWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential = await user.linkWithCredential(credential);
      
      if (userCredential.user == null) {
        return const Left(AuthFailure('Erro ao vincular conta'));
      }

      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        return const Left(AuthFailure('Erro ao atualizar perfil'));
      }

      return Right(_mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> linkWithGoogle() async {
    try {
      // TODO: Implementar Google Sign In linking
      return const Left(AuthFailure('Vinculação com Google não implementada ainda'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> linkWithApple() async {
    try {
      // TODO: Implementar Apple Sign In linking
      return const Left(AuthFailure('Vinculação com Apple não implementada ainda'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Mapeia um User do Firebase para UserEntity
  core_entities.UserEntity _mapFirebaseUserToEntity(User firebaseUser) {
    return core_entities.UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'Usuário',
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      provider: _mapAuthProvider(firebaseUser.providerData),
      createdAt: firebaseUser.metadata.creationTime,
      updatedAt: DateTime.now(),
    );
  }

  /// Mapeia os provedores do Firebase para AuthProvider
  core_entities.AuthProvider _mapAuthProvider(List<UserInfo> providerData) {
    if (providerData.isEmpty) return core_entities.AuthProvider.anonymous;
    
    final providerId = providerData.first.providerId;
    switch (providerId) {
      case 'google.com':
        return core_entities.AuthProvider.google;
      case 'apple.com':
        return core_entities.AuthProvider.apple;
      case 'facebook.com':
        return core_entities.AuthProvider.facebook;
      case 'password':
      default:
        return core_entities.AuthProvider.email;
    }
  }

  /// Mapeia erros do FirebaseAuth para mensagens user-friendly
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email não encontrado. Verifique o email ou crie uma conta.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este email já está em uso. Faça login ou use outro email.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido. Verifique o formato do email.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada. Entre em contato com o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Operação não permitida. Entre em contato com o suporte.';
      case 'requires-recent-login':
        return 'Por segurança, faça login novamente para continuar.';
      case 'credential-already-in-use':
        return 'Esta conta já está vinculada a outro usuário.';
      default:
        return e.message ?? 'Erro de autenticação desconhecido.';
    }
  }
}