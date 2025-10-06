import 'package:dartz/dartz.dart';
import 'package:core/core.dart' show injectable;
import 'package:core/core.dart' as core;
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar se pode usar uma feature
@injectable
class CanUseFeature implements UseCase<bool, CanUseFeatureParams> {
  CanUseFeature(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(CanUseFeatureParams params) async {
    return await repository.canUseFeature(params.featureId);
  }
}
