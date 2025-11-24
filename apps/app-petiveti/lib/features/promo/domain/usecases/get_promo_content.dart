import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/promo_content.dart';
import '../repositories/promo_repository.dart';

/// Use case for retrieving promotional content
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles promo content retrieval flow
/// - **Dependency Inversion**: Depends on repository abstraction
class GetPromoContent implements UseCase<PromoContent, NoParams> {
  final PromoRepository _repository;

  GetPromoContent(this._repository);

  @override
  Future<Either<Failure, PromoContent>> call(NoParams params) async {
    return await _repository.getPromoContent();
  }
}
