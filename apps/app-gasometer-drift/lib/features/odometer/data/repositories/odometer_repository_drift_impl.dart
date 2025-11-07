import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../database/repositories/odometer_reading_repository.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/repositories/odometer_repository.dart';
import '../datasources/odometer_reading_local_datasource.dart';

/// Implementação do repositório de odômetro usando Drift
@LazySingleton(as: OdometerRepository)
class OdometerRepositoryDriftImpl implements OdometerRepository {
  const OdometerRepositoryDriftImpl(this._dataSource);

  final OdometerReadingLocalDataSource _dataSource;

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

      return Right(_toEntity(created));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OdometerEntity?>> updateOdometerReading(
    OdometerEntity reading,
  ) async {
    try {
      final success = await _dataSource.update(
        id: int.parse(reading.id),
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
      final updated = await _dataSource.findById(int.parse(reading.id));
      if (updated == null) {
        return const Left(CacheFailure('Failed to retrieve updated record'));
      }

      return Right(_toEntity(updated));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteOdometerReading(String id) async {
    try {
      final idInt = int.parse(id);
      final success = await _dataSource.delete(idInt);
      return Right(success);
    } catch (e) {
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
          .where((entity) =>
              entity.registrationDate.isAfter(startDate) &&
              entity.registrationDate.isBefore(endDate))
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
      final entities = dataList
          .map(_toEntity)
          .where((entity) {
            final matchesNotes = entity.description.toLowerCase().contains(query.toLowerCase());
            final matchesValue = entity.value.toString().contains(query);
            return matchesNotes || matchesValue;
          })
          .toList();
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
      
      final totalDistance = await _dataSource.calculateTotalDistance(vehicleIdInt);
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
