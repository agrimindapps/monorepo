import 'package:core/core.dart' hide Column;

import '../repositories/account_repository.dart';

/// Use Case para realizar logout do usuário
/// Segue o princípio de Single Responsibility
class LogoutUseCase implements UseCase<void, NoParams> {
  final AccountRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
