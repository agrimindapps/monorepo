import 'package:core/core.dart' hide Column;

import '../entities/auth_status.dart';
import '../repositories/auth_status_repository.dart';

/// Use case to check authentication status
class CheckAuthStatusUseCase {
  final LandingAuthRepository _repository;

  const CheckAuthStatusUseCase(this._repository);

  /// Executes the use case
  ///
  /// Returns [Right(LandingAuthStatus)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, LandingAuthStatus>> call() async {
    return await _repository.checkAuthStatus();
  }

  /// Watch authentication status changes
  Stream<LandingAuthStatus> watch() {
    return _repository.watchAuthStatus();
  }
}
