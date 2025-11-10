import 'package:core/core.dart' hide Column;

import '../repositories/account_repository.dart';

/// Use Case para limpar dados de conteúdo do usuário
/// Mantém a conta ativa, apenas remove plantas, tarefas, etc.
class ClearDataUseCase implements UseCase<int, NoParams> {
  final AccountRepository repository;

  const ClearDataUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.clearUserData();
  }
}
