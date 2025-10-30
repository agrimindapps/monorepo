import 'package:core/core.dart';

import '../entities/auth_status.dart';

/// Repository interface for landing authentication status
abstract class LandingAuthRepository {
  /// Check current authentication status
  ///
  /// Returns [Right(LandingAuthStatus)] on success
  /// Returns [Left(Failure)] on error:
  /// - [AuthFailure] if authentication check fails
  /// - [UnknownFailure] for unexpected errors
  Future<Either<Failure, LandingAuthStatus>> checkAuthStatus();

  /// Watch authentication status changes
  Stream<LandingAuthStatus> watchAuthStatus();
}
