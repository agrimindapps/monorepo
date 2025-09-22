import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'petiveti_sync_config.dart';
import '../../features/animals/domain/entities/sync/animal_sync_entity.dart';
import '../../features/medications/domain/entities/sync/medication_sync_entity.dart';
import '../../features/appointments/domain/entities/sync/appointment_sync_entity.dart';
import '../../features/weight/domain/entities/sync/weight_sync_entity.dart';
import '../../features/settings/domain/entities/sync/user_settings_sync_entity.dart';

/// Serviço principal de sincronização para Petiveti
/// Integra com UnifiedSyncManager e gerencia funcionalidades específicas de pet care
class PetivetiSyncService {
  static final PetivetiSyncService _instance = PetivetiSyncService._internal();
  static PetivetiSyncService get instance => _instance;

  PetivetiSyncService._internal();

  PetivetiSyncConfig? _config;
  bool _isInitialized = false;
  StreamSubscription<Map<String, SyncStatus>>? _statusSubscription;
  StreamSubscription<AppSyncEvent>? _eventSubscription;

  // Controllers para streams específicos do pet care
  final StreamController<PetCareSyncEvent> _petCareEventController =
      StreamController<PetCareSyncEvent>.broadcast();
  final StreamController<EmergencySyncStatus> _emergencyStatusController =
      StreamController<EmergencySyncStatus>.broadcast();

  /// Stream de eventos específicos do pet care
  Stream<PetCareSyncEvent> get petCareEventStream => _petCareEventController.stream;

  /// Stream de status de emergência
  Stream<EmergencySyncStatus> get emergencyStatusStream => _emergencyStatusController.stream;

  /// Inicializa o serviço de sync do Petiveti
  Future<Either<Failure, void>> initialize({
    PetivetiSyncConfig? config,
    bool enableDevelopmentMode = false,
  }) async {
    try {
      if (_isInitialized) {
        developer.log('PetivetiSyncService already initialized', name: 'PetivetiSync');
        return const Right(null);
      }

      // Usar configuração padrão baseada no ambiente
      _config = config ?? _getDefaultConfig(enableDevelopmentMode);

      developer.log(
        'Initializing PetivetiSyncService with config: ${_config!}',
        name: 'PetivetiSync',
      );

      // Inicializar UnifiedSyncManager
      final result = await UnifiedSyncManager.instance.initializeApp(
        appName: _config!.appSyncConfig.appName,
        config: _config!.appSyncConfig,
        entities: _config!.entityRegistrations,
      );

      if (result.isLeft()) {
        return result;
      }

      // Configurar listeners
      _setupListeners();

      // Configurar funcionalidades específicas do pet care
      await _setupPetCareFeatures();

      _isInitialized = true;

      developer.log(
        'PetivetiSyncService initialized successfully',
        name: 'PetivetiSync',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        'Error initializing PetivetiSyncService: $e',
        name: 'PetivetiSync',
      );
      return Left(InitializationFailure('Failed to initialize sync service: $e'));
    }
  }

  /// Obtém configuração padrão baseada no ambiente
  PetivetiSyncConfig _getDefaultConfig(bool developmentMode) {
    if (kDebugMode || developmentMode) {
      return PetivetiSyncConfig.development();
    } else {
      return PetivetiSyncConfig.simple();
    }
  }

  /// Configura listeners de sync
  void _setupListeners() {
    // Listener para status global
    _statusSubscription = UnifiedSyncManager.instance.globalSyncStatusStream.listen(
      (statusMap) {
        final petivetiStatus = statusMap[_config!.appSyncConfig.appName];
        if (petivetiStatus != null) {
          _handleStatusChange(petivetiStatus);
        }
      },
      onError: (error) {
        developer.log('Error in status stream: $error', name: 'PetivetiSync');
      },
    );

    // Listener para eventos de sync
    _eventSubscription = UnifiedSyncManager.instance.syncEventStream.listen(
      (event) {
        if (event.appName == _config!.appSyncConfig.appName) {
          _handleSyncEvent(event);
        }
      },
      onError: (error) {
        developer.log('Error in event stream: $error', name: 'PetivetiSync');
      },
    );
  }

