import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/praga_info.dart';
import '../repositories/praga_info_repository.dart';

/// Use case to save PragaInfo (create or update)
class SavePragaInfoUseCase {
  final PragaInfoRepository repository;

  SavePragaInfoUseCase(this.repository);

  Future<Either<Failure, PragaInfo>> call(PragaInfo info) async {
    // Validation
    if (info.pragaId.isEmpty) {
      return const Left(ValidationFailure('ID da praga é obrigatório'));
    }

    // Update timestamp
    final updatedInfo = info.copyWith(
      updatedAt: DateTime.now(),
    );

    return repository.savePragaInfo(updatedInfo);
  }
}
