import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authRepository,
  });
  final IProfileRemoteDataSource remoteDataSource;
  final IProfileLocalDataSource localDataSource;
  final AuthRepository authRepository;

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile() async {
    try {
      // Try to get from cache first
      try {
        final cachedProfile = await localDataSource.getCachedProfile();
        return Right(cachedProfile);
      } catch (_) {
        // If cache fails, fetch from remote
      }

      final userResult = await authRepository.getCurrentUser();
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null) {
            return const Left(AuthFailure('User not authenticated'));
          }
          final profile = await remoteDataSource.getProfile(user.id);
          await localDataSource.cacheProfile(profile);
          return Right(profile);
        },
      );
    } on ServerException {
      return const Left(ServerFailure('Failed to fetch profile'));
    } on CacheException {
      return const Left(CacheFailure('Failed to load cached profile'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfile(
    UserProfileEntity profile,
  ) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final updatedProfile = await remoteDataSource.updateProfile(model);
      await localDataSource.cacheProfile(updatedProfile);
      return Right(updatedProfile);
    } on ServerException {
      return const Left(ServerFailure('Failed to update profile'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String imagePath) async {
    try {
      final userResult = await authRepository.getCurrentUser();
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null) {
            return const Left(AuthFailure('User not authenticated'));
          }
          final imageUrl = await remoteDataSource.uploadProfileImage(
            user.id,
            imagePath,
          );
          return Right(imageUrl);
        },
      );
    } catch (e) {
      return Left(
        ImageOperationFailure(
          message: e.toString(),
          operation: 'upload',
          imagePath: imagePath,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAccount() async {
    try {
      final userResult = await authRepository.getCurrentUser();
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null) {
            return const Left(AuthFailure('User not authenticated'));
          }
          await remoteDataSource.deleteProfile(user.id);
          await localDataSource.clearProfile();
          return const Right(unit);
        },
      );
    } on ServerException {
      return const Left(ServerFailure('Failed to delete account'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
