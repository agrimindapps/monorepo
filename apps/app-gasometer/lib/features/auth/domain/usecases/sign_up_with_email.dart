import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

@injectable
class SignUpWithEmail implements UseCase<UserEntity, SignUpWithEmailParams> {

  SignUpWithEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) async {
    final emailValidation = repository.validateEmail(params.email);
    if (emailValidation.isLeft()) {
      return emailValidation.fold((failure) => Left(failure), (_) => throw Exception());
    }
    final passwordValidation = repository.validatePassword(params.password);
    if (passwordValidation.isLeft()) {
      return passwordValidation.fold((failure) => Left(failure), (_) => throw Exception());
    }

    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class SignUpWithEmailParams {

  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });
  final String email;
  final String password;
  final String? displayName;
}