import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/extensions/user_entity_gasometer_extension.dart';

abstract class AuthRemoteDataSource {
  Stream<UserEntity?> watchAuthState();
  Future<UserEntity?> getCurrentUser();

  // Sign In
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signInAnonymously();
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithApple();
  Future<UserEntity> signInWithFacebook();

  // Sign Up
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  );

  // Profile Management
  Future<UserEntity> updateProfile(String? displayName, String? photoUrl);
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String newPassword);
  Future<void> sendEmailVerification();

  // Password Reset
  Future<void> sendPasswordResetEmail(String email);

  // Account Conversion
  Future<UserEntity> linkAnonymousWithEmail(String email, String password);
  Future<UserEntity> linkAnonymousWithGoogle();
  Future<UserEntity> linkAnonymousWithApple();
  Future<UserEntity> linkAnonymousWithFacebook();

  // Sign Out
  Future<void> signOut();
  Future<void> deleteAccount();

  // Firestore user data
  Future<void> saveUserToFirestore(UserEntity user);
  Future<UserEntity?> getUserFromFirestore(String userId);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
    this._coreAuthRepository,
  );
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final IAuthRepository _coreAuthRepository;

  @override
  Stream<UserEntity?> watchAuthState() {
    try {
      return _firebaseAuth.authStateChanges().map((user) {
        if (user == null) return null;
        return UserEntityGasometerExtension.fromFirebaseUser(user);
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

      return UserEntityGasometerExtension.fromFirebaseUser(user);
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

      if (credential.user == null) {
        throw const AuthenticationException('No user returned from sign in');
      }

      final userModel = UserEntityGasometerExtension.fromFirebaseUser(
        credential.user!,
      );

      // Save/update user data in Firestore
      await saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '🔥 Firebase Auth Error - Code: ${e.code}, Message: ${e.message}',
        );
      }

      // Handle specific Firebase Auth error codes
      switch (e.code) {
        case 'too-many-requests':
          if (kDebugMode) {
            debugPrint(
              '🔥 Firebase rate limiting detected - too-many-requests',
            );
          }
          throw const AuthenticationException(
            'FIREBASE BLOQUEIO: Muitas tentativas. Tente novamente mais tarde.',
          );
        case 'user-disabled':
          throw const AuthenticationException('Esta conta foi desabilitada.');
        case 'user-not-found':
          throw const AuthenticationException('Email não encontrado.');
        case 'wrong-password':
          throw const AuthenticationException('Senha incorreta.');
        case 'invalid-email':
          throw const AuthenticationException('Email inválido.');
        case 'operation-not-allowed':
          throw const AuthenticationException('Operação não permitida.');
        default:
          throw AuthenticationException('Erro de autenticação: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected sign in error: $e');
    }
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();

      if (userCredential.user == null) {
        throw const AuthenticationException(
          'No user returned from anonymous sign in',
        );
      }

      return UserEntityGasometerExtension.fromFirebaseUser(
        userCredential.user!,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Anonymous sign in failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected anonymous sign in error: $e');
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

      if (credential.user == null) {
        throw const AuthenticationException('No user returned from sign up');
      }

      // Update display name if provided
      if (displayName != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      final userModel = UserEntityGasometerExtension.fromFirebaseUser(
        credential.user!,
      );

      // Save user data in Firestore
      await saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Sign up failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected sign up error: $e');
    }
  }

  @override
  Future<UserEntity> updateProfile(
    String? displayName,
    String? photoUrl,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      await user.reload();

      final updatedUser = _firebaseAuth.currentUser!;
      final userModel = UserEntityGasometerExtension.fromFirebaseUser(
        updatedUser,
      );

      // Update user data in Firestore
      await saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Profile update failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected profile update error: $e');
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Email update failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected email update error: $e');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Password update failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected password update error: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Email verification failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected email verification error: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Password reset failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected password reset error: $e');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Gasometer: Attempting Google Sign In via core...');
      }

      final result = await _coreAuthRepository.signInWithGoogle();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Gasometer: Google Sign In failed - ${failure.message}');
          }
          throw AuthenticationException(failure.message);
        },
        (coreUser) async {
          if (kDebugMode) {
            debugPrint('✅ Gasometer: Google Sign In successful, converting to app entity...');
          }

          // Convert core UserEntity to app UserEntity and save to Firestore
          final appUser = UserEntityGasometerExtension.fromCoreUserEntity(coreUser);
          await saveUserToFirestore(appUser);

          return appUser;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gasometer: Unexpected error in Google Sign In: $e');
      }
      throw ServerException('Unexpected Google Sign In error: $e');
    }
  }

  @override
  Future<UserEntity> signInWithApple() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Gasometer: Attempting Apple Sign In via core...');
      }

      final result = await _coreAuthRepository.signInWithApple();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Gasometer: Apple Sign In failed - ${failure.message}');
          }
          throw AuthenticationException(failure.message);
        },
        (coreUser) async {
          if (kDebugMode) {
            debugPrint('✅ Gasometer: Apple Sign In successful, converting to app entity...');
          }

          // Convert core UserEntity to app UserEntity and save to Firestore
          final appUser = UserEntityGasometerExtension.fromCoreUserEntity(coreUser);
          await saveUserToFirestore(appUser);

          return appUser;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gasometer: Unexpected error in Apple Sign In: $e');
      }
      throw ServerException('Unexpected Apple Sign In error: $e');
    }
  }

  @override
  Future<UserEntity> signInWithFacebook() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Gasometer: Attempting Facebook Sign In via core...');
      }

      final result = await _coreAuthRepository.signInWithFacebook();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Gasometer: Facebook Sign In failed - ${failure.message}');
          }
          throw AuthenticationException(failure.message);
        },
        (coreUser) async {
          if (kDebugMode) {
            debugPrint('✅ Gasometer: Facebook Sign In successful, converting to app entity...');
          }

          // Convert core UserEntity to app UserEntity and save to Firestore
          final appUser = UserEntityGasometerExtension.fromCoreUserEntity(coreUser);
          await saveUserToFirestore(appUser);

          return appUser;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gasometer: Unexpected error in Facebook Sign In: $e');
      }
      throw ServerException('Unexpected Facebook Sign In error: $e');
    }
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

      if (userCredential.user == null) {
        throw const AuthenticationException('No user returned from linking');
      }

      final userModel = UserEntityGasometerExtension.fromFirebaseUser(
        userCredential.user!,
      );

      // Save user data in Firestore
      await saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Account linking failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected account linking error: $e');
    }
  }

  @override
  Future<UserEntity> linkAnonymousWithGoogle() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Gasometer: Attempting to link anonymous account with Google...');
      }

      final result = await _coreAuthRepository.linkWithGoogle();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Gasometer: Google account linking failed - ${failure.message}');
          }
          throw AuthenticationException(failure.message);
        },
        (coreUser) async {
          if (kDebugMode) {
            debugPrint('✅ Gasometer: Google account linking successful, converting to app entity...');
          }

          // Convert core UserEntity to app UserEntity and save to Firestore
          final appUser = UserEntityGasometerExtension.fromCoreUserEntity(coreUser);
          await saveUserToFirestore(appUser);

          return appUser;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gasometer: Unexpected error linking with Google: $e');
      }
      throw ServerException('Unexpected Google linking error: $e');
    }
  }

  @override
  Future<UserEntity> linkAnonymousWithApple() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Gasometer: Attempting to link anonymous account with Apple...');
      }

      final result = await _coreAuthRepository.linkWithApple();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Gasometer: Apple account linking failed - ${failure.message}');
          }
          throw AuthenticationException(failure.message);
        },
        (coreUser) async {
          if (kDebugMode) {
            debugPrint('✅ Gasometer: Apple account linking successful, converting to app entity...');
          }

          // Convert core UserEntity to app UserEntity and save to Firestore
          final appUser = UserEntityGasometerExtension.fromCoreUserEntity(coreUser);
          await saveUserToFirestore(appUser);

          return appUser;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gasometer: Unexpected error linking with Apple: $e');
      }
      throw ServerException('Unexpected Apple linking error: $e');
    }
  }

  @override
  Future<UserEntity> linkAnonymousWithFacebook() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Gasometer: Attempting to link anonymous account with Facebook...');
      }

      final result = await _coreAuthRepository.linkWithFacebook();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Gasometer: Facebook account linking failed - ${failure.message}');
          }
          throw AuthenticationException(failure.message);
        },
        (coreUser) async {
          if (kDebugMode) {
            debugPrint('✅ Gasometer: Facebook account linking successful, converting to app entity...');
          }

          // Convert core UserEntity to app UserEntity and save to Firestore
          final appUser = UserEntityGasometerExtension.fromCoreUserEntity(coreUser);
          await saveUserToFirestore(appUser);

          return appUser;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Gasometer: Unexpected error linking with Facebook: $e');
      }
      throw ServerException('Unexpected Facebook linking error: $e');
    }
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
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      // Delete user data from Firestore first
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete the user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Account deletion failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected account deletion error: $e');
    }
  }

  @override
  Future<void> saveUserToFirestore(UserEntity user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toGasometerFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to save user to Firestore: $e');
    }
  }

  @override
  Future<UserEntity?> getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      return UserEntityGasometerExtension.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get user from Firestore: $e');
    }
  }
}