  /// Configura funcionalidades específicas do pet care
  Future<void> _setupPetCareFeatures() async {
    final features = _config!.petCareFeatures;

    // Configurar alertas médicos
    if (features.enableMedicalAlerts) {
      await _setupMedicalAlerts();
    }

    // Configurar lembretes de cronograma
    if (features.enableScheduleReminders) {
      await _setupScheduleReminders();
    }

    // Configurar monitoramento de emergência
    if (_config!.emergencyDataConfig.enableEmergencyMode) {
      await _setupEmergencyMonitoring();
    }

    developer.log(
      'Pet care features configured: ${features.enabledFeatures}',
      name: 'PetivetiSync',
    );
  }

  /// Configura alertas médicos
  Future<void> _setupMedicalAlerts() async {
    // TODO: Implementar alertas para medicações vencendo
    // TODO: Implementar alertas para consultas próximas
    // TODO: Implementar alertas para vacinas em atraso
    developer.log('Medical alerts configured', name: 'PetivetiSync');
  }

  /// Configura lembretes de cronograma
  Future<void> _setupScheduleReminders() async {
    // TODO: Implementar lembretes de alimentação
    // TODO: Implementar lembretes de exercícios
    // TODO: Implementar lembretes de medicação
    developer.log('Schedule reminders configured', name: 'PetivetiSync');
  }

  /// Configura monitoramento de emergência
  Future<void> _setupEmergencyMonitoring() async {
    // Monitorar dados críticos de medicação
    // Monitorar mudanças significativas de peso
    // Monitorar consultas de emergência
    developer.log('Emergency monitoring configured', name: 'PetivetiSync');
  }

  /// Manipula mudanças de status
  void _handleStatusChange(SyncStatus status) {
    developer.log('Sync status changed to: ${status.name}', name: 'PetivetiSync');

    // Emitir status de emergência se necessário
    if (_config!.emergencyDataConfig.enableEmergencyMode) {
      _emitEmergencyStatus(status);
    }
  }

  /// Manipula eventos de sync
  void _handleSyncEvent(AppSyncEvent event) {
    developer.log(
      'Sync event: ${event.action.name} for ${event.entityType}',
      name: 'PetivetiSync',
    );

    // Converter para evento específico do pet care
    final petCareEvent = _convertToPetCareEvent(event);
    if (petCareEvent != null) {
      _petCareEventController.add(petCareEvent);
    }

    // Verificar se é evento de emergência
    if (_isEmergencyEvent(event)) {
      _handleEmergencyEvent(event);
    }
  }

  /// Converte evento genérico para evento de pet care
  PetCareSyncEvent? _convertToPetCareEvent(AppSyncEvent event) {
    PetCareEntityType? entityType;

    switch (event.entityType.toString()) {
      case 'AnimalSyncEntity':
        entityType = PetCareEntityType.animal;
        break;
      case 'MedicationSyncEntity':
        entityType = PetCareEntityType.medication;
        break;
      case 'AppointmentSyncEntity':
        entityType = PetCareEntityType.appointment;
        break;
      case 'WeightSyncEntity':
        entityType = PetCareEntityType.weight;
        break;
      case 'UserSettingsSyncEntity':
        entityType = PetCareEntityType.settings;
        break;
      default:
        return null;
    }

    return PetCareSyncEvent(
      entityType: entityType,
      action: _convertSyncAction(event.action),
      entityId: event.entityId,
      timestamp: event.timestamp ?? DateTime.now(),
      error: event.error,
    );
  }

  /// Converte ação de sync
  PetCareSyncAction _convertSyncAction(SyncAction action) {
    switch (action) {
      case SyncAction.create:
        return PetCareSyncAction.create;
      case SyncAction.update:
        return PetCareSyncAction.update;
      case SyncAction.delete:
        return PetCareSyncAction.delete;
      case SyncAction.sync:
        return PetCareSyncAction.sync;
      case SyncAction.conflict:
        return PetCareSyncAction.conflict;
      case SyncAction.error:
        return PetCareSyncAction.error;
    }
  }

  /// Verifica se é evento de emergência
  bool _isEmergencyEvent(AppSyncEvent event) {
    // Medicações sempre são críticas
    if (event.entityType.toString() == 'MedicationSyncEntity') {
      return true;
    }

    // Consultas de emergência
    if (event.entityType.toString() == 'AppointmentSyncEntity') {
      // TODO: Verificar se é consulta de emergência
      return false;
    }

    // Mudanças significativas de peso
    if (event.entityType.toString() == 'WeightSyncEntity') {
      // TODO: Verificar se é mudança significativa
      return false;
    }

    return false;
  }

