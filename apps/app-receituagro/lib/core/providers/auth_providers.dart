import 'package:core/core.dart' hide AuthState;

import '../di/injection_container.dart' as di;
import 'auth_notifier.dart';
import 'auth_state.dart' as local;

/// **AUTH PROVIDERS - Riverpod StateNotifierProvider**
///
/// Maintains StateNotifierProvider pattern for AuthNotifier compatibility.
/// AuthNotifier already manages its own state using StateNotifier pattern,
/// so we don't need code generation here - just expose it via providers.
///
/// ## Migration Notes:
/// - AuthNotifier remains unchanged (StateNotifier)
/// - Using StateNotifierProvider directly (no @riverpod needed)
/// - Computed providers for derived state
/// - Maintains same API for backward compatibility

// ============================================================================
// Auth Notifier Provider
// ============================================================================

/// StateNotifierProvider for authentication
/// Exposes AuthNotifier and its state to consumers
final authProvider = StateNotifierProvider<AuthNotifier, local.AuthState>((ref) {
  return di.sl<AuthNotifier>();
});

// ============================================================================
// Derived Providers (computed from auth state)
// ============================================================================

/// Computed provider: Current authenticated user
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).currentUser;
});

/// Computed provider: Authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Computed provider: Loading state
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Computed provider: Error message
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});
