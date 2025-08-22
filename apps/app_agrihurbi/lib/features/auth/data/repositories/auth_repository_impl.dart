import 'package:dartz/dartz.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/network/network_info.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_agrihurbi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart';
import 'package:app_agrihurbi/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.login(
          email: email,
          password: password,
        );
        
        // Cache user locally
        await localDataSource.cacheUser(user);
        
        return Right(user);
      } else {
        return const Left(NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ));
      }
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.register(
          name: name,
          email: email,
          password: password,
          phone: phone,
        );
        
        // Cache user locally
        await localDataSource.cacheUser(user);
        
        return Right(user);
      } else {
        return const Left(NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ));
      }
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  ResultVoid logout() async {
    try {
      // Clear local cache first
      await localDataSource.clearUser();
      
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
        return const Right(null);
      } else {
        // Even without internet, local logout should succeed
        return const Right(null);
      }
    } catch (e) {
      return Left(GeneralFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getLastUser();
      return Right(cachedUser);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached user: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<String> refreshToken() async {
    try {
      if (await networkInfo.isConnected) {
        final token = await remoteDataSource.refreshToken();
        return Right(token);
      } else {
        return const Left(NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ));
      }
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Token refresh failed: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserEntity> updateProfile({
    required UserEntity user,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final updatedUser = await remoteDataSource.updateProfile(user: user);
        
        // Update local cache
        await localDataSource.cacheUser(updatedUser);
        
        return Right(updatedUser);
      } else {
        return const Left(NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ));
      }
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Profile update failed: ${e.toString()}'));
    }
  }

  @override
  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        return const Right(null);
      } else {
        return const Left(NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ));
      }
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Password change failed: ${e.toString()}'));
    }
  }

  @override
  ResultVoid forgotPassword({required String email}) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.forgotPassword(email: email);
        return const Right(null);
      } else {
        return const Left(NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ));
      }
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Password reset request failed: ${e.toString()}'));
    }
  }

  @override
  ResultVoid resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.resetPassword(
          token: token,
          newPassword: newPassword,
        );
        return const Right(null);
      } else {
        return const Left(NetworkFailure(
          'No internet connection. Please check your connection and try again.',
        ));
      }
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Password reset failed: ${e.toString()}'));
    }
  }
}