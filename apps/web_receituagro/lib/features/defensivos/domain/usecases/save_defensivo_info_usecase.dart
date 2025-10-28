import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/defensivo_info.dart';
import '../repositories/defensivos_info_repository.dart';

/// Use case for saving (create or update) defensivo complementary information
/// Performs an "upsert" operation
@lazySingleton
class SaveDefensivoInfoUseCase {
  final DefensivosInfoRepository repository;

  const SaveDefensivoInfoUseCase(this.repository);

  /// Execute the use case
  /// Checks if info exists for the defensivo and creates or updates accordingly
  Future<Either<Failure, DefensivoInfo>> call(DefensivoInfo info) async {
    // Business validation
    if (info.defensivoId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do defensivo é obrigatório'));
    }

    // Check if info already exists for this defensivo
    final existingResult = await repository.getDefensivoInfoByDefensivoId(
      info.defensivoId,
    );

    // If failed to check, return the failure
    if (existingResult.isLeft()) {
      return existingResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected right value'),
      );
    }

    // Extract existing info (if any)
    final existingInfo = existingResult.fold(
      (_) => null,
      (info) => info,
    );

    // If exists, update with the existing ID
    if (existingInfo != null) {
      final updatedInfo = info.copyWith(id: existingInfo.id);
      return repository.updateDefensivoInfo(updatedInfo);
    }

    // Otherwise, create new
    return repository.createDefensivoInfo(info);
  }
}
