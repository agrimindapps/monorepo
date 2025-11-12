import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/odometer_reading_repository.dart';
import '../../domain/entities/odometer_entity.dart';

class OdometerNotifier extends StateNotifier<AsyncValue<List<OdometerEntity>>> {
  OdometerNotifier(this._ref) : super(const AsyncValue.loading()) {
    _repository = _ref.read(odometerReadingRepositoryProvider);
  }

  final Ref _ref;
  late final OdometerReadingRepository _repository;

  /// Carrega leituras de odômetro por veículo
  Future<List<OdometerEntity>> loadByVehicle(String vehicleId) async {
    try {
      final vehicleIdInt = int.tryParse(vehicleId);
      if (vehicleIdInt == null) {
        state = const AsyncValue.data([]);
        return [];
      }

      state = const AsyncValue.loading();

      final readings = await _repository.findByVehicleId(vehicleIdInt);
      final entities = readings
          .map((data) => _toEntity(data))
          .toList();

      state = AsyncValue.data(entities);
      return entities;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return [];
    }
  }

  /// Carrega leituras de odômetro por veículo e período
  Future<List<OdometerEntity>> loadByPeriod(
    String vehicleId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final vehicleIdInt = int.tryParse(vehicleId);
      if (vehicleIdInt == null) {
        state = const AsyncValue.data([]);
        return [];
      }

      state = const AsyncValue.loading();

      final readings = await _repository.findByPeriod(
        vehicleIdInt,
        startDate: startDate,
        endDate: endDate,
      );

      final entities = readings
          .map((data) => _toEntity(data))
          .toList();

      state = AsyncValue.data(entities);
      return entities;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return [];
    }
  }

  /// Obtém última leitura de odômetro
  Future<OdometerEntity?> getLatestReading(String vehicleId) async {
    try {
      final vehicleIdInt = int.tryParse(vehicleId);
      if (vehicleIdInt == null) return null;

      final data = await _repository.findLatestByVehicleId(vehicleIdInt);
      return data != null ? _toEntity(data) : null;
    } catch (e) {
      return null;
    }
  }

  /// Converte OdometerReadingData para OdometerEntity
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
      metadata: const {},
    );
  }
}

/// Provider do notifier de odômetro
final odometerNotifierProvider =
    StateNotifierProvider<OdometerNotifier, AsyncValue<List<OdometerEntity>>>(
  (ref) => OdometerNotifier(ref),
);
