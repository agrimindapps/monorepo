import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import '../constants/gasometer_environment_config.dart';

/// Gasometer-specific storage service that manages app-specific boxes
/// This prevents contamination with other apps while using the core infrastructure
class GasometerStorageService {
  static final GasometerStorageService _instance = GasometerStorageService._internal();
  factory GasometerStorageService() => _instance;
  GasometerStorageService._internal();

  late final IBoxRegistryService _boxRegistry;
  late final ILocalStorageRepository _storage;
  bool _isInitialized = false;

  /// Initialize the gasometer storage system
  Future<Result<void, Failure>> initialize() async {
    try {
      if (_isInitialized) return Result.success(null);

      // Get core services
      _boxRegistry = GetIt.I<IBoxRegistryService>();
      _storage = GetIt.I<ILocalStorageRepository>();

      // Register gasometer-specific boxes
      await _registerGasometerBoxes();

      _isInitialized = true;
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to initialize gasometer storage: $e'));
    }
  }

  /// Register gasometer-specific boxes
  Future<void> _registerGasometerBoxes() async {
    final gasometerBoxes = [
      BoxConfiguration.basic(
        name: GasometerBoxes.main,
        appId: 'gasometer',
      ),
      BoxConfiguration.basic(
        name: GasometerBoxes.readings,
        appId: 'gasometer',
      ),
      BoxConfiguration.basic(
        name: GasometerBoxes.vehicles,
        appId: 'gasometer',
      ),
      BoxConfiguration.basic(
        name: GasometerBoxes.statistics,
        appId: 'gasometer',
      ),
      BoxConfiguration.basic(
        name: GasometerBoxes.backups,
        appId: 'gasometer',
      ),
    ];

    for (final config in gasometerBoxes) {
      final result = await _boxRegistry.registerBox(config);
      if (result.isLeft()) {
        print('Warning: Failed to register gasometer box "${config.name}": ${result.fold((f) => f.message, (_) => '')}');
      }
    }
  }

  /// Save vehicle data
  Future<Result<void, Failure>> saveVehicle<T>({
    required String vehicleId,
    required T vehicle,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: vehicleId,
      data: vehicle,
      box: GasometerBoxes.vehicles,
    );
  }

  /// Get vehicle data
  Future<Result<T?, Failure>> getVehicle<T>({
    required String vehicleId,
  }) async {
    await _ensureInitialized();
    return _storage.get<T>(
      key: vehicleId,
      box: GasometerBoxes.vehicles,
    );
  }

  /// Save odometer reading
  Future<Result<void, Failure>> saveReading<T>({
    required String readingId,
    required T reading,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: readingId,
      data: reading,
      box: GasometerBoxes.readings,
    );
  }

  /// Get odometer reading
  Future<Result<T?, Failure>> getReading<T>({
    required String readingId,
  }) async {
    await _ensureInitialized();
    return _storage.get<T>(
      key: readingId,
      box: GasometerBoxes.readings,
    );
  }

  /// Get all readings
  Future<Result<List<T>, Failure>> getAllReadings<T>() async {
    await _ensureInitialized();
    return _storage.getValues<T>(box: GasometerBoxes.readings);
  }

  /// Save statistics
  Future<Result<void, Failure>> saveStatistics<T>({
    required String key,
    required T statistics,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: key,
      data: statistics,
      box: GasometerBoxes.statistics,
    );
  }

  /// Get statistics
  Future<Result<T?, Failure>> getStatistics<T>({
    required String key,
  }) async {
    await _ensureInitialized();
    return _storage.get<T>(
      key: key,
      box: GasometerBoxes.statistics,
    );
  }

  /// Save backup data
  Future<Result<void, Failure>> saveBackup<T>({
    required String backupId,
    required T backupData,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: backupId,
      data: backupData,
      box: GasometerBoxes.backups,
    );
  }

  /// Get backup data
  Future<Result<List<T>, Failure>> getAllBackups<T>() async {
    await _ensureInitialized();
    return _storage.getValues<T>(box: GasometerBoxes.backups);
  }

  /// Save gasometer-specific setting
  Future<Result<void, Failure>> saveGasometerSetting({
    required String key,
    required dynamic value,
  }) async {
    await _ensureInitialized();
    return _storage.save<dynamic>(
      key: 'gasometer_$key', // Prefix to avoid conflicts
      data: value,
      box: GasometerBoxes.main,
    );
  }

  /// Get gasometer-specific setting
  Future<Result<T?, Failure>> getGasometerSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: 'gasometer_$key', // Prefix to avoid conflicts
      box: GasometerBoxes.main,
    );
    
    return result.fold(
      (failure) => Result.failure(failure),
      (value) => Result.success(value ?? defaultValue),
    );
  }

  /// Clear all gasometer data (for reset/uninstall)
  Future<Result<void, Failure>> clearAllGasometerData() async {
    await _ensureInitialized();
    
    final boxes = [
      GasometerBoxes.main,
      GasometerBoxes.readings,
      GasometerBoxes.vehicles,
      GasometerBoxes.statistics,
      GasometerBoxes.backups,
    ];

    for (final boxName in boxes) {
      final result = await _storage.clear(box: boxName);
      if (result.isLeft()) {
        return result;
      }
    }

    return Result.success(null);
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