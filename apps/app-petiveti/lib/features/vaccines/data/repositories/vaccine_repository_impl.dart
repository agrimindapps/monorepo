import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/vaccine.dart';
import '../../domain/repositories/vaccine_repository.dart';
import '../datasources/vaccine_local_datasource.dart';
import '../datasources/vaccine_remote_datasource.dart';
import '../models/vaccine_model.dart';

class VaccineRepositoryImpl implements VaccineRepository {
  final VaccineLocalDataSource localDataSource;
  final VaccineRemoteDataSource remoteDataSource;

  VaccineRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // Helper methods
  Either<Failure, List<Vaccine>> _handleLocalSuccess(List<VaccineModel> models) {
    try {
      final vaccines = models.map((model) => model.toEntity()).toList();
      return Right(vaccines);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao converter dados: ${e.toString()}'));
    }
  }

  Either<Failure, Vaccine> _handleLocalSuccessSingle(VaccineModel model) {
    try {
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao converter dados: ${e.toString()}'));
    }
  }

  Future<void> _syncToRemote(Future<void> Function() remoteOperation) async {
    try {
      await remoteOperation();
    } on ServerException {
      // Ignore server errors for local-first approach
      // Data will be synced later when connection is available
    } catch (e) {
      // Ignore other sync errors
    }
  }

