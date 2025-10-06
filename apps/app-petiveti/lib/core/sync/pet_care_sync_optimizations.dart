import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../features/animals/domain/entities/sync/animal_sync_entity.dart';
import '../../features/appointments/domain/entities/sync/appointment_sync_entity.dart';
import '../../features/medications/domain/entities/sync/medication_sync_entity.dart';
import 'petiveti_sync_config.dart';

/// Otimizações específicas para pet care
/// Implementa funcionalidades avançadas de sincronização:
/// - Emergency data priority para situações críticas
/// - Conflict resolution específico para dados médicos
/// - Batch optimization para dados de rotina
/// - Single-user optimizations
class PetCareSyncOptimizations {
  static final PetCareSyncOptimizations _instance = PetCareSyncOptimizations._internal();
  static PetCareSyncOptimizations get instance => _instance;

  PetCareSyncOptimizations._internal();

  PetivetiSyncConfig? _config;
  Timer? _emergencyCheckTimer;
  final Set<String> _emergencyEntityIds = <String>{};

  /// Inicializa otimizações
  Future<void> initialize(PetivetiSyncConfig config) async {
    _config = config;

    developer.log(
      'Initializing PetCareSyncOptimizations',
      name: 'PetCareOptimizations',
    );

    if (config.emergencyDataConfig.enableEmergencyMode) {
      await _initializeEmergencyMode();
    }

    developer.log(
      'PetCareSyncOptimizations initialized successfully',
      name: 'PetCareOptimizations',
    );
  }

