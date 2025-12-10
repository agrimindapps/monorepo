import 'package:core/core.dart' hide AuthState, Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import '../../features/auth/domain/usecases/update_profile_usecase.dart';
import 'auth_notifier.dart';
import 'auth_state.dart' as local;
import 'core_providers.dart';

// Re-export authProvider from auth_notifier (generated in auth_notifier.g.dart)
export 'auth_notifier.dart' show authProvider, AuthNotifier, AuthResult;
export 'auth_state.dart' show AuthState, UserType;

/// **AUTH PROVIDERS - Riverpod AsyncNotifier (3.0)**
///
/// Uses @riverpod code generation with AsyncNotifier pattern.
///
/// ## Architecture:
/// ```
/// UI Layer → AsyncNotifierProvider → AuthNotifier (AsyncNotifier) → AuthRepository
/// ```
///
/// ## Usage:
/// ```dart
/// // Watch auth state (returns AsyncValue<AuthState>)
/// final authAsync = ref.watch(authProvider);
/// authAsync.when(
///   data: (state) => /* use state */,
///   loading: () => /* loading UI */,
///   error: (e, s) => /* error UI */,
/// );
///
/// // Access notifier methods
/// ref.read(authProvider.notifier).signOut();
///
/// // For synchronous access (when state is guaranteed)
/// final state = ref.watch(authProvider).value;
/// ```
///
/// Note: authProvider is generated in auth_notifier.g.dart

// ============================================================================
// Use Cases
// ============================================================================

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(authRepositoryProvider));
});

final sendPasswordResetEmailUseCaseProvider = Provider<SendPasswordResetEmailUseCase>((ref) {
  return SendPasswordResetEmailUseCase(ref.watch(authRepositoryProvider));
});

// ============================================================================
// Derived Providers (computed from auth state)
// ============================================================================

/// Computed provider: Current authenticated user
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).value?.currentUser;
});

/// Computed provider: Authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value?.isAuthenticated ?? false;
});

/// Computed provider: Loading state
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).value?.isLoading ?? false;
});

/// Computed provider: Error message
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).value?.errorMessage;
});
