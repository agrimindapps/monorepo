import 'package:core/core.dart' hide Column;

import '../entities/account_info.dart';
import '../repositories/account_repository.dart';

/// Use Case para obter informações da conta do usuário
class GetAccountInfoUseCase implements UseCase<AccountInfo, NoParams> {
  final AccountRepository repository;

  const GetAccountInfoUseCase(this.repository);

  @override
  Future<Either<Failure, AccountInfo>> call(NoParams params) async {
    return await repository.getAccountInfo();
  }
}
