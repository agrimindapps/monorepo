import 'package:core/core.dart';

import '../entities/landing_content.dart';
import '../repositories/landing_content_repository.dart';

/// Use case to get landing page content
class GetLandingContentUseCase {
  final LandingContentRepository _repository;

  const GetLandingContentUseCase(this._repository);

  /// Executes the use case
  ///
  /// Returns [Right(LandingContent)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, LandingContent>> call() async {
    return await _repository.getLandingContent();
  }
}
