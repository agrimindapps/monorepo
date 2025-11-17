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
  Either<Failure, List<Vaccine>> _handleLocalSuccess(
    List<VaccineModel> models,
  ) {
    try {
      final vaccines = models.map((model) => model.toEntity()).toList();
      return Right(vaccines);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Erro ao converter dados: ${e.toString()}'),
      );
    }
  }

  Future<void> _syncToRemote(Future<void> Function() remoteOperation) async {
    try {
      await remoteOperation();
    } catch (e) {
      // Remote sync failed, but local operation succeeded - will sync later
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccines() async {
    try {
      final vaccineModels = await localDataSource.getVaccines('');
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Erro inesperado ao buscar vacinas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByAnimal(
    String animalId,
  ) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByAnimalId(
        int.tryParse(animalId) ?? 0,
      );
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(
          message:
              'Erro inesperado ao buscar vacinas do animal: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Vaccine?>> getVaccineById(String id) async {
    try {
      final vaccineModel = await localDataSource.getVaccineById(int.tryParse(id) ?? 0);
      if (vaccineModel == null) {
        return const Right(null);
      }
      return Right(vaccineModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Erro inesperado ao buscar vacina: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Vaccine>> addVaccine(Vaccine vaccine) async {
    try {
      final vaccineModel = VaccineModel.fromEntity(vaccine);
      await localDataSource.addVaccine(vaccineModel);
      await _syncToRemote(() => remoteDataSource.addVaccine(vaccineModel));

      return Right(vaccine);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Erro inesperado ao adicionar vacina: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Vaccine>> updateVaccine(Vaccine vaccine) async {
    try {
      final vaccineModel = VaccineModel.fromEntity(vaccine);
      await localDataSource.updateVaccine(vaccineModel);
      await _syncToRemote(() => remoteDataSource.updateVaccine(vaccineModel));

      return Right(vaccine);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Erro inesperado ao atualizar vacina: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteVaccine(String id) async {
    try {
      // Convert String ID to int for datasource
      final intId = int.tryParse(id);
      if (intId == null) {
        return const Left(CacheFailure(message: 'Invalid vaccine ID format'));
      }
      
      await localDataSource.deleteVaccine(intId);
      await _syncToRemote(() => remoteDataSource.deleteVaccine(id));

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Erro inesperado ao excluir vacina: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteVaccinesByAnimal(String animalId) async {
    try {
      final vaccines = await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0);
      for (final vaccine in vaccines) {
        if (vaccine.id != null) {
          await localDataSource.deleteVaccine(vaccine.id!);
        }
      }
      await _syncToRemote(
        () => remoteDataSource.deleteVaccinesByAnimalId(animalId),
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Erro inesperado ao excluir vacinas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getPendingVaccines([
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.toEntity().isPending).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getOverdueVaccines([
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.toEntity().isOverdue).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getCompletedVaccines([
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.isCompleted).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getRequiredVaccines([
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.isRequired).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getUpcomingVaccines([
    String? animalId,
  ]) async {
    try {
      final vaccineModels = animalId != null 
        ? await localDataSource.getUpcomingVaccines(int.tryParse(animalId) ?? 0)
        : <VaccineModel>[];
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getDueTodayVaccines([
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.toEntity().isDueToday).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getDueSoonVaccines([
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.toEntity().isDueSoon).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) {
        final vaccine = v.toEntity();
        return vaccine.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
               vaccine.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
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
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) {
        final vaccine = v.toEntity();
        return vaccine.date.year == year && vaccine.date.month == month;
      }).toList();
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
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) {
        final vaccine = v.toEntity();
        return vaccine.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
               vaccine.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
      final vaccines = vaccineModels.map((VaccineModel model) => model.toEntity()).toList();
      final Map<DateTime, List<Vaccine>> calendar = {};
      for (final vaccine in vaccines) {
        final date = DateTime(
          vaccine.date.year,
          vaccine.date.month,
          vaccine.date.day,
        );
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

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesNeedingReminders() async {
    try {
      final allVaccines = await localDataSource.getVaccines('');
      final now = DateTime.now();
      final vaccineModels = allVaccines.where((v) {
        final vaccine = v.toEntity();
        return vaccine.reminderDate != null && 
               vaccine.reminderDate!.isBefore(now) && 
               !vaccine.isCompleted;
      }).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>>
  getVaccinesWithActiveReminders() async {
    try {
      final allVaccines = await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.toEntity().reminderDate != null).toList();
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
      final vaccineModel = await localDataSource.getVaccineById(int.tryParse(vaccineId) ?? 0);
      if (vaccineModel == null) {
        return const Left(ValidationFailure(message: 'Vacina não encontrada'));
      }
      final updatedVaccine = vaccineModel.toEntity().scheduleReminder(
        reminderDate,
      );
      final updatedModel = VaccineModel.fromEntity(updatedVaccine);
      await localDataSource.updateVaccine(updatedModel);
      await _syncToRemote(
        () => remoteDataSource.scheduleVaccineReminder(vaccineId, reminderDate),
      );

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
      final vaccineModel = await localDataSource.getVaccineById(int.tryParse(vaccineId) ?? 0);
      if (vaccineModel == null) {
        return const Left(ValidationFailure(message: 'Vacina não encontrada'));
      }
      final updatedVaccine = vaccineModel.toEntity().copyWith(
        reminderDate: null,
      );
      final updatedModel = VaccineModel.fromEntity(updatedVaccine);
      await localDataSource.updateVaccine(updatedModel);
      await _syncToRemote(
        () => remoteDataSource.removeVaccineReminder(vaccineId),
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> searchVaccines(
    String query, [
    String? animalId,
  ]) async {
    try {
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final queryLower = query.toLowerCase();
      final vaccineModels = allVaccines.where((v) {
        final vaccine = v.toEntity();
        return vaccine.name.toLowerCase().contains(queryLower) ||
               vaccine.veterinarian.toLowerCase().contains(queryLower) ||
               (vaccine.notes?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
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
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.veterinarian == veterinarian).toList();
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
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.name == vaccineName).toList();
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
      final allVaccines = animalId != null 
        ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
        : await localDataSource.getVaccines('');
      final vaccineModels = allVaccines.where((v) => v.manufacturer == manufacturer).toList();
      return _handleLocalSuccess(vaccineModels);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getVaccineStatistics([
    String? animalId,
  ]) async {
    try {
      final allVaccines =
          animalId != null
              ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
              : await localDataSource.getVaccines('');

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
  Future<Either<Failure, List<Vaccine>>> getVaccineHistory(
    String animalId,
  ) async {
    try {
      final vaccineModels = await localDataSource.getVaccinesByAnimalId(
        int.tryParse(animalId) ?? 0,
      );
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
  Future<Either<Failure, Map<String, List<Vaccine>>>> getVaccinesByStatus([
    String? animalId,
  ]) async {
    try {
      final vaccineModels =
          animalId != null
              ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
              : await localDataSource.getVaccines('');

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
        } else if (vaccine.nextDueDate != null &&
            vaccine.nextDueDate!.isAfter(DateTime.now())) {
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
      final vaccines = await localDataSource.getVaccines('');
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
      final vaccines = await localDataSource.getVaccines('');
      final veterinarians =
          vaccines.map((v) => v.veterinarian).toSet().toList()..sort();
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
      final vaccines = await localDataSource.getVaccines('');
      final manufacturers =
          vaccines
              .where((v) => v.manufacturer != null)
              .map((v) => v.manufacturer!)
              .toSet()
              .toList()
            ..sort();
      return Right(manufacturers);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Vaccine>>> addMultipleVaccines(
    List<Vaccine> vaccines,
  ) async {
    try {
      final vaccineModels =
          vaccines.map((v) => VaccineModel.fromEntity(v)).toList();
      for (final model in vaccineModels) {
        await localDataSource.addVaccine(model);
      }
      await _syncToRemote(
        () => remoteDataSource.addMultipleVaccines(vaccineModels),
      );

      return Right(vaccines);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markVaccinesAsCompleted(
    List<String> vaccineIds,
  ) async {
    try {
      for (final id in vaccineIds) {
        final vaccine = await localDataSource.getVaccineById(int.tryParse(id) ?? 0);
        if (vaccine != null) {
          final updated = vaccine.toEntity().copyWith(isCompleted: true);
          await localDataSource.updateVaccine(VaccineModel.fromEntity(updated));
        }
      }
      await _syncToRemote(
        () => remoteDataSource.markVaccinesAsCompleted(vaccineIds),
      );

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
      for (final id in vaccineIds) {
        final vaccine = await localDataSource.getVaccineById(int.tryParse(id) ?? 0);
        if (vaccine != null) {
          final updatedVaccine = vaccine.toEntity().copyWith(status: status);
          await localDataSource.updateVaccine(
            VaccineModel.fromEntity(updatedVaccine),
          );
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncVaccines() async {
    try {
      final lastSync = await remoteDataSource.getLastSyncTime();

      if (lastSync != null) {
        final modifiedVaccines = await remoteDataSource
            .getVaccinesModifiedAfter(lastSync);
        for (final vaccine in modifiedVaccines.where((v) => !v.isDeleted)) {
          await localDataSource.addVaccine(vaccine);
        }
        for (final vaccine in modifiedVaccines.where((v) => v.isDeleted)) {
          if (vaccine.id != null) {
            await localDataSource.deleteVaccine(vaccine.id!);
          }
        }
      }
      await remoteDataSource.updateLastSyncTime();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        NetworkFailure(message: 'Erro de sincronização: ${e.toString()}'),
      );
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
      return Left(
        NetworkFailure(
          message: 'Erro ao obter tempo de sincronização: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportVaccineData([
    String? animalId,
  ]) async {
    try {
      final vaccineModels =
          animalId != null
              ? await localDataSource.getVaccinesByAnimalId(int.tryParse(animalId) ?? 0)
              : await localDataSource.getVaccines('');

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
      return Left(
        CacheFailure(message: 'Erro ao exportar dados: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> importVaccineData(
    Map<String, dynamic> data,
  ) async {
    try {
      final vaccinesData = data['vaccines'] as List<dynamic>;
      final vaccineModels =
          vaccinesData
              .map((v) => VaccineModel.fromMap(v as Map<String, dynamic>))
              .toList();

      for (final model in vaccineModels) {
        await localDataSource.addVaccine(model);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        CacheFailure(message: 'Erro ao importar dados: ${e.toString()}'),
      );
    }
  }
}