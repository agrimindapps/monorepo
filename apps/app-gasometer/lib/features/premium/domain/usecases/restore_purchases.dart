import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para restaurar compras
@injectable
class RestorePurchases implements UseCase<bool, NoParams> {
  final PremiumRepository repository;

  RestorePurchases(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.restorePurchases();
  }
}