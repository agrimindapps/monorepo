import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/promo_entity.dart';

abstract class IPromoRepository {
  Future<Either<Failure, List<PromoEntity>>> getActivePromos();
  Future<Either<Failure, PromoEntity>> getPromoById(String id);
  Future<Either<Failure, Unit>> markPromoAsViewed(String promoId);
}
