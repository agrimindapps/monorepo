import 'package:core/core.dart' hide Column;

// ❌ REMOVIDO: user_settings_repository_impl.dart (via )
// ❌ REMOVIDO: i_user_settings_repository.dart (via )
// ❌ REMOVIDO: get_user_settings_usecase.dart (via )
// ❌ REMOVIDO: update_user_settings_usecase.dart (via )

/// Dependency Injection setup for Settings module following Clean Architecture.
/// DEPRECATED: Use Riverpod providers instead
abstract class SettingsDI {
  static void register(dynamic getIt) {}
  static void unregister(dynamic getIt) {}
}
