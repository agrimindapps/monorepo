import 'package:core/core.dart' hide Failure, UseCase;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignUpWithEmail implements UseCase<UserEntity, SignUpWithEmailParams> {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) async {
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

    return repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class SignUpWithEmailParams extends UseCaseParams {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}