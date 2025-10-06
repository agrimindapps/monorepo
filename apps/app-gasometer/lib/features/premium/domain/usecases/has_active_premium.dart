import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:core/core.dart' show injectable;
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar se tem premium ativo
@injectable
class HasActivePremium implements UseCase<bool, NoParams> {
  HasActivePremium(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(NoParams params) async {
    return repository.hasActivePremium();
  }
}
