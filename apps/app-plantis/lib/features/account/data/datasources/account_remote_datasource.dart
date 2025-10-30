import 'package:core/core.dart';

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
  final FirebaseService firebaseService;

  const AccountRemoteDataSourceImpl(this.firebaseService);

  @override
  Future<UserEntity?> getRemoteAccountInfo() async {
    try {
      final firebaseUser = firebaseService.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      return UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        isAnonymous: firebaseUser.isAnonymous,
        provider: AuthProvider.fromFirebase(
          firebaseUser.providerData.firstOrNull?.providerId ?? 'anonymous',
        ),
        createdAt: firebaseUser.metadata.creationTime,
        lastLoginAt: firebaseUser.metadata.lastSignInTime,
      );
    } catch (e) {
      throw ServerFailure('Erro ao buscar dados remotos: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseService.signOut();
    } catch (e) {
      throw AuthFailure('Erro ao fazer logout: $e');
    }
  }

  @override
  Future<int> clearRemoteUserData(String userId) async {
    try {
      int totalCleared = 0;

      // Limpa coleção de plantas
      final plantsSnapshot = await firebaseService.firestore
          .collection('plantas')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in plantsSnapshot.docs) {
        await doc.reference.delete();
        totalCleared++;
      }

      // Limpa coleção de tarefas
      final tasksSnapshot = await firebaseService.firestore
          .collection('tarefas')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in tasksSnapshot.docs) {
        await doc.reference.delete();
        totalCleared++;
      }

      return totalCleared;
    } catch (e) {
      throw ServerFailure('Erro ao limpar dados remotos: $e');
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      // Primeiro limpa todos os dados do usuário
      await clearRemoteUserData(userId);

      // Remove documento do usuário
      await firebaseService.firestore.collection('users').doc(userId).delete();

      // Deleta a conta de autenticação
      final currentUser = firebaseService.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }
    } catch (e) {
      throw AuthFailure('Erro ao excluir conta: $e');
    }
  }
}
