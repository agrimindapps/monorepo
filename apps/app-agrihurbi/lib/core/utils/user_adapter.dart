import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart' as local;
import 'package:core/core.dart' as core_lib;

/// Adapter para converter entre UserEntity local e do core
class UserAdapter {
  UserAdapter._();

  /// Converte UserEntity local para core UserEntity
  static core_lib.UserEntity localToCore(local.UserEntity localUser) {
    return core_lib.UserEntity(
      id: localUser.id,
      email: localUser.email,
      displayName: localUser.displayName, // displayName is required
      photoUrl: localUser.photoUrl,
      isEmailVerified: true, // Default value for now
      lastLoginAt: localUser.lastLoginAt,
      provider: core_lib.AuthProvider.email,
      createdAt: localUser.createdAt,
    );
  }

  /// Converte core UserEntity para UserEntity local  
  static local.UserEntity coreToLocal(core_lib.UserEntity coreUser) {
    return local.UserEntity(
      id: coreUser.id,
      displayName: coreUser.displayName,
      email: coreUser.email,
      photoUrl: coreUser.photoUrl,
      lastLoginAt: coreUser.lastLoginAt,
      createdAt: coreUser.createdAt ?? DateTime.now(),
    );
  }
}
