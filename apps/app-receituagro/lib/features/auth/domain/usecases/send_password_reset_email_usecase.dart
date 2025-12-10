import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

class SendPasswordResetEmailUseCase {
  final IAuthRepository _repository;

  SendPasswordResetEmailUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String email,
  }) {
    return _repository.sendPasswordResetEmail(
      email: email,
    );
  }
}
