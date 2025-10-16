import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case to get current authenticated user
@injectable
class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    try {
      return await repository.getCurrentUser();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
