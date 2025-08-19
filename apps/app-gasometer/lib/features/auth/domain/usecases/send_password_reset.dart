import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SendPasswordReset implements UseCase<Unit, SendPasswordResetParams> {
  final AuthRepository repository;

  SendPasswordReset(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendPasswordResetParams params) async {
    // Validate email
    final emailValidation = repository.validateEmail(params.email);
    if (emailValidation.isLeft()) {
      return emailValidation.fold((failure) => Left(failure), (_) => throw Exception());
    }

    return await repository.sendPasswordResetEmail(params.email);
  }
}

class SendPasswordResetParams extends UseCaseParams {
  final String email;

  const SendPasswordResetParams({required this.email});

  @override
  List<Object> get props => [email];
}