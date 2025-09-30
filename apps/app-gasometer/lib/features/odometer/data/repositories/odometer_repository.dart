import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/logging/entities/log_entry.dart';
import '../../../../core/logging/mixins/loggable_repository_mixin.dart';
import '../../../../core/logging/services/logging_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/odometer_entity.dart';
import '../datasources/odometer_remote_data_source.dart';
import '../models/odometer_model.dart';

/// Repository para persistência de leituras de odômetro usando Hive com cache strategy e sync Firebase
@injectable
class OdometerRepository with CachedRepository<OdometerEntity>, LoggableRepositoryMixin {

  OdometerRepository(
    this._loggingService,
    this._remoteDataSource,
    this._connectivity,
    this._authRepository,
  );
  static const String _boxName = 'odometer';
  late Box<OdometerModel> _box;
  final LoggingService _loggingService;
  final OdometerRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity;
  final AuthRepository _authRepository;

  @override
  LoggingService get loggingService => _loggingService;

  @override
  String get repositoryCategory => LogCategory.odometer;

  Future<bool> _isConnected() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  Future<String?> _getCurrentUserId() async {
    final userResult = await _authRepository.getCurrentUser();
    return userResult.fold(
      (failure) => null,
      (user) => user?.id,
    );
  }

  /// Initializes the repository
  Future<void> initialize() async {
    _box = await Hive.openBox<OdometerModel>(_boxName);
    
    // Initialize cache with optimized settings for odometer
    initializeCache(
      maxSize: 100,
      defaultTtl: const Duration(minutes: 8), // TTL médio para leituras de odômetro
    );
  }

  /// Saves new odometer reading
  Future<OdometerEntity?> saveOdometerReading(OdometerEntity reading) async {
    return await withLogging<OdometerEntity?>(
      operation: LogOperation.create,
      entityType: 'OdometerReading',
      entityId: reading.id,
      metadata: {
        'vehicle_id': reading.vehicleId,
        'value': reading.value,
        'type': reading.type.name,
      },
      operationFunc: () async {
        final model = _entityToModel(reading);
        await _box.put(reading.id, model);
        
        // Log local storage
        await logLocalStorage(
          action: 'saved',
          entityType: 'OdometerReading',
          entityId: reading.id,
          metadata: {'storage_type': 'hive'},
        );
        
        // Remote sync in background (fire-and-forget)
        unawaited(_syncOdometerReadingToRemoteInBackground(reading));
        
        return _modelToEntity(model);
      },
    );
  }

  /// Updates existing odometer reading
  Future<OdometerEntity?> updateOdometerReading(OdometerEntity reading) async {
    return await withLogging<OdometerEntity?>(
      operation: LogOperation.update,
      entityType: 'OdometerReading',
      entityId: reading.id,
      metadata: {
        'vehicle_id': reading.vehicleId,
        'value': reading.value,
        'type': reading.type.name,
      },
      operationFunc: () async {
        if (!_box.containsKey(reading.id)) {
          throw Exception('Leitura de odômetro não encontrada');
        }
        
        final model = _entityToModel(reading);
        await _box.put(reading.id, model);
        
        // Log local storage
        await logLocalStorage(
          action: 'updated',
          entityType: 'OdometerReading',
          entityId: reading.id,
          metadata: {'storage_type': 'hive'},
        );
        
        // Remote sync in background (fire-and-forget)
        unawaited(_syncOdometerReadingToRemoteInBackground(reading));
        
        return _modelToEntity(model);
      },
    );
  }

  /// Removes odometer reading by ID
  Future<bool> deleteOdometerReading(String readingId) async {
    return await withLogging<bool>(
      operation: LogOperation.delete,
      entityType: 'OdometerReading',
      entityId: readingId,
      operationFunc: () async {
        await _box.delete(readingId);
        
        // Log local storage
        await logLocalStorage(
          action: 'deleted',
          entityType: 'OdometerReading',
          entityId: readingId,
          metadata: {'storage_type': 'hive'},
        );
        
        return true;
      },
    );
  }

  /// Finds odometer reading by ID
  Future<OdometerEntity?> getOdometerReadingById(String readingId) async {
    try {
      final model = _box.get(readingId);
      return model != null ? _modelToEntity(model) : null;
    } catch (e) {
      throw Exception('Erro ao buscar leitura de odômetro: $e');
    }
  }

  /// Loads all odometer readings
  Future<List<OdometerEntity>> getAllOdometerReadings() async {
    try {
      // Verificar cache primeiro
      const cacheKey = 'all_odometer_readings';
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final entities = models.map((model) => _modelToEntity(model)).toList();
      
      // Cache o resultado
      cacheList(cacheKey, entities);
      
      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar leituras de odômetro: $e');
    }
  }

