import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/entities/log_entry.dart';
import '../../../../core/logging/services/logging_service.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_local_data_source.dart';
import '../datasources/maintenance_remote_data_source.dart';

@LazySingleton(as: MaintenanceRepository)
class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceRemoteDataSource remoteDataSource;
  final MaintenanceLocalDataSource localDataSource;
  final Connectivity connectivity;
  final LoggingService loggingService;

  // Controle de sync em background
  Completer<void>? _syncInProgress;
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(seconds: 5);

  MaintenanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required this.loggingService,
  });

  Future<bool> get _isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi) || 
           result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.ethernet);
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getAllMaintenanceRecords() async {
    try {
      // OFFLINE FIRST: Sempre retorna dados locais primeiro
      final localRecords = await localDataSource.getAllMaintenanceRecords();
      
      // Sync em background TEMPORARIAMENTE DESABILITADO devido a índices Firestore ausentes
      // _scheduleSyncInBackground();
      
      return Right(localRecords);
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Agenda sync em background com debounce para evitar múltiplas operações
  void _scheduleSyncInBackground() {
    // Cancelar timer anterior se existir
    _debounceTimer?.cancel();
    
    // Agendar novo sync com debounce
    _debounceTimer = Timer(_debounceDelay, () {
      unawaited(_syncAllMaintenanceRecordsInBackground());
    });
  }

  /// Sync em background sem bloquear a UI
  Future<void> _syncAllMaintenanceRecordsInBackground() async {
    // Verificar se já existe sync em progresso
    if (_syncInProgress != null && !_syncInProgress!.isCompleted) {
      return; // Sync já em andamento, evitar duplicação
    }
    
    _syncInProgress = Completer<void>();
    
    try {
      final isConnected = await _isConnected;
      if (!isConnected) {
        _syncInProgress!.complete();
        return;
      }

      // Sync remoto com controle adequado
      final remoteRecords = await remoteDataSource.getAllMaintenanceRecords();
      
      // Atualizar cache local
      for (final record in remoteRecords) {
        await localDataSource.addMaintenanceRecord(record);
      }
      
      // Sync bem-sucedido
      _syncInProgress!.complete();
      
    } catch (e) {
      // Log estruturado ao invés de print
      // TODO: Implementar logger adequado
      debugPrint('Background maintenance sync error: $e');
      _syncInProgress!.complete();
    }
  }

  /// Limpar recursos quando necessário
  void dispose() {
    _debounceTimer?.cancel();
    _syncInProgress?.complete();
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByVehicle(String vehicleId) async {
    try {
      // OFFLINE FIRST: Sempre retorna dados locais primeiro
      final localRecords = await localDataSource.getMaintenanceRecordsByVehicle(vehicleId);
      
      // Sync em background se conectado
      unawaited(_syncMaintenanceRecordsByVehicleInBackground(vehicleId));
      
      return Right(localRecords);
      
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Sync de registros por veículo em background
  Future<void> _syncMaintenanceRecordsByVehicleInBackground(String vehicleId) async {
    try {
      final isConnected = await _isConnected;
      if (!isConnected) return;

      unawaited(remoteDataSource.getMaintenanceRecordsByVehicle(vehicleId).then((remoteRecords) async {
        for (final record in remoteRecords) {
          await localDataSource.addMaintenanceRecord(record);
        }
      }).catchError((Object error) {
        // Log error adequadamente sem print em produção
        debugPrint('Background maintenance vehicle sync failed: $error');
      }));
    } catch (e) {
      // Log error adequadamente sem print em produção
      debugPrint('Background maintenance vehicle sync error: $e');
    } finally {
      // Garantir que o Completer sempre seja finalizado
      _syncInProgress?.complete();
    }
  }

  /// Sync de novo maintenance record para remoto em background sem bloquear UI
  Future<void> _syncMaintenanceRecordToRemoteInBackground(MaintenanceEntity maintenance) async {
    try {
      final isConnected = await _isConnected;
      if (!isConnected) {
        await loggingService.logInfo(
          category: LogCategory.maintenance,
          message: 'No connection available for background sync, maintenance record will sync later',
          metadata: {'maintenance_id': maintenance.id, 'vehicle_id': maintenance.vehicleId},
        );
        return;
      }

      // Fire-and-forget remote sync
      unawaited(remoteDataSource.addMaintenanceRecord(maintenance).then((_) async {
        await loggingService.logInfo(
          category: LogCategory.maintenance,
          message: 'Background sync to remote completed successfully',
          metadata: {
            'maintenance_id': maintenance.id,
            'vehicle_id': maintenance.vehicleId,
          },
        );
      }).catchError((Object error) async {
        await loggingService.logOperationWarning(
          category: LogCategory.maintenance,
          operation: LogOperation.sync,
          message: 'Background sync to remote failed - will retry later',
          metadata: {
            'maintenance_id': maintenance.id,
            'vehicle_id': maintenance.vehicleId,
            'error': error.toString(),
          },
        );
      }));
    } catch (e) {
      await loggingService.logOperationWarning(
        category: LogCategory.maintenance,
        operation: LogOperation.sync,
        message: 'Background sync setup failed',
        metadata: {
          'maintenance_id': maintenance.id,
          'vehicle_id': maintenance.vehicleId,
          'error': e.toString(),
        },
      );
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity?>> getMaintenanceRecordById(String id) async {
    try {
      if (await _isConnected) {
        final remoteRecord = await remoteDataSource.getMaintenanceRecordById(id);
        if (remoteRecord != null) {
          await localDataSource.addMaintenanceRecord(remoteRecord);
        }
        return Right(remoteRecord);
      } else {
        final localRecord = await localDataSource.getMaintenanceRecordById(id);
        return Right(localRecord);
      }
    } on ServerException catch (e) {
      try {
        final localRecord = await localDataSource.getMaintenanceRecordById(id);
        return Right(localRecord);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity>> addMaintenanceRecord(MaintenanceEntity maintenance) async {
    await loggingService.logOperationStart(
      category: LogCategory.maintenance,
      operation: LogOperation.create,
      message: 'Starting maintenance record creation for vehicle ${maintenance.vehicleId}',
      metadata: {
        'maintenance_id': maintenance.id,
        'vehicle_id': maintenance.vehicleId,
        'maintenance_type': maintenance.type.displayName,
        'cost': maintenance.cost.toString(),
        'odometer_reading': maintenance.odometer.toString(),
        'service_date': maintenance.serviceDate.toIso8601String(),
        'status': maintenance.status.displayName,
      },
    );

    try {
      await loggingService.logInfo(
        category: LogCategory.maintenance,
        message: 'Saving maintenance record to local storage',
        metadata: {
          'maintenance_id': maintenance.id,
          'vehicle_id': maintenance.vehicleId,
        },
      );

      // Always save locally first
      final localRecord = await localDataSource.addMaintenanceRecord(maintenance);

      await loggingService.logInfo(
        category: LogCategory.maintenance,
        message: 'Maintenance record saved to local storage successfully',
        metadata: {
          'maintenance_id': maintenance.id,
          'vehicle_id': maintenance.vehicleId,
        },
      );
      
      // Remote sync in background (fire-and-forget)
      unawaited(_syncMaintenanceRecordToRemoteInBackground(maintenance));
      
      await loggingService.logInfo(
        category: LogCategory.maintenance,
        message: 'Maintenance record saved locally, remote sync initiated in background',
        metadata: {
          'maintenance_id': maintenance.id,
          'vehicle_id': maintenance.vehicleId,
        },
      );
      
      await loggingService.logOperationSuccess(
        category: LogCategory.maintenance,
        operation: LogOperation.create,
        message: 'Maintenance record creation completed successfully',
        metadata: {
          'maintenance_id': maintenance.id,
          'vehicle_id': maintenance.vehicleId,
          'saved_locally': true,
          'remote_sync': 'background',
        },
      );

      return Right(localRecord);
    } on CacheException catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.maintenance,
        operation: LogOperation.create,
        message: 'Cache error during maintenance record creation',
        error: e,
        metadata: {
          'maintenance_id': maintenance.id,
          'vehicle_id': maintenance.vehicleId,
        },
      );
      return Left(CacheFailure(e.message));
    } catch (e) {
      await loggingService.logOperationError(
        category: LogCategory.maintenance,
        operation: LogOperation.create,
        message: 'Unexpected error during maintenance record creation',
        error: e,
        metadata: {
          'maintenance_id': maintenance.id,
          'vehicle_id': maintenance.vehicleId,
        },
      );
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity>> updateMaintenanceRecord(MaintenanceEntity maintenance) async {
    try {
      // Always update locally first
      final localRecord = await localDataSource.updateMaintenanceRecord(maintenance);
      
      if (await _isConnected) {
        try {
          await remoteDataSource.updateMaintenanceRecord(maintenance);
        } catch (e) {
          // Continue with local update if remote fails
        }
      }
      
      return Right(localRecord);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMaintenanceRecord(String id) async {
    try {
      // Delete locally first
      await localDataSource.deleteMaintenanceRecord(id);
      
      if (await _isConnected) {
        try {
          await remoteDataSource.deleteMaintenanceRecord(id);
        } catch (e) {
          // Continue with local deletion if remote fails
        }
      }
      
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> searchMaintenanceRecords(String query) async {
    try {
      if (await _isConnected) {
        final remoteRecords = await remoteDataSource.searchMaintenanceRecords(query);
        return Right(remoteRecords);
      } else {
        final localRecords = await localDataSource.searchMaintenanceRecords(query);
        return Right(localRecords);
      }
    } on ServerException catch (e) {
      try {
        final localRecords = await localDataSource.searchMaintenanceRecords(query);
        return Right(localRecords);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MaintenanceEntity>>> watchMaintenanceRecords() {
    try {
      return remoteDataSource.watchMaintenanceRecords()
          .map((records) => Right<Failure, List<MaintenanceEntity>>(records))
          .handleError((Object error) => Left<Failure, List<MaintenanceEntity>>(
                ServerFailure(error.toString()),
              ));
    } catch (e) {
      return Stream.value(Left(UnexpectedFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<MaintenanceEntity>>> watchMaintenanceRecordsByVehicle(String vehicleId) {
    try {
      return remoteDataSource.watchMaintenanceRecordsByVehicle(vehicleId)
          .map((records) => Right<Failure, List<MaintenanceEntity>>(records))
          .handleError((Object error) => Left<Failure, List<MaintenanceEntity>>(
                ServerFailure(error.toString()),
              ));
    } catch (e) {
      return Stream.value(Left(UnexpectedFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByType(String vehicleId, MaintenanceType type) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final filteredRecords = recordsList.where((record) => record.type == type).toList();
          return Right(filteredRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByStatus(String vehicleId, MaintenanceStatus status) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final filteredRecords = recordsList.where((record) => record.status == status).toList();
          return Right(filteredRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByDateRange(String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final filteredRecords = recordsList.where((record) {
            return record.serviceDate.isAfter(startDate) && record.serviceDate.isBefore(endDate);
          }).toList();
          return Right(filteredRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getUpcomingMaintenanceRecords(String vehicleId, {int days = 30}) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final cutoffDate = DateTime.now().add(Duration(days: days));
          final upcomingRecords = recordsList.where((record) {
            if (record.nextServiceDate == null) return false;
            return record.nextServiceDate!.isBefore(cutoffDate) && record.nextServiceDate!.isAfter(DateTime.now());
          }).toList();
          
          // Sort by next service date
          upcomingRecords.sort((a, b) => a.nextServiceDate!.compareTo(b.nextServiceDate!));
          
          return Right(upcomingRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getOverdueMaintenanceRecords(String vehicleId) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final now = DateTime.now();
          final overdueRecords = recordsList.where((record) {
            if (record.nextServiceDate == null) return false;
            return record.nextServiceDate!.isBefore(now);
          }).toList();
          
          return Right(overdueRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalMaintenanceCost(String vehicleId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          var filteredRecords = recordsList;
          
          if (startDate != null && endDate != null) {
            filteredRecords = recordsList.where((record) {
              return record.serviceDate.isAfter(startDate) && record.serviceDate.isBefore(endDate);
            }).toList();
          }
          
          final totalCost = filteredRecords.fold(0.0, (sum, record) => sum + record.cost);
          return Right(totalCost);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getMaintenanceCountByType(String vehicleId) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          final countByType = <String, int>{};
          
          for (final record in recordsList) {
            final typeName = record.type.displayName;
            countByType[typeName] = (countByType[typeName] ?? 0) + 1;
          }
          
          return Right(countByType);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageMaintenanceCost(String vehicleId) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          if (recordsList.isEmpty) return const Right(0.0);
          
          final totalCost = recordsList.fold(0.0, (sum, record) => sum + record.cost);
          final averageCost = totalCost / recordsList.length;
          
          return Right(averageCost);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getRecentMaintenanceRecords(String vehicleId, {int limit = 10}) async {
    try {
      final records = await getMaintenanceRecordsByVehicle(vehicleId);
      return records.fold(
        (failure) => Left(failure),
        (recordsList) {
          // Sort by service date (most recent first) and take limit
          recordsList.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
          final recentRecords = recordsList.take(limit).toList();
          
          return Right(recentRecords);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity?>> getLastMaintenanceRecord(String vehicleId) async {
    try {
      final recentRecords = await getRecentMaintenanceRecords(vehicleId, limit: 1);
      return recentRecords.fold(
        (failure) => Left(failure),
        (recordsList) {
          final lastRecord = recordsList.isNotEmpty ? recordsList.first : null;
          return Right(lastRecord);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}