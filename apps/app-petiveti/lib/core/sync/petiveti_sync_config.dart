import 'package:core/core.dart';
import 'package:core/src/sync/entity_sync_registration.dart' as entity_sync;

import '../../features/animals/domain/entities/sync/animal_sync_entity.dart';
import '../../features/appointments/domain/entities/sync/appointment_sync_entity.dart';
import '../../features/medications/domain/entities/sync/medication_sync_entity.dart';
import '../../features/settings/domain/entities/sync/user_settings_sync_entity.dart';
import '../../features/weight/domain/entities/sync/weight_sync_entity.dart';

/// Configuração de sincronização específica para Petiveti
/// Implementa configurações especializadas para pet care com foco em:
/// - Single-user pet management (usuário único)
/// - Emergency data access (informações médicas críticas)
/// - Offline-first para dados de alimentação e rotina
/// - Real-time sync para dados médicos urgentes
class PetivetiSyncConfig {
  const PetivetiSyncConfig._({
    required this.appSyncConfig,
    required this.petCareFeatures,
    required this.emergencyDataConfig,
    required this.mediaConfig,
  });

  /// Configuração base do app
  final AppSyncConfig appSyncConfig;

  /// Configurações específicas de pet care
  final PetCareFeatures petCareFeatures;

  /// Configuração para dados de emergência
  final EmergencyDataConfig emergencyDataConfig;


  /// Configuração para mídia/fotos
  final MediaConfig mediaConfig;

  /// Modo Simples - Para uso básico do app sem recursos avançados
  /// Ideal para usuários únicos com um ou poucos pets
  factory PetivetiSyncConfig.simple({
    String appName = 'petiveti',
    Duration syncInterval = const Duration(minutes: 15),
  }) {
    return PetivetiSyncConfig._(
      appSyncConfig: AppSyncConfig.simple(
        appName: appName,
        syncInterval: syncInterval,
        conflictStrategy: ConflictStrategy.timestamp,
      ),
      petCareFeatures: const PetCareFeatures(
        enableMedicalAlerts: false,
        enableScheduleReminders: true,
        enableHealthTracking: false,
        enableVetIntegration: false,
        realTimeMedicalSync: false,
        offlineFirstFeeding: true,
      ),
      emergencyDataConfig: const EmergencyDataConfig(
        enableEmergencyMode: false,
        priorityMedicalData: false,
        offlineEmergencyAccess: true,
        emergencySyncPriority: entity_sync.SyncPriority.normal,
      ),
      mediaConfig: const MediaConfig(
        enablePhotoSync: true,
        maxPhotoSize: 2, // MB
        photoCompressionQuality: 0.7,
        enableVideoSync: false,
        batchPhotoUpload: false,
      ),
    );
  }

  /// Modo Desenvolvimento - Para desenvolvimento e testes
  /// Inclui logging detalhado e sync frequente
  factory PetivetiSyncConfig.development({
    String appName = 'petiveti-dev',
    Duration syncInterval = const Duration(minutes: 2),
  }) {
    return PetivetiSyncConfig._(
      appSyncConfig: AppSyncConfig.development(
        appName: appName,
        syncInterval: syncInterval,
      ),
      petCareFeatures: const PetCareFeatures(
        enableMedicalAlerts: true,
        enableScheduleReminders: true,
        enableHealthTracking: true,
        enableVetIntegration: true,
        realTimeMedicalSync: true,
        offlineFirstFeeding: true,
      ),
      emergencyDataConfig: const EmergencyDataConfig(
        enableEmergencyMode: true,
        priorityMedicalData: true,
        offlineEmergencyAccess: true,
        emergencySyncPriority: entity_sync.SyncPriority.high,
      ),
      mediaConfig: const MediaConfig(
        enablePhotoSync: true,
        maxPhotoSize: 5, // MB
        photoCompressionQuality: 0.9,
        enableVideoSync: true,
        batchPhotoUpload: true,
      ),
    );
  }

