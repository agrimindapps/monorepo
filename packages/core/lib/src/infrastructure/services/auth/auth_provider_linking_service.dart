import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../domain/entities/user_entity.dart' as core_entities;
import '../../../shared/utils/failure.dart';
import 'auth_mapper_service.dart';

/// Serviço especializado em vinculação de provedores de autenticação
///
/// Responsabilidades:
/// - Link account com Google
/// - Link account com Apple
/// - Link account com Facebook
/// - Link account com Email/Password
class AuthProviderLinkingService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final AuthMapperService _mapper;

  AuthProviderLinkingService({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
    required AuthMapperService mapper,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _facebookAuth = facebookAuth,
        _mapper = mapper;

  /// Vincula conta anônima com email e senha
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

      return Right(_mapper.mapFirebaseUserToEntity(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: $e'));
    }
  }

  /// Vincula conta com Google
  Future<Either<Failure, core_entities.UserEntity>> linkWithGoogle() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting to link account with Google...');
      }

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Check if already linked
      final isLinked = user.providerData.any((info) => info.providerId == 'google.com');
      if (isLinked) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Account already linked with Google');
        }
        return const Left(AuthFailure('Conta já vinculada com Google'));
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Google Sign In canceled by user');
        }
        return const Left(AuthFailure('Vinculação cancelada pelo usuário'));
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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

      return Right(_mapper.mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}');
      }

      if (e.code == 'credential-already-in-use') {
        return const Left(AuthFailure('Esta conta Google já está em uso por outro usuário'));
      } else if (e.code == 'email-already-in-use') {
        return const Left(AuthFailure('O email desta conta Google já está em uso'));
      } else if (e.code == 'provider-already-linked') {
        return const Left(AuthFailure('Conta já vinculada com Google'));
      }

      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Google linking: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado ao vincular com Google: $e'));
    }
  }

  /// Vincula conta com Apple
  Future<Either<Failure, core_entities.UserEntity>> linkWithApple() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting to link account with Apple...');
      }

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Check if already linked
      final isLinked = user.providerData.any((info) => info.providerId == 'apple.com');
      if (isLinked) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Account already linked with Apple');
        }
        return const Left(AuthFailure('Conta já vinculada com Apple'));
      }

      if (!await SignInWithApple.isAvailable()) {
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

      // Update display name if available
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty && userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: Account successfully linked with Apple');
      }

      return Right(_mapper.mapFirebaseUserToEntity(userCredential.user!));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: SignInWithAppleAuthorizationException - ${e.code}: ${e.message}');
      }

      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left(AuthFailure('Vinculação com Apple cancelada'));
      }

      return Left(AuthFailure('Erro ao vincular com Apple: ${e.message}'));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}');
      }

      if (e.code == 'credential-already-in-use') {
        return const Left(AuthFailure('Esta conta Apple já está em uso por outro usuário'));
      } else if (e.code == 'email-already-in-use') {
        return const Left(AuthFailure('O email desta conta Apple já está em uso'));
      } else if (e.code == 'provider-already-linked') {
        return const Left(AuthFailure('Conta já vinculada com Apple'));
      }

      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Apple linking: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado ao vincular com Apple: $e'));
    }
  }

  /// Vincula conta com Facebook
  Future<Either<Failure, core_entities.UserEntity>> linkWithFacebook() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Firebase: Attempting to link account with Facebook...');
      }

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Check if already linked
      final isLinked = user.providerData.any((info) => info.providerId == 'facebook.com');
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
        return Left(AuthFailure('Falha ao vincular com Facebook: ${result.message}'));
      }

      if (result.accessToken == null) {
        return const Left(AuthFailure('Falha ao obter token de acesso do Facebook'));
      }

      final OAuthCredential facebookCredential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );

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

      return Right(_mapper.mapFirebaseUserToEntity(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: FirebaseAuthException - ${e.code}: ${e.message}');
      }

      if (e.code == 'credential-already-in-use') {
        return const Left(AuthFailure('Esta conta Facebook já está em uso por outro usuário'));
      } else if (e.code == 'email-already-in-use') {
        return const Left(AuthFailure('O email desta conta Facebook já está em uso'));
      } else if (e.code == 'provider-already-linked') {
        return const Left(AuthFailure('Conta já vinculada com Facebook'));
      }

      return Left(AuthFailure(_mapper.mapFirebaseAuthError(e)));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Firebase: Unexpected error during Facebook linking: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(AuthFailure('Erro inesperado ao vincular com Facebook: $e'));
    }
  }
}
