import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  /// Execute logout
  ResultVoid call() {
    return repository.logout();
  }
}