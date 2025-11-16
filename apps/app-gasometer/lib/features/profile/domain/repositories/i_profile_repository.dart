import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getProfile();
  Future<Either<Failure, UserProfileEntity>> updateProfile(
    UserProfileEntity profile,
  );
  Future<Either<Failure, String>> uploadProfileImage(String imagePath);
  Future<Either<Failure, Unit>> deleteAccount();
}
