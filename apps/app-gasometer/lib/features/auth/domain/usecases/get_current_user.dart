import 'package:core/core.dart';

import '../repositories/auth_repository.dart';


class GetCurrentUser implements NoParamsUseCase<UserEntity?> {
  const GetCurrentUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity?>> call() {
    return repository.getCurrentUser();
  }
}
