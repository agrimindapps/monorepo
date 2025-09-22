import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../../features/animals/domain/entities/sync/animal_sync_entity.dart';
import '../../features/medications/domain/entities/sync/medication_sync_entity.dart';
import '../../features/appointments/domain/entities/sync/appointment_sync_entity.dart';
import '../../features/weight/domain/entities/sync/weight_sync_entity.dart';
import '../../features/settings/domain/entities/sync/user_settings_sync_entity.dart';
import 'petiveti_sync_config.dart';

/// Gerenciador de sincronização simplificado para Petiveti
/// Integração single-user com UnifiedSyncManager sem features multi-user
class PetivetiSyncManager {
  static final PetivetiSyncManager _instance = PetivetiSyncManager._internal();
  static PetivetiSyncManager get instance => _instance;

  PetivetiSyncManager._internal();

  bool _isInitialized = false;
  PetivetiSyncConfig? _config;

  /// Inicializa o sync manager para Petiveti com modo single-user
  Future<Either<Failure, void>> initialize({
    PetivetiSyncMode mode = PetivetiSyncMode.simple,
  }) async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      // Criar configuração baseada no modo
      _config = _createConfigForMode(mode);

      // Inicializar com UnifiedSyncManager
      final result = await UnifiedSyncManager.instance.initializeApp(
        appName: 'petiveti',
        config: _config!.appSyncConfig,
        entities: _config!.entityRegistrations,
      );

      if (result.isRight()) {
        _isInitialized = true;
      }

