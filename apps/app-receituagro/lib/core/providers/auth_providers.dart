import 'package:core/core.dart' hide AuthState;

import '../di/injection_container.dart' as di;
import 'auth_notifier.dart';
import 'auth_state.dart' as local;

/// StateNotifierProvider for authentication
/// Replaces ChangeNotifierProvider from Provider pattern
final authProvider = StateNotifierProvider<AuthNotifier, local.AuthState>((ref) {
  return di.sl<AuthNotifier>();
});

/// Convenience providers for specific state properties
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});