  /// Loads odometer readings by vehicle with caching optimization
  ///
  /// This method implements a comprehensive loading strategy:
  /// - Checks cache first for improved performance
  /// - Filters deleted records automatically
  /// - Sorts results by date (most recent first)
  /// - Maintains cache consistency for frequent access patterns
  ///
  /// [vehicleId] The unique identifier of the vehicle
  ///
  /// Returns a sorted list of [OdometerEntity] objects for the specified vehicle
  /// Throws [Exception] if data access fails
  Future<List<OdometerEntity>> getOdometerReadingsByVehicle(String vehicleId) async {
    try {
      // Verificar cache primeiro
      final cacheKey = vehicleCacheKey(vehicleId, 'odometer_readings');
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      final models = _box.values
          .where((model) => model.vehicleId == vehicleId && !model.isDeleted)
          .toList();
      
      // Ordenar por data decrescente (mais recente primeiro)
      models.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
      
      final entities = models.map((model) => _modelToEntity(model)).toList();
      
      // Cache o resultado
      cacheList(cacheKey, entities);
      
      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar leituras do veículo: $e');
    }
  }

  /// Loads odometer readings by type
  Future<List<OdometerEntity>> getOdometerReadingsByType(OdometerType type) async {
    try {
      final typeString = _typeToString(type);
      final models = _box.values
          .where((model) => model.type == typeString && !model.isDeleted)
          .toList();
      
      // Ordenar por data decrescente
      models.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar leituras por tipo: $e');
    }
  }

  /// Loads odometer readings by period
  Future<List<OdometerEntity>> getOdometerReadingsByPeriod(DateTime start, DateTime end) async {
    try {
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      
      final models = _box.values.where((model) {
        return model.registrationDate >= startMs && 
               model.registrationDate <= endMs && 
               !model.isDeleted;
      }).toList();
      
      // Ordenar por data decrescente
      models.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar leituras por período: $e');
    }
  }

  /// Finds the last reading for a vehicle
  Future<OdometerEntity?> getLastOdometerReading(String vehicleId) async {
    try {
      final models = _box.values
          .where((model) => model.vehicleId == vehicleId && !model.isDeleted)
          .toList();
      
      if (models.isEmpty) return null;
      
      // Encontrar o modelo com a maior data
      final latestModel = models.reduce((a, b) => 
          a.registrationDate > b.registrationDate ? a : b);
      
      return _modelToEntity(latestModel);
    } catch (e) {
      throw Exception('Erro ao buscar última leitura: $e');
    }
  }

