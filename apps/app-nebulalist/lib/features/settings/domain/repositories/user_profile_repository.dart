import 'package:dartz/dartz.dart';
import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<Either<String, UserProfileEntity?>> getUserProfile();
  Future<Either<String, UserProfileEntity>> updateUserProfile(UserProfileEntity profile);
  Future<Either<String, bool>> deleteAccount();
}
