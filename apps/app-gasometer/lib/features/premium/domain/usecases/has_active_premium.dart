import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar se tem premium ativo
@injectable
class HasActivePremium implements UseCase<bool, NoParams> {

  HasActivePremium(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.hasActivePremium();
  }
}