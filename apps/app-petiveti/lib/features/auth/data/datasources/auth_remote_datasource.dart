import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart' as domain;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String? name);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithFacebook();
  Future<UserModel> signInAnonymously();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateProfile(String? name, String? photoUrl);
  Future<void> deleteAccount();
  Stream<UserModel?> watchAuthState();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const ServerException(message: 'Falha na autenticação');
      }
      await _updateLastLogin(credential.user!.uid);

      return await _createUserModelFromFirebaseUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String? name) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const ServerException(message: 'Falha na criação da conta');
      }
      if (name != null && name.isNotEmpty) {
        await credential.user!.updateDisplayName(name);
      }
      await credential.user!.sendEmailVerification();
      await _createUserDocument(credential.user!, name);

      return await _createUserModelFromFirebaseUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw const ServerException(message: 'Login com Google cancelado pelo usuário');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw const ServerException(message: 'Falha no login com Google');
      }
      await _createOrUpdateUserDocument(userCredential.user!);

      return await _createUserModelFromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro no login com Google: $e');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await firebaseAuth.signInWithCredential(oauthCredential);
      
      if (userCredential.user == null) {
        throw const ServerException(message: 'Falha no login com Apple');
      }
      await _createOrUpdateUserDocument(
        userCredential.user!,
        appleName: _getAppleName(appleCredential),
      );

      return await _createUserModelFromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro no login com Apple: $e');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        throw const ServerException(message: 'Login com Facebook cancelado ou falhou');
      }
      final facebookAuthCredential = firebase_auth.FacebookAuthProvider.credential(
        result.accessToken!.token,
      );
      final userCredential = await firebaseAuth.signInWithCredential(facebookAuthCredential);
      
      if (userCredential.user == null) {
        throw const ServerException(message: 'Falha no login com Facebook');
      }
      await _createOrUpdateUserDocument(userCredential.user!);

      return await _createUserModelFromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro no login com Facebook: $e');
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    try {
      final userCredential = await firebaseAuth.signInAnonymously();
      
      if (userCredential.user == null) {
        throw const ServerException(message: 'Falha no login anônimo');
      }
      await _createAnonymousUserDocument(userCredential.user!);

      return await _createUserModelFromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro no login anônimo: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      throw ServerException(message: 'Erro ao fazer logout: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return await _createUserModelFromFirebaseUser(firebaseUser);
    } catch (e) {
      throw ServerException(message: 'Erro ao obter usuário atual: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'Usuário não está logado');
      }

      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(String? name, String? photoUrl) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'Usuário não está logado');
      }
      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await _updateUserDocument(user.uid, name, photoUrl);

      await user.reload();
      final updatedUser = firebaseAuth.currentUser!;

      return await _createUserModelFromFirebaseUser(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException(message: 'Usuário não está logado');
      }
      await firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(message: _getAuthErrorMessage(e));
    } catch (e) {
      throw ServerException(message: 'Erro inesperado: $e');
    }
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _createUserModelFromFirebaseUser(firebaseUser);
    });
  }
  Future<UserModel> _createUserModelFromFirebaseUser(firebase_auth.User firebaseUser) async {
    try {
      final userDoc = await firestore.collection('users').doc(firebaseUser.uid).get();
      
      final now = DateTime.now();
      Map<String, dynamic>? firestoreData;
      
      if (userDoc.exists) {
        firestoreData = userDoc.data();
      }

      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        role: _parseUserRole(firestoreData?['role']),
        provider: _parseAuthProvider(firebaseUser.providerData),
        isEmailVerified: firebaseUser.emailVerified,
        isPremium: (firestoreData?['isPremium'] as bool?) ?? false,
        premiumExpiresAt: firestoreData?['premiumExpiresAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(firestoreData!['premiumExpiresAt'] as int)
            : null,
        metadata: firestoreData?['metadata'] as Map<String, dynamic>?,
        createdAt: firebaseUser.metadata.creationTime ?? now,
        updatedAt: now,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );
    } catch (e) {
      throw ServerException(message: 'Erro ao criar modelo do usuário: $e');
    }
  }

  Future<void> _createUserDocument(firebase_auth.User firebaseUser, String? name) async {
    try {
      final now = DateTime.now();
      await firestore.collection('users').doc(firebaseUser.uid).set({
        'email': firebaseUser.email,
        'name': name ?? firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
        'role': domain.UserRole.user.toString().split('.').last,
        'provider': _parseAuthProvider(firebaseUser.providerData).toString().split('.').last,
        'isEmailVerified': firebaseUser.emailVerified,
        'isPremium': false,
        'premiumExpiresAt': null,
        'metadata': <String, dynamic>{},
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'lastLoginAt': now.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw ServerException(message: 'Erro ao criar documento do usuário: $e');
    }
  }

  Future<void> _createOrUpdateUserDocument(
    firebase_auth.User firebaseUser, {
    String? appleName,
  }) async {
    try {
      final now = DateTime.now();
      final userDoc = firestore.collection('users').doc(firebaseUser.uid);
      final docSnapshot = await userDoc.get();
      
      if (docSnapshot.exists) {
        await userDoc.update({
          'lastLoginAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
        });
      } else {
        final displayName = appleName ?? firebaseUser.displayName;
        await userDoc.set({
          'email': firebaseUser.email,
          'name': displayName,
          'photoUrl': firebaseUser.photoURL,
          'role': domain.UserRole.user.toString().split('.').last,
          'provider': _parseAuthProvider(firebaseUser.providerData).toString().split('.').last,
          'isEmailVerified': firebaseUser.emailVerified,
          'isPremium': false,
          'premiumExpiresAt': null,
          'metadata': <String, dynamic>{},
          'createdAt': now.millisecondsSinceEpoch,
          'updatedAt': now.millisecondsSinceEpoch,
          'lastLoginAt': now.millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw ServerException(message: 'Erro ao criar/atualizar documento do usuário: $e');
    }
  }

  Future<void> _createAnonymousUserDocument(firebase_auth.User firebaseUser) async {
    try {
      final now = DateTime.now();
      await firestore.collection('users').doc(firebaseUser.uid).set({
        'email': 'anonymous@petiveti.com',
        'name': 'Usuário Anônimo',
        'photoUrl': null,
        'role': domain.UserRole.user.toString().split('.').last,
        'provider': domain.AuthProvider.anonymous.toString().split('.').last,
        'isEmailVerified': false,
        'isPremium': false,
        'premiumExpiresAt': null,
        'metadata': <String, dynamic>{
          'isAnonymous': true,
        },
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
        'lastLoginAt': now.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw ServerException(message: 'Erro ao criar documento do usuário anônimo: $e');
    }
  }

  Future<void> _updateUserDocument(String uid, String? name, String? photoUrl) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (name != null) {
        updates['name'] = name;
      }
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }

      await firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw ServerException(message: 'Erro ao atualizar documento do usuário: $e');
    }
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
    }
  }

  domain.UserRole _parseUserRole(dynamic role) {
    if (role == null) return domain.UserRole.user;
    
    try {
      return domain.UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.$role',
        orElse: () => domain.UserRole.user,
      );
    } catch (e) {
      return domain.UserRole.user;
    }
  }

  domain.AuthProvider _parseAuthProvider(List<firebase_auth.UserInfo> providerData) {
    if (providerData.isEmpty) return domain.AuthProvider.anonymous;

    final primaryProvider = providerData.first.providerId;
    switch (primaryProvider) {
      case 'google.com':
        return domain.AuthProvider.google;
      case 'apple.com':
        return domain.AuthProvider.apple;
      case 'facebook.com':
        return domain.AuthProvider.facebook;
      case 'firebase':
        return domain.AuthProvider.anonymous;
      default:
        return domain.AuthProvider.email;
    }
  }

  String? _getAppleName(AuthorizationCredentialAppleID appleCredential) {
    final givenName = appleCredential.givenName;
    final familyName = appleCredential.familyName;
    
    if (givenName != null && familyName != null) {
      return '$givenName $familyName';
    } else if (givenName != null) {
      return givenName;
    } else if (familyName != null) {
      return familyName;
    }
    return null;
  }

  String _getAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Conta desabilitada';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'email-already-in-use':
        return 'Este email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      case 'invalid-credential':
        return 'Credenciais inválidas';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este email usando outro provedor';
      case 'requires-recent-login':
        return 'Esta operação requer login recente. Faça login novamente';
      default:
        return e.message ?? 'Erro de autenticação desconhecido';
    }
  }
}
