import 'package:core/core.dart' show Hive, HiveX, Box;

// Generated Adapters
import '../../features/animals/data/models/animal_model.dart';
import '../../features/appointments/data/models/appointment_model.dart';
import '../../features/medications/data/models/medication_model.dart';
import '../../features/vaccines/data/models/vaccine_model.dart';
import '../../features/weight/data/models/weight_model.dart';

/// Serviço centralizado para inicialização e gerenciamento do Hive
class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  HiveService._();

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
    // Animals
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(AnimalModelAdapter());
    }

    // Appointments
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(AppointmentModelAdapter());
    }

    // Medications
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(MedicationModelAdapter());
    }

    // Vaccines
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(VaccineModelAdapter());
    }

    // Weight
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(WeightModelAdapter());
    }

    // Adapters para novos modelos serão adicionados aqui conforme necessário
  }

  /// Abre boxes essenciais que são usados frequentemente
  Future<void> _openEssentialBoxes() async {
    try {
      // Boxes principais
      await Hive.openBox<AnimalModel>(HiveBoxNames.animals);
      await Hive.openBox<AppointmentModel>(HiveBoxNames.appointments);
      await Hive.openBox<MedicationModel>(HiveBoxNames.medications);
      await Hive.openBox<VaccineModel>(HiveBoxNames.vaccines);
      await Hive.openBox<WeightModel>(HiveBoxNames.weights);

      // Boxes para configurações e cache
      await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.settings);
      await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.cache);

      // Logging box (JSON strings for now)
      await Hive.openBox<String>('logs_json');
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

  /// Backup de dados para um arquivo
  Future<bool> backupData() async {
    try {
      // Implementar backup dos dados importantes
      // Por agora retorna true como placeholder
      return true;
    } catch (e) {
      print('Erro no backup: $e');
      return false;
    }
  }

  /// Restaura dados de um backup
  Future<bool> restoreData(String backupPath) async {
    try {
      // Implementar restauração dos dados
      // Por agora retorna true como placeholder
      return true;
    } catch (e) {
      print('Erro na restauração: $e');
      return false;
    }
  }
}

/// Nomes de todas as boxes utilizadas no app
class HiveBoxNames {
  // Boxes principais de dados
  static const String animals = 'animals';
  static const String appointments = 'appointments';
  static const String medications = 'medications';
  static const String vaccines = 'vaccines';
  static const String weights = 'weights';
  static const String reminders = 'reminders';
  static const String expenses = 'expenses';

  // Boxes de sistema
  static const String settings = 'settings';
  static const String cache = 'cache';
  static const String userPreferences = 'user_preferences';
  static const String syncQueue = 'sync_queue';

  // Boxes de autenticação e assinatura
  static const String auth = 'auth';
  static const String subscription = 'subscription';

  /// Lista de todas as boxes para operações em lote
  static const List<String> allBoxes = [
    animals,
    appointments,
    medications,
    vaccines,
    weights,
    reminders,
    expenses,
    settings,
    cache,
    userPreferences,
    syncQueue,
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