  // Basic CRUD operations
  @override
  Future<Either<Failure, List<Vaccine>>> getVaccines() async {
    try {
      final vaccineModels = await localDataSource.getVaccines();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacinas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByAnimal(String animalId) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByAnimalId(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacinas do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vaccine?>> getVaccineById(String id) async {
    try {
      final vaccineModel = await localDataSource.getVaccineById(id);
      if (vaccineModel == null) {
        return const Right(null);
      }
      return Right(vaccineModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao buscar vacina: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vaccine>> addVaccine(Vaccine vaccine) async {
    try {
      final vaccineModel = VaccineModel.fromEntity(vaccine);
      
      // Local-first: save to local storage immediately
      await localDataSource.addVaccine(vaccineModel);
      
      // Background sync to remote
      await _syncToRemote(() => remoteDataSource.addVaccine(vaccineModel));
      
      return Right(vaccine);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao adicionar vacina: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vaccine>> updateVaccine(Vaccine vaccine) async {
    try {
      final vaccineModel = VaccineModel.fromEntity(vaccine);
      
      // Local-first: update local storage immediately
      await localDataSource.updateVaccine(vaccineModel);
      
      // Background sync to remote
      await _syncToRemote(() => remoteDataSource.updateVaccine(vaccineModel));
      
      return Right(vaccine);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao atualizar vacina: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVaccine(String id) async {
    try {
      // Local-first: delete from local storage immediately
      await localDataSource.deleteVaccine(id);
      
      // Background sync to remote
      await _syncToRemote(() => remoteDataSource.deleteVaccine(id));
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao excluir vacina: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVaccinesByAnimal(String animalId) async {
    try {
      await localDataSource.deleteVaccinesByAnimalId(animalId);
      await _syncToRemote(() => remoteDataSource.deleteVaccinesByAnimalId(animalId));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado ao excluir vacinas: ${e.toString()}'));
    }
  }

  // Status-based queries
  @override
  Future<Either<Failure, List<Vaccine>>> getPendingVaccines([String? animalId]) async {
    try {
      final vaccineModels = await localDataSource.getPendingVaccines(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getOverdueVaccines([String? animalId]) async {
    try {
      final vaccineModels = await localDataSource.getOverdueVaccines(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getCompletedVaccines([String? animalId]) async {
    try {
      final vaccineModels = await localDataSource.getCompletedVaccines(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getRequiredVaccines([String? animalId]) async {
    try {
      final vaccineModels = await localDataSource.getRequiredVaccines(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getUpcomingVaccines([String? animalId]) async {
    try {
      final vaccineModels = await localDataSource.getUpcomingVaccines(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getDueTodayVaccines([String? animalId]) async {
    try {
      final vaccineModels = await localDataSource.getDueTodayVaccines(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getDueSoonVaccines([String? animalId]) async {
    try {
      final vaccineModels = await localDataSource.getDueSoonVaccines(animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  // Calendar and date-based queries
  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByDateRange(startDate, endDate, animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByMonth(
    int year,
    int month, [
    String? animalId,
  ]) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByMonth(year, month, animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, List<Vaccine>>>> getVaccineCalendar(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByDateRange(startDate, endDate, animalId);
      final vaccines = vaccineModels.map((model) => model.toEntity()).toList();
      
      // Group vaccines by date
      final Map<DateTime, List<Vaccine>> calendar = {};
      for (final vaccine in vaccines) {
        final date = DateTime(vaccine.date.year, vaccine.date.month, vaccine.date.day);
        calendar[date] ??= [];
        calendar[date]!.add(vaccine);
      }
      
      return Right(calendar);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  // Reminder functionality
  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesNeedingReminders() async {
    try {
      final vaccineModels = await localDataSource.getVaccinesNeedingReminders();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesWithActiveReminders() async {
    try {
      final vaccineModels = await localDataSource.getVaccinesWithActiveReminders();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Vaccine>> scheduleVaccineReminder(
    String vaccineId,
    DateTime reminderDate,
  ) async {
    try {
      // Get the vaccine first
      final vaccineModel = await localDataSource.getVaccineById(vaccineId);
      if (vaccineModel == null) {
        return const Left(ValidationFailure(message: 'Vacina não encontrada'));
      }

      // Update with reminder
      final updatedVaccine = vaccineModel.toEntity().scheduleReminder(reminderDate);
      final updatedModel = VaccineModel.fromEntity(updatedVaccine);
      
      // Local-first update
      await localDataSource.updateVaccine(updatedModel);
      
      // Background sync to remote
      await _syncToRemote(() => remoteDataSource.scheduleVaccineReminder(vaccineId, reminderDate));
      
      return Right(updatedVaccine);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeVaccineReminder(String vaccineId) async {
    try {
      // Get the vaccine first
      final vaccineModel = await localDataSource.getVaccineById(vaccineId);
      if (vaccineModel == null) {
        return const Left(ValidationFailure(message: 'Vacina não encontrada'));
      }

      // Update without reminder
      final updatedVaccine = vaccineModel.toEntity().copyWith(reminderDate: null);
      final updatedModel = VaccineModel.fromEntity(updatedVaccine);
      
      // Local-first update
      await localDataSource.updateVaccine(updatedModel);
      
      // Background sync to remote
      await _syncToRemote(() => remoteDataSource.removeVaccineReminder(vaccineId));
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  // Search and filtering
  @override
  Future<Either<Failure, List<Vaccine>>> searchVaccines(
    String query, [
    String? animalId,
  ]) async {
    try {
      final vaccineModels = await localDataSource.searchVaccines(query, animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByVeterinarian(
    String veterinarian, [
    String? animalId,
  ]) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByVeterinarian(veterinarian, animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByName(
    String vaccineName, [
    String? animalId,
  ]) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByName(vaccineName, animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByManufacturer(
    String manufacturer, [
    String? animalId,
  ]) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByManufacturer(manufacturer, animalId);
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  // Statistics and reporting
  @override
  Future<Either<Failure, Map<String, int>>> getVaccineStatistics([String? animalId]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(animalId)
        : await localDataSource.getVaccines();
      
      final stats = <String, int>{
        'total': allVaccines.length,
        'completed': allVaccines.where((v) => v.isCompleted).length,
        'pending': allVaccines.where((v) => v.toEntity().isPending).length,
        'overdue': allVaccines.where((v) => v.toEntity().isOverdue).length,
        'required': allVaccines.where((v) => v.isRequired).length,
        'optional': allVaccines.where((v) => !v.isRequired).length,
        'dueToday': allVaccines.where((v) => v.toEntity().isDueToday).length,
        'dueSoon': allVaccines.where((v) => v.toEntity().isDueSoon).length,
      };
      
      return Right(stats);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccineHistory(String animalId) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByAnimalId(animalId);
      final vaccines = vaccineModels.map((model) => model.toEntity()).toList();
      vaccines.sort((a, b) => b.date.compareTo(a.date));
      return Right(vaccines);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<Vaccine>>>> getVaccinesByStatus([String? animalId]) async {
    try {
      final vaccineModels = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(animalId)
        : await localDataSource.getVaccines();
      
      final vaccines = vaccineModels.map((model) => model.toEntity()).toList();
      final Map<String, List<Vaccine>> statusMap = {
        'completed': [],
        'pending': [],
        'overdue': [],
        'upcoming': [],
      };

      for (final vaccine in vaccines) {
        if (vaccine.isCompleted) {
          statusMap['completed']!.add(vaccine);
        } else if (vaccine.isOverdue) {
          statusMap['overdue']!.add(vaccine);
        } else if (vaccine.isPending) {
          statusMap['pending']!.add(vaccine);
        } else if (vaccine.nextDueDate != null && vaccine.nextDueDate!.isAfter(DateTime.now())) {
          statusMap['upcoming']!.add(vaccine);
        }
      }
      
      return Right(statusMap);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getVaccineNames() async {
    try {
      final vaccines = await localDataSource.getVaccines();
      final names = vaccines.map((v) => v.name).toSet().toList()..sort();
      return Right(names);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getVeterinarians() async {
    try {
      final vaccines = await localDataSource.getVaccines();
      final veterinarians = vaccines.map((v) => v.veterinarian).toSet().toList()..sort();
      return Right(veterinarians);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getManufacturers() async {
    try {
      final vaccines = await localDataSource.getVaccines();
      final manufacturers = vaccines
          .where((v) => v.manufacturer != null)
          .map((v) => v.manufacturer!)
          .toSet()
          .toList()..sort();
      return Right(manufacturers);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  // Bulk operations
  @override
  Future<Either<Failure, List<Vaccine>>> addMultipleVaccines(List<Vaccine> vaccines) async {
    try {
      final vaccineModels = vaccines.map((v) => VaccineModel.fromEntity(v)).toList();
      
      // Local-first: save to local storage immediately
      await localDataSource.addMultipleVaccines(vaccineModels);
      
      // Background sync to remote
      await _syncToRemote(() => remoteDataSource.addMultipleVaccines(vaccineModels));
      
      return Right(vaccines);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markVaccinesAsCompleted(List<String> vaccineIds) async {
    try {
      // Local-first: update local storage immediately
      await localDataSource.markVaccinesAsCompleted(vaccineIds);
      
      // Background sync to remote
      await _syncToRemote(() => remoteDataSource.markVaccinesAsCompleted(vaccineIds));
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateVaccineStatuses(
    List<String> vaccineIds,
    VaccineStatus status,
  ) async {
    try {
      // Update locally
      for (final id in vaccineIds) {
        final vaccine = await localDataSource.getVaccineById(id);
        if (vaccine != null) {
          final updatedVaccine = vaccine.toEntity().copyWith(status: status);
          await localDataSource.updateVaccine(VaccineModel.fromEntity(updatedVaccine));
        }
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  // Data synchronization
  @override
  Future<Either<Failure, void>> syncVaccines() async {
    try {
      // Get last sync time
      final lastSync = await remoteDataSource.getLastSyncTime();
      
      if (lastSync != null) {
        // Get vaccines modified after last sync
        final modifiedVaccines = await remoteDataSource.getVaccinesModifiedAfter(lastSync);
        
        // Update local cache with modified vaccines
        await localDataSource.cacheVaccines(modifiedVaccines.where((v) => !v.isDeleted).toList());
        
        // Handle deletions
        for (final vaccine in modifiedVaccines.where((v) => v.isDeleted)) {
          await localDataSource.deleteVaccine(vaccine.id);
        }
      }
      
      // Update last sync time
      await remoteDataSource.updateLastSyncTime();
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(NetworkFailure(message: 'Erro de sincronização: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      final lastSync = await remoteDataSource.getLastSyncTime();
      return Right(lastSync);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(NetworkFailure(message: 'Erro ao obter tempo de sincronização: ${e.toString()}'));
    }
  }

  // Data export/import
  @override
  Future<Either<Failure, Map<String, dynamic>>> exportVaccineData([String? animalId]) async {
    try {
      final vaccineModels = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(animalId)
        : await localDataSource.getVaccines();
      
      final data = {
        'vaccines': vaccineModels.map((v) => v.toMap()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'animalId': animalId,
        'totalVaccines': vaccineModels.length,
      };
      
      return Right(data);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao exportar dados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> importVaccineData(Map<String, dynamic> data) async {
    try {
      final vaccinesData = data['vaccines'] as List<dynamic>;
      final vaccineModels = vaccinesData
          .map((v) => VaccineModel.fromMap(v as Map<String, dynamic>))
          .toList();
      
      await localDataSource.cacheVaccines(vaccineModels);
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao importar dados: ${e.toString()}'));
    }
  }
}