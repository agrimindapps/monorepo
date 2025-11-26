import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/defensivo_info.dart';
import '../repositories/defensivos_info_repository.dart';

/// Use case for getting defensivo complementary information by defensivo ID
class GetDefensivoInfoByDefensivoIdUseCase {
  final DefensivosInfoRepository repository;

  const GetDefensivoInfoByDefensivoIdUseCase(this.repository);

  /// Execute the use case
  /// Returns null if no info exists (optional relationship)
  Future<Either<Failure, DefensivoInfo?>> call(String defensivoId) async {
    // Validation
    if (defensivoId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do defensivo é obrigatório'));
    }

    // Delegate to repository
    return repository.getDefensivoInfoByDefensivoId(defensivoId);
  }
}
