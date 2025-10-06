import 'package:core/core.dart' show Hive, HiveX, Box;

// Generated Adapters - Using existing gasometer models
import '../../core/data/models/category_model.dart';
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
    // Inicializar Hive com Flutter
    await Hive.initFlutter();

    // Registrar adapters gerados
    _registerGeneratedAdapters();

    // Abrir boxes essenciais
    await _openEssentialBoxes();
  }

  /// Registra todos os adapters gerados pelo build_runner
  void _registerGeneratedAdapters() {
    // Vehicles (TypeId: 0)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VehicleModelAdapter());
    }

    // Fuel Supplies (TypeId: 1)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FuelSupplyModelAdapter());
    }

    // Odometer (TypeId: 2)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(OdometerModelAdapter());
    }

    // Expenses (TypeId: 3)
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }

    // Maintenance (TypeId: 4)
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MaintenanceModelAdapter());
    }

    // Categories (TypeId: 5)
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    // LogEntry (TypeId: 20)
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(LogEntryAdapter());
    }
  }

  /// Abre boxes essenciais que são usados frequentemente
  Future<void> _openEssentialBoxes() async {
    try {
      // Boxes principais
      await Hive.openBox<VehicleModel>(HiveBoxNames.vehicles);
      await Hive.openBox<FuelSupplyModel>(HiveBoxNames.fuelSupplies);
      await Hive.openBox<OdometerModel>(HiveBoxNames.odometer);
      await Hive.openBox<ExpenseModel>(HiveBoxNames.expenses);
      await Hive.openBox<MaintenanceModel>(HiveBoxNames.maintenance);
      await Hive.openBox<CategoryModel>(HiveBoxNames.categories);

      // Boxes para configurações e cache
      await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.settings);
      await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.cache);

      // Logging box
      await Hive.openBox<LogEntry>(HiveBoxNames.logs);
    } catch (e) {
      // Log do erro mas não falha a inicialização
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
  // Boxes principais de dados
  static const String vehicles = 'vehicles';
  static const String fuelSupplies = 'fuel_supplies';
  static const String odometer = 'odometer';
  static const String expenses = 'expenses';
  static const String maintenance = 'maintenance';
  static const String categories = 'categories';

  // Boxes de sistema
  static const String settings = 'settings';
  static const String cache = 'cache';
  static const String userPreferences = 'user_preferences';
  static const String syncQueue = 'sync_queue';
  static const String logs = 'logs';

  // Boxes de autenticação e assinatura
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
  // Settings
  static const String firstLaunch = 'first_launch';
  static const String darkMode = 'dark_mode';
  static const String language = 'language';
  static const String notifications = 'notifications';
  static const String autoSync = 'auto_sync';
  static const String lastSyncTimestamp = 'last_sync_timestamp';

  // Auth
  static const String currentUser = 'current_user';
  static const String authToken = 'auth_token';
  static const String rememberLogin = 'remember_login';

  // Cache
  static const String lastAppVersion = 'last_app_version';
  static const String cacheVersion = 'cache_version';
}
