import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../constants/gasometer_environment_config.dart';
import '../errors/failures.dart';

/// Gasometer-specific storage service that manages app-specific boxes
/// This prevents contamination with other apps while using the core infrastructure
class GasometerStorageService {
  factory GasometerStorageService() => _instance;
  GasometerStorageService._internal();
  static final GasometerStorageService _instance =
      GasometerStorageService._internal();

  late final IBoxRegistryService _boxRegistry;
  late final ILocalStorageRepository _storage;
  bool _isInitialized = false;

  // Storage box names for gasometer app
  static const String _vehiclesBox = 'gasometer_vehicles';
  static const String _readingsBox = 'gasometer_readings';
  static const String _statisticsBox = 'gasometer_statistics';
  static const String _backupsBox = 'gasometer_backups';
  static const String _mainBox = 'gasometer_main';

  /// Initialize the gasometer storage system
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);
      _boxRegistry = GetIt.I<IBoxRegistryService>();
      _storage = GetIt.I<ILocalStorageRepository>();
      await _registerGasometerBoxes();

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(
        StorageFailure(message: 'Failed to initialize gasometer storage: $e'),
      );
    }
  }

  /// Register gasometer-specific boxes
  Future<void> _registerGasometerBoxes() async {
    final gasometerBoxes = [
      BoxConfiguration.basic(name: _mainBox, appId: 'gasometer'),
      BoxConfiguration.basic(name: _readingsBox, appId: 'gasometer'),
      BoxConfiguration.basic(name: _vehiclesBox, appId: 'gasometer'),
      BoxConfiguration.basic(name: _statisticsBox, appId: 'gasometer'),
      BoxConfiguration.basic(name: _backupsBox, appId: 'gasometer'),
    ];

    for (final config in gasometerBoxes) {
      final result = await _boxRegistry.registerBox(config);
      if (result.isLeft()) {
        print(
          'Warning: Failed to register gasometer box "${config.name}": ${result.fold((f) => f.message, (_) => '')}',
        );
      }
    }
  }

  /// Save vehicle data
  Future<Either<Failure, void>> saveVehicle<T>({
    required String vehicleId,
    required T vehicle,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: vehicleId,
      data: vehicle,
      box: _vehiclesBox,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  /// Get vehicle data
  Future<Either<Failure, T?>> getVehicle<T>({required String vehicleId}) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(key: vehicleId, box: _vehiclesBox);
    return result.fold((failure) => Left(failure), (value) => Right(value));
  }

  /// Save odometer reading
  Future<Either<Failure, void>> saveReading<T>({
    required String readingId,
    required T reading,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: readingId,
      data: reading,
      box: _readingsBox,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  /// Get odometer reading
  Future<Either<Failure, T?>> getReading<T>({required String readingId}) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(key: readingId, box: _readingsBox);
    return result.fold((failure) => Left(failure), (value) => Right(value));
  }

  /// Get all readings
  Future<Either<Failure, List<T>>> getAllReadings<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: _readingsBox);
    return result.fold((failure) => Left(failure), (values) => Right(values));
  }

  /// Save statistics
  Future<Either<Failure, void>> saveStatistics<T>({
    required String key,
    required T statistics,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: key,
      data: statistics,
      box: _statisticsBox,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  /// Get statistics
  Future<Either<Failure, T?>> getStatistics<T>({required String key}) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(key: key, box: _statisticsBox);
    return result.fold((failure) => Left(failure), (value) => Right(value));
  }

  /// Save backup data
  Future<Either<Failure, void>> saveBackup<T>({
    required String backupId,
    required T backupData,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: backupId,
      data: backupData,
      box: _backupsBox,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  /// Get backup data
  Future<Either<Failure, List<T>>> getAllBackups<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: _backupsBox);
    return result.fold((failure) => Left(failure), (values) => Right(values));
  }

  /// Save gasometer-specific setting
  Future<Either<Failure, void>> saveGasometerSetting({
    required String key,
    required dynamic value,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save(key: key, data: value, box: _mainBox);
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  /// Get gasometer-specific setting
  Future<Either<Failure, T?>> getGasometerSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: 'gasometer_$key', // Prefix to avoid conflicts
      box: GasometerBoxes.main,
    );

    return result.fold(
      (failure) => Left(failure),
      (value) => Right(value ?? defaultValue),
    );
  }

  /// Clear all gasometer data (for reset/uninstall)
  Future<Either<Failure, void>> clearAllGasometerData() async {
    await _ensureInitialized();

    final boxes = [
      _mainBox,
      _readingsBox,
      _vehiclesBox,
      _statisticsBox,
      _backupsBox,
    ];

    for (final boxName in boxes) {
      final result = await _storage.clear(box: boxName);
      if (result.isLeft()) {
        return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }
    }

    return const Right(null);
  }

  /// Get storage statistics for debugging
  Future<Map<String, int>> getStorageStatistics() async {
    await _ensureInitialized();

    final statistics = <String, int>{};

    final boxes = [
      GasometerBoxes.main,
      GasometerBoxes.readings,
      GasometerBoxes.vehicles,
      GasometerBoxes.statistics,
      GasometerBoxes.backups,
    ];

    for (final boxName in boxes) {
      final result = await _storage.length(box: boxName);
      result.fold(
        (failure) => statistics[boxName] = -1,
        (length) => statistics[boxName] = length,
      );
    }

    return statistics;
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _isInitialized = false;
  }
}
