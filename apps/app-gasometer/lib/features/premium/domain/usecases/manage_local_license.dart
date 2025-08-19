import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para gerar licença local de desenvolvimento
@injectable
class GenerateLocalLicense implements UseCase<void, GenerateLocalLicenseParams> {
  final PremiumRepository repository;

  GenerateLocalLicense(this.repository);

  @override
  Future<Either<Failure, void>> call(GenerateLocalLicenseParams params) async {
    return await repository.generateLocalLicense(days: params.days);
  }
}


/// Use case para revogar licença local
@injectable
class RevokeLocalLicense implements UseCase<void, NoParams> {
  final PremiumRepository repository;

  RevokeLocalLicense(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.revokeLocalLicense();
  }
}

/// Use case para verificar licença local ativa
@injectable
class HasActiveLocalLicense implements UseCase<bool, NoParams> {
  final PremiumRepository repository;

  HasActiveLocalLicense(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.hasActiveLocalLicense();
  }
}