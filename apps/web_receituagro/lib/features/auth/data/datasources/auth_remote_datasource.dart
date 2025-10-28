import '../models/user_model.dart';

/// Remote data source contract for authentication
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Logout current user
  Future<void> logout();

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
}
