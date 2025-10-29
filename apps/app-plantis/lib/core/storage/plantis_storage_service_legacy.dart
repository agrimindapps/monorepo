import 'package:core/core.dart';
import '../constants/plantis_environment_config.dart';

/// Plantis-specific storage service that manages app-specific boxes
/// This prevents contamination with other apps while using the core infrastructure
class PlantisStorageService {
  static final PlantisStorageService _instance =
      PlantisStorageService._internal();
  factory PlantisStorageService() => _instance;
  PlantisStorageService._internal();

  late final IBoxRegistryService _boxRegistry;
  late final ILocalStorageRepository _storage;
  bool _isInitialized = false;

  /// Initialize the plantis storage system
  Future<Result<void>> initialize() async {
    try {
      if (_isInitialized) return Result.success(null);
      _boxRegistry = GetIt.I<IBoxRegistryService>();
      _storage = GetIt.I<ILocalStorageRepository>();
      await _registerPlantisBoxes();

      _isInitialized = true;
      return Result.success(null);
    } catch (e) {
      return Result.error(
        StorageError(
          message: 'Failed to initialize plantis storage: $e',
          code: 'PLANTIS_STORAGE_INIT_ERROR',
        ),
      );
    }
  }

  /// Register plantis-specific boxes
  Future<void> _registerPlantisBoxes() async {
    final plantisBoxes = [
      BoxConfiguration.basic(name: PlantisBoxes.main, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.plants, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.spaces, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.tasks, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.reminders, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.careLogs, appId: 'plantis'),
      BoxConfiguration.basic(name: PlantisBoxes.backups, appId: 'plantis'),
    ];

    for (final config in plantisBoxes) {
      final result = await _boxRegistry.registerBox(config);
      if (result.isLeft()) {
        print(
          'Warning: Failed to register plantis box "${config.name}": ${result.fold((f) => f.message, (_) => '')}',
        );
      }
    }
  }

  /// Save plant data
  Future<Result<void>> savePlant<T>({
    required String plantId,
    required T plant,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: plantId,
      data: plant,
      box: PlantisBoxes.plants,
    );
    return result.toResult();
  }

  /// Get plant data
  Future<Result<T?>> getPlant<T>({required String plantId}) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: plantId,
      box: PlantisBoxes.plants,
    );
    return result.toResult();
  }

  /// Get all plants
  Future<Result<List<T>>> getAllPlants<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: PlantisBoxes.plants);
    return result.toResult();
  }

  /// Save space data
  Future<Result<void>> saveSpace<T>({
    required String spaceId,
    required T space,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: spaceId,
      data: space,
      box: PlantisBoxes.spaces,
    );
    return result.toResult();
  }

  /// Get space data
  Future<Result<T?>> getSpace<T>({required String spaceId}) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: spaceId,
      box: PlantisBoxes.spaces,
    );
    return result.toResult();
  }

  /// Save care task
  Future<Result<void>> saveTask<T>({
    required String taskId,
    required T task,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: taskId,
      data: task,
      box: PlantisBoxes.tasks,
    );
    return result.toResult();
  }

  /// Get all tasks
  Future<Result<List<T>>> getAllTasks<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: PlantisBoxes.tasks);
    return result.toResult();
  }

  /// Save reminder
  Future<Result<void>> saveReminder<T>({
    required String reminderId,
    required T reminder,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: reminderId,
      data: reminder,
      box: PlantisBoxes.reminders,
    );
    return result.toResult();
  }

  /// Get all reminders
  Future<Result<List<T>>> getAllReminders<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: PlantisBoxes.reminders);
    return result.toResult();
  }

  /// Save care log entry
  Future<Result<void>> saveCareLog<T>({
    required String logId,
    required T careLog,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<T>(
      key: logId,
      data: careLog,
      box: PlantisBoxes.careLogs,
    );
    return result.toResult();
  }

  /// Get care log entries for a plant
  Future<Result<List<T>>> getCareLogsForPlant<T>({
    required String plantId,
  }) async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: PlantisBoxes.careLogs);
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
      box: PlantisBoxes.backups,
    );
    return result.toResult();
  }

  /// Get backup data
  Future<Result<List<T>>> getAllBackups<T>() async {
    await _ensureInitialized();
    final result = await _storage.getValues<T>(box: PlantisBoxes.backups);
    return result.toResult();
  }

  /// Save plantis-specific setting
  Future<Result<void>> setPlantisSetting({
    required String key,
    required dynamic value,
  }) async {
    await _ensureInitialized();
    final result = await _storage.save<dynamic>(
      key: 'plantis_$key', // Prefix to avoid conflicts
      data: value,
      box: PlantisBoxes.main,
    );
    return result.toResult();
  }

  /// Get plantis-specific setting
  Future<Result<T?>> getPlantisSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    await _ensureInitialized();
    final result = await _storage.get<T>(
      key: 'plantis_$key', // Prefix to avoid conflicts
      box: PlantisBoxes.main,
    );

    return result.fold(
      (failure) => Result.error(AppErrorFactory.fromFailure(failure)),
      (value) => Result.success(value ?? defaultValue),
    );
  }

  /// Clear all plantis data (for reset/uninstall)
  Future<Result<void>> clearAllPlantisData() async {
    await _ensureInitialized();

    final boxes = [
      PlantisBoxes.main,
      PlantisBoxes.plants,
      PlantisBoxes.spaces,
      PlantisBoxes.tasks,
      PlantisBoxes.reminders,
      PlantisBoxes.careLogs,
      PlantisBoxes.backups,
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
      PlantisBoxes.main,
      PlantisBoxes.plants,
      PlantisBoxes.spaces,
      PlantisBoxes.tasks,
      PlantisBoxes.reminders,
      PlantisBoxes.careLogs,
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