  /// Modo Offline-First - Para uso principalmente offline
  /// Maximiza funcionalidade offline e sincroniza quando possível
  /// Ideal para áreas com conectividade limitada
  factory PetivetiSyncConfig.offlineFirst({
    String appName = 'petiveti',
    Duration syncInterval = const Duration(hours: 2),
  }) {
    return PetivetiSyncConfig._(
      appSyncConfig: AppSyncConfig.offlineFirst(
        appName: appName,
        syncInterval: syncInterval,
      ),
      petCareFeatures: const PetCareFeatures(
        enableMedicalAlerts: true,
        enableScheduleReminders: true,
        enableHealthTracking: true,
        enableVetIntegration: false, // Não disponível offline
        realTimeMedicalSync: false, // Sync em lotes
        offlineFirstFeeding: true,
      ),
      emergencyDataConfig: const EmergencyDataConfig(
        enableEmergencyMode: true,
        priorityMedicalData: true,
        offlineEmergencyAccess: true,
        emergencySyncPriority: entity_sync.SyncPriority.critical,
      ),
      mediaConfig: const MediaConfig(
        enablePhotoSync: true,
        maxPhotoSize: 1, // MB - Comprimido para economizar dados
        photoCompressionQuality: 0.5,
        enableVideoSync: false, // Muito pesado para offline
        batchPhotoUpload: true,
      ),
    );
  }

  /// Configuração customizada para necessidades específicas
  factory PetivetiSyncConfig.custom({
    required AppSyncConfig appSyncConfig,
    PetCareFeatures? petCareFeatures,
    EmergencyDataConfig? emergencyDataConfig,
    MediaConfig? mediaConfig,
  }) {
    return PetivetiSyncConfig._(
      appSyncConfig: appSyncConfig,
      petCareFeatures: petCareFeatures ?? const PetCareFeatures(),
      emergencyDataConfig: emergencyDataConfig ?? const EmergencyDataConfig(),
      mediaConfig: mediaConfig ?? const MediaConfig(),
    );
  }

  /// Converte para lista de registros de entidades
  List<EntitySyncRegistration> get entityRegistrations => [
    EntitySyncRegistration<AnimalSyncEntity>(
      entityType: AnimalSyncEntity,
      collectionName: 'animals',
      fromMap: (map) => AnimalSyncEntity.fromFirebaseMap(map),
      toMap: (entity) => entity.toFirebaseMap(),
      enableRealtime: petCareFeatures.realTimeMedicalSync,
      enableOfflineMode: true,
      batchSize: 25,
      syncInterval: appSyncConfig.syncInterval,
      priority: entity_sync.SyncPriority.high,
      conflictStrategy: ConflictStrategy.timestamp,
    ),
    EntitySyncRegistration<MedicationSyncEntity>(
      entityType: MedicationSyncEntity,
      collectionName: 'medications',
      fromMap: (map) => MedicationSyncEntity.fromFirebaseMap(map),
      toMap: (entity) => entity.toFirebaseMap(),
      enableRealtime: emergencyDataConfig.priorityMedicalData,
      enableOfflineMode: emergencyDataConfig.offlineEmergencyAccess,
      batchSize: 15,
      syncInterval: emergencyDataConfig.priorityMedicalData
        ? const Duration(minutes: 2)
        : appSyncConfig.syncInterval,
      priority: emergencyDataConfig.emergencySyncPriority,
      conflictStrategy: ConflictStrategy.version,
    ),
    EntitySyncRegistration<AppointmentSyncEntity>(
      entityType: AppointmentSyncEntity,
      collectionName: 'appointments',
      fromMap: (map) => AppointmentSyncEntity.fromFirebaseMap(map),
      toMap: (entity) => entity.toFirebaseMap(),
      enableRealtime: petCareFeatures.enableVetIntegration,
      enableOfflineMode: true,
      batchSize: 20,
      syncInterval: appSyncConfig.syncInterval,
      priority: entity_sync.SyncPriority.high,
      conflictStrategy: ConflictStrategy.timestamp,
    ),
    EntitySyncRegistration<WeightSyncEntity>(
      entityType: WeightSyncEntity,
      collectionName: 'weights',
      fromMap: (map) => WeightSyncEntity.fromFirebaseMap(map),
      toMap: (entity) => entity.toFirebaseMap(),
      enableRealtime: petCareFeatures.enableHealthTracking,
      enableOfflineMode: true,
      batchSize: 50,
      syncInterval: appSyncConfig.syncInterval,
      priority: entity_sync.SyncPriority.normal,
      conflictStrategy: ConflictStrategy.timestamp,
    ),
    EntitySyncRegistration<UserSettingsSyncEntity>(
      entityType: UserSettingsSyncEntity,
      collectionName: 'user_settings',
      fromMap: (map) => UserSettingsSyncEntity.fromFirebaseMap(map),
      toMap: (entity) => entity.toFirebaseMap(),
      enableRealtime: false, // Single-user não precisa de realtime
      enableOfflineMode: true,
      batchSize: 10,
      syncInterval: Duration(minutes: appSyncConfig.syncInterval.inMinutes * 2),
      priority: entity_sync.SyncPriority.low,
      conflictStrategy: ConflictStrategy.localWins,
    ),
  ];

