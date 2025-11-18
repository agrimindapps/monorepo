import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/entities/user_entity.dart' as core_entities;
import '../../domain/repositories/i_auth_repository.dart';
import '../../shared/utils/failure.dart';

/// Implementação concreta do repositório de autenticação usando Firebase Auth
///
/// Fornece métodos para autenticação via:
/// - Email e senha
/// - Google Sign In
/// - Apple Sign In
/// - Facebook Login
/// - Login anônimo
///
/// Também suporta vinculação de contas e gerenciamento de perfil.
class FirebaseAuthService implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final FacebookAuth _facebookAuth;

  /// Cria uma nova instância do serviço de autenticação Firebase
  ///
  /// Parâmetros opcionais permitem injeção de dependências para testes.
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       // Não inicializa GoogleSignIn na web sem configuração explícita
       _googleSignIn = googleSignIn ?? (kIsWeb ? null : GoogleSignIn(scopes: ['email'])),
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

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
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting Google Sign In...');
      }

      // 🔥 FIX: Verifica se Google Sign-In está disponível
      if (_googleSignIn == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Google Sign-In not configured');
        }
        return Left(AuthFailure('Google Sign-In não está configurado para esta plataforma'));
      }

      // 🔥 FIX: Previne "Future already completed" na Web
      // Limpa estado anterior antes de nova tentativa
      if (kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {
          // Ignora erro de signOut (pode não estar logado)
        }
      }

      // 🔥 FIX: Adiciona timeout para prevenir Future travado
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signIn()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('⏱️ Firebase: Google Sign In timeout');
              }
              return null;
            },
          );

      if (googleUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Google Sign In canceled by user');
        }
        return const Left(AuthFailure('Login cancelado pelo usuário'));
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 Firebase: Google user obtained, getting authentication...',
        );
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: Missing Google auth tokens');
        }
        return const Left(AuthFailure('Falha ao obter credenciais do Google'));
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Signing in with Google credential...');
      }
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: User is null after sign in');
        }
        return const Left(AuthFailure('Falha no login com Google'));
      }

      if (kDebugMode) {
        debugPrint(
          '✅ Firebase: Google Sign In successful - User: ${userCredential.user!.uid}',
        );
      }

      return Right(_mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}',
        );
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } on StateError catch (e) {
      // 🔥 FIX: Captura especificamente "Bad state: Future already completed"
      if (e.message.contains('Future already completed')) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Firebase: Future already completed - Google Sign In plugin state issue',
          );
          debugPrint('💡 Usuário deve tentar novamente (estado foi resetado)');
        }
        return const Left(
          AuthFailure('Estado inválido do login. Tente novamente.'),
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Google Sign In: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado no login com Google: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInWithApple() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting Apple Sign In...');
      }
      if (!await SignInWithApple.isAvailable()) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: Apple Sign In not available on this device');
        }
        return const Left(
          AuthFailure('Login com Apple não disponível neste dispositivo'),
        );
      }
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: kIsWeb
            ? WebAuthenticationOptions(
                clientId: 'your.bundle.id',
                redirectUri: Uri.parse(
                  'https://your-project.firebaseapp.com/__/auth/handler',
                ),
              )
            : null,
      );

      if (kDebugMode) {
        debugPrint(
          '🔄 Firebase: Apple credential obtained, creating Firebase credential...',
        );
      }
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Signing in with Apple credential...');
      }
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: User is null after sign in');
        }
        return const Left(AuthFailure('Falha no login com Apple'));
      }
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty &&
            userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(displayName);
          if (kDebugMode) {
            debugPrint('✅ Firebase: Updated display name to: $displayName');
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          '✅ Firebase: Apple Sign In successful - User: ${userCredential.user!.uid}',
        );
      }

      return Right(_mapFirebaseUserToEntity(userCredential.user!));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: SignInWithAppleAuthorizationException - ${e.code}: ${e.message}',
        );
      }
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return const Left(AuthFailure('Login com Apple cancelado'));
        case AuthorizationErrorCode.failed:
          return const Left(AuthFailure('Falha na autenticação com Apple'));
        case AuthorizationErrorCode.invalidResponse:
          return const Left(AuthFailure('Resposta inválida do Apple Sign In'));
        case AuthorizationErrorCode.notHandled:
          return const Left(AuthFailure('Solicitação não processada'));
        case AuthorizationErrorCode.notInteractive:
          return const Left(
            AuthFailure('Autenticação não interativa não suportada'),
          );
        case AuthorizationErrorCode.unknown:
          return Left(
            AuthFailure('Erro desconhecido no login com Apple: ${e.message}'),
          );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}',
        );
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Apple Sign In: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado no login com Apple: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInAnonymously() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting anonymous sign in...');
      }
      final credential = await _firebaseAuth.signInAnonymously();
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Credential received successfully');
      }

      if (credential.user == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: credential.user is null');
        }
        return const Left(AuthFailure('Falha no login anônimo'));
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Anonymous login successful');
      }
      return Right(_mapFirebaseUserToEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - code: ${e.code}');
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: General error occurred');
      }
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> signInWithFacebook() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting Facebook Sign In...');
      }
      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success) {
        if (kDebugMode) {
          debugPrint(
            '❌ Firebase: Facebook login failed with status: ${result.status}',
          );
        }

        switch (result.status) {
          case LoginStatus.cancelled:
            return const Left(AuthFailure('Login com Facebook cancelado'));
          case LoginStatus.failed:
            return Left(
              AuthFailure('Falha no login com Facebook: ${result.message}'),
            );
          case LoginStatus.operationInProgress:
            return const Left(AuthFailure('Operação de login já em andamento'));
          default:
            return Left(
              AuthFailure(
                'Erro desconhecido no login com Facebook: ${result.message}',
              ),
            );
        }
      }

      if (result.accessToken == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: Facebook access token is null');
        }
        return const Left(
          AuthFailure('Falha ao obter token de acesso do Facebook'),
        );
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 Firebase: Facebook token obtained, creating Firebase credential...',
        );
      }
      final OAuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Signing in with Facebook credential...');
      }
      final userCredential = await _firebaseAuth.signInWithCredential(
        facebookCredential,
      );

      if (userCredential.user == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: User is null after sign in');
        }
        return const Left(AuthFailure('Falha no login com Facebook'));
      }

      if (kDebugMode) {
        debugPrint(
          '✅ Firebase: Facebook Sign In successful - User: ${userCredential.user!.uid}',
        );
      }

      return Right(_mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}',
        );
      }
      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Facebook Sign In: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado no login com Facebook: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Signing out from all providers...');
      }
      await _firebaseAuth.signOut();
      try {
        await _googleSignIn?.signOut();
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Firebase: Google sign out error (may not be signed in): $e',
          );
        }
      }

      try {
        await _facebookAuth.logOut();
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Firebase: Facebook sign out error (may not be signed in): $e',
          );
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Sign out successful from all providers');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Error during sign out: $e');
      }
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
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting to link account with Google...');
      }

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }
      final isLinked = user.providerData.any(
        (info) => info.providerId == 'google.com',
      );
      if (isLinked) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Account already linked with Google');
        }
        return const Left(AuthFailure('Conta já vinculada com Google'));
      }
      // 🔥 FIX: Verifica se Google Sign-In está disponível
      if (_googleSignIn == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Google Sign-In not configured');
        }
        return Left(AuthFailure('Google Sign-In não está configurado para esta plataforma'));
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Google Sign In canceled by user');
        }
        return const Left(AuthFailure('Vinculação cancelada pelo usuário'));
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return const Left(AuthFailure('Falha ao obter credenciais do Google'));
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Linking account with Google credential...');
      }
      final userCredential = await user.linkWithCredential(credential);

      if (userCredential.user == null) {
        return const Left(AuthFailure('Erro ao vincular conta com Google'));
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Account successfully linked with Google');
      }

      return Right(_mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}',
        );
      }
      if (e.code == 'credential-already-in-use') {
        return const Left(
          AuthFailure('Esta conta Google já está em uso por outro usuário'),
        );
      } else if (e.code == 'email-already-in-use') {
        return const Left(
          AuthFailure('O email desta conta Google já está em uso'),
        );
      } else if (e.code == 'provider-already-linked') {
        return const Left(AuthFailure('Conta já vinculada com Google'));
      }

      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Google linking: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado ao vincular com Google: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> linkWithApple() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting to link account with Apple...');
      }

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }
      final isLinked = user.providerData.any(
        (info) => info.providerId == 'apple.com',
      );
      if (isLinked) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Account already linked with Apple');
        }
        return const Left(AuthFailure('Conta já vinculada com Apple'));
      }
      if (!await SignInWithApple.isAvailable()) {
        return const Left(
          AuthFailure('Login com Apple não disponível neste dispositivo'),
        );
      }
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: kIsWeb
            ? WebAuthenticationOptions(
                clientId: 'your.bundle.id',
                redirectUri: Uri.parse(
                  'https://your-project.firebaseapp.com/__/auth/handler',
                ),
              )
            : null,
      );
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Linking account with Apple credential...');
      }
      final userCredential = await user.linkWithCredential(credential);

      if (userCredential.user == null) {
        return const Left(AuthFailure('Erro ao vincular conta com Apple'));
      }
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty &&
            userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Account successfully linked with Apple');
      }

      return Right(_mapFirebaseUserToEntity(userCredential.user!));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: SignInWithAppleAuthorizationException - ${e.code}: ${e.message}',
        );
      }

      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left(AuthFailure('Vinculação com Apple cancelada'));
      }
      return Left(AuthFailure('Erro ao vincular com Apple: ${e.message}'));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}',
        );
      }
      if (e.code == 'credential-already-in-use') {
        return const Left(
          AuthFailure('Esta conta Apple já está em uso por outro usuário'),
        );
      } else if (e.code == 'email-already-in-use') {
        return const Left(
          AuthFailure('O email desta conta Apple já está em uso'),
        );
      } else if (e.code == 'provider-already-linked') {
        return const Left(AuthFailure('Conta já vinculada com Apple'));
      }

      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Apple linking: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado ao vincular com Apple: $e'));
    }
  }

  @override
  Future<Either<Failure, core_entities.UserEntity>> linkWithFacebook() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting to link account with Facebook...');
      }

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }
      final isLinked = user.providerData.any(
        (info) => info.providerId == 'facebook.com',
      );
      if (isLinked) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Account already linked with Facebook');
        }
        return const Left(AuthFailure('Conta já vinculada com Facebook'));
      }
      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success) {
        if (result.status == LoginStatus.cancelled) {
          return const Left(AuthFailure('Vinculação com Facebook cancelada'));
        }
        return Left(
          AuthFailure('Falha ao vincular com Facebook: ${result.message}'),
        );
      }

      if (result.accessToken == null) {
        return const Left(
          AuthFailure('Falha ao obter token de acesso do Facebook'),
        );
      }
      final OAuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Linking account with Facebook credential...');
      }
      final userCredential = await user.linkWithCredential(facebookCredential);

      if (userCredential.user == null) {
        return const Left(AuthFailure('Erro ao vincular conta com Facebook'));
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Account successfully linked with Facebook');
      }

      return Right(_mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}',
        );
      }
      if (e.code == 'credential-already-in-use') {
        return const Left(
          AuthFailure('Esta conta Facebook já está em uso por outro usuário'),
        );
      } else if (e.code == 'email-already-in-use') {
        return const Left(
          AuthFailure('O email desta conta Facebook já está em uso'),
        );
      } else if (e.code == 'provider-already-linked') {
        return const Left(AuthFailure('Conta já vinculada com Facebook'));
      }

      return Left(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Facebook linking: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado ao vincular com Facebook: $e'));
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
      case 'invalid-credential':
        return 'Email ou senha incorretos. Verifique suas credenciais e tente novamente.';
      default:
        return e.message ?? 'Erro de autenticação desconhecido.';
    }
  }
}