  /// Manipula evento de emergência
  void _handleEmergencyEvent(AppSyncEvent event) {
    developer.log(
      'Emergency event detected: ${event.entityType} ${event.action.name}',
      name: 'PetivetiSync',
    );

    // TODO: Implementar notificações de emergência
    // TODO: Implementar sync prioritário
  }

  /// Emite status de emergência
  void _emitEmergencyStatus(SyncStatus status) {
    final emergencyStatus = EmergencySyncStatus(
      isEmergencyMode: _config!.emergencyDataConfig.enableEmergencyMode,
      medicalDataSynced: status == SyncStatus.synced,
      lastEmergencySync: DateTime.now(),
      priorityDataPending: status == SyncStatus.syncing,
    );

    _emergencyStatusController.add(emergencyStatus);
  }

  /// Força sync de dados de emergência
  Future<Either<Failure, void>> forceEmergencySync() async {
    if (!_isInitialized) {
      return Left(InitializationFailure('Sync service not initialized'));
    }

    developer.log('Forcing emergency sync', name: 'PetivetiSync');

    // Forçar sync de medicações primeiro (prioridade crítica)
    final medicationResult = await UnifiedSyncManager.instance.forceSyncEntity<MedicationSyncEntity>(
      _config!.appSyncConfig.appName,
    );

    if (medicationResult.isLeft()) {
      return medicationResult;
    }

    // Forçar sync de animais
    final animalResult = await UnifiedSyncManager.instance.forceSyncEntity<AnimalSyncEntity>(
      _config!.appSyncConfig.appName,
    );

    if (animalResult.isLeft()) {
      return animalResult;
    }

    // Forçar sync de consultas
    final appointmentResult = await UnifiedSyncManager.instance.forceSyncEntity<AppointmentSyncEntity>(
      _config!.appSyncConfig.appName,
    );

    return appointmentResult;
  }

  /// Obtém status de sync atual
  SyncStatus get currentStatus {
    if (!_isInitialized) return SyncStatus.offline;
    return UnifiedSyncManager.instance.getAppSyncStatus(_config!.appSyncConfig.appName);
  }

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    if (!_isInitialized) {
      return {'error': 'Not initialized'};
    }

    final baseInfo = UnifiedSyncManager.instance.getAppDebugInfo(_config!.appSyncConfig.appName);

