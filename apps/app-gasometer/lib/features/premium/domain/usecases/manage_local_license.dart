import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para gerar licença local de desenvolvimento

class GenerateLocalLicense
    implements UseCase<void, GenerateLocalLicenseParams> {
  GenerateLocalLicense(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, void>> call(
    GenerateLocalLicenseParams params,
  ) async {
    return await repository.generateLocalLicense(days: params.days);
  }
}

/// Use case para revogar licença local

class RevokeLocalLicense implements UseCase<void, NoParams> {
  RevokeLocalLicense(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, void>> call(NoParams params) async {
    return await repository.revokeLocalLicense();
  }
}

/// Use case para verificar licença local ativa

class HasActiveLocalLicense implements UseCase<bool, NoParams> {
  HasActiveLocalLicense(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(NoParams params) async {
    return await repository.hasActiveLocalLicense();
  }
}
