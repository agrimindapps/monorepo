import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class DeleteAccount implements NoParamsUseCase<Unit> {

  DeleteAccount(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, Unit>> call() async {
    return await repository.deleteAccount();
  }
}