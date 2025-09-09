import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import '../constants/plantis_environment_config.dart';

/// Plantis-specific storage service that manages app-specific boxes
/// This prevents contamination with other apps while using the core infrastructure
class PlantisStorageService {
  static final PlantisStorageService _instance = PlantisStorageService._internal();
  factory PlantisStorageService() => _instance;
  PlantisStorageService._internal();

  late final IBoxRegistryService _boxRegistry;
  late final ILocalStorageRepository _storage;
  bool _isInitialized = false;

  /// Initialize the plantis storage system
  Future<Result<void, Failure>> initialize() async {
    try {
      if (_isInitialized) return Result.success(null);

      // Get core services
      _boxRegistry = GetIt.I<IBoxRegistryService>();
      _storage = GetIt.I<ILocalStorageRepository>();

      // Register plantis-specific boxes
      await _registerPlantisBoxes();

      _isInitialized = true;
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Failed to initialize plantis storage: $e'));
    }
  }

  /// Register plantis-specific boxes
  Future<void> _registerPlantisBoxes() async {
    final plantisBoxes = [
      BoxConfiguration.basic(
        name: PlantisBoxes.main,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.plants,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.spaces,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.tasks,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.reminders,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.care_logs,
        appId: 'plantis',
      ),
      BoxConfiguration.basic(
        name: PlantisBoxes.backups,
        appId: 'plantis',
      ),
    ];

    for (final config in plantisBoxes) {
      final result = await _boxRegistry.registerBox(config);
      if (result.isLeft()) {
        print('Warning: Failed to register plantis box "${config.name}": ${result.fold((f) => f.message, (_) => '')}');
      }
    }
  }

  /// Save plant data
  Future<Result<void, Failure>> savePlant<T>({
    required String plantId,
    required T plant,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: plantId,
      data: plant,
      box: PlantisBoxes.plants,
    );
  }

  /// Get plant data
  Future<Result<T?, Failure>> getPlant<T>({
    required String plantId,
  }) async {
    await _ensureInitialized();
    return _storage.get<T>(
      key: plantId,
      box: PlantisBoxes.plants,
    );
  }

  /// Get all plants
  Future<Result<List<T>, Failure>> getAllPlants<T>() async {
    await _ensureInitialized();
    return _storage.getValues<T>(box: PlantisBoxes.plants);
  }

  /// Save space data
  Future<Result<void, Failure>> saveSpace<T>({
    required String spaceId,
    required T space,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: spaceId,
      data: space,
      box: PlantisBoxes.spaces,
    );
  }

  /// Get space data
  Future<Result<T?, Failure>> getSpace<T>({
    required String spaceId,
  }) async {
    await _ensureInitialized();
    return _storage.get<T>(
      key: spaceId,
      box: PlantisBoxes.spaces,
    );
  }

  /// Save care task
  Future<Result<void, Failure>> saveTask<T>({
    required String taskId,
    required T task,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: taskId,
      data: task,
      box: PlantisBoxes.tasks,
    );
  }

  /// Get all tasks
  Future<Result<List<T>, Failure>> getAllTasks<T>() async {
    await _ensureInitialized();
    return _storage.getValues<T>(box: PlantisBoxes.tasks);
  }

  /// Save reminder
  Future<Result<void, Failure>> saveReminder<T>({
    required String reminderId,
    required T reminder,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: reminderId,
      data: reminder,
      box: PlantisBoxes.reminders,
    );
  }

  /// Get all reminders
  Future<Result<List<T>, Failure>> getAllReminders<T>() async {
    await _ensureInitialized();
    return _storage.getValues<T>(box: PlantisBoxes.reminders);
  }

  /// Save care log entry
  Future<Result<void, Failure>> saveCareLog<T>({
    required String logId,
    required T careLog,
  }) async {
    await _ensureInitialized();
    return _storage.save<T>(
      key: logId,
      data: careLog,
      box: PlantisBoxes.care_logs,
    );
  }

  /// Get care log entries for a plant
  Future<Result<List<T>, Failure>> getCareLogsForPlant<T>({
    required String plantId,
  }) async {
    await _ensureInitialized();
    // This would require filtering by plant ID in a real implementation
    return _storage.getValues<T>(box: PlantisBoxes.care_logs);
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
      box: PlantisBoxes.backups,
    );
  }

  /// Get backup data
  Future<Result<List<T>, Failure>> getAllBackups<T>() async {
    await _ensureInitialized();
    return _storage.getValues<T>(box: PlantisBoxes.backups);
  }

  /// Save plantis-specific setting
  Future<Result<void, Failure>> setPlantisSetting({
    required String key,
    required dynamic value,
  }) async {
    await _ensureInitialized();
    return _storage.save<dynamic>(
      key: 'plantis_$key', // Prefix to avoid conflicts
      data: value,
      box: PlantisBoxes.main,
    );
  }

  /// Get plantis-specific setting
  Future<Result<T?, Failure>> getPlantisSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: 'plantis_$key', // Prefix to avoid conflicts
      box: PlantisBoxes.main,
    );
    
    return result.fold(
      (failure) => Result.failure(failure),
      (value) => Result.success(value ?? defaultValue),
    );
  }

  /// Clear all plantis data (for reset/uninstall)
  Future<Result<void, Failure>> clearAllPlantisData() async {
    await _ensureInitialized();
    
    final boxes = [
      PlantisBoxes.main,
      PlantisBoxes.plants,
      PlantisBoxes.spaces,
      PlantisBoxes.tasks,
      PlantisBoxes.reminders,
      PlantisBoxes.care_logs,
      PlantisBoxes.backups,
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
      PlantisBoxes.main,
      PlantisBoxes.plants,
      PlantisBoxes.spaces,
      PlantisBoxes.tasks,
      PlantisBoxes.reminders,
      PlantisBoxes.care_logs,
      PlantisBoxes.backups,
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