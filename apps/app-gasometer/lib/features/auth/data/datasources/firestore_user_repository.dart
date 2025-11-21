import 'package:core/core.dart';

import '../../../../core/error/exceptions.dart';
import 'user_converter.dart';

/// Repositório especializado para operações de usuário no Firestore
///
/// Responsabilidade: Gerenciar persistência de dados do usuário no Firestore
/// Aplica SRP (Single Responsibility Principle)

class FirestoreUserRepository {
  FirestoreUserRepository(this._firestore, this._userConverter);

  final FirebaseFirestore _firestore;
  final UserConverter _userConverter;

  static const String _usersCollection = 'users';

  /// Salva ou atualiza dados do usuário no Firestore
  Future<void> saveUser(UserEntity user) async {
    try {
      final userData = _userConverter.toFirestore(user);
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to save user to Firestore: $e');
    }
  }

  /// Busca dados do usuário no Firestore
  Future<UserEntity?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      return _userConverter.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get user from Firestore: $e');
    }
  }

  /// Deleta dados do usuário no Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw ServerException('Failed to delete user from Firestore: $e');
    }
  }

  /// Atualiza campos específicos do usuário
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(fields);
    } catch (e) {
      throw ServerException('Failed to update user fields: $e');
    }
  }
}