  /// Inicializa modo de emergência
  Future<void> _initializeEmergencyMode() async {
    developer.log('Initializing emergency mode', name: 'PetCareOptimizations');
    _emergencyCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkEmergencyData(),
    );
    await _identifyEmergencyData();
  }


  /// Identifica dados de emergência no sistema
  Future<void> _identifyEmergencyData() async {
    try {
      final appName = _config!.appSyncConfig.appName;
      final medicationsResult = await UnifiedSyncManager.instance.findAll<MedicationSyncEntity>(appName);
      medicationsResult.fold(
        (failure) => developer.log('Error loading medications: ${failure.message}'),
        (medications) {
          for (final medication in medications) {
            if (medication.requiresEmergencySync) {
              _emergencyEntityIds.add(medication.id);
              developer.log('Emergency medication identified: ${medication.id}');
            }
          }
        },
      );
      final appointmentsResult = await UnifiedSyncManager.instance.findAll<AppointmentSyncEntity>(appName);
      appointmentsResult.fold(
        (failure) => developer.log('Error loading appointments: ${failure.message}'),
        (appointments) {
          for (final appointment in appointments) {
            if (appointment.requiresUrgentSync) {
              _emergencyEntityIds.add(appointment.id);
              developer.log('Emergency appointment identified: ${appointment.id}');
            }
          }
        },
      );
      final animalsResult = await UnifiedSyncManager.instance.findAll<AnimalSyncEntity>(appName);
      animalsResult.fold(
        (failure) => developer.log('Error loading animals: ${failure.message}'),
        (animals) {
          for (final animal in animals) {
            if (animal.hasEmergencyData) {
              _emergencyEntityIds.add(animal.id);
              developer.log('Animal with emergency data identified: ${animal.id}');
            }
          }
        },
      );

      developer.log(
        'Identified ${_emergencyEntityIds.length} emergency entities',
        name: 'PetCareOptimizations',
      );
    } catch (e) {
      developer.log('Error identifying emergency data: $e', name: 'PetCareOptimizations');
    }
  }

  /// Verifica dados de emergência periodicamente
  Future<void> _checkEmergencyData() async {
    try {
      if (_emergencyEntityIds.isEmpty) {
        await _identifyEmergencyData();
        return;
      }

      developer.log('Checking emergency data sync status', name: 'PetCareOptimizations');
      final appName = _config!.appSyncConfig.appName;
      bool needsEmergencySync = false;
      for (final entityId in _emergencyEntityIds) {
        final medicationResult = await UnifiedSyncManager.instance.findById<MedicationSyncEntity>(
          appName,
          entityId,
        );

        medicationResult.fold(
          (failure) => null,
          (medication) {
            if (medication != null && medication.needsSync) {
              needsEmergencySync = true;
              developer.log('Emergency medication needs sync: ${medication.id}');
            }
          },
        );
      }

      if (needsEmergencySync) {
        await _executeEmergencySync();
      }
    } catch (e) {
      developer.log('Error checking emergency data: $e', name: 'PetCareOptimizations');
    }
  }

  /// Executa sincronização de emergência
  Future<void> _executeEmergencySync() async {
    developer.log('Executing emergency sync', name: 'PetCareOptimizations');

    final appName = _config!.appSyncConfig.appName;

    try {
      final medicationResult = await UnifiedSyncManager.instance.forceSyncEntity<MedicationSyncEntity>(appName);
      if (medicationResult.isLeft()) {
        developer.log('Emergency medication sync failed', name: 'PetCareOptimizations');
      }
      final appointmentResult = await UnifiedSyncManager.instance.forceSyncEntity<AppointmentSyncEntity>(appName);
      if (appointmentResult.isLeft()) {
        developer.log('Emergency appointment sync failed', name: 'PetCareOptimizations');
      }
      final animalResult = await UnifiedSyncManager.instance.forceSyncEntity<AnimalSyncEntity>(appName);
      if (animalResult.isLeft()) {
        developer.log('Emergency animal sync failed', name: 'PetCareOptimizations');
      }

      developer.log('Emergency sync completed', name: 'PetCareOptimizations');
    } catch (e) {
      developer.log('Error during emergency sync: $e', name: 'PetCareOptimizations');
    }
  }


  /// Otimiza sync baseado no tipo de dados
  SyncPriority optimizeSyncPriority(String entityType, Map<String, dynamic> entityData) {
    switch (entityType) {
      case 'MedicationSyncEntity':
        return _optimizeMedicationPriority(entityData);
      case 'AppointmentSyncEntity':
        return _optimizeAppointmentPriority(entityData);
      case 'WeightSyncEntity':
        return _optimizeWeightPriority(entityData);
      case 'AnimalSyncEntity':
        return _optimizeAnimalPriority(entityData);
      default:
        return SyncPriority.normal;
    }
  }

  /// Otimiza prioridade de medicação
  SyncPriority _optimizeMedicationPriority(Map<String, dynamic> data) {
    final isCritical = data['is_critical'] as bool? ?? false;
    final requiresSupervision = data['requires_supervision'] as bool? ?? false;
    final isOverdue = data['is_overdue'] as bool? ?? false;

    if (isCritical || isOverdue) {
      return SyncPriority.critical;
    } else if (requiresSupervision) {
      return SyncPriority.high;
    } else {
      return SyncPriority.normal;
    }
  }

  /// Otimiza prioridade de consulta
  SyncPriority _optimizeAppointmentPriority(Map<String, dynamic> data) {
    final isEmergency = data['is_emergency'] as bool? ?? false;
    final priority = data['priority'] as String?;

    if (isEmergency || priority == 'emergency') {
      return SyncPriority.critical;
    } else if (priority == 'urgent') {
      return SyncPriority.high;
    } else {
      return SyncPriority.normal;
    }
  }

  /// Otimiza prioridade de peso
  SyncPriority _optimizeWeightPriority(Map<String, dynamic> data) {
    final requiresVetAttention = data['requires_vet_attention'] as bool? ?? false;
    final isSignificantChange = data['is_significant_change'] as bool? ?? false;

    if (requiresVetAttention) {
      return SyncPriority.high;
    } else if (isSignificantChange) {
      return SyncPriority.normal;
    } else {
      return SyncPriority.low;
    }
  }

  /// Otimiza prioridade de animal
  SyncPriority _optimizeAnimalPriority(Map<String, dynamic> data) {
    final hasEmergencyData = data['has_emergency_data'] as bool? ?? false;
    final isShared = data['is_shared'] as bool? ?? false;

    if (hasEmergencyData) {
      return SyncPriority.high;
    } else if (isShared) {
      return SyncPriority.normal;
    } else {
      return SyncPriority.low;
    }
  }

  /// Otimiza batch size baseado no tipo de entidade
  int optimizeBatchSize(String entityType, int defaultBatchSize) {
    switch (entityType) {
      case 'MedicationSyncEntity':
        return 10;
      case 'AppointmentSyncEntity':
        return 20;
      case 'WeightSyncEntity':
        return 50;
      case 'AnimalSyncEntity':
        return 15;
      case 'UserSettingsSyncEntity':
        return 5;
      default:
        return defaultBatchSize;
    }
  }

  /// Estratégia de resolução de conflitos específica para pet care
  ConflictResolutionStrategy getConflictResolution(String entityType, Map<String, dynamic> context) {
    switch (entityType) {
      case 'MedicationSyncEntity':
        return ConflictResolutionStrategy.timestamp;
      case 'AppointmentSyncEntity':
        final priority = context['priority'] as String?;
        if (priority == 'emergency') {
          return ConflictResolutionStrategy.timestamp;
        } else {
          return ConflictResolutionStrategy.manual;
        }
      case 'WeightSyncEntity':
        return ConflictResolutionStrategy.manual;
      case 'AnimalSyncEntity':
        if (context['has_emergency_data'] == true) {
          return ConflictResolutionStrategy.timestamp;
        } else {
          return ConflictResolutionStrategy.version;
        }
      case 'UserSettingsSyncEntity':
        return ConflictResolutionStrategy.localWins;
      default:
        return ConflictResolutionStrategy.timestamp;
    }
  }

  /// Decide se deve usar sync em tempo real
  bool shouldUseRealtimeSync(String entityType, Map<String, dynamic> entityData) {
    if (!_config!.petCareFeatures.realTimeMedicalSync) {
      return false;
    }

    switch (entityType) {
      case 'MedicationSyncEntity':
        final isCritical = entityData['is_critical'] as bool? ?? false;
        final requiresSupervision = entityData['requires_supervision'] as bool? ?? false;
        return isCritical || requiresSupervision;

      case 'AppointmentSyncEntity':
        final isEmergency = entityData['is_emergency'] as bool? ?? false;
        final isToday = entityData['is_today'] as bool? ?? false;
        return isEmergency || isToday;

      case 'AnimalSyncEntity':
        final hasEmergencyData = entityData['has_emergency_data'] as bool? ?? false;
        return hasEmergencyData;

      case 'WeightSyncEntity':
        final requiresVetAttention = entityData['requires_vet_attention'] as bool? ?? false;
        return requiresVetAttention;

      default:
        return false;
    }
  }


  /// Obtém estatísticas de otimização
  Map<String, dynamic> getOptimizationStats() {
    return {
      'emergency_entities_count': _emergencyEntityIds.length,
      'emergency_mode_enabled': _config?.emergencyDataConfig.enableEmergencyMode ?? false,
      'last_emergency_check': _emergencyCheckTimer?.isActive ?? false,
    };
  }

  /// Limpa recursos
  Future<void> dispose() async {
    _emergencyCheckTimer?.cancel();
    _emergencyEntityIds.clear();
    _config = null;

    developer.log('PetCareSyncOptimizations disposed', name: 'PetCareOptimizations');
  }
}

