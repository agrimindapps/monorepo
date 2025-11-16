import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDataSource remoteDataSource;
  final IProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

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

      // TODO: Get userId from auth service
      final profile = await remoteDataSource.getProfile('current_user_id');
      await localDataSource.cacheProfile(profile);
      return Right(profile);
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
      // TODO: Implement image upload logic with Firebase Storage
      return const Right('https://example.com/image.jpg');
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
      // TODO: Get userId from auth service
      await remoteDataSource.deleteProfile('current_user_id');
      await localDataSource.clearProfile();
      return const Right(unit);
    } on ServerException {
      return const Left(ServerFailure('Failed to delete account'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
