import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:core/core.dart' as core;
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar limites de registros de combustível
@injectable
class CanAddFuelRecord implements UseCase<bool, CanAddFuelRecordParams> {

  CanAddFuelRecord(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(CanAddFuelRecordParams params) async {
    return await repository.canAddFuelRecord(params.currentCount);
  }
}