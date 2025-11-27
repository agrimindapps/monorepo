import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../database/repositories/odometer_reading_repository.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/repositories/odometer_repository.dart';
import '../datasources/odometer_reading_local_datasource.dart';
import '../sync/odometer_drift_sync_adapter.dart';

/// Implementação do repositório de odômetro usando Drift
///
/// Padrão "Sync-on-Write": Sincroniza imediatamente com Firebase quando online,
/// seguindo o padrão do app-plantis. Background sync permanece como fallback.

class OdometerRepositoryDriftImpl implements OdometerRepository {
  const OdometerRepositoryDriftImpl(
    this._dataSource,
    this._connectivityService,
    this._syncAdapter,
  );

  final OdometerReadingLocalDataSource _dataSource;
  final ConnectivityService _connectivityService;
  final OdometerDriftSyncAdapter _syncAdapter;

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ========== CONVERSÕES ==========

  OdometerEntity _toEntity(OdometerReadingData data) {
    return OdometerEntity(
      id: data.id.toString(),
      vehicleId: data.vehicleId.toString(),
      value: data.reading,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(data.date),
      description: data.notes ?? '',
      type: OdometerType.other, // Default type
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      userId: data.userId,
      moduleName: data.moduleName,
    );
  }

  // ========== CRUD BÁSICO ==========

  @override
  Future<Either<Failure, List<OdometerEntity>>> getAllOdometerReadings() async {
    try {
      final dataList = await _dataSource.findAll();
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OdometerEntity?>> getOdometerReadingById(
    String id,
  ) async {
    try {
      final idInt = int.parse(id);
      final data = await _dataSource.findById(idInt);
      final entity = data != null ? _toEntity(data) : null;
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OdometerEntity?>> addOdometerReading(
    OdometerEntity reading,
  ) async {
    try {
      developer.log(
        '🔵 OdometerRepository.addOdometerReading() - Starting',
        name: 'OdometerRepository',
      );

      // 1. Salvar localmente primeiro (sempre)
      final id = await _dataSource.create(
        userId: _userId,
        vehicleId: int.parse(reading.vehicleId),
        reading: reading.value,
        date: reading.registrationDate,
        notes: reading.description.isEmpty ? null : reading.description,
      );

      // Buscar o registro criado para retornar
      final created = await _dataSource.findById(id);
      if (created == null) {
        return const Left(CacheFailure('Failed to retrieve created record'));
      }

      var entity = _toEntity(created);
      developer.log(
        '✅ OdometerRepository.addOdometerReading() - Saved locally with id=$id',
        name: 'OdometerRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente com Firebase
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 OdometerRepository.addOdometerReading() - Online, syncing to Firebase...',
          name: 'OdometerRepository',
        );
        try {
          // Push para Firebase usando o adapter
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ OdometerRepository.addOdometerReading() - Sync failed: ${failure.message}. Will retry via background sync.',
                name: 'OdometerRepository',
              );
            },
            (result) {
              developer.log(
                '✅ OdometerRepository.addOdometerReading() - Synced to Firebase (${result.recordsPushed} pushed, ${result.recordsFailed} failed)',
                name: 'OdometerRepository',
              );
            },
          );

          // Reload entity com estado atualizado (isDirty=false, firebaseId set)
          final refreshed = await _dataSource.findById(id);
          if (refreshed != null) {
            entity = _toEntity(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ OdometerRepository.addOdometerReading() - Sync error: $e. Will retry via background sync.',
            name: 'OdometerRepository',
          );
          // Falhou remoto, mas local já está salvo - retorna local
        }
      } else {
        developer.log(
          '📴 OdometerRepository.addOdometerReading() - Offline, will sync later via background sync',
          name: 'OdometerRepository',
        );
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ OdometerRepository.addOdometerReading() - Error: $e',
        name: 'OdometerRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OdometerEntity?>> updateOdometerReading(
    OdometerEntity reading,
  ) async {
    try {
      developer.log(
        '🔵 OdometerRepository.updateOdometerReading() - Starting for id=${reading.id}',
        name: 'OdometerRepository',
      );

      // 1. Atualizar localmente primeiro
      final idInt = int.parse(reading.id);
      final success = await _dataSource.update(
        id: idInt,
        userId: _userId,
        vehicleId: int.parse(reading.vehicleId),
        reading: reading.value,
        date: reading.registrationDate,
        notes: reading.description.isEmpty ? null : reading.description,
      );

      if (!success) {
        return const Left(CacheFailure('Failed to update odometer reading'));
      }

      // Buscar o registro atualizado para retornar
      final updated = await _dataSource.findById(idInt);
      if (updated == null) {
        return const Left(CacheFailure('Failed to retrieve updated record'));
      }

      var entity = _toEntity(updated);
      developer.log(
        '✅ OdometerRepository.updateOdometerReading() - Updated locally',
        name: 'OdometerRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 OdometerRepository.updateOdometerReading() - Online, syncing to Firebase...',
          name: 'OdometerRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ OdometerRepository.updateOdometerReading() - Sync failed: ${failure.message}',
                name: 'OdometerRepository',
              );
            },
            (result) {
              developer.log(
                '✅ OdometerRepository.updateOdometerReading() - Synced to Firebase',
                name: 'OdometerRepository',
              );
            },
          );

          // Reload entity com estado atualizado
          final refreshed = await _dataSource.findById(idInt);
          if (refreshed != null) {
            entity = _toEntity(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ OdometerRepository.updateOdometerReading() - Sync error: $e',
            name: 'OdometerRepository',
          );
        }
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ OdometerRepository.updateOdometerReading() - Error: $e',
        name: 'OdometerRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteOdometerReading(String id) async {
    try {
      developer.log(
        '🔵 OdometerRepository.deleteOdometerReading() - Starting for id=$id',
        name: 'OdometerRepository',
      );

      // 1. Soft delete localmente primeiro (marca isDeleted=true, isDirty=true)
      final idInt = int.parse(id);
      final success = await _dataSource.delete(idInt);

      if (!success) {
        return const Left(CacheFailure('Failed to delete odometer reading'));
      }

      developer.log(
        '✅ OdometerRepository.deleteOdometerReading() - Marked as deleted locally',
        name: 'OdometerRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 OdometerRepository.deleteOdometerReading() - Online, syncing deletion to Firebase...',
          name: 'OdometerRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ OdometerRepository.deleteOdometerReading() - Sync failed: ${failure.message}',
                name: 'OdometerRepository',
              );
            },
            (result) {
              developer.log(
                '✅ OdometerRepository.deleteOdometerReading() - Synced deletion to Firebase',
                name: 'OdometerRepository',
              );
            },
          );
        } catch (e) {
          developer.log(
            '⚠️ OdometerRepository.deleteOdometerReading() - Sync error: $e',
            name: 'OdometerRepository',
          );
        }
      }

