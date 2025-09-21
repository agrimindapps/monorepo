import 'package:core/core.dart' hide Failure, NoParamsUseCase;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUser implements NoParamsUseCase<UserEntity?> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}