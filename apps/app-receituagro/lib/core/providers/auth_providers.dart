import 'package:core/core.dart' hide AuthState, Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/injection_container.dart' as di;
import 'auth_notifier.dart';
import 'auth_state.dart' as local;

part 'auth_providers.g.dart';

/// **AUTH PROVIDERS - Riverpod Code Generation (@riverpod)**
///
/// Migrated from StateNotifierProvider to @riverpod code generation pattern.
/// AuthNotifier remains unchanged (StateNotifier), but providers use modern syntax.
///
/// ## Migration Notes:
/// - AuthNotifier remains unchanged (StateNotifier)
/// - Providers now use @riverpod code generation
/// - Computed providers for derived state
/// - Type-safe, auto-dispose, better performance
///
/// ## Architecture:
/// ```
/// UI Layer → @riverpod Providers → AuthNotifier (StateNotifier) → AuthRepository
/// ```

// ============================================================================
// Auth Notifier Provider
// ============================================================================

/// Authentication notifier provider
/// Exposes AuthNotifier and its state to consumers
@riverpod
AuthNotifier authNotifier(AuthNotifierRef ref) {
  return di.sl<AuthNotifier>();
}

/// Auth state provider (convenience)
/// Provides direct access to AuthState
@riverpod
local.AuthState authState(AuthStateRef ref) {
  final notifier = ref.watch(authNotifierProvider);
  return notifier.state;
}

// ============================================================================
// Derived Providers (computed from auth state)
// ============================================================================

/// Computed provider: Current authenticated user
@riverpod
UserEntity? currentUser(CurrentUserRef ref) {
  return ref.watch(authStateProvider).currentUser;
}

/// Computed provider: Authentication status
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  return ref.watch(authStateProvider).isAuthenticated;
}

/// Computed provider: Loading state
@riverpod
bool isLoading(IsLoadingRef ref) {
  return ref.watch(authStateProvider).isLoading;
}

/// Computed provider: Error message
@riverpod
String? errorMessage(ErrorMessageRef ref) {
  return ref.watch(authStateProvider).errorMessage;
}