  /// Searches odometer readings by text
  Future<List<OdometerEntity>> searchOdometerReadings(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final models = _box.values.where((model) {
        return !model.isDeleted && 
               model.description.toLowerCase().contains(lowerQuery);
      }).toList();
      
      // Ordenar por data decrescente
      models.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar leituras: $e');
    }
  }

  /// Loads comprehensive vehicle statistics with intelligent calculations
  ///
  /// This method performs complex statistical analysis on odometer data:
  /// - Aggregates total record count for the vehicle
  /// - Calculates current odometer reading from latest entry
  /// - Identifies chronological first and last readings
  /// - Computes total distance traveled based on reading span
  /// - Handles edge cases (no data, single reading, etc.)
  ///
  /// [vehicleId] The unique identifier of the vehicle
  ///
  /// Returns a map containing:
  /// - 'totalRecords': Number of odometer readings
  /// - 'currentOdometer': Latest odometer value
  /// - 'firstReading': Earliest odometer reading entity
  /// - 'lastReading': Latest odometer reading entity
  /// - 'totalDistance': Calculated distance between first and last readings
  ///
  /// Throws [Exception] if statistical calculation fails
  Future<Map<String, dynamic>> getVehicleStats(String vehicleId) async {
    try {
      final models = _box.values
          .where((model) => model.vehicleId == vehicleId && !model.isDeleted)
          .toList();
      
      if (models.isEmpty) {
        return {
          'totalRecords': 0,
          'currentOdometer': 0.0,
          'firstReading': null,
          'lastReading': null,
          'totalDistance': 0.0,
        };
      }

      // Ordenar por data
      models.sort((a, b) => a.registrationDate.compareTo(b.registrationDate));
      
      final firstModel = models.first;
      final lastModel = models.last;
      final totalDistance = lastModel.value - firstModel.value;
      
      return {
        'totalRecords': models.length,
        'currentOdometer': lastModel.value,
        'firstReading': _modelToEntity(firstModel),
        'lastReading': _modelToEntity(lastModel),
        'totalDistance': totalDistance.abs(),
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Detects potential duplicate odometer readings using intelligent algorithms
  ///
  /// This method implements sophisticated duplicate detection logic:
  /// - Compares readings for the same vehicle
  /// - Considers small odometer value differences (< 1.0 km) as potential duplicates
  /// - Analyzes temporal proximity (within 1 day) for duplicate detection
  /// - Accounts for user error patterns in data entry
  /// - Excludes already deleted records from analysis
  ///
  /// Detection criteria:
  /// - Same vehicle ID
  /// - Odometer values within 1 km of each other
  /// - Registration dates within 1 day of each other
  ///
  /// Returns a list of [OdometerEntity] objects that are potential duplicates
  /// Throws [Exception] if duplicate analysis fails
  Future<List<OdometerEntity>> findDuplicates() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final duplicates = <OdometerModel>[];
      
      for (int i = 0; i < models.length; i++) {
        for (int j = i + 1; j < models.length; j++) {
          final model1 = models[i];
          final model2 = models[j];
          
          // Considera duplicata se mesmo veículo, valor próximo e data próxima
          final date1 = DateTime.fromMillisecondsSinceEpoch(model1.registrationDate);
          final date2 = DateTime.fromMillisecondsSinceEpoch(model2.registrationDate);
          final daysDiff = date1.difference(date2).inDays.abs();
          
          if (model1.vehicleId == model2.vehicleId &&
              (model1.value - model2.value).abs() < 1.0 &&
              daysDiff <= 1) {
            duplicates.add(model2);
          }
        }
      }
      
      return duplicates.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar duplicatas: $e');
    }
  }

  /// Clears all readings (debug/reset only)
  Future<void> clearAllOdometerReadings() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Erro ao limpar leituras de odômetro: $e');
    }
  }

  /// Converte OdometerEntity para OdometerModel
  OdometerModel _entityToModel(OdometerEntity entity) {
    return OdometerModel.create(
      id: entity.id,
      userId: entity.userId,
      vehicleId: entity.vehicleId,
      registrationDate: entity.registrationDate.millisecondsSinceEpoch,
      value: entity.value,
      description: entity.description,
      type: _typeToString(entity.type),
    );
  }

  /// Converte OdometerModel para OdometerEntity
  OdometerEntity _modelToEntity(OdometerModel model) {
    return OdometerEntity(
      id: model.id,
      vehicleId: model.vehicleId,
      userId: model.userId ?? '',
      value: model.value,
      registrationDate: DateTime.fromMillisecondsSinceEpoch(model.registrationDate),
      description: model.description,
      type: _stringToType(model.type ?? 'other'),
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: {
        'version': model.version,
        'isDirty': model.isDirty,
        'lastSync': model.lastSyncAt?.toIso8601String(),
      },
    );
  }

  /// Converte OdometerType para string
  String _typeToString(OdometerType type) {
    return type.name;
  }

  /// Converte string para OdometerType
  OdometerType _stringToType(String typeString) {
    return OdometerType.fromString(typeString);
  }

  /// Sincroniza leitura de odômetro com Firebase em background
  Future<void> _syncOdometerReadingToRemoteInBackground(OdometerEntity reading) async {
    try {
      // Verificar se está conectado
      if (!await _isConnected()) {
        return;
      }

      // Verificar se tem usuário autenticado
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return;
      }

      // Sincronizar com Firebase
      await _remoteDataSource.addOdometerReading(userId, reading);
      
      // Log successful sync
      await logRemoteSync(
        action: 'synced',
        entityType: 'OdometerReading',
        entityId: reading.id,
        success: true,
        metadata: {
          'vehicle_id': reading.vehicleId,
          'type': reading.type.name,
          'value': reading.value,
        },
      );
    } catch (e) {
      // Log failed sync
      await logRemoteSync(
        action: 'sync_failed',
        entityType: 'OdometerReading',
        entityId: reading.id,
        success: false,
        metadata: {
          'error': e.toString(),
          'vehicle_id': reading.vehicleId,
          'type': reading.type.name,
        },
      );
      
      // Log but don't throw - background sync should be silent
      if (kDebugMode) {
        print('Background sync failed for odometer reading ${reading.id}: $e');
      }
    }
  }

  /// Fecha o box (cleanup)
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      // Log error but don't crash
      if (kDebugMode) {
        print('Erro ao fechar box de odômetro: $e');
      }
    }
  }
}