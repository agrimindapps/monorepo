import 'package:dartz/dartz.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  const UpdateUserProfileUseCase(this.repository);

  Future<Either<String, UserProfileEntity>> call(UserProfileEntity profile) {
    return repository.updateUserProfile(profile);
  }
}
