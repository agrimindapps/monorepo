import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

class UserProfileRemoteDataSource {
  final FirebaseAuth _auth;

  UserProfileRemoteDataSource(this._auth);

  Future<UserProfileModel?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      return UserProfileModel(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        createdAt: user.metadata.creationTime,
        lastLoginAt: user.metadata.lastSignInTime,
      );
    } catch (e) {
      throw Exception('Erro ao buscar perfil: $e');
    }
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      await user.updateDisplayName(profile.displayName);
      await user.updatePhotoURL(profile.photoUrl);
      
      // Recarrega o usuário para obter dados atualizados
      await user.reload();
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      await user.delete();
    } catch (e) {
      throw Exception('Erro ao excluir conta: $e');
    }
  }
}
