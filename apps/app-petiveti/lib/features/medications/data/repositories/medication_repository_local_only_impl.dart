import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_datasource.dart';
import '../models/medication_model.dart';

class MedicationRepositoryLocalOnlyImpl implements MedicationRepository {
  final MedicationLocalDataSource localDataSource;

  MedicationRepositoryLocalOnlyImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Medication>>> getMedications() async {
    try {
      final medicationModels = await localDataSource.getMedications();
      final medications = medicationModels.map((model) => model.toEntity()).toList();
      return Right(medications);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar medicamentos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> getMedicationsByAnimalId(String animalId) async {
    try {
      final medicationModels = await localDataSource.getMedicationsByAnimalId(animalId);
      final medications = medicationModels.map((model) => model.toEntity()).toList();
      return Right(medications);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar medicamentos do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> getActiveMedications() async {
    try {
      final medicationModels = await localDataSource.getActiveMedications();
      final medications = medicationModels.map((model) => model.toEntity()).toList();
      return Right(medications);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar medicamentos ativos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> getActiveMedicationsByAnimalId(String animalId) async {
    try {
      final medicationModels = await localDataSource.getActiveMedicationsByAnimalId(animalId);
      final medications = medicationModels.map((model) => model.toEntity()).toList();
      return Right(medications);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar medicamentos ativos do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> getExpiringSoonMedications() async {
    try {
      final medicationModels = await localDataSource.getExpiringSoonMedications();
      final medications = medicationModels.map((model) => model.toEntity()).toList();
      return Right(medications);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar medicamentos próximos ao vencimento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Medication>> getMedicationById(String id) async {
    try {
      final medicationModel = await localDataSource.getMedicationById(id);
      if (medicationModel == null) {
        return Left(CacheFailure(message: 'Medicamento não encontrado'));
      }
      return Right(medicationModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar medicamento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addMedication(Medication medication) async {
    try {
      final medicationModel = _createMedicationModel(medication);
      await localDataSource.cacheMedication(medicationModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao adicionar medicamento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedication(Medication medication) async {
    try {
      final medicationModel = _createMedicationModel(medication);
      await localDataSource.updateMedication(medicationModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao atualizar medicamento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    try {
      await localDataSource.deleteMedication(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao excluir medicamento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> hardDeleteMedication(String id) async {
    try {
      await localDataSource.hardDeleteMedication(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao excluir permanentemente medicamento: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> discontinueMedication(String id, String reason) async {
    try {
      await localDataSource.discontinueMedication(id, reason);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao descontinuar medicamento: ${e.toString()}'));
    }
  }

  @override
  Stream<List<Medication>> watchMedications() {
    return localDataSource.watchMedications().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Medication>> watchMedicationsByAnimalId(String animalId) {
    return localDataSource.watchMedicationsByAnimalId(animalId).map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Stream<List<Medication>> watchActiveMedications() {
    return localDataSource.watchActiveMedications().map(
      (models) => models.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<Either<Failure, List<Medication>>> searchMedications(String query) async {
    try {
      final medicationModels = await localDataSource.searchMedications(query);
      final medications = medicationModels.map((model) => model.toEntity()).toList();
      return Right(medications);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar medicamentos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final medicationModels = await localDataSource.getMedicationHistory(
        animalId,
        startDate,
        endDate,
      );
      final medications = medicationModels.map((model) => model.toEntity()).toList();
      return Right(medications);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar histórico de medicamentos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Medication>>> checkMedicationConflicts(
    Medication medication,
  ) async {
    try {
      final medicationModel = _createMedicationModel(medication);
      final conflictModels = await localDataSource.checkMedicationConflicts(medicationModel);
      final conflicts = conflictModels.map((model) => model.toEntity()).toList();
      return Right(conflicts);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao verificar conflitos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getActiveMedicationsCount(String animalId) async {
    try {
      final count = await localDataSource.getActiveMedicationsCount(animalId);
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao contar medicamentos ativos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> exportMedicationsData() async {
    try {
      final medicationModels = await localDataSource.getMedications();
      final data = medicationModels.map((model) => model.toJson()).toList();
      return Right(data);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao exportar dados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> importMedicationsData(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final medicationModels = data
          .map((json) => MedicationModel.fromJson(json))
          .toList();
      await localDataSource.cacheMedications(medicationModels);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao importar dados: ${e.toString()}'));
    }
  }

  MedicationModel _createMedicationModel(Medication medication) {
    return MedicationModel.fromEntity(medication);
  }
}