      return result;
    } catch (e) {
      return Left(InitializationFailure('Failed to initialize Petiveti sync: $e'));
    }
  }

  /// Cria configuração baseada no modo
  PetivetiSyncConfig _createConfigForMode(PetivetiSyncMode mode) {
    switch (mode) {
      case PetivetiSyncMode.simple:
        return PetivetiSyncConfig.simple();
      case PetivetiSyncMode.development:
        return PetivetiSyncConfig.development();
      case PetivetiSyncMode.offlineFirst:
        return PetivetiSyncConfig.offlineFirst();
    }
  }

  /// Força sincronização de todos os dados
  Future<Either<Failure, void>> forceSync() async {
    if (!_isInitialized) {
      return Left(InitializationFailure('Sync manager not initialized'));
    }

    return await UnifiedSyncManager.instance.forceSyncApp('petiveti');
  }

  /// Força sincronização de dados de emergência (medications críticas)
  Future<Either<Failure, void>> forceEmergencySync() async {
    if (!_isInitialized) {
      return Left(InitializationFailure('Sync manager not initialized'));
    }

    // Sincronizar especificamente entidades críticas
    final medicationsResult = await UnifiedSyncManager.instance
        .forceSyncEntity<MedicationSyncEntity>('petiveti');

    if (medicationsResult.isLeft()) {
      return medicationsResult;
    }

    final animalsResult = await UnifiedSyncManager.instance
        .forceSyncEntity<AnimalSyncEntity>('petiveti');

    return animalsResult;
  }

  /// Stream de status de sincronização
  Stream<SyncStatus> get syncStatusStream {
    return UnifiedSyncManager.instance.globalSyncStatusStream
        .map((statusMap) => statusMap['petiveti'] ?? SyncStatus.offline);
  }

  /// Status atual de sincronização
  SyncStatus get currentStatus {
    return UnifiedSyncManager.instance.getAppSyncStatus('petiveti');
  }

  /// Informações de debug
  Map<String, dynamic> getDebugInfo() {
    if (!_isInitialized) {
      return {'error': 'Not initialized'};
    }

    final debugInfo = UnifiedSyncManager.instance.getAppDebugInfo('petiveti');
    debugInfo['petiveti_config'] = _config?.toDebugMap();
    return debugInfo;
  }

  /// Limpa dados locais
  Future<Either<Failure, void>> clearLocalData() async {
    if (!_isInitialized) {
      return Left(InitializationFailure('Sync manager not initialized'));
    }

    return await UnifiedSyncManager.instance.clearAppData('petiveti');
  }

  /// Operações CRUD para Animais
  Future<Either<Failure, String>> createAnimal(AnimalSyncEntity animal) async {
    return await UnifiedSyncManager.instance.create('petiveti', animal);
  }

  Future<Either<Failure, void>> updateAnimal(String id, AnimalSyncEntity animal) async {
    return await UnifiedSyncManager.instance.update('petiveti', id, animal);
  }

  Future<Either<Failure, void>> deleteAnimal(String id) async {
    return await UnifiedSyncManager.instance.delete<AnimalSyncEntity>('petiveti', id);
  }

  Future<Either<Failure, AnimalSyncEntity?>> getAnimal(String id) async {
    return await UnifiedSyncManager.instance.findById<AnimalSyncEntity>('petiveti', id);
  }

  Future<Either<Failure, List<AnimalSyncEntity>>> getAllAnimals() async {
    return await UnifiedSyncManager.instance.findAll<AnimalSyncEntity>('petiveti');
  }

  Stream<List<AnimalSyncEntity>>? get animalsStream {
    return UnifiedSyncManager.instance.streamAll<AnimalSyncEntity>('petiveti');
  }

  /// Operações CRUD para Medicações
  Future<Either<Failure, String>> createMedication(MedicationSyncEntity medication) async {
    return await UnifiedSyncManager.instance.create('petiveti', medication);
  }

  Future<Either<Failure, void>> updateMedication(String id, MedicationSyncEntity medication) async {
    return await UnifiedSyncManager.instance.update('petiveti', id, medication);
  }

  Future<Either<Failure, void>> deleteMedication(String id) async {
    return await UnifiedSyncManager.instance.delete<MedicationSyncEntity>('petiveti', id);
  }

  Future<Either<Failure, List<MedicationSyncEntity>>> getMedicationsForAnimal(String animalId) async {
    return await UnifiedSyncManager.instance.findWhere<MedicationSyncEntity>(
      'petiveti',
      {'animal_id': animalId},
    );
  }

  Stream<List<MedicationSyncEntity>>? get medicationsStream {
    return UnifiedSyncManager.instance.streamAll<MedicationSyncEntity>('petiveti');
  }

  /// Operações CRUD para Consultas
  Future<Either<Failure, String>> createAppointment(AppointmentSyncEntity appointment) async {
    return await UnifiedSyncManager.instance.create('petiveti', appointment);
  }

  Future<Either<Failure, void>> updateAppointment(String id, AppointmentSyncEntity appointment) async {
    return await UnifiedSyncManager.instance.update('petiveti', id, appointment);
  }

  Future<Either<Failure, List<AppointmentSyncEntity>>> getAppointmentsForAnimal(String animalId) async {
    return await UnifiedSyncManager.instance.findWhere<AppointmentSyncEntity>(
      'petiveti',
      {'animal_id': animalId},
    );
  }

  /// Operações CRUD para Peso
  Future<Either<Failure, String>> createWeightRecord(WeightSyncEntity weight) async {
    return await UnifiedSyncManager.instance.create('petiveti', weight);
  }

  Future<Either<Failure, List<WeightSyncEntity>>> getWeightRecordsForAnimal(String animalId) async {
    return await UnifiedSyncManager.instance.findWhere<WeightSyncEntity>(
      'petiveti',
      {'animal_id': animalId},
    );
  }

  /// Operações para Configurações do Usuário
  Future<Either<Failure, String>> saveUserSettings(UserSettingsSyncEntity settings) async {
    return await UnifiedSyncManager.instance.create('petiveti', settings);
  }

  Future<Either<Failure, void>> updateUserSettings(String id, UserSettingsSyncEntity settings) async {
    return await UnifiedSyncManager.instance.update('petiveti', id, settings);
  }

  Future<Either<Failure, UserSettingsSyncEntity?>> getUserSettings() async {
    final result = await UnifiedSyncManager.instance.findAll<UserSettingsSyncEntity>('petiveti');
    return result.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.isNotEmpty ? settings.first : null),
    );
  }

  /// Dispose do gerenciador
  Future<void> dispose() async {
    _isInitialized = false;
    _config = null;
  }
}

/// Modos de sincronização disponíveis para Petiveti
enum PetivetiSyncMode {
  /// Modo simples - Para uso básico single-user
  simple,

  /// Modo desenvolvimento - Com logs detalhados
  development,

  /// Modo offline-first - Maximiza funcionalidade offline
  offlineFirst,
}

/// Falha de inicialização específica do Petiveti
class InitializationFailure extends Failure {
  const InitializationFailure(String message) : super(message: message);
}