import 'package:core/core.dart';

import '../../features/fuel/data/models/fuel_supply_model.dart';
import '../../features/fuel/domain/entities/fuel_record_entity.dart';
import '../../features/maintenance/data/models/maintenance_model.dart';
import '../../features/maintenance/domain/entities/maintenance_entity.dart';
import '../../features/vehicles/data/models/vehicle_model.dart';
import '../../features/vehicles/domain/entities/vehicle_entity.dart';
import '../services/conflict_audit_service.dart';
import 'conflict_resolution_strategy.dart';

/// Configuração de sincronização específica do app-gasometer
/// Gerencia sincronização offline-first de veículos, abastecimentos e manutenções
/// com estratégias otimizadas para dados financeiros
///
/// **ID Reconciliation:**
/// O sistema usa DataIntegrityService para prevenir duplicação de registros quando:
/// 1. Usuário cria registro offline (ID local temporário)
/// 2. Registro é sincronizado com Firebase (pode receber ID remoto diferente)
/// 3. DataIntegrityService reconcilia IDs (atualiza HiveBox e referências)
///
/// **Quando executar ID Reconciliation:**
/// - Após forceSync manual: `await dataIntegrityService.verifyDataIntegrity()`
/// - Periodicamente em background (timer)
/// - Antes de operações críticas (relatórios financeiros, exportação)
///
/// **Exemplo de uso:**
/// ```dart
/// // 1. Criar veículo offline
/// final vehicle = VehicleEntity(id: 'local_abc123', ...);
/// await unifiedSync.create('gasometer', vehicle);
///
/// // 2. Sincronizar
/// await unifiedSync.forceSyncApp('gasometer');
///
/// // 3. Reconciliar IDs (se necessário)
/// final dataIntegrity = getIt<DataIntegrityService>();
/// await dataIntegrity.verifyDataIntegrity();
/// ```
abstract final class GasometerSyncConfig {
  const GasometerSyncConfig._();

  /// Configura o sistema de sincronização para o app-gasometer
  /// Usa configuração avançada devido à natureza crítica dos dados financeiros
  ///
  /// **Conflict Resolution Strategy:**
  /// - **VehicleModel**: Version-based + Custom merge (prioriza dados mais recentes)
  /// - **FuelSupplyModel**: Last Write Wins (timestamp-based)
  /// - **MaintenanceModel**: Last Write Wins (timestamp-based)
  ///
  /// Todos os conflitos são registrados pelo ConflictAuditService para auditoria.
  static Future<void> configure() async {
    // Obter serviços necessários
    final loggingService = getIt<LoggingService>();
    final conflictAuditService = ConflictAuditService(loggingService);

    // Registrar no DI para uso global (se necessário)
    if (!getIt.isRegistered<ConflictAuditService>()) {
      getIt.registerSingleton<ConflictAuditService>(conflictAuditService);
    }

    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.advanced(
        appName: 'gasometer',
        syncInterval: const Duration(
          minutes: 3,
        ), // Sync frequente para dados financeiros
        conflictStrategy:
            ConflictStrategy.version, // Version-based para segurança
        enableOrchestration: true, // Entidades têm dependências (Vehicle -> Fuel)
      ),
      entities: [
        // Vehicle é a entidade raiz - deve ser sincronizada primeiro
        // Usa version-based + custom merge conflict resolution
        EntitySyncRegistration<VehicleEntity>.advanced(
          entityType: VehicleEntity,
          collectionName: 'vehicles',
          fromMap: _vehicleFromFirebaseMap,
          toMap: (vehicle) => vehicle.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.version,
          conflictResolver: (local, remote) {
            return _resolveVehicleConflict(
              local as VehicleEntity,
              remote as VehicleEntity,
              conflictAuditService,
            );
          },
        ),

        // FuelRecord depende de Vehicle
        // Usa Last Write Wins (timestamp-based)
        EntitySyncRegistration<FuelRecordEntity>.advanced(
          entityType: FuelRecordEntity,
          collectionName: 'fuel_records',
          fromMap: _fuelRecordFromFirebaseMap,
          toMap: (fuelRecord) => fuelRecord.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.timestamp,
          conflictResolver: (local, remote) {
            return _resolveFuelSupplyConflict(
              local as FuelRecordEntity,
              remote as FuelRecordEntity,
              conflictAuditService,
            );
          },
        ),

        // Maintenance também depende de Vehicle
        // Usa Last Write Wins (timestamp-based)
        EntitySyncRegistration<MaintenanceEntity>.advanced(
          entityType: MaintenanceEntity,
          collectionName: 'maintenance_records',
          fromMap: _maintenanceFromFirebaseMap,
          toMap: (maintenance) => maintenance.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.timestamp,
          conflictResolver: (local, remote) {
            return _resolveMaintenanceConflict(
              local as MaintenanceEntity,
              remote as MaintenanceEntity,
              conflictAuditService,
            );
          },
        ),
      ],
    );

