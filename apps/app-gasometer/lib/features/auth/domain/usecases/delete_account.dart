import 'package:core/core.dart';

import '../repositories/auth_repository.dart';


class DeleteAccount implements NoParamsUseCase<Unit> {
  const DeleteAccount(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, Unit>> call() {
    return repository.deleteAccount();
  }
}
