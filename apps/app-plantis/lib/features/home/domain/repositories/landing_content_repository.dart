import 'package:core/core.dart';

import '../entities/landing_content.dart';

/// Repository interface for landing page content
abstract class LandingContentRepository {
  /// Get landing page content
  ///
  /// Returns [Right(LandingContent)] on success
  /// Returns [Left(Failure)] on error:
  /// - [CacheFailure] if content cannot be loaded
  /// - [UnknownFailure] for unexpected errors
  Future<Either<Failure, LandingContent>> getLandingContent();
}
