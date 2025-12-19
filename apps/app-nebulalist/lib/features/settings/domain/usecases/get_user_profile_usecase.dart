import 'package:dartz/dartz.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository repository;

  const GetUserProfileUseCase(this.repository);

  Future<Either<String, UserProfileEntity?>> call() {
    return repository.getUserProfile();
  }
}
