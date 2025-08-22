import 'package:core/core.dart' as core_lib;
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart' as local;

/// Adapter para converter entre UserEntity local e do core
class UserAdapter {
  /// Converte UserEntity local para core UserEntity
  static core_lib.UserEntity localToCore(local.UserEntity localUser) {
    return core_lib.UserEntity(
      id: localUser.id,
      email: localUser.email,
      displayName: localUser.name,
      photoUrl: localUser.profileImageUrl,
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
      name: coreUser.displayName,
      email: coreUser.email,
      profileImageUrl: coreUser.photoUrl,
      lastLoginAt: coreUser.lastLoginAt,
      createdAt: coreUser.createdAt ?? DateTime.now(),
    );
  }
}