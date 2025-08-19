import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar se pode usar uma feature
@injectable
class CanUseFeature implements UseCase<bool, CanUseFeatureParams> {
  final PremiumRepository repository;

  CanUseFeature(this.repository);

  @override
  Future<Either<Failure, bool>> call(CanUseFeatureParams params) async {
    return await repository.canUseFeature(params.featureId);
  }
}