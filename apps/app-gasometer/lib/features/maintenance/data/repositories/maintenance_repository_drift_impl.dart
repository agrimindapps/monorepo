import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../database/repositories/maintenance_repository.dart' as db;
import '../../domain/entities/maintenance_entity.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_local_datasource.dart';
import '../sync/maintenance_drift_sync_adapter.dart';

/// Implementação do repositório de manutenções usando Drift
///
/// Padrão "Sync-on-Write": Sincroniza imediatamente com Firebase quando online,
/// seguindo o padrão do app-plantis. Background sync permanece como fallback.

class MaintenanceRepositoryDriftImpl implements MaintenanceRepository {
  const MaintenanceRepositoryDriftImpl(
    this._dataSource,
    this._connectivityService,
    this._syncAdapter,
  );

  final MaintenanceLocalDataSource _dataSource;
  final ConnectivityService _connectivityService;
  final MaintenanceDriftSyncAdapter _syncAdapter;

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ========== CONVERSÕES ==========

  MaintenanceEntity _toEntity(db.MaintenanceData data) {
    return MaintenanceEntity(
      id: data.id.toString(),
      vehicleId: data.vehicleId.toString(),
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == data.tipo,
        orElse: () => MaintenanceType.corrective,
      ),
      status: data.concluida
          ? MaintenanceStatus.completed
          : MaintenanceStatus.pending,
      title: data.descricao,
      description: data.descricao,
      cost: data.valor,
      serviceDate: DateTime.fromMillisecondsSinceEpoch(data.data),
      odometer: data.odometro.toDouble(),
      nextServiceDate: data.proximaRevisao != null
          ? DateTime.fromMillisecondsSinceEpoch(data.proximaRevisao!)
          : null,
      nextServiceOdometer: null, // Não temos este campo na tabela atual
      photosPaths: const [], // Não temos este campo na tabela atual
      invoicesPaths: data.receiptImagePath != null
          ? [data.receiptImagePath!]
          : const [],
      parts: const {}, // Não temos este campo na tabela atual
      notes: null, // Não temos este campo na tabela atual
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      userId: data.userId,
      moduleName: data.moduleName,
      metadata: const {},
    );
  }

  // ========== CRUD BÁSICO ==========

  @override
  Future<Either<Failure, List<MaintenanceEntity>>>
  getAllMaintenanceRecords() async {
    try {
      final dataList = await _dataSource.findAll();
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>>
  getMaintenanceRecordsByVehicle(String vehicleId) async {
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
  Future<Either<Failure, MaintenanceEntity?>> getMaintenanceRecordById(
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
  Future<Either<Failure, MaintenanceEntity>> addMaintenanceRecord(
    MaintenanceEntity maintenance,
  ) async {
    try {
      developer.log(
        '🔵 MaintenanceRepository.addMaintenanceRecord() - Starting',
        name: 'MaintenanceRepository',
      );

      // 1. Salvar localmente primeiro (sempre)
      final id = await _dataSource.create(
        userId: _userId,
        vehicleId: int.parse(maintenance.vehicleId),
        tipo: maintenance.type.name,
        descricao: maintenance.title,
        valor: maintenance.cost,
        data: maintenance.serviceDate,
        odometro: maintenance.odometer.toInt(),
        proximaRevisao: maintenance.nextServiceDate?.millisecondsSinceEpoch,
        concluida: maintenance.status == MaintenanceStatus.completed,
        receiptImagePath: maintenance.invoicesPaths.isNotEmpty
            ? maintenance.invoicesPaths.first
            : null,
      );

      // Buscar o registro criado para retornar
      final createdData = await _dataSource.findById(id);
      if (createdData == null) {
        return Left(
          CacheFailure('Failed to retrieve created maintenance record'),
        );
      }

      var entity = _toEntity(createdData);
      developer.log(
        '✅ MaintenanceRepository.addMaintenanceRecord() - Saved locally with id=$id',
        name: 'MaintenanceRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente com Firebase
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 MaintenanceRepository.addMaintenanceRecord() - Online, syncing to Firebase...',
          name: 'MaintenanceRepository',
        );
        try {
          // Push para Firebase usando o adapter
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ MaintenanceRepository.addMaintenanceRecord() - Sync failed: ${failure.message}. Will retry via background sync.',
                name: 'MaintenanceRepository',
              );
            },
            (result) {
              developer.log(
                '✅ MaintenanceRepository.addMaintenanceRecord() - Synced to Firebase (${result.recordsPushed} pushed, ${result.recordsFailed} failed)',
                name: 'MaintenanceRepository',
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
            '⚠️ MaintenanceRepository.addMaintenanceRecord() - Sync error: $e. Will retry via background sync.',
            name: 'MaintenanceRepository',
          );
          // Falhou remoto, mas local já está salvo - retorna local
        }
      } else {
        developer.log(
          '📴 MaintenanceRepository.addMaintenanceRecord() - Offline, will sync later via background sync',
          name: 'MaintenanceRepository',
        );
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ MaintenanceRepository.addMaintenanceRecord() - Error: $e',
        name: 'MaintenanceRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity>> updateMaintenanceRecord(
    MaintenanceEntity maintenance,
  ) async {
    try {
      developer.log(
        '🔵 MaintenanceRepository.updateMaintenanceRecord() - Starting for id=${maintenance.id}',
        name: 'MaintenanceRepository',
      );

      // 1. Atualizar localmente primeiro
      final idInt = int.parse(maintenance.id);
      final success = await _dataSource.update(
        id: idInt,
        userId: _userId,
        vehicleId: int.parse(maintenance.vehicleId),
        tipo: maintenance.type.name,
        descricao: maintenance.title,
        valor: maintenance.cost,
        data: maintenance.serviceDate,
        odometro: maintenance.odometer.toInt(),
        proximaRevisao: maintenance.nextServiceDate?.millisecondsSinceEpoch,
        concluida: maintenance.status == MaintenanceStatus.completed,
        receiptImagePath: maintenance.invoicesPaths.isNotEmpty
            ? maintenance.invoicesPaths.first
            : null,
      );

      if (!success) {
        return Left(CacheFailure('Failed to update maintenance record'));
      }

      // Buscar o registro atualizado para retornar
      final updatedData = await _dataSource.findById(idInt);
      if (updatedData == null) {
        return Left(
          CacheFailure('Failed to retrieve updated maintenance record'),
        );
      }

      var entity = _toEntity(updatedData);
      developer.log(
        '✅ MaintenanceRepository.updateMaintenanceRecord() - Updated locally',
        name: 'MaintenanceRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 MaintenanceRepository.updateMaintenanceRecord() - Online, syncing to Firebase...',
          name: 'MaintenanceRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ MaintenanceRepository.updateMaintenanceRecord() - Sync failed: ${failure.message}',
                name: 'MaintenanceRepository',
              );
            },
            (result) {
              developer.log(
                '✅ MaintenanceRepository.updateMaintenanceRecord() - Synced to Firebase',
                name: 'MaintenanceRepository',
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
            '⚠️ MaintenanceRepository.updateMaintenanceRecord() - Sync error: $e',
            name: 'MaintenanceRepository',
          );
        }
      }

      return Right(entity);
    } catch (e) {
      developer.log(
        '❌ MaintenanceRepository.updateMaintenanceRecord() - Error: $e',
        name: 'MaintenanceRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMaintenanceRecord(String id) async {
    try {
      developer.log(
        '🔵 MaintenanceRepository.deleteMaintenanceRecord() - Starting for id=$id',
        name: 'MaintenanceRepository',
      );

      // 1. Soft delete localmente primeiro (marca isDeleted=true, isDirty=true)
      final idInt = int.parse(id);
      await _dataSource.delete(idInt);

      developer.log(
        '✅ MaintenanceRepository.deleteMaintenanceRecord() - Marked as deleted locally',
        name: 'MaintenanceRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 MaintenanceRepository.deleteMaintenanceRecord() - Online, syncing deletion to Firebase...',
          name: 'MaintenanceRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ MaintenanceRepository.deleteMaintenanceRecord() - Sync failed: ${failure.message}',
                name: 'MaintenanceRepository',
              );
            },
            (result) {
              developer.log(
                '✅ MaintenanceRepository.deleteMaintenanceRecord() - Synced deletion to Firebase',
                name: 'MaintenanceRepository',
              );
            },
          );
        } catch (e) {
          developer.log(
            '⚠️ MaintenanceRepository.deleteMaintenanceRecord() - Sync error: $e',
            name: 'MaintenanceRepository',
          );
        }
      }

      return const Right(unit);
    } catch (e) {
      developer.log(
        '❌ MaintenanceRepository.deleteMaintenanceRecord() - Error: $e',
        name: 'MaintenanceRepository',
      );
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> searchMaintenanceRecords(
    String query,
  ) async {
    try {
      // Implementação simples: buscar todos e filtrar
      final allData = await _dataSource.findAll();
      final filteredData = allData
          .where(
            (data) =>
                data.descricao.toLowerCase().contains(query.toLowerCase()) ||
                data.tipo.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      final entities = filteredData.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MaintenanceEntity>>> watchMaintenanceRecords() {
    return _dataSource.watchAll().map((dataList) {
      try {
        final entities = dataList.map(_toEntity).toList();
        return Right(entities);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    });
  }

  @override
  Stream<Either<Failure, List<MaintenanceEntity>>>
  watchMaintenanceRecordsByVehicle(String vehicleId) {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      return _dataSource.watchByVehicleId(vehicleIdInt).map((dataList) {
        try {
          final entities = dataList.map(_toEntity).toList();
          return Right(entities);
        } catch (e) {
          return Left(CacheFailure(e.toString()));
        }
      });
    } catch (e) {
      return Stream.value(Left(CacheFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenanceRecordsByType(
    String vehicleId,
    MaintenanceType type,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final dataList = await _dataSource.findByType(vehicleIdInt, type.name);
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>>
  getMaintenanceRecordsByStatus(
    String vehicleId,
    MaintenanceStatus status,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final isCompleted = status == MaintenanceStatus.completed;
      final dataList = isCompleted
          ? await _dataSource.findCompletedByVehicleId(vehicleIdInt)
          : await _dataSource.findPendingByVehicleId(vehicleIdInt);
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>>
  getMaintenanceRecordsByDateRange(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final dataList = await _dataSource.findByPeriod(
        vehicleIdInt,
        startDate,
        endDate,
      );
      final entities = dataList.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>>
  getUpcomingMaintenanceRecords(String vehicleId, {int days = 30}) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final allData = await _dataSource.findByVehicleId(vehicleIdInt);
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));
      final upcomingData = allData.where((data) {
        final serviceDate = DateTime.fromMillisecondsSinceEpoch(data.data);
        return serviceDate.isAfter(now) &&
            serviceDate.isBefore(futureDate) &&
            !data.concluida;
      }).toList();
      final entities = upcomingData.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getOverdueMaintenanceRecords(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final allData = await _dataSource.findByVehicleId(vehicleIdInt);
      final now = DateTime.now();
      final overdueData = allData.where((data) {
        final serviceDate = DateTime.fromMillisecondsSinceEpoch(data.data);
        return serviceDate.isBefore(now) && !data.concluida;
      }).toList();
      final entities = overdueData.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalMaintenanceCost(
    String vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final total = await _dataSource.calculateTotalCost(
        vehicleIdInt,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getMaintenanceCountByType(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final types = await _dataSource.findDistinctTypes(vehicleIdInt);
      final countMap = <String, int>{};
      for (final type in types) {
        final dataList = await _dataSource.findByType(vehicleIdInt, type);
        countMap[type] = dataList.length;
      }
      return Right(countMap);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageMaintenanceCost(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final allData = await _dataSource.findByVehicleId(vehicleIdInt);
      if (allData.isEmpty) return const Right(0.0);
      final total = allData.fold<double>(0.0, (sum, data) => sum + data.valor);
      return Right(total / allData.length);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getRecentMaintenanceRecords(
    String vehicleId, {
    int limit = 10,
  }) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final allData = await _dataSource.findByVehicleId(vehicleIdInt);
      final sortedData = allData
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentData = sortedData.take(limit).toList();
      final entities = recentData.map(_toEntity).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceEntity?>> getLastMaintenanceRecord(
    String vehicleId,
  ) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final allData = await _dataSource.findByVehicleId(vehicleIdInt);
      if (allData.isEmpty) return const Right(null);
      final sortedData = allData
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastData = sortedData.first;
      return Right(_toEntity(lastData));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
