import 'package:core/core.dart' hide Column;
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Interface para data source remoto de conta
/// Abstração para acesso ao Firebase
abstract class AccountRemoteDataSource {
  /// Obtém informações da conta do Firebase
  Future<UserEntity?> getRemoteAccountInfo();

  /// Realiza logout no Firebase
  Future<void> logout();

  /// Limpa dados remotos de conteúdo do usuário
  Future<int> clearRemoteUserData(String userId);

  /// Exclui conta do usuário no Firebase
  Future<void> deleteAccount(String userId);
}

/// Implementação do data source remoto usando Firebase
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final fb.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  const AccountRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  @override
  Future<UserEntity?> getRemoteAccountInfo() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      // Determina o provider de autenticação
      final providerId =
          firebaseUser.providerData.firstOrNull?.providerId ?? 'password';
      final provider = _mapFirebaseProviderToAuthProvider(providerId);

      return UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Usuário',
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
        provider: provider,
        createdAt: firebaseUser.metadata.creationTime,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );
    } catch (e) {
      throw Exception('Erro ao buscar dados remotos: $e');
    }
  }

  /// Mapeia provider ID do Firebase para AuthProvider do core
  AuthProvider _mapFirebaseProviderToAuthProvider(String providerId) {
    switch (providerId) {
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

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  @override
  Future<int> clearRemoteUserData(String userId) async {
    try {
      int totalCleared = 0;

      // Limpa coleção de plantas
      final plantsSnapshot = await firebaseFirestore
          .collection('plantas')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in plantsSnapshot.docs) {
        await doc.reference.delete();
        totalCleared++;
      }

      // Limpa coleção de tarefas
      final tasksSnapshot = await firebaseFirestore
          .collection('tarefas')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in tasksSnapshot.docs) {
        await doc.reference.delete();
        totalCleared++;
      }

      return totalCleared;
    } catch (e) {
      throw Exception('Erro ao limpar dados remotos: $e');
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      // Primeiro limpa todos os dados do usuário
      await clearRemoteUserData(userId);

      // Remove documento do usuário
      await firebaseFirestore.collection('users').doc(userId).delete();

      // Deleta a conta de autenticação
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }
    } catch (e) {
      throw Exception('Erro ao excluir conta: $e');
    }
  }
}
