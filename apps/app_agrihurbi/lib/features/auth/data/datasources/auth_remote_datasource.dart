import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/auth/data/models/user_model.dart';
import 'package:app_agrihurbi/core/network/dio_client.dart';
import 'package:app_agrihurbi/core/error/failures.dart';

/// Abstract class for authentication remote data source
abstract class AuthRemoteDataSource {
  /// Login user
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Register user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Logout user
  Future<void> logout();

  /// Refresh token
  Future<String> refreshToken();

  /// Update profile
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  });

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Forgot password
  Future<void> forgotPassword({
    required String email,
  });

  /// Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user'] as DataMap);
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        return UserModel.fromJson(response.data['user'] as DataMap);
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      final response = await dioClient.post('/auth/refresh');
      
      if (response.statusCode == 200) {
        return response.data['token'] as String;
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Token refresh failed',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final response = await dioClient.put(
        '/users/$userId',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user'] as DataMap);
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Profile update failed',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dioClient.put(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw ServerFailure(
          message: response.data['message'] ?? 'Password change failed',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw ServerFailure(
          message: response.data['message'] ?? 'Forgot password failed',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw ServerFailure(
          message: response.data['message'] ?? 'Password reset failed',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ServerFailure.fromException(Exception(e.toString()));
    }
  }
}