import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart';
import 'package:app_agrihurbi/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user login
class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  /// Execute login
  ResultFuture<UserEntity> call(LoginParams params) {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

/// Parameters for login use case
class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}