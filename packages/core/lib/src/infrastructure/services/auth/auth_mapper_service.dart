import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/entities/user_entity.dart' as core_entities;

/// Serviço utilitário para mapeamento de entidades e erros de autenticação
///
/// Responsabilidades:
/// - Mapear User do Firebase para UserEntity
/// - Mapear provedores de autenticação
/// - Mapear erros do Firebase para mensagens user-friendly
class AuthMapperService {
  /// Mapeia um User do Firebase para UserEntity
  core_entities.UserEntity mapFirebaseUserToEntity(User firebaseUser) {
    return core_entities.UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'Usuário',
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      provider: mapAuthProvider(firebaseUser.providerData),
      createdAt: firebaseUser.metadata.creationTime,
      updatedAt: DateTime.now(),
    );
  }

  /// Mapeia os provedores do Firebase para AuthProvider
  core_entities.AuthProvider mapAuthProvider(List<UserInfo> providerData) {
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
  String mapFirebaseAuthError(FirebaseAuthException e) {
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