      return Right(success);
    } catch (e) {
      developer.log(
        '❌ OdometerRepository.deleteOdometerReading() - Error: $e',
        name: 'OdometerRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OdometerEntity>>> getOdometerReadingsByVehicle(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final dataList = await _dataSource.findByVehicleId(vehicleIdInt);
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OdometerEntity?>> getLastOdometerReading(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final data = await _dataSource.findLatestByVehicleId(vehicleIdInt);
      final entity = data != null ? _toEntity(data) : null;
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OdometerEntity>>> getOdometerReadingsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Busca todas as leituras e filtra por período
      final dataList = await _dataSource.findAll();
      final entities = dataList
          .map(_toEntity)
          .where(
            (entity) =>
                entity.registrationDate.isAfter(startDate) &&
                entity.registrationDate.isBefore(endDate),
          )
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OdometerEntity>>> getOdometerReadingsByType(
    OdometerType type,
  ) async {
    try {
      // Por enquanto retorna todas (type não está armazenado no Drift)
      final dataList = await _dataSource.findAll();
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OdometerEntity>>> findDuplicates() async {
    try {
      // Por enquanto retorna lista vazia
      // Implementação completa requer query complexa
      return const Right([]);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OdometerEntity>>> searchOdometerReadings(
    String query,
  ) async {
    try {
      final dataList = await _dataSource.findAll();
      final entities = dataList.map(_toEntity).where((entity) {
        final matchesNotes = entity.description.toLowerCase().contains(
          query.toLowerCase(),
        );
        final matchesValue = entity.value.toString().contains(query);
        return matchesNotes || matchesValue;
      }).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVehicleStats(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);

      final totalDistance = await _dataSource.calculateTotalDistance(
        vehicleIdInt,
      );
      final count = await _dataSource.countByVehicleId(vehicleIdInt);
      final latest = await _dataSource.findLatestByVehicleId(vehicleIdInt);
      final first = await _dataSource.findFirstByVehicleId(vehicleIdInt);

      return Right({
        'totalDistance': totalDistance,
        'totalReadings': count,
        'latestReading': latest?.reading ?? 0.0,
        'firstReading': first?.reading ?? 0.0,
        'latestDate': latest?.dateTime.toIso8601String(),
        'firstDate': first?.dateTime.toIso8601String(),
      });
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
