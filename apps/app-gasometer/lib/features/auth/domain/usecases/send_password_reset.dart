import 'package:core/core.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendPasswordReset implements UseCase<Unit, SendPasswordResetParams> {

  SendPasswordReset(this.repository);
  final AuthRepository repository;

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

class SendPasswordResetParams {

  const SendPasswordResetParams({required this.email});
  final String email;
}