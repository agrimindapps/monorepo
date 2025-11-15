import 'dart:developer' as developer;
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/i_auth_provider.dart';

/// Provider de autenticação implementando IAuthProvider
///
/// **Implementação de:** IAuthProvider
///
/// **Responsabilidades:**
/// - Autenticação com Firebase Auth
/// - Gerenciar sessão do usuário
/// - Operações de login/logout
/// - Abstração de FirebaseAuth para o resto da aplicação
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas operações de autenticação
/// - Dependency Injection: FirebaseAuth injetado
/// - Interface Segregation: Implementa apenas IAuthProvider
/// - Dependency Inversion: Depende de abstração, não de implementação direta
///
/// **Exemplo:**
/// ```dart
/// final authProvider = FirebaseAuthProvider(firebaseAuth: FirebaseAuth.instance);
/// final result = await authProvider.loginWithEmail('user@example.com', 'password');
/// result.fold(
///   (failure) => print('Login failed: ${failure.message}'),
///   (user) => print('Logged in: ${user.email}'),
/// );
/// ```
class FirebaseAuthProvider implements IAuthProvider {
  FirebaseAuthProvider({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  /// Obtém usuário autenticado atual
  ///
  /// **Retorna:**
  /// - Right(UserEntity?): Usuário atual ou null se não autenticado
  /// - Left(failure): Erro ao obter usuário
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      developer.log(
        '🔍 Getting current user...',
        name: 'FirebaseAuth',
      );

      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        developer.log(
          'ℹ️ No user currently authenticated',
          name: 'FirebaseAuth',
        );
        return const Right(null);
      }

      final userEntity = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Usuario',
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );

      developer.log(
        '✅ Current user: ${firebaseUser.email}',
        name: 'FirebaseAuth',
      );

      return Right(userEntity);
    } catch (e) {
      developer.log(
        '❌ Error getting current user: $e',
        name: 'FirebaseAuth',
      );
      return Left(AuthFailure('Failed to get current user: $e'));
    }
  }

  /// Faz login com email/senha
  ///
  /// **Retorna:**
  /// - Right(UserEntity): Usuário autenticado
  /// - Left(failure): Erro ao fazer login
  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      developer.log(
        '🔐 Logging in with email: $email',
        name: 'FirebaseAuth',
      );

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        developer.log(
          '❌ Login returned null user',
          name: 'FirebaseAuth',
        );
        return Left(AuthFailure('Login failed: user is null'));
      }

      final userEntity = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Usuario',
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );

      developer.log(
        '✅ Logged in successfully: ${firebaseUser.email}',
        name: 'FirebaseAuth',
      );

      return Right(userEntity);
    } on FirebaseAuthException catch (e) {
      developer.log(
        '❌ Firebase auth error: ${e.code} - ${e.message}',
        name: 'FirebaseAuth',
      );
      final message = _mapFirebaseErrorToMessage(e.code);
      return Left(AuthFailure(message));
    } catch (e) {
      developer.log(
        '❌ Login exception: $e',
        name: 'FirebaseAuth',
      );
      return Left(AuthFailure('Login failed: $e'));
    }
  }

  /// Faz logout
  ///
  /// **Retorna:**
  /// - Right(null): Logout realizado com sucesso
  /// - Left(failure): Erro ao fazer logout
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      developer.log(
        '🚪 Logging out...',
        name: 'FirebaseAuth',
      );

      await _firebaseAuth.signOut();

      developer.log(
        '✅ Logged out successfully',
        name: 'FirebaseAuth',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Logout exception: $e',
        name: 'FirebaseAuth',
      );
      return Left(AuthFailure('Logout failed: $e'));
    }
  }

  /// Verifica se usuário está autenticado
  ///
  /// **Retorna:** true se autenticado, false caso contrário
  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = _firebaseAuth.currentUser;
      final authenticated = user != null;

      developer.log(
        authenticated ? '✅ User authenticated' : 'ℹ️ User not authenticated',
        name: 'FirebaseAuth',
      );

      return authenticated;
    } catch (e) {
      developer.log(
        '❌ Error checking authentication: $e',
        name: 'FirebaseAuth',
      );
      return false;
    }
  }

  /// Obtém ID do usuário atual
  ///
  /// **Retorna:**
  /// - Right(userId): ID do usuário autenticado
  /// - Left(failure): Erro ao obter ID ou não autenticado
  @override
  Future<Either<Failure, String>> getCurrentUserId() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        developer.log(
          'ℹ️ No user authenticated to get ID',
          name: 'FirebaseAuth',
        );
        return Left(AuthFailure('User not authenticated'));
      }

      developer.log(
        '✅ Current user ID: ${user.uid}',
        name: 'FirebaseAuth',
      );

      return Right(user.uid);
    } catch (e) {
      developer.log(
        '❌ Error getting user ID: $e',
        name: 'FirebaseAuth',
      );
      return Left(AuthFailure('Failed to get user ID: $e'));
    }
  }

  /// Mapeia códigos de erro Firebase para mensagens legíveis
  String _mapFirebaseErrorToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas de login. Tente novamente mais tarde';
      case 'email-already-in-use':
        return 'Email já cadastrado';
      case 'weak-password':
        return 'Senha muito fraca';
      default:
        return 'Erro na autenticação: $code';
    }
  }
}
