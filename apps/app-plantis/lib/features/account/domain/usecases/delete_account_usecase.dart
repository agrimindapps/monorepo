import 'package:core/core.dart';

import '../repositories/account_repository.dart';

/// Use Case para excluir conta do usuário permanentemente
/// Esta é uma operação irreversível
class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final AccountRepository repository;

  const DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}
