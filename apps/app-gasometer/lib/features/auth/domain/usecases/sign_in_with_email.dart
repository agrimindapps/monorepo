import 'package:core/core.dart' hide Failure, UseCase;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInWithEmail implements UseCase<UserEntity, SignInWithEmailParams> {

  SignInWithEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) async {
    // Validate email
    final emailValidation = repository.validateEmail(params.email);
    if (emailValidation.isLeft()) {
      return emailValidation.fold((failure) => Left(failure), (_) => throw Exception());
    }

    // Validate password
    final passwordValidation = repository.validatePassword(params.password);
    if (passwordValidation.isLeft()) {
      return passwordValidation.fold((failure) => Left(failure), (_) => throw Exception());
    }

    return repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailParams extends UseCaseParams {

  const SignInWithEmailParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}