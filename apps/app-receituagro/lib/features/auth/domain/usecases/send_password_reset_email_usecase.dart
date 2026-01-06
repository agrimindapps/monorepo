import 'package:core/core.dart';

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