    loggingService.info('[GasometerSync] Conflict resolution strategy configured');
  }

  /// Resolve conflito de VehicleEntity usando VehicleConflictResolver
  static VehicleEntity _resolveVehicleConflict(
    VehicleEntity localEntity,
    VehicleEntity remoteEntity,
    ConflictAuditService auditService,
  ) {
    // Converter entities para models para usar os resolvers
    final localModel = VehicleModel.fromEntity(localEntity);
    final remoteModel = VehicleModel.fromEntity(remoteEntity);

    // Resolver usando VehicleConflictResolver
    final resolver = VehicleConflictResolver();
    final resolution = resolver.resolve(localModel, remoteModel);

    // Log de auditoria
    auditService.logConflict(
      entityType: 'vehicle',
      entityId: localEntity.id,
      localEntity: localModel,
      remoteEntity: remoteModel,
      resolution: resolution.action,
      mergedEntity: resolution.action == ConflictAction.useMerged
          ? resolution.mergedEntity
          : null,
    );

    // Retornar entity resolvida
    return resolution.resolvedEntity.toEntity();
  }

  /// Resolve conflito de FuelRecordEntity usando FuelSupplyConflictResolver
  static FuelRecordEntity _resolveFuelSupplyConflict(
    FuelRecordEntity localEntity,
    FuelRecordEntity remoteEntity,
    ConflictAuditService auditService,
  ) {
    // Converter entities para models
    final localModel = _fuelRecordToModel(localEntity);
    final remoteModel = _fuelRecordToModel(remoteEntity);

    // Resolver usando FuelSupplyConflictResolver
    final resolver = FuelSupplyConflictResolver();
    final resolution = resolver.resolve(localModel, remoteModel);

    // Log de auditoria (especial para dados financeiros)
    auditService.logConflict(
      entityType: 'fuel_supply',
      entityId: localEntity.id,
      localEntity: localModel,
      remoteEntity: remoteModel,
      resolution: resolution.action,
      additionalNotes: 'Financial data - requires special attention',
    );

    // Retornar entity resolvida
    return _modelToFuelRecord(resolution.resolvedEntity);
  }

  /// Resolve conflito de MaintenanceEntity usando MaintenanceConflictResolver
  static MaintenanceEntity _resolveMaintenanceConflict(
    MaintenanceEntity localEntity,
    MaintenanceEntity remoteEntity,
    ConflictAuditService auditService,
  ) {
    // Converter entities para models
    final localModel = _maintenanceToModel(localEntity);
    final remoteModel = _maintenanceToModel(remoteEntity);

    // Resolver usando MaintenanceConflictResolver
    final resolver = MaintenanceConflictResolver();
    final resolution = resolver.resolve(localModel, remoteModel);

    // Log de auditoria (especial para dados financeiros)
    auditService.logConflict(
      entityType: 'maintenance',
      entityId: localEntity.id,
      localEntity: localModel,
      remoteEntity: remoteModel,
      resolution: resolution.action,
      additionalNotes: 'Financial data - requires special attention',
    );

    // Retornar entity resolvida
    return _modelToMaintenance(resolution.resolvedEntity);
  }
}

// ============================================================================
// Funções de conversão Firebase Map <-> Entity
// ============================================================================

VehicleEntity _vehicleFromFirebaseMap(Map<String, dynamic> map) {
  return VehicleEntity.fromFirebaseMap(map);
}

FuelRecordEntity _fuelRecordFromFirebaseMap(Map<String, dynamic> map) {
  return FuelRecordEntity.fromFirebaseMap(map);
}

MaintenanceEntity _maintenanceFromFirebaseMap(Map<String, dynamic> map) {
  return MaintenanceEntity.fromFirebaseMap(map);
}

// ============================================================================
// Funções de conversão Entity <-> Model (para conflict resolution)
// ============================================================================

