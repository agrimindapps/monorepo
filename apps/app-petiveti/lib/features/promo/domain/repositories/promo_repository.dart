import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/promo_content.dart';

abstract class PromoRepository {
  Future<Either<Failure, PromoContent>> getPromoContent();
  Future<Either<Failure, void>> submitPreRegistration(String email);
  Future<Either<Failure, void>> trackEvent(String event, Map<String, dynamic> parameters);
}