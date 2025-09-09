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
  Future<Result<void>> initialize() async {
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
      return Result.error(StorageError(message: 'Failed to initialize gasometer storage: $e'));
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
  Future<Result<void>> saveVehicle<T>({
    required String vehicleId,
    required T vehicle,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: vehicleId,
      data: vehicle,
      box: GasometerBoxes.vehicles,
    );
    return result.toResult();
  }

  /// Get vehicle data
  Future<Result<T?>> getVehicle<T>({
    required String vehicleId,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: vehicleId,
      box: GasometerBoxes.vehicles,
    );
    return result.toResult();
  }

  /// Save odometer reading
  Future<Result<void>> saveReading<T>({
    required String readingId,
    required T reading,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: readingId,
      data: reading,
      box: GasometerBoxes.readings,
    );
    return result.toResult();
  }

  /// Get odometer reading
  Future<Result<T?>> getReading<T>({
    required String readingId,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: readingId,
      box: GasometerBoxes.readings,
    );
    return result.toResult();
  }

  /// Get all readings
  Future<Result<List<T>>> getAllReadings<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: GasometerBoxes.readings);
    return result.toResult();
  }

  /// Save statistics
  Future<Result<void>> saveStatistics<T>({
    required String key,
    required T statistics,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: key,
      data: statistics,
      box: GasometerBoxes.statistics,
    );
    return result.toResult();
  }

  /// Get statistics
  Future<Result<T?>> getStatistics<T>({
    required String key,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: key,
      box: GasometerBoxes.statistics,
    );
    return result.toResult();
  }

  /// Save backup data
  Future<Result<void>> saveBackup<T>({
    required String backupId,
    required T backupData,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: backupId,
      data: backupData,
      box: GasometerBoxes.backups,
    );
    return result.toResult();
  }

  /// Get backup data
  Future<Result<List<T>>> getAllBackups<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: GasometerBoxes.backups);
    return result.toResult();
  }

  /// Save gasometer-specific setting
  Future<Result<void>> saveGasometerSetting({
    required String key,
    required dynamic value,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<dynamic>(
      key: 'gasometer_$key', // Prefix to avoid conflicts
      data: value,
      box: GasometerBoxes.main,
    );
    return result.toResult();
  }

  /// Get gasometer-specific setting
  Future<Result<T?>> getGasometerSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: 'gasometer_$key', // Prefix to avoid conflicts
      box: GasometerBoxes.main,
    );
    
    return result.fold(
      (failure) => Result.error(AppErrorFactory.fromFailure(failure)),
      (value) => Result.success(value ?? defaultValue),
    );
  }

  /// Clear all gasometer data (for reset/uninstall)
  Future<Result<void>> clearAllGasometerData() async {
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
        return result.toResult();
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