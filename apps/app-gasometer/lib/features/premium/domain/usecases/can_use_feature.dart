import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar se pode usar uma feature
@injectable
class CanUseFeature implements UseCase<bool, CanUseFeatureParams> {

  CanUseFeature(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<Failure, bool>> call(CanUseFeatureParams params) async {
    return await repository.canUseFeature(params.featureId);
  }
}