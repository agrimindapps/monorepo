import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case to logout user
@injectable
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      return await repository.logout();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
