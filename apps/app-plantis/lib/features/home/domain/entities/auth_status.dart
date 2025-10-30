import 'package:equatable/equatable.dart';

/// Entity representing the authentication status for landing page
class LandingAuthStatus extends Equatable {
  /// Whether the authentication system is initialized
  final bool isInitialized;

  /// Whether the user is authenticated
  final bool isAuthenticated;

  /// User ID if authenticated
  final String? userId;

  const LandingAuthStatus({
    required this.isInitialized,
    required this.isAuthenticated,
    this.userId,
  });

  /// Create an uninitialized status
  const LandingAuthStatus.uninitialized()
    : isInitialized = false,
      isAuthenticated = false,
      userId = null;

  /// Create an unauthenticated status
  const LandingAuthStatus.unauthenticated()
    : isInitialized = true,
      isAuthenticated = false,
      userId = null;

  /// Create an authenticated status
  const LandingAuthStatus.authenticated(this.userId)
    : isInitialized = true,
      isAuthenticated = true;

  /// Check if should redirect to main app
  bool get shouldRedirect => isInitialized && isAuthenticated;

  @override
  List<Object?> get props => [isInitialized, isAuthenticated, userId];

  @override
  String toString() =>
      'LandingAuthStatus('
      'isInitialized: $isInitialized, '
      'isAuthenticated: $isAuthenticated, '
      'userId: $userId)';
}
