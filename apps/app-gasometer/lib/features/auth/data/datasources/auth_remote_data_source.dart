import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import 'firebase_error_handler.dart';
import 'firestore_user_repository.dart';
import 'user_converter.dart';

/// Interface para data source remoto de autenticação
///
/// Define contrato para operações de autenticação
/// Aplica ISP (Interface Segregation Principle)
abstract class AuthRemoteDataSource {
  Stream<UserEntity?> watchAuthState();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signInAnonymously();
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithApple();
  Future<UserEntity> signInWithFacebook();
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  );
  Future<UserEntity> updateProfile(String? displayName, String? photoUrl);
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String newPassword);
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserEntity> linkAnonymousWithEmail(String email, String password);
  Future<UserEntity> linkAnonymousWithGoogle();
  Future<UserEntity> linkAnonymousWithApple();
  Future<UserEntity> linkAnonymousWithFacebook();
  Future<void> signOut();
  Future<void> deleteAccount();
}

/// Implementação do data source remoto de autenticação
///
/// Responsabilidades (refatorado para SRP):
/// - Operações de autenticação via Firebase Auth
/// - Integração com core auth repository para social login
/// - Delegação de conversão para UserConverter
/// - Delegação de persistência Firestore para FirestoreUserRepository
/// - Delegação de tratamento de erros para FirebaseErrorHandler
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._coreAuthRepository,
    this._userConverter,
    this._firestoreUserRepository,
    this._errorHandler,
  );

  final FirebaseAuth _firebaseAuth;
  final IAuthRepository _coreAuthRepository;
  final UserConverter _userConverter;
  final FirestoreUserRepository _firestoreUserRepository;
  final FirebaseErrorHandler _errorHandler;

  @override
  Stream<UserEntity?> watchAuthState() {
    try {
      return _firebaseAuth.authStateChanges().map((user) {
        if (user == null) return null;
        return _userConverter.fromFirebaseUser(user);
      });
    } catch (e) {
      throw ServerException('Failed to watch auth state: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return _userConverter.fromFirebaseUser(user);
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _errorHandler.validateAuthResult(credential, 'sign in');
      final userModel = _userConverter.fromFirebaseUser(user);
      await _firestoreUserRepository.saveUser(userModel);

      return userModel;
    } catch (e) {
      _errorHandler.handleAuthError(e, 'sign in');
      rethrow; // Never reached, but needed for type safety
    }
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final user = _errorHandler.validateAuthResult(
        credential,
        'anonymous sign in',
      );
      return _userConverter.fromFirebaseUser(user);
    } catch (e) {
      _errorHandler.handleAuthError(e, 'anonymous sign in');
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var user = _errorHandler.validateAuthResult(credential, 'sign up');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
        user = _firebaseAuth.currentUser!;
      }

      final userModel = _userConverter.fromFirebaseUser(user);
      await _firestoreUserRepository.saveUser(userModel);

      return userModel;
    } catch (e) {
      _errorHandler.handleAuthError(e, 'sign up');
      rethrow;
    }
  }

  @override
  Future<UserEntity> updateProfile(
    String? displayName,
    String? photoUrl,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      _errorHandler.ensureUserAuthenticated(user, 'update profile');

      await user!.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      await user.reload();

      final updatedUser = _firebaseAuth.currentUser!;
      final userModel = _userConverter.fromFirebaseUser(updatedUser);
      await _firestoreUserRepository.saveUser(userModel);

      return userModel;
    } catch (e) {
      _errorHandler.handleAuthError(e, 'profile update');
      rethrow;
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _firebaseAuth.currentUser;
      _errorHandler.ensureUserAuthenticated(user, 'update email');
      await user!.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      _errorHandler.handleAuthError(e, 'email update');
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      _errorHandler.ensureUserAuthenticated(user, 'update password');
      await user!.updatePassword(newPassword);
    } catch (e) {
      _errorHandler.handleAuthError(e, 'password update');
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      _errorHandler.ensureUserAuthenticated(user, 'send email verification');
      await user!.sendEmailVerification();
    } catch (e) {
      _errorHandler.handleAuthError(e, 'email verification');
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _errorHandler.handleAuthError(e, 'password reset');
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return _handleSocialAuth(
      () => _coreAuthRepository.signInWithGoogle(),
      'Google Sign In',
    );
  }

  @override
  Future<UserEntity> signInWithApple() async {
    return _handleSocialAuth(
      () => _coreAuthRepository.signInWithApple(),
      'Apple Sign In',
    );
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    return _handleSocialAuth(
      () => _coreAuthRepository.signInWithFacebook(),
      'Facebook Sign In',
    );
  }

  @override
  Future<UserEntity> linkAnonymousWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || !user.isAnonymous) {
        throw const AuthenticationException('No anonymous user to link');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final userCredential = await user.linkWithCredential(credential);
      final linkedUser = _errorHandler.validateAuthResult(
        userCredential,
        'account linking',
      );

      final userModel = _userConverter.fromFirebaseUser(linkedUser);
      await _firestoreUserRepository.saveUser(userModel);

      return userModel;
    } catch (e) {
      _errorHandler.handleAuthError(e, 'account linking');
      rethrow;
    }
  }

  @override
  Future<UserEntity> linkAnonymousWithGoogle() async {
    return _handleSocialAuth(
      () => _coreAuthRepository.linkWithGoogle(),
      'Google linking',
    );
  }

  @override
  Future<UserEntity> linkAnonymousWithApple() async {
    return _handleSocialAuth(
      () => _coreAuthRepository.linkWithApple(),
      'Apple linking',
    );
  }

  @override
  Future<UserEntity> linkAnonymousWithFacebook() async {
    return _handleSocialAuth(
      () => _coreAuthRepository.linkWithFacebook(),
      'Facebook linking',
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Sign out failed: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      _errorHandler.ensureUserAuthenticated(user, 'delete account');

      await _firestoreUserRepository.deleteUser(user!.uid);
      await user.delete();
    } catch (e) {
      _errorHandler.handleAuthError(e, 'account deletion');
      rethrow;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - Reduzir código duplicado (DRY)
  // ============================================================================

  /// Helper method para autenticação social (Google, Apple, Facebook)
  /// Aplica Template Method Pattern para eliminar duplicação
  Future<UserEntity> _handleSocialAuth(
    Future<Either<Failure, UserEntity>> Function() authMethod,
    String operationName,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Gasometer: Attempting $operationName via core...');
      }

      final result = await authMethod();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ Gasometer: $operationName failed - ${failure.message}',
            );
          }
          throw AuthenticationException(failure.message);
        },
        (coreUser) async {
          if (kDebugMode) {
            debugPrint(
              '✅ Gasometer: $operationName successful, converting to app entity...',
            );
          }
          final appUser = _userConverter.fromCoreUserEntity(coreUser);
          await _firestoreUserRepository.saveUser(appUser);
          return appUser;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gasometer: Unexpected error in $operationName: $e');
      }
      if (e is AuthenticationException) rethrow;
      throw ServerException('Unexpected $operationName error: $e');
    }
  }
}
