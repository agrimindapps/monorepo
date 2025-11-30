import 'package:drift/drift.dart';

import '../../features/auth/data/user_model.dart';
import '../tables/users_table.dart';
import '../taskolist_database.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<TaskolistDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  // ========================================================================
  // READ OPERATIONS
  // ========================================================================

  /// Get user by Firebase ID
  Future<UserModel?> getUserByFirebaseId(String firebaseId) async {
    final result = await (select(users)
          ..where((tbl) => tbl.firebaseId.equals(firebaseId)))
        .getSingleOrNull();

    return result != null ? _userDataToModel(result) : null;
  }

  /// Get cached user (current user)
  Future<UserModel?> getCachedUser() async {
    final result = await (select(users)
          ..where((tbl) => tbl.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();

    return result != null ? _userDataToModel(result) : null;
  }

  // ========================================================================
  // WRITE OPERATIONS
  // ========================================================================

  /// Cache user (insert or update)
  Future<void> cacheUser(UserModel user) async {
    await into(users).insertOnConflictUpdate(_modelToUserData(user));
  }

  /// Clear all users
  Future<void> clearCache() async {
    await delete(users).go();
  }

  // ========================================================================
  // CONVERTERS
  // ========================================================================

  /// Convert UserData to UserModel
  UserModel _userDataToModel(UserData data) {
    return UserModel(
      id: data.firebaseId,
      name: data.name,
      email: data.email,
      avatarUrl: data.avatarUrl,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isActive: data.isActive,
      emailVerified: data.emailVerified,
    );
  }

  /// Convert UserModel to UsersCompanion
  UsersCompanion _modelToUserData(UserModel model) {
    return UsersCompanion.insert(
      firebaseId: model.id,
      name: model.name,
      email: model.email,
      avatarUrl: Value(model.avatarUrl),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isActive: Value(model.isActive),
      emailVerified: Value(model.emailVerified),
    );
  }
}
