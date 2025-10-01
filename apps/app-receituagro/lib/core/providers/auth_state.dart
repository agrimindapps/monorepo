import 'package:core/core.dart';
import '../data/models/user_session_data.dart';

/// Immutable state class for authentication
/// Replaces mutable state variables from ChangeNotifier
class AuthState {
  final UserEntity? currentUser;
  final UserSessionData? sessionData;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.sessionData,
    this.isLoading = false,
    this.errorMessage,
  });

  // Initial state factory
  const AuthState.initial()
      : currentUser = null,
        sessionData = null,
        isLoading = false,
        errorMessage = null;

  // Computed properties (migrated from getters)
  bool get isAuthenticated => currentUser != null && !_isAnonymous;
  bool get isAnonymous => currentUser?.provider.toString() == 'anonymous';
  bool get _isAnonymous => currentUser?.provider.toString() == 'anonymous';

  UserType get userType {
    if (!isAuthenticated) return UserType.guest;
    // TODO: Integrate with Premium service to determine premium status
    return UserType.registered;
  }

  // copyWith method for state immutability
  AuthState copyWith({
    UserEntity? currentUser,
    UserSessionData? sessionData,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      sessionData: sessionData ?? this.sessionData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // Convenience method to clear user (logout)
  AuthState clearUser() {
    return const AuthState(
      currentUser: null,
      sessionData: null,
      isLoading: false,
      errorMessage: null,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, hasError: ${errorMessage != null})';
  }
}

// Supporting enums (migrated from auth_provider.dart)
enum UserType { guest, registered, premium }
