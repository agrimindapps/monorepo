import 'package:dartz/dartz.dart';
import '../repositories/user_profile_repository.dart';

class DeleteAccountUseCase {
  final UserProfileRepository repository;

  const DeleteAccountUseCase(this.repository);

  Future<Either<String, bool>> call() {
    return repository.deleteAccount();
  }
}
