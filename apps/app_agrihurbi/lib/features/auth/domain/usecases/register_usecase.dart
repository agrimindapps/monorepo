import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart';
import 'package:app_agrihurbi/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  /// Execute registration
  ResultFuture<UserEntity> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      phone: params.phone,
    );
  }
}

/// Parameters for register use case
class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String? phone;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });
}