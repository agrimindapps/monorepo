import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/auth/domain/entities/user_entity.dart';
import 'package:app_agrihurbi/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting current user
class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  /// Execute get current user
  ResultFuture<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}