    return {
      ...baseInfo,
      'petiveti_config': _config!.toDebugMap(),
      'pet_care_features_enabled': _config!.petCareFeatures.enabledFeatures,
      'emergency_mode': _config!.emergencyDataConfig.enableEmergencyMode,
      'family_sharing': false, // Single-user mode - family sharing disabled
      'is_initialized': _isInitialized,
    };
  }

  /// Wrapper methods para operações comuns

  // Animal operations
  Future<Either<Failure, String>> createAnimal(AnimalSyncEntity animal) async {
    return UnifiedSyncManager.instance.create(_config!.appSyncConfig.appName, animal);
  }

  Future<Either<Failure, void>> updateAnimal(String id, AnimalSyncEntity animal) async {
    return UnifiedSyncManager.instance.update(_config!.appSyncConfig.appName, id, animal);
  }

  Future<Either<Failure, List<AnimalSyncEntity>>> getAnimals() async {
    return UnifiedSyncManager.instance.findAll<AnimalSyncEntity>(_config!.appSyncConfig.appName);
  }

  Stream<List<AnimalSyncEntity>>? get animalsStream {
    return UnifiedSyncManager.instance.streamAll<AnimalSyncEntity>(_config!.appSyncConfig.appName);
  }

  // Medication operations
  Future<Either<Failure, String>> createMedication(MedicationSyncEntity medication) async {
    return UnifiedSyncManager.instance.create(_config!.appSyncConfig.appName, medication);
  }

  Future<Either<Failure, void>> updateMedication(String id, MedicationSyncEntity medication) async {
    return UnifiedSyncManager.instance.update(_config!.appSyncConfig.appName, id, medication);
  }

  Future<Either<Failure, List<MedicationSyncEntity>>> getMedications() async {
    return UnifiedSyncManager.instance.findAll<MedicationSyncEntity>(_config!.appSyncConfig.appName);
  }

  Stream<List<MedicationSyncEntity>>? get medicationsStream {
    return UnifiedSyncManager.instance.streamAll<MedicationSyncEntity>(_config!.appSyncConfig.appName);
  }

  // Appointment operations
  Future<Either<Failure, String>> createAppointment(AppointmentSyncEntity appointment) async {
    return UnifiedSyncManager.instance.create(_config!.appSyncConfig.appName, appointment);
  }

  Future<Either<Failure, void>> updateAppointment(String id, AppointmentSyncEntity appointment) async {
    return UnifiedSyncManager.instance.update(_config!.appSyncConfig.appName, id, appointment);
  }

  Future<Either<Failure, List<AppointmentSyncEntity>>> getAppointments() async {
    return UnifiedSyncManager.instance.findAll<AppointmentSyncEntity>(_config!.appSyncConfig.appName);
  }

  Stream<List<AppointmentSyncEntity>>? get appointmentsStream {
    return UnifiedSyncManager.instance.streamAll<AppointmentSyncEntity>(_config!.appSyncConfig.appName);
  }

  // Weight operations
  Future<Either<Failure, String>> createWeight(WeightSyncEntity weight) async {
    return UnifiedSyncManager.instance.create(_config!.appSyncConfig.appName, weight);
  }

  Future<Either<Failure, List<WeightSyncEntity>>> getWeights() async {
    return UnifiedSyncManager.instance.findAll<WeightSyncEntity>(_config!.appSyncConfig.appName);
  }

  Stream<List<WeightSyncEntity>>? get weightsStream {
    return UnifiedSyncManager.instance.streamAll<WeightSyncEntity>(_config!.appSyncConfig.appName);
  }

  // User Settings operations
  Future<Either<Failure, void>> updateUserSettings(String id, UserSettingsSyncEntity settings) async {
    return UnifiedSyncManager.instance.update(_config!.appSyncConfig.appName, id, settings);
  }

  Future<Either<Failure, UserSettingsSyncEntity?>> getUserSettings(String id) async {
    return UnifiedSyncManager.instance.findById<UserSettingsSyncEntity>(_config!.appSyncConfig.appName, id);
  }

  /// Dispose de recursos
  Future<void> dispose() async {
    try {
      await _statusSubscription?.cancel();
      await _eventSubscription?.cancel();
      await _petCareEventController.close();
      await _emergencyStatusController.close();

      _isInitialized = false;
      _config = null;

      developer.log('PetivetiSyncService disposed', name: 'PetivetiSync');
    } catch (e) {
      developer.log('Error disposing PetivetiSyncService: $e', name: 'PetivetiSync');
    }
  }
}

/// Evento específico do pet care
class PetCareSyncEvent {
  const PetCareSyncEvent({
    required this.entityType,
    required this.action,
    this.entityId,
    required this.timestamp,
    this.error,
  });

  final PetCareEntityType entityType;
  final PetCareSyncAction action;
  final String? entityId;
  final DateTime timestamp;
  final String? error;

  @override
  String toString() {
    return 'PetCareSyncEvent(type: $entityType, action: $action, id: $entityId)';
  }
}

/// Tipos de entidade específicos do pet care
enum PetCareEntityType {
  animal,
  medication,
  appointment,
  weight,
  settings,
}

/// Ações de sync específicas do pet care
enum PetCareSyncAction {
  create,
  update,
  delete,
  sync,
  conflict,
  error,
}

/// Status de sincronização de emergência
class EmergencySyncStatus {
  const EmergencySyncStatus({
    required this.isEmergencyMode,
    required this.medicalDataSynced,
    required this.lastEmergencySync,
    required this.priorityDataPending,
  });

  final bool isEmergencyMode;
  final bool medicalDataSynced;
  final DateTime lastEmergencySync;
  final bool priorityDataPending;

  bool get isEmergencyDataCurrent {
    final timeSinceSync = DateTime.now().difference(lastEmergencySync);
    return medicalDataSynced && timeSinceSync.inMinutes < 5;
  }

  @override
  String toString() {
    return 'EmergencySyncStatus(emergency: $isEmergencyMode, '
           'synced: $medicalDataSynced, pending: $priorityDataPending)';
  }
}