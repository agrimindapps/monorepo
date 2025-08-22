import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Login user with email and password
  ResultFuture<UserEntity> login({
    required String email,
    required String password,
  });

  /// Register new user
  ResultFuture<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Logout current user
  ResultVoid logout();

  /// Get current logged user
  ResultFuture<UserEntity?> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Refresh user token
  ResultFuture<String> refreshToken();

  /// Update user profile
  ResultFuture<UserEntity> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  });

  /// Change password
  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Forgot password
  ResultVoid forgotPassword({
    required String email,
  });

  /// Reset password
  ResultVoid resetPassword({
    required String token,
    required String newPassword,
  });
}