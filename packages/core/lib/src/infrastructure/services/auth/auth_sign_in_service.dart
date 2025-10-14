import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../domain/entities/user_entity.dart' as core_entities;
import '../../../shared/utils/failure.dart';
import 'auth_mapper_service.dart';

/// Serviço especializado em operações de sign-in/sign-up
///
/// Responsabilidades:
/// - Sign-in com email/password, Google, Apple, Facebook
/// - Sign-up com email/password
/// - Login anônimo
/// - Sign-out de todos os provedores
class AuthSignInService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final AuthMapperService _mapper;

  AuthSignInService({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
    required AuthMapperService mapper,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _facebookAuth = facebookAuth,
        _mapper = mapper;

  /// Sign-in com email e senha
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

      return Right(_mapper.mapFirebaseUserToEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Sign-up com email e senha
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

      return Right(_mapper.mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Sign-in com Google
  Future<Either<Failure, core_entities.UserEntity>> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting Google Sign In...');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Google Sign In canceled by user');
        }
        return const Left(AuthFailure('Login cancelado pelo usuário'));
      }

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Google user obtained, getting authentication...');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: User is null after sign in');
        }
        return const Left(AuthFailure('Falha no login com Google'));
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Google Sign In successful - User: ${userCredential.user!.uid}');
      }

      return Right(_mapper.mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}');
      }
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Google Sign In: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado no login com Google: $e'));
    }
  }

  /// Sign-in com Apple
  Future<Either<Failure, core_entities.UserEntity>> signInWithApple() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting Apple Sign In...');
      }

      if (!await SignInWithApple.isAvailable()) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: Apple Sign In not available on this device');
        }
        return const Left(AuthFailure('Login com Apple não disponível neste dispositivo'));
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: kIsWeb
            ? WebAuthenticationOptions(
                clientId: 'your.bundle.id',
                redirectUri: Uri.parse('https://your-project.firebaseapp.com/__/auth/handler'),
              )
            : null,
      );

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Apple credential obtained, creating Firebase credential...');
      }

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Signing in with Apple credential...');
      }

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: User is null after sign in');
        }
        return const Left(AuthFailure('Falha no login com Apple'));
      }

      // Update display name if available
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty && userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(displayName);
          if (kDebugMode) {
            debugPrint('✅ Firebase: Updated display name to: $displayName');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Apple Sign In successful - User: ${userCredential.user!.uid}');
      }

      return Right(_mapper.mapFirebaseUserToEntity(userCredential.user!));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: SignInWithAppleAuthorizationException - ${e.code}: ${e.message}');
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
          return const Left(AuthFailure('Autenticação não interativa não suportada'));
        case AuthorizationErrorCode.unknown:
          return Left(AuthFailure('Erro desconhecido no login com Apple: ${e.message}'));
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}');
      }
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Apple Sign In: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado no login com Apple: $e'));
    }
  }

  /// Sign-in com Facebook
  Future<Either<Failure, core_entities.UserEntity>> signInWithFacebook() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting Facebook Sign In...');
      }

      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: Facebook login failed with status: ${result.status}');
        }

        switch (result.status) {
          case LoginStatus.cancelled:
            return const Left(AuthFailure('Login com Facebook cancelado'));
          case LoginStatus.failed:
            return Left(AuthFailure('Falha no login com Facebook: ${result.message}'));
          case LoginStatus.operationInProgress:
            return const Left(AuthFailure('Operação de login já em andamento'));
          default:
            return Left(AuthFailure('Erro desconhecido no login com Facebook: ${result.message}'));
        }
      }

      if (result.accessToken == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: Facebook access token is null');
        }
        return const Left(AuthFailure('Falha ao obter token de acesso do Facebook'));
      }

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Facebook token obtained, creating Firebase credential...');
      }

      final OAuthCredential facebookCredential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

      if (kDebugMode) {
        debugPrint('🔄 Firebase: Signing in with Facebook credential...');
      }

      final userCredential = await _firebaseAuth.signInWithCredential(facebookCredential);

      if (userCredential.user == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: User is null after sign in');
        }
        return const Left(AuthFailure('Falha no login com Facebook'));
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Facebook Sign In successful - User: ${userCredential.user!.uid}');
      }

      return Right(_mapper.mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}');
      }
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Facebook Sign In: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado no login com Facebook: $e'));
    }
  }

  /// Sign-in anônimo
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

      return Right(_mapper.mapFirebaseUserToEntity(credential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - code: ${e.code}');
      }
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: General error occurred');
      }
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Sign-out de todos os provedores
  Future<Either<Failure, void>> signOut() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Signing out from all providers...');
      }

      await _firebaseAuth.signOut();

      // Try to sign out from Google (may not be signed in)
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Google sign out error (may not be signed in): $e');
        }
      }

      // Try to sign out from Facebook (may not be signed in)
      try {
        await _facebookAuth.logOut();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Facebook sign out error (may not be signed in): $e');
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

  /// Stream com o usuário atual
  Stream<core_entities.UserEntity?> get currentUserStream {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapper.mapFirebaseUserToEntity(user) : null;
    });
  }

  /// Verifica se está logado
  Future<bool> get isLoggedIn async {
    return _firebaseAuth.currentUser != null;
  }
}
