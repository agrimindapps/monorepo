import 'package:core/core.dart' as core;
import 'package:core/core.dart' show injectable;
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/premium_status.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar o status premium do usuário

class CheckPremiumStatus implements UseCase<PremiumStatus, NoParams> {
  CheckPremiumStatus(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, PremiumStatus>> call(NoParams params) async {
    return await repository.getPremiumStatus();
  }
}
