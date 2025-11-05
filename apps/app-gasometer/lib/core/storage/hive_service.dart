import 'package:core/core.dart' show Hive, HiveX, Box;
import 'package:flutter/foundation.dart';

import '../../core/data/models/category_model.dart';
import '../../core/data/models/pending_image_upload.dart';
import '../../core/logging/entities/log_entry.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/fuel/data/models/fuel_supply_model.dart';
import '../../features/maintenance/data/models/maintenance_model.dart';
import '../../features/odometer/data/models/odometer_model.dart';
import '../../features/vehicles/data/models/vehicle_model.dart';

/// Serviço centralizado para inicialização e gerenciamento do Hive
class HiveService {
  HiveService._();
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  /// Inicializa o Hive e registra todos os adapters
  Future<void> init() async {
    // Only initialize Hive on non-web platforms
    // Web doesn't support Hive.initFlutter()
    if (!kIsWeb) {
      await Hive.initFlutter();
      _registerGeneratedAdapters();
      await _openEssentialBoxes();
    } else {
      print('⚠️ Hive not initialized on web platform');
    }
  }

  /// Registra todos os adapters gerados pelo build_runner
  void _registerGeneratedAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VehicleModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FuelSupplyModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OdometerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MaintenanceModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(LogEntryAdapter());
    }
    // ✅ NOVO: Adapter para fila de uploads de imagens pendentes
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(PendingImageUploadAdapter());
    }
  }

  /// Abre boxes essenciais que são usados frequentemente
  Future<void> _openEssentialBoxes() async {
    try {
      await Hive.openBox<VehicleModel>(HiveBoxNames.vehicles);
      await Hive.openBox<FuelSupplyModel>(HiveBoxNames.fuelSupplies);
      await Hive.openBox<OdometerModel>(HiveBoxNames.odometer);
      await Hive.openBox<ExpenseModel>(HiveBoxNames.expenses);
      await Hive.openBox<MaintenanceModel>(HiveBoxNames.maintenance);
      await Hive.openBox<CategoryModel>(HiveBoxNames.categories);
      await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.settings);
      await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.cache);
      await Hive.openBox<LogEntry>(HiveBoxNames.logs);
    } catch (e) {
      print('Erro ao abrir boxes: $e');
    }
  }

  /// Obtém uma box específica, abrindo se necessário
  Future<Box<T>> getBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  /// Obtém uma box simples (sem tipo), abrindo se necessário
  Future<Box<dynamic>> getSimpleBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<dynamic>(boxName);
    }
    return Hive.box<dynamic>(boxName);
  }

  /// Fecha uma box específica
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
  }

  /// Fecha todas as boxes abertas
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Deleta uma box específica
  Future<void> deleteBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).clear();
      await Hive.box<dynamic>(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  /// Limpa todos os dados do cache
  Future<void> clearCache() async {
    try {
      final cacheBox = await getSimpleBox(HiveBoxNames.cache);
      await cacheBox.clear();
    } catch (e) {
      print('Erro ao limpar cache: $e');
    }
  }

  /// Compacta uma box para reduzir tamanho
  Future<void> compactBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<dynamic>(boxName).compact();
      }
    } catch (e) {
      print('Erro ao compactar box $boxName: $e');
    }
  }

  /// Compacta todas as boxes abertas
  Future<void> compactAllBoxes() async {
    for (final boxName in HiveBoxNames.allBoxes) {
      await compactBox(boxName);
    }
  }
}

/// Nomes de todas as boxes utilizadas no app
class HiveBoxNames {
  static const String vehicles = 'vehicles';
  static const String fuelSupplies = 'fuel_supplies';
  static const String odometer = 'odometer';
  static const String expenses = 'expenses';
  static const String maintenance = 'maintenance';
  static const String categories = 'categories';
  static const String settings = 'settings';
  static const String cache = 'cache';
  static const String userPreferences = 'user_preferences';
  static const String syncQueue = 'sync_queue';
  static const String logs = 'logs';
  static const String auth = 'auth';
  static const String subscription = 'subscription';

  /// Lista de todas as boxes para operações em lote
  static const List<String> allBoxes = [
    vehicles,
    fuelSupplies,
    odometer,
    expenses,
    maintenance,
    categories,
    settings,
    cache,
    userPreferences,
    syncQueue,
    logs,
    auth,
    subscription,
  ];
}

/// Chaves utilizadas nas boxes de configuração
class HiveKeys {
  static const String firstLaunch = 'first_launch';
  static const String darkMode = 'dark_mode';
  static const String language = 'language';
  static const String notifications = 'notifications';
  static const String autoSync = 'auto_sync';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
  static const String currentUser = 'current_user';
  static const String authToken = 'auth_token';
  static const String rememberLogin = 'remember_login';
  static const String lastAppVersion = 'last_app_version';
  static const String cacheVersion = 'cache_version';
}
