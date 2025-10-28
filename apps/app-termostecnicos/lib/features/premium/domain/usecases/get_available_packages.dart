import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../repositories/premium_repository.dart';

/// Use case for getting available subscription packages
@injectable
class GetAvailablePackages {
  final PremiumRepository _repository;

  GetAvailablePackages(this._repository);

  Future<Either<Failure, List<dynamic>>> call() async {
    try {
      return await _repository.getAvailablePackages();
    } catch (e) {
      return Left(
        ServerFailure('Failed to get available packages: ${e.toString()}'),
      );
    }
  }
}
