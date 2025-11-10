import 'package:core/core.dart' hide Column;
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
  const AuthState.initial()
      : currentUser = null,
        sessionData = null,
        isLoading = false,
        errorMessage = null;
  bool get isAuthenticated => currentUser != null && !_isAnonymous;
  bool get isAnonymous => currentUser?.provider.toString() == 'anonymous';
  bool get _isAnonymous => currentUser?.provider.toString() == 'anonymous';

  UserType get userType {
    if (!isAuthenticated) return UserType.guest;
    return UserType.registered;
  }
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
enum UserType { guest, registered, premium }
