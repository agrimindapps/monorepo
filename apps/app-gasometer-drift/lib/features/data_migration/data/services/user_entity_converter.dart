import 'package:core/core.dart';

/// Conversor de entidades de usuário
///
/// Responsabilidade: Converter dados Firebase/Firestore para UserEntity
/// Aplica SRP (Single Responsibility Principle)
@injectable
class UserEntityConverter {
  /// Converte Firebase User para UserEntity
  UserEntity fromFirebaseUser(User firebaseUser) {
    return UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'Usuário',
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      provider: firebaseUser.isAnonymous
          ? AuthProvider.anonymous
          : AuthProvider.email,
      createdAt: firebaseUser.metadata.creationTime,
      updatedAt: DateTime.now(),
    );
  }

  /// Converte Firestore document para UserEntity
  UserEntity fromFirestoreDocument(String userId, Map<String, dynamic> data) {
    return UserEntity(
      id: userId,
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String? ?? 'Usuário',
      photoUrl: data['photo_url'] as String?,
      isEmailVerified: data['email_verified'] as bool? ?? false,
      lastLoginAt: (data['last_login_at'] as Timestamp?)?.toDate(),
      provider: _parseAuthProvider(data['provider'] as String?),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Parseia provider de autenticação
  AuthProvider _parseAuthProvider(String? provider) {
    switch (provider) {
      case 'google.com':
        return AuthProvider.google;
      case 'apple.com':
        return AuthProvider.apple;
      case 'facebook.com':
        return AuthProvider.facebook;
      case 'anonymous':
        return AuthProvider.anonymous;
      default:
        return AuthProvider.email;
    }
  }

  /// Valida se usuário é anônimo
  bool isAnonymousUser(User? user, String userId) {
    return user != null && user.uid == userId && user.isAnonymous;
  }

  /// Valida se é o usuário atual
  bool isCurrentUser(User? user, String userId) {
    return user != null && user.uid == userId;
  }
}
