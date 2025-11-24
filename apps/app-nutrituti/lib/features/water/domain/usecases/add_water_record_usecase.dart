import 'package:app_nutrituti/core/error/failures.dart';
import 'package:app_nutrituti/features/water/domain/entities/water_record.dart';
import 'package:app_nutrituti/features/water/domain/repositories/water_repository.dart';
import 'package:dartz/dartz.dart';

/// Parameters for adding a water record
class AddWaterRecordParams {
  final String id;
  final int amount;
  final DateTime timestamp;
  final String? note;

  const AddWaterRecordParams({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note,
  });
}

/// Use case for adding a water intake record
/// Implements validation and business rules
class AddWaterRecordUseCase {
  final WaterRepository _repository;

  const AddWaterRecordUseCase(this._repository);

  /// Execute the use case
  /// Returns Either Failure or WaterRecord
  Future<Either<Failure, WaterRecord>> call(AddWaterRecordParams params) async {
    // Validation: Amount must be positive
    if (params.amount <= 0) {
      return const Left(
        ValidationFailure('Quantidade de água deve ser maior que zero'),
      );
    }

    // Validation: Amount must be reasonable (max 2000ml per record)
    if (params.amount > 2000) {
      return const Left(
        ValidationFailure('Quantidade máxima por registro é 2000ml'),
      );
    }

    // Validation: ID must not be empty
    if (params.id.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do registro é obrigatório'),
      );
    }

    // Validation: Timestamp cannot be in the future
    if (params.timestamp.isAfter(DateTime.now())) {
      return const Left(
        ValidationFailure('Data do registro não pode ser no futuro'),
      );
    }

    // Validation: Note length (if provided)
    if (params.note != null && params.note!.trim().length > 200) {
      return const Left(
        ValidationFailure('Observação não pode ter mais de 200 caracteres'),
      );
    }

    // Create entity
    final record = WaterRecord(
      id: params.id.trim(),
      amount: params.amount,
      timestamp: params.timestamp,
      note: params.note?.trim(),
    );

    // Delegate to repository
    return await _repository.addWaterRecord(record);
  }
}
