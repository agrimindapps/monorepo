import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart' as local;
import 'package:core/core.dart' as core_lib;

/// An adapter to handle conversions between different `UserEntity` types.
///
/// **NOTE:** The local `UserEntity` is currently a direct export of the `core`
/// `UserEntity`. As a result, this adapter acts as a simple pass-through.
///
/// This implementation was chosen as a low-risk refactoring to fix a bug where
/// the previous adapter was creating new instances with hardcoded values.
///
/// In the future, this adapter should either be removed (and the core entity
/// used directly) or updated if a distinct local `UserEntity` is introduced.
class UserAdapter {
  UserAdapter._();

  /// Pass-through method for `UserEntity`.
  ///
  /// Since the local and core entities are the same, this method simply
  /// returns the provided [localUser] without modification.
  static core_lib.UserEntity localToCore(local.UserEntity localUser) {
    return localUser;
  }

  /// Pass-through method for `UserEntity`.
  ///
  /// Since the core and local entities are the same, this method simply
  /// returns the provided [coreUser] without modification.
  static local.UserEntity coreToLocal(core_lib.UserEntity coreUser) {
    return coreUser;
  }
}