/// Converte FuelRecordEntity para FuelSupplyModel
FuelSupplyModel _fuelRecordToModel(FuelRecordEntity entity) {
  return FuelSupplyModel(
    id: entity.id,
    createdAtMs: entity.createdAt?.millisecondsSinceEpoch,
    updatedAtMs: entity.updatedAt?.millisecondsSinceEpoch,
    lastSyncAtMs: entity.metadata['lastSyncAt'] != null
        ? (entity.metadata['lastSyncAt'] as DateTime).millisecondsSinceEpoch
        : null,
    isDirty: entity.metadata['isDirty'] as bool? ?? false,
    isDeleted: !entity.isActive,
    version: entity.metadata['version'] as int? ?? 1,
    userId: entity.userId,
    moduleName: 'gasometer',
    vehicleId: entity.vehicleId,
    date: entity.date.millisecondsSinceEpoch,
    odometer: entity.odometer,
    liters: entity.liters,
    totalPrice: entity.totalCost,
    fullTank: entity.isFullTank,
    pricePerLiter: entity.pricePerLiter,
    gasStationName: entity.metadata['gasStationName'] as String?,
    notes: entity.notes,
    fuelType: entity.metadata['fuelType'] as int? ?? 0,
    receiptImageUrl: entity.metadata['receiptImageUrl'] as String?,
    receiptImagePath: entity.metadata['receiptImagePath'] as String?,
  );
}

/// Converte FuelSupplyModel para FuelRecordEntity
FuelRecordEntity _modelToFuelRecord(FuelSupplyModel model) {
  return FuelRecordEntity(
    id: model.id,
    userId: model.userId ?? '',
    vehicleId: model.vehicleId,
    date: DateTime.fromMillisecondsSinceEpoch(model.date),
    odometer: model.odometer,
    liters: model.liters,
    pricePerLiter: model.pricePerLiter,
    totalCost: model.totalPrice,
    isFullTank: model.fullTank ?? false,
    notes: model.notes,
    createdAt: model.createdAt ?? DateTime.now(),
    updatedAt: model.updatedAt ?? DateTime.now(),
    isActive: !model.isDeleted,
    metadata: {
      'isDirty': model.isDirty,
      'version': model.version,
      'lastSyncAt':
          model.lastSyncAt ?? DateTime.now(),
      'gasStationName': model.gasStationName,
      'fuelType': model.fuelType,
      'receiptImageUrl': model.receiptImageUrl,
      'receiptImagePath': model.receiptImagePath,
    },
  );
}

/// Converte MaintenanceEntity para MaintenanceModel
MaintenanceModel _maintenanceToModel(MaintenanceEntity entity) {
  return MaintenanceModel(
    id: entity.id,
    createdAtMs: entity.createdAt?.millisecondsSinceEpoch,
    updatedAtMs: entity.updatedAt?.millisecondsSinceEpoch,
    lastSyncAtMs: entity.metadata['lastSyncAt'] != null
        ? (entity.metadata['lastSyncAt'] as DateTime).millisecondsSinceEpoch
        : null,
    isDirty: entity.metadata['isDirty'] as bool? ?? false,
    isDeleted: !entity.isActive,
    version: entity.metadata['version'] as int? ?? 1,
    userId: entity.userId,
    moduleName: 'gasometer',
    veiculoId: entity.vehicleId,
    tipo: entity.type,
    descricao: entity.description,
    valor: entity.cost,
    data: entity.date.millisecondsSinceEpoch,
    odometro: entity.odometer,
    proximaRevisao: entity.nextServiceDate?.millisecondsSinceEpoch,
    concluida: entity.isCompleted,
    receiptImageUrl: entity.metadata['receiptImageUrl'] as String?,
    receiptImagePath: entity.metadata['receiptImagePath'] as String?,
  );
}

/// Converte MaintenanceModel para MaintenanceEntity
MaintenanceEntity _modelToMaintenance(MaintenanceModel model) {
  return MaintenanceEntity(
    id: model.id,
    userId: model.userId ?? '',
    vehicleId: model.veiculoId,
    type: model.tipo,
    description: model.descricao,
    cost: model.valor,
    date: DateTime.fromMillisecondsSinceEpoch(model.data),
    odometer: model.odometro,
    nextServiceDate: model.proximaRevisao != null
        ? DateTime.fromMillisecondsSinceEpoch(model.proximaRevisao!)
        : null,
    isCompleted: model.concluida,
    createdAt: model.createdAt ?? DateTime.now(),
    updatedAt: model.updatedAt ?? DateTime.now(),
    isActive: !model.isDeleted,
    metadata: {
      'isDirty': model.isDirty,
      'version': model.version,
      'lastSyncAt': model.lastSyncAt ?? DateTime.now(),
      'receiptImageUrl': model.receiptImageUrl,
      'receiptImagePath': model.receiptImagePath,
    },
  );
}
