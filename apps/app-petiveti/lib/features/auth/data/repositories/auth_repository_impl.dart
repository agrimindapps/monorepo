import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> signInWithEmail(String email, String password) async {
    try {
      // Mock implementation - Replace with real authentication service
      await Future.delayed(const Duration(seconds: 1));
      
      if (email == 'test@example.com' && password == '123456') {
        final user = UserModel(
          id: 'user1',
          email: email,
          name: 'Usuário Teste',
          isEmailVerified: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await localDataSource.cacheUser(user);
        await localDataSource.storeToken('mock_token_123');
        
        return Right(user);
      } else {
        return Left(AuthFailure('Email ou senha incorretos'));
      }
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmail(String email, String password, String? name) async {
    try {
      // Mock implementation - Replace with real authentication service
      await Future.delayed(const Duration(seconds: 1));
      
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(user);
      await localDataSource.storeToken('mock_token_${user.id}');
      
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Erro ao criar conta: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      // Mock implementation - Replace with Google Sign-In
      await Future.delayed(const Duration(seconds: 2));
      
      final user = UserModel(
        id: 'google_user_1',
        email: 'usuario@gmail.com',
        name: 'Usuário Google',
        photoUrl: 'https://lh3.googleusercontent.com/a/default-user',
        provider: AuthProvider.google,
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(user);
      await localDataSource.storeToken('google_token_123');
      
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login com Google: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      // Mock implementation - Replace with Apple Sign-In
      await Future.delayed(const Duration(seconds: 2));
      
      final user = UserModel(
        id: 'apple_user_1',
        email: 'usuario@privaterelay.appleid.com',
        name: 'Usuário Apple',
        provider: AuthProvider.apple,
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(user);
      await localDataSource.storeToken('apple_token_123');
      
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login com Apple: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    try {
      // Mock implementation - Replace with Facebook Login
      await Future.delayed(const Duration(seconds: 2));
      
      final user = UserModel(
        id: 'facebook_user_1',
        email: 'usuario@facebook.com',
        name: 'Usuário Facebook',
        photoUrl: 'https://graph.facebook.com/123456789/picture',
        provider: AuthProvider.facebook,
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(user);
      await localDataSource.storeToken('facebook_token_123');
      
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login com Facebook: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      return Right(cachedUser);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar usuário: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      // Mock implementation - Replace with real email verification
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao enviar verificação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      // Mock implementation - Replace with real password reset
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao enviar reset de senha: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(String? name, String? photoUrl) async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser == null) {
        return Left(AuthFailure('Usuário não encontrado'));
      }
      
      final updatedUser = cachedUser.copyWith(
        name: name ?? cachedUser.name,
        photoUrl: photoUrl ?? cachedUser.photoUrl,
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(updatedUser);
      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure('Erro ao atualizar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao deletar conta: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, User?>> watchAuthState() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return getCurrentUser();
    }).asyncMap((future) => future);
  }
}