import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';

/// UseCase para deletar uma leitura de odômetro
///
/// Responsável por:
/// - Validar se leitura existe
/// - Deletar localmente (hard delete)
@injectable
class DeleteOdometerReadingUseCase implements UseCase<bool, String> {
  const DeleteOdometerReadingUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, bool>> call(String readingId) async {
    try {
      if (readingId.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da leitura é obrigatório'),
        );
      }
      final existing = await _repository.getOdometerReadingById(readingId);
      if (existing == null) {
        return const Left(
          ValidationFailure('Leitura de odômetro não encontrada'),
        );
      }
      final success = await _repository.deleteOdometerReading(readingId);

      return Right(success);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao deletar leitura: ${e.toString()}'),
      );
    }
  }
}
