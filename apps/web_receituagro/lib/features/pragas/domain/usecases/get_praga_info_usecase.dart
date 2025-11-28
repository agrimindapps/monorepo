import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/praga_info.dart';
import '../repositories/praga_info_repository.dart';

/// Use case to get PragaInfo by praga ID
class GetPragaInfoUseCase {
  final PragaInfoRepository repository;

  GetPragaInfoUseCase(this.repository);

  Future<Either<Failure, PragaInfo?>> call(String pragaId) async {
    if (pragaId.isEmpty) {
      return const Left(ValidationFailure('ID da praga é obrigatório'));
    }
    return repository.getPragaInfoByPragaId(pragaId);
  }
}
