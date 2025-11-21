import 'package:core/core.dart';

import '../repositories/odometer_repository.dart';

/// UseCase para deletar uma leitura de odômetro
///
/// Responsável por:
/// - Validar se leitura existe
/// - Deletar localmente (hard delete)

class DeleteOdometerReadingUseCase implements UseCase<bool, String> {
  const DeleteOdometerReadingUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, bool>> call(String readingId) async {
    try {
      if (readingId.trim().isEmpty) {
        return const Left(ValidationFailure('ID da leitura é obrigatório'));
      }

      final existingResult = await _repository.getOdometerReadingById(
        readingId,
      );
      return existingResult.fold((failure) => Left(failure), (existing) async {
        if (existing == null) {
          return const Left(
            ValidationFailure('Leitura de odômetro não encontrada'),
          );
        }

        final deleteResult = await _repository.deleteOdometerReading(readingId);
        return deleteResult.fold(
          (failure) => Left(failure),
          (success) => Right(success),
        );
      });
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao deletar leitura: ${e.toString()}'),
      );
    }
  }
}
