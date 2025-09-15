import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> watchAuthState();
  Future<UserModel?> getCurrentUser();
  
  // Sign In
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signInAnonymously();
  
  // Sign Up
  Future<UserModel> signUpWithEmail(String email, String password, String? displayName);
  
  // Profile Management
  Future<UserModel> updateProfile(String? displayName, String? photoUrl);
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String newPassword);
  Future<void> sendEmailVerification();
  
  // Password Reset
  Future<void> sendPasswordResetEmail(String email);
  
  // Account Conversion
  Future<UserModel> linkAnonymousWithEmail(String email, String password);
  
  // Sign Out
  Future<void> signOut();
  Future<void> deleteAccount();
  
  // Firestore user data
  Future<void> saveUserToFirestore(UserModel user);
  Future<UserModel?> getUserFromFirestore(String userId);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
  );

  @override
  Stream<UserModel?> watchAuthState() {
    try {
      return _firebaseAuth.authStateChanges().map((user) {
        if (user == null) return null;
        return UserModel.fromFirebaseUser(user);
      });
    } catch (e) {
      throw ServerException('Failed to watch auth state: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      
      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthenticationException('No user returned from sign in');
      }

      final userModel = UserModel.fromFirebaseUser(credential.user!);
      
      // Save/update user data in Firestore
      await saveUserToFirestore(userModel);
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 Firebase Auth Error - Code: ${e.code}, Message: ${e.message}');
      }
      
      // Handle specific Firebase Auth error codes
      switch (e.code) {
        case 'too-many-requests':
          if (kDebugMode) {
            debugPrint('🔥 Firebase rate limiting detected - too-many-requests');
          }
          throw AuthenticationException('FIREBASE BLOQUEIO: Muitas tentativas. Tente novamente mais tarde.');
        case 'user-disabled':
          throw AuthenticationException('Esta conta foi desabilitada.');
        case 'user-not-found':
          throw AuthenticationException('Email não encontrado.');
        case 'wrong-password':
          throw AuthenticationException('Senha incorreta.');
        case 'invalid-email':
          throw AuthenticationException('Email inválido.');
        case 'operation-not-allowed':
          throw AuthenticationException('Operação não permitida.');
        default:
          throw AuthenticationException('Erro de autenticação: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected sign in error: $e');
    }
  }


  @override
  Future<UserModel> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      
      if (userCredential.user == null) {
        throw const AuthenticationException('No user returned from anonymous sign in');
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Anonymous sign in failed: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected anonymous sign in error: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String? displayName) async {
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

      final userModel = UserModel.fromFirebaseUser(credential.user!);
      
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
  Future<UserModel> updateProfile(String? displayName, String? photoUrl) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      await user.reload();

      final updatedUser = _firebaseAuth.currentUser!;
      final userModel = UserModel.fromFirebaseUser(updatedUser);
      
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
  Future<UserModel> linkAnonymousWithEmail(String email, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || !user.isAnonymous) {
        throw const AuthenticationException('No anonymous user to link');
      }

      final credential = EmailAuthProvider.credential(email: email, password: password);
      final userCredential = await user.linkWithCredential(credential);
      
      if (userCredential.user == null) {
        throw const AuthenticationException('No user returned from linking');
      }

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);
      
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
  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to save user to Firestore: $e');
    }
  }

  @override
  Future<UserModel?> getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) return null;
      
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get user from Firestore: $e');
    }
  }
}