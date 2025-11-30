import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../entities/fuel_record_entity.dart';
import '../services/i_fuel_crud_service.dart';
import '../usecases/add_fuel_record.dart';
import '../usecases/delete_fuel_record.dart';
import '../usecases/update_fuel_record.dart';

/// Serviço especializado em operações CRUD de combustível (Create/Read/Update/Delete)
///
/// **Responsabilidades:**
/// - Adicionar novos registros de combustível
/// - Atualizar registros existentes
/// - Deletar registros
/// - Apenas operações CRUD diretas, sem lógica complexa
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas CRUD operations
/// - Dependency Injection via constructor
/// - Error handling via Either<Failure, T>
/// - Interface Segregation: Implementa IFuelCrudService
///
/// **Exemplo:**
/// ```dart
/// final service = FuelCrudService(addUseCase, updateUseCase, deleteUseCase);
/// final result = await service.addFuel(record);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (record) => print('Added: ${record.id}'),
/// );
/// ```
class FuelCrudService implements IFuelCrudService {
  FuelCrudService({
    required AddFuelRecord addFuelRecord,
    required UpdateFuelRecord updateFuelRecord,
    required DeleteFuelRecord deleteFuelRecord,
  })  : _addFuelRecord = addFuelRecord,
        _updateFuelRecord = updateFuelRecord,
        _deleteFuelRecord = deleteFuelRecord;

  final AddFuelRecord _addFuelRecord;
  final UpdateFuelRecord _updateFuelRecord;
  final DeleteFuelRecord _deleteFuelRecord;

  /// Adiciona um novo registro de combustível
  ///
  /// **Quando usar:**
  /// - Usuário cria novo abastecimento
  /// - Offline-first: salva localmente primeiro
  ///
  /// **Retorna:**
  /// - Right(record): Combustível adicionado com sucesso
  /// - Left(failure): Erro na adição
  @override
  Future<Either<Failure, FuelRecordEntity>> addFuel(
    FuelRecordEntity record,
  ) async {
    try {
      developer.log(
        '➕ Adding fuel record: ${record.id}',
        name: 'FuelCRUD',
      );

      final result = await _addFuelRecord(AddFuelRecordParams(fuelRecord: record));

      return result.fold(
        (failure) {
          developer.log(
            '❌ Failed to add fuel: ${failure.message}',
            name: 'FuelCRUD',
          );
          return Left(failure);
        },
        (record) {
          developer.log(
            '✅ Fuel record added: ${record.id}',
            name: 'FuelCRUD',
          );
          return Right(record);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Exception adding fuel: $e',
        name: 'FuelCRUD',
      );
      return Left(CacheFailure('Failed to add fuel record: $e'));
    }
  }

  /// Atualiza um registro de combustível existente
  ///
  /// **Quando usar:**
  /// - Usuário edita abastecimento
  /// - Offline-first: atualiza localmente
  ///
  /// **Retorna:**
  /// - Right(record): Combustível atualizado
  /// - Left(failure): Erro na atualização
  @override
  Future<Either<Failure, FuelRecordEntity>> updateFuel(
    FuelRecordEntity record,
  ) async {
    try {
      developer.log(
        '✏️ Updating fuel record: ${record.id}',
        name: 'FuelCRUD',
      );

      final result = await _updateFuelRecord(
        UpdateFuelRecordParams(fuelRecord: record),
      );

      return result.fold(
        (failure) {
          developer.log(
            '❌ Failed to update fuel: ${failure.message}',
            name: 'FuelCRUD',
          );
          return Left(failure);
        },
        (record) {
          developer.log(
            '✅ Fuel record updated: ${record.id}',
            name: 'FuelCRUD',
          );
          return Right(record);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Exception updating fuel: $e',
        name: 'FuelCRUD',
      );
      return Left(CacheFailure('Failed to update fuel record: $e'));
    }
  }

  /// Deleta um registro de combustível
  ///
  /// **Quando usar:**
  /// - Usuário deleta abastecimento
  /// - Soft delete: marca como isDirty para sincronizar
  ///
  /// **Retorna:**
  /// - Right(null): Combustível deletado
  /// - Left(failure): Erro na deleção
  @override
  Future<Either<Failure, void>> deleteFuel(String recordId) async {
    try {
      developer.log(
        '🗑️ Deleting fuel record: $recordId',
        name: 'FuelCRUD',
      );

      final result = await _deleteFuelRecord(
        DeleteFuelRecordParams(id: recordId),
      );

      return result.fold(
        (failure) {
          developer.log(
            '❌ Failed to delete fuel: ${failure.message}',
            name: 'FuelCRUD',
          );
          return Left(failure);
        },
        (_) {
          developer.log(
            '✅ Fuel record deleted: $recordId',
            name: 'FuelCRUD',
          );
          return const Right(null);
        },
      );
    } catch (e) {
      developer.log(
        '❌ Exception deleting fuel: $e',
        name: 'FuelCRUD',
      );
      return Left(CacheFailure('Failed to delete fuel record: $e'));
    }
  }
}
