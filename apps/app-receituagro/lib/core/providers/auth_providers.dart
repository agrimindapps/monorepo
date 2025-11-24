import 'package:core/core.dart' hide AuthState, Column;

import 'core_providers.dart';
import 'package:app_receituagro/features/sync/services/sync_coordinator.dart';
import '../../features/analytics/analytics_providers.dart';
import 'auth_notifier.dart';
import 'auth_state.dart' as local;

/// **AUTH PROVIDERS - Riverpod StateNotifierProvider**
///
/// Uses traditional StateNotifierProvider pattern (not @riverpod code generation)
/// because StateNotifier's .state property is protected and can't be accessed
/// in generated providers.
///
/// ## Architecture:
/// ```
/// UI Layer → StateNotifierProvider → AuthNotifier (StateNotifier) → AuthRepository
/// ```
///
/// ## Usage:
/// ```dart
/// // Watch auth state
/// final authState = ref.watch(authNotifierProvider);
///
/// // Access current user
/// final user = ref.watch(currentUserProvider);
///
/// // Check authentication
/// final isAuth = ref.watch(isAuthenticatedProvider);
/// ```

// ============================================================================
// Auth Notifier Provider (StateNotifierProvider)
// ============================================================================

/// Authentication notifier provider
/// Exposes both the AuthNotifier and its AuthState to consumers
///
/// This uses the traditional StateNotifierProvider pattern which automatically
/// exposes the state without needing to access the protected .state property.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, local.AuthState>((ref) {
  return AuthNotifier(ref);
});

// ============================================================================
// Derived Providers (computed from auth state)
// ============================================================================

/// Computed provider: Current authenticated user
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).currentUser;
});

/// Computed provider: Authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Computed provider: Loading state
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

/// Computed provider: Error message
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).errorMessage;
});
