import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/promo_content.dart';
import '../repositories/promo_repository.dart';

class GetPromoContent implements UseCase<PromoContent, NoParams> {
  final PromoRepository repository;

  GetPromoContent(this.repository);

  @override
  Future<Either<Failure, PromoContent>> call(NoParams params) async {
    return await repository.getPromoContent();
  }
}
