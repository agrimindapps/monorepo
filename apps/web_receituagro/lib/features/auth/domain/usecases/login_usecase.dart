import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../../../core/validation/validators.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Parameters for login use case
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Use case to login user
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    // Validate email
    final emailValidation = Validators.validateEmail(params.email);
    if (emailValidation != null) return Left(emailValidation);

    // Validate password
    final passwordValidation = Validators.validateRequired(
      params.password,
      'Senha',
    );
    if (passwordValidation != null) return Left(passwordValidation);

    final minLengthValidation = Validators.validateMinLength(
      params.password,
      6,
      'Senha',
    );
    if (minLengthValidation != null) return Left(minLengthValidation);

    // Execute login
    try {
      return await repository.login(
        email: params.email.trim(),
        password: params.password,
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