  /// Informações para debug
  Map<String, dynamic> toDebugMap() {
    return {
      'app_config': appSyncConfig.toDebugMap(),
      'pet_care_features': petCareFeatures.toDebugMap(),
      'emergency_config': emergencyDataConfig.toDebugMap(),
      'single_user_mode': true,
      'media_config': mediaConfig.toDebugMap(),
      'entity_count': entityRegistrations.length,
    };
  }

  @override
  String toString() {
    return 'PetivetiSyncConfig(app: ${appSyncConfig.appName}, '
           'features: ${petCareFeatures.enabledFeatures}, '
           'emergency: ${emergencyDataConfig.enableEmergencyMode}, '
           'mode: single-user)';
  }
}

/// Configurações específicas de funcionalidades de pet care
class PetCareFeatures {
  const PetCareFeatures({
    this.enableMedicalAlerts = true,
    this.enableScheduleReminders = true,
    this.enableHealthTracking = true,
    this.enableVetIntegration = false,
    this.realTimeMedicalSync = false,
    this.offlineFirstFeeding = true,
  });

  /// Alertas médicos (medicações, consultas)
  final bool enableMedicalAlerts;

  /// Lembretes de cronograma (alimentação, exercícios)
  final bool enableScheduleReminders;

  /// Acompanhamento de saúde (peso, vacinas)
  final bool enableHealthTracking;

  /// Integração com veterinários
  final bool enableVetIntegration;

  /// Sincronização em tempo real para dados médicos
  final bool realTimeMedicalSync;

  /// Alimentação funciona offline primeiro
  final bool offlineFirstFeeding;

  /// Lista de funcionalidades habilitadas
  List<String> get enabledFeatures {
    final features = <String>[];
    if (enableMedicalAlerts) features.add('medical_alerts');
    if (enableScheduleReminders) features.add('schedule_reminders');
    if (enableHealthTracking) features.add('health_tracking');
    if (enableVetIntegration) features.add('vet_integration');
    if (realTimeMedicalSync) features.add('realtime_medical');
    if (offlineFirstFeeding) features.add('offline_feeding');
    return features;
  }

  Map<String, dynamic> toDebugMap() {
    return {
      'medical_alerts': enableMedicalAlerts,
      'schedule_reminders': enableScheduleReminders,
      'health_tracking': enableHealthTracking,
      'vet_integration': enableVetIntegration,
      'realtime_medical_sync': realTimeMedicalSync,
      'offline_first_feeding': offlineFirstFeeding,
      'enabled_features': enabledFeatures,
    };
  }
}

/// Configuração para dados de emergência
class EmergencyDataConfig {
  const EmergencyDataConfig({
    this.enableEmergencyMode = true,
    this.priorityMedicalData = true,
    this.offlineEmergencyAccess = true,
    this.emergencySyncPriority = entity_sync.SyncPriority.high,
  });

  /// Modo de emergência habilitado
  final bool enableEmergencyMode;

  /// Dados médicos têm prioridade
  final bool priorityMedicalData;

  /// Acesso offline a dados de emergência
  final bool offlineEmergencyAccess;

  /// Prioridade de sync para emergências
  final entity_sync.SyncPriority emergencySyncPriority;

  Map<String, dynamic> toDebugMap() {
    return {
      'emergency_mode': enableEmergencyMode,
      'priority_medical_data': priorityMedicalData,
      'offline_emergency_access': offlineEmergencyAccess,
      'emergency_sync_priority': emergencySyncPriority.name,
    };
  }
}


/// Configuração para mídia (fotos, vídeos)
class MediaConfig {
  const MediaConfig({
    this.enablePhotoSync = true,
    this.maxPhotoSize = 2, // MB
    this.photoCompressionQuality = 0.7,
    this.enableVideoSync = false,
    this.batchPhotoUpload = false,
  });

  /// Sincronização de fotos habilitada
  final bool enablePhotoSync;

  /// Tamanho máximo da foto em MB
  final double maxPhotoSize;

  /// Qualidade da compressão (0.0 - 1.0)
  final double photoCompressionQuality;

  /// Sincronização de vídeos habilitada
  final bool enableVideoSync;

  /// Upload de fotos em lote
  final bool batchPhotoUpload;

  Map<String, dynamic> toDebugMap() {
    return {
      'photo_sync': enablePhotoSync,
      'max_photo_size_mb': maxPhotoSize,
      'photo_compression_quality': photoCompressionQuality,
      'video_sync': enableVideoSync,
      'batch_photo_upload': batchPhotoUpload,
    };
  }
}

