import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../datasources/reminder_remote_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryHybridImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;
  final ReminderRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  ReminderRepositoryHybridImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<Either<Failure, List<Reminder>>> getReminders(String userId) async {
    try {
      final localReminders = await localDataSource.getReminders(userId);
      
      if (await isConnected) {
        try {
          final remoteReminders = await remoteDataSource.getReminders(userId);
          for (final remoteReminder in remoteReminders) {
            final localReminder = localReminders.firstWhere(
              (local) => local.id == remoteReminder.id,
              orElse: () => remoteReminder,
            );
            
            if (remoteReminder.updatedAt.isAfter(localReminder.updatedAt)) {
              await localDataSource.updateReminder(remoteReminder);
            }
          }
          
          final updatedLocalReminders = await localDataSource.getReminders(userId);
          return Right(updatedLocalReminders);
          
        } catch (e) {
          return Right(localReminders);
        }
      }
      
      return Right(localReminders);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getRemindersByAnimal(String animalId) async {
    try {
      final reminders = await localDataSource.getRemindersByAnimal(animalId);
      return Right(reminders);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao buscar lembretes do animal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getTodayReminders(String userId) async {
    try {
      final localReminders = await localDataSource.getTodayReminders(userId);
      
      if (await isConnected) {
        try {
          final remoteReminders = await remoteDataSource.getTodayReminders(userId);
          for (final remoteReminder in remoteReminders) {
            final localReminder = localReminders.firstWhere(
              (local) => local.id == remoteReminder.id,
              orElse: () => remoteReminder,
            );
            
            if (remoteReminder.updatedAt.isAfter(localReminder.updatedAt)) {
              await localDataSource.updateReminder(remoteReminder);
            }
          }
          
          final updatedReminders = await localDataSource.getTodayReminders(userId);
          return Right(updatedReminders);
          
        } catch (e) {
          return Right(localReminders);
        }
      }
      
      return Right(localReminders);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao buscar lembretes de hoje: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getOverdueReminders(String userId) async {
    try {
      final localReminders = await localDataSource.getOverdueReminders(userId);
      
      if (await isConnected) {
        try {
          final remoteReminders = await remoteDataSource.getOverdueReminders(userId);
          for (final remoteReminder in remoteReminders) {
            final localReminder = localReminders.firstWhere(
              (local) => local.id == remoteReminder.id,
              orElse: () => remoteReminder,
            );
            
            if (remoteReminder.updatedAt.isAfter(localReminder.updatedAt)) {
              await localDataSource.updateReminder(remoteReminder);
            }
          }
          
          final updatedReminders = await localDataSource.getOverdueReminders(userId);
          return Right(updatedReminders);
          
        } catch (e) {
          return Right(localReminders);
        }
      }
      
      return Right(localReminders);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao buscar lembretes atrasados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getUpcomingReminders(String userId, int days) async {
    try {
      final reminders = await localDataSource.getUpcomingReminders(userId, days);
      return Right(reminders);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao buscar próximos lembretes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addReminder(Reminder reminder) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      await localDataSource.addReminder(reminderModel);
      
      if (await isConnected) {
        try {
          final remoteId = await remoteDataSource.addReminder(reminderModel, reminder.userId);
          if (remoteId != reminderModel.id) {
            final updatedModel = reminderModel.copyWith(id: remoteId);
            await localDataSource.updateReminder(updatedModel);
          }
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao adicionar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReminder(Reminder reminder) async {
    try {
      final reminderModel = ReminderModel.fromEntity(reminder);
      await localDataSource.updateReminder(reminderModel);
      
      if (await isConnected) {
        try {
          await remoteDataSource.updateReminder(reminderModel);
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao atualizar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String reminderId) async {
    try {
      await localDataSource.deleteReminder(reminderId);
      
      if (await isConnected) {
        try {
          await remoteDataSource.deleteReminder(reminderId);
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao deletar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> completeReminder(String reminderId) async {
    try {
      final reminders = await localDataSource.getReminders('');
      final reminder = reminders.firstWhere((r) => r.id == reminderId);
      
      final completedReminder = reminder.copyWith(
        status: ReminderStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.updateReminder(completedReminder);
      
      if (await isConnected) {
        try {
          await remoteDataSource.updateReminder(completedReminder);
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao completar lembrete: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> snoozeReminder(String reminderId, DateTime snoozeUntil) async {
    try {
      final reminders = await localDataSource.getReminders('');
      final reminder = reminders.firstWhere((r) => r.id == reminderId);
      
      final snoozedReminder = reminder.copyWith(
        status: ReminderStatus.snoozed,
        snoozeUntil: snoozeUntil,
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.updateReminder(snoozedReminder);
      
      if (await isConnected) {
        try {
          await remoteDataSource.updateReminder(snoozedReminder);
        } catch (e) {
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erro ao adiar lembrete: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<Reminder>>> watchReminders(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getReminders(userId);
    }).asyncMap((future) => future);
  }

  @override
  Stream<Either<Failure, List<Reminder>>> watchTodayReminders(String userId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return getTodayReminders(userId);
    }).asyncMap((future) => future);
  }
}
