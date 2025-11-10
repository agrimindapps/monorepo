import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../core/sync/adapters/drift_sync_adapter_base.dart';
import '../../../../database/gasometer_database.dart';
import '../../../../database/tables/gasometer_tables.dart';
import '../../domain/entities/maintenance_entity.dart';

/// Adapter de sincronização para Manutenções (Drift ↔ Firestore)
///
/// Implementa conversões bidirecionais entre:
/// - **Drift Row** (Maintenance): Dados do SQLite via Drift ORM
/// - **Domain Entity** (MaintenanceEntity): Entidade de negócio
/// - **Firestore Document** (Map<String, dynamic>): JSON para Firebase
///
/// **Mapeamento de Campos:**
///
/// | MaintenanceEntity    | Drift Table (Maintenances) | Firestore          |
/// |----------------------|----------------------------|--------------------|
/// | id (String)          | firebaseId                 | id                 |
/// | vehicleId (String)   | vehicleId (int FK)         | vehicle_id         |
/// | type (enum)          | tipo (String)              | type               |
/// | status (enum)        | concluida (bool)           | status             |
/// | title                | tipo (duplicado)           | title              |
/// | description          | descricao                  | description        |
/// | cost                 | valor                      | cost               |
/// | serviceDate          | data (timestamp)           | service_date       |
/// | odometer             | odometro                   | odometer           |
/// | nextServiceOdometer  | proximaRevisao             | next_service_odometer |
/// | workshopName         | N/A                        | workshop_name      |
/// | workshopPhone        | N/A                        | workshop_phone     |
/// | workshopAddress      | N/A                        | workshop_address   |
/// | nextServiceDate      | N/A                        | next_service_date  |
/// | photosPaths          | N/A                        | photos_paths       |
/// | invoicesPaths        | receiptImagePath           | invoices_paths     |
/// | parts                | N/A                        | parts              |
/// | notes                | N/A                        | notes              |
///
/// **Validações:**
/// - vehicleId não vazio
/// - tipo e descricao não vazios
/// - valor >= 0
/// - data válido
/// - odometro > 0
/// - proximaRevisao > odometro (se definido)
///
/// **Helpers Específicos:**
/// - getPendingMaintenances(String vehicleFirebaseId)
/// - getMaintenancesByType(String vehicleFirebaseId, String tipo)
///
/// **Conflict Resolution:**
/// - Last Write Wins (LWW) com version checking
@lazySingleton
class MaintenanceDriftSyncAdapter
    extends DriftSyncAdapterBase<MaintenanceEntity, Maintenance> {
  MaintenanceDriftSyncAdapter(
    super.db,
    super.firestore,
    super.connectivityService,
  );

  @override
  String get collectionName => 'maintenances';

  @override
  TableInfo<Maintenances, Maintenance> get table =>
      db.maintenances as TableInfo<Maintenances, Maintenance>;

  // ==========================================================================
  // CONVERSÕES: DRIFT → DOMAIN ENTITY
  // ==========================================================================

  @override
  MaintenanceEntity toDomainEntity(Maintenance driftRow) {
    // Converter timestamp (int) → DateTime
    final serviceDate = DateTime.fromMillisecondsSinceEpoch(driftRow.data);

    // Mapear tipo (String) → MaintenanceType enum
    final type = _parseMaintenanceType(driftRow.tipo);

    // Mapear status: concluida (bool) → MaintenanceStatus enum
    final status = driftRow.concluida
        ? MaintenanceStatus.completed
        : MaintenanceStatus.pending;

    return MaintenanceEntity(
      // ID: usar firebaseId se disponível, senão id.toString()
      id: driftRow.firebaseId ?? driftRow.id.toString(),

      // Vehicle ID: será resolvido para firebaseId no helper
      vehicleId: driftRow.vehicleId.toString(),

      // Tipo e status
      type: type,
      status: status,

      // Descrição (usar tipo como título, descrição como descrição)
      title: driftRow.tipo,
      description: driftRow.descricao,

      // Valores financeiros
      cost: driftRow.valor,

      // Datas e odômetro
      serviceDate: serviceDate,
      odometer: driftRow.odometro.toDouble(),

      // Próxima revisão
      nextServiceOdometer: driftRow.proximaRevisao?.toDouble(),
      nextServiceDate: null, // Não disponível no Drift legado
      // Oficina (não disponível no Drift legado)
      workshopName: null,
      workshopPhone: null,
      workshopAddress: null,

      // Documentos (apenas um caminho disponível no Drift)
      photosPaths: const [],
      invoicesPaths: driftRow.receiptImagePath != null
          ? [driftRow.receiptImagePath!]
          : const [],

      // Peças (não disponível no Drift legado)
      parts: const {},

      // Observações (não disponível no Drift legado)
      notes: null,

      // Metadata base (BaseSyncEntity)
      createdAt: driftRow.createdAt,
      updatedAt: driftRow.updatedAt,
      lastSyncAt: driftRow.lastSyncAt,
      isDirty: driftRow.isDirty,
      isDeleted: driftRow.isDeleted,
      version: driftRow.version,
      userId: driftRow.userId,
      moduleName: driftRow.moduleName,

      // Metadata adicional
      metadata: const {},
    );
  }

  /// Converte string de tipo para MaintenanceType enum
  MaintenanceType _parseMaintenanceType(String tipo) {
    final tipoLower = tipo.toLowerCase().trim();

    if (tipoLower.contains('preventiv') || tipoLower.contains('programad')) {
      return MaintenanceType.preventive;
    } else if (tipoLower.contains('revis') || tipoLower.contains('inspe')) {
      return MaintenanceType.inspection;
    } else if (tipoLower.contains('emergenc') ||
        tipoLower.contains('urgente')) {
      return MaintenanceType.emergency;
    } else {
      return MaintenanceType.corrective; // Default
    }
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → DRIFT COMPANION
  // ==========================================================================

  @override
  Insertable<Maintenance> toCompanion(MaintenanceEntity entity) {
    // Parse vehicleId (pode ser firebaseId ou localId)
    int vehicleLocalId;
    try {
      vehicleLocalId = int.parse(entity.vehicleId);
    } catch (e) {
      // Se não for int, usar 0 (será resolvido na camada de repository)
      vehicleLocalId = 0;
      developer.log(
        'Warning: vehicleId ${entity.vehicleId} is not a valid local ID',
        name: 'MaintenanceDriftSyncAdapter',
      );
    }

    // Parse firebaseId para localId (se necessário)
    int? localId;
    if (entity.id.isNotEmpty) {
      localId = int.tryParse(entity.id);
    }

    // Converter DateTime → timestamp (int)
    final dataTimestamp = entity.serviceDate.millisecondsSinceEpoch;

    // Determinar se concluída baseado no status
    final concluida = entity.status == MaintenanceStatus.completed;

    // Pegar primeiro invoice path (Drift suporta apenas um)
    final receiptImagePath = entity.invoicesPaths.isNotEmpty
        ? entity.invoicesPaths.first
        : null;

    return MaintenancesCompanion(
      // ID: usar Value() se existe, senão Value.absent() (autoIncrement)
      id: localId != null ? Value(localId) : const Value.absent(),

      // Firebase ID
      firebaseId: entity.id.isNotEmpty && localId == null
          ? Value(entity.id)
          : const Value.absent(),

      // Campos obrigatórios
      userId: Value(
        entity.userId ?? '',
      ), // userId garantido por validateForSync
      moduleName: Value(entity.moduleName ?? 'gasometer'),

      // Timestamps
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt ?? DateTime.now()),
      lastSyncAt: entity.lastSyncAt != null
          ? Value(entity.lastSyncAt)
          : const Value.absent(),

      // Controle de sincronização
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),

      // Relacionamento
      vehicleId: Value(vehicleLocalId),

      // Dados da manutenção
      tipo: Value(entity.title), // Usar title como tipo
      descricao: Value(entity.description),
      valor: Value(entity.cost),
      data: Value(dataTimestamp),
      odometro: Value(entity.odometer.toInt()),

      // Próxima revisão
      proximaRevisao: entity.nextServiceOdometer != null
          ? Value(entity.nextServiceOdometer!.toInt())
          : const Value.absent(),

      // Status
      concluida: Value(concluida),

      // Comprovante
      receiptImagePath: receiptImagePath != null
          ? Value(receiptImagePath)
          : const Value.absent(),
      receiptImageUrl: const Value.absent(),
    );
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → FIRESTORE MAP
  // ==========================================================================

  @override
  Map<String, dynamic> toFirestoreMap(MaintenanceEntity entity) {
    // Usar método existente da entidade
    final map = entity.toFirebaseMap();

    // Garantir que user_id está presente (security rules)
    if (!map.containsKey('user_id') && entity.userId != null) {
      map['user_id'] = entity.userId;
    }

    return map;
  }

  // ==========================================================================
  // CONVERSÕES: FIRESTORE MAP → DOMAIN ENTITY
  // ==========================================================================

  @override
  Either<Failure, MaintenanceEntity> fromFirestoreMap(
    Map<String, dynamic> map,
  ) {
    try {
      // Usar método existente da entidade
      final entity = MaintenanceEntity.fromFirebaseMap(map);

      // Validar campos obrigatórios
      if (entity.id.isEmpty) {
        return const Left(
          ValidationFailure('Maintenance ID missing from Firestore document'),
        );
      }

      if (entity.vehicleId.isEmpty) {
        return const Left(
          ValidationFailure('Vehicle ID missing from Firestore document'),
        );
      }

      return Right(entity);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to parse Firestore document to MaintenanceEntity',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(
        ParseFailure('Failed to parse maintenance from Firestore: $e'),
      );
    }
  }

  // ==========================================================================
  // VALIDAÇÃO
  // ==========================================================================

  @override
  Either<Failure, void> validateForSync(MaintenanceEntity entity) {
    // 1. Validações base (ID, userId)
    final baseValidation = super.validateForSync(entity);
    if (baseValidation.isLeft()) {
      return baseValidation;
    }

    // 2. Validar vehicleId obrigatório
    if (entity.vehicleId.trim().isEmpty) {
      return const Left(ValidationFailure('Vehicle ID cannot be empty'));
    }

    // 3. Validar tipo obrigatório
    if (entity.title.trim().isEmpty) {
      return const Left(ValidationFailure('Maintenance title cannot be empty'));
    }

    // 4. Validar descrição obrigatória
    if (entity.description.trim().isEmpty) {
      return const Left(
        ValidationFailure('Maintenance description cannot be empty'),
      );
    }

    // 5. Validar custo (não negativo)
    if (entity.cost < 0) {
      return Left(
        ValidationFailure('Invalid cost: ${entity.cost}. Cannot be negative'),
      );
    }

    // 6. Validar data (não futuro demais - tolerância de 1 dia)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (entity.serviceDate.isAfter(tomorrow)) {
      return Left(
        ValidationFailure(
          'Invalid service date: ${entity.serviceDate.toIso8601String()}. Cannot be more than 1 day in the future',
        ),
      );
    }

    // 7. Validar odômetro (positivo)
    if (entity.odometer <= 0) {
      return Left(
        ValidationFailure(
          'Invalid odometer: ${entity.odometer}. Must be greater than 0',
        ),
      );
    }

    // 8. Validar próxima revisão (se definida, deve ser > odômetro atual)
    if (entity.nextServiceOdometer != null &&
        entity.nextServiceOdometer! <= entity.odometer) {
      return Left(
        ValidationFailure(
          'Invalid next service odometer: ${entity.nextServiceOdometer}. Must be greater than current odometer (${entity.odometer})',
        ),
      );
    }

    return const Right(null);
  }

  // ==========================================================================
  // CONFLICT RESOLUTION
  // ==========================================================================

  @override
  MaintenanceEntity resolveConflict(
    MaintenanceEntity local,
    MaintenanceEntity remote,
  ) {
    // Usar estratégia padrão (Last Write Wins - LWW)
    final resolved = super.resolveConflict(local, remote);

    developer.log(
      'Conflict resolved for maintenance: ${resolved.id} (${resolved.title})',
      name: 'MaintenanceDriftSyncAdapter',
    );

    return resolved;
  }

  // ==========================================================================
  // OPERAÇÕES DRIFT (Implementações de métodos abstratos)
  // ==========================================================================

  // ignore: unused_element
  Future<Either<Failure, List<MaintenanceEntity>>> _getDirtyRecords(
    String userId,
  ) async {
    try {
      developer.log(
        '🔍 Starting _getDirtyRecords for user: $userId',
        name: 'MaintenanceDriftSyncAdapter',
      );

      developer.log(
        '🔍 Database instance: ${db.hashCode}, type: ${db.runtimeType}',
        name: 'MaintenanceDriftSyncAdapter',
      );

      final query = db.select(db.maintenances)
        ..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.isDirty.equals(true) &
              tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.updatedAt)])
        ..limit(50); // Batch size

      developer.log(
        '🔍 Query created successfully',
        name: 'MaintenanceDriftSyncAdapter',
      );

      final rows = await query.get();

      developer.log(
        '🔍 Query executed successfully, got ${rows.length} rows',
        name: 'MaintenanceDriftSyncAdapter',
      );

      // Verificar se temos rows válidas
      if (rows.isEmpty) {
        developer.log(
          'ℹ️ No dirty maintenances found for user $userId',
          name: 'MaintenanceDriftSyncAdapter',
        );
        return const Right([]);
      }

      // Log details of each row com verificações de segurança
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        try {
          developer.log(
            '🔍 Row $i: id=${row.id}, firebaseId=${row.firebaseId}, vehicleId=${row.vehicleId}, tipo=${row.tipo}',
            name: 'MaintenanceDriftSyncAdapter',
          );
        } catch (e) {
          developer.log(
            '⚠️ Error logging row $i: $e',
            name: 'MaintenanceDriftSyncAdapter',
          );
        }
      }

      // Converter entities com tratamento de erro individual
      final entities = <MaintenanceEntity>[];
      for (final row in rows) {
        try {
          final entity = toDomainEntity(row);
          entities.add(entity);
        } catch (e) {
          developer.log(
            '❌ Error converting row to entity: $e',
            name: 'MaintenanceDriftSyncAdapter',
            error: e,
          );
          // Continuar com outras rows em vez de falhar completamente
        }
      }

      developer.log(
        'Found ${entities.length} dirty maintenances for user $userId',
        name: 'MaintenanceDriftSyncAdapter',
      );

      return Right(entities);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get dirty records',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get dirty maintenance records: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, MaintenanceEntity?>> _getLocalEntity(String id) async {
    try {
      // Buscar por firebaseId OU por id (local autoIncrement)
      final query = db.select(db.maintenances)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        )
        ..limit(1);

      final row = await query.getSingleOrNull();

      if (row != null) {
        developer.log(
          'Found local maintenance: $id',
          name: 'MaintenanceDriftSyncAdapter',
        );
        return Right(toDomainEntity(row));
      }

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get local entity',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get local maintenance: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, void>> _insertLocal(MaintenanceEntity entity) async {
    try {
      final companion = toCompanion(entity);
      await db.into(db.maintenances).insert(companion);

      developer.log(
        'Inserted maintenance: ${entity.id} (${entity.title})',
        name: 'MaintenanceDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to insert local entity',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to insert maintenance: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, void>> _updateLocal(MaintenanceEntity entity) async {
    try {
      final companion = toCompanion(entity);

      // Atualizar por firebaseId OU por id local
      final query = db.update(db.maintenances)
        ..where(
          (tbl) => (entity.id.isNotEmpty && int.tryParse(entity.id) == null
              ? tbl.firebaseId.equals(entity.id)
              : tbl.id.equals(int.tryParse(entity.id) ?? -1)),
        );

      final rowsAffected = await query.write(companion);

      if (rowsAffected == 0) {
        developer.log(
          'No rows updated for maintenance ${entity.id}, inserting instead',
          name: 'MaintenanceDriftSyncAdapter',
        );
        return _insertLocal(entity);
      }

      developer.log(
        'Updated maintenance: ${entity.id} (${entity.title})',
        name: 'MaintenanceDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update local entity',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to update maintenance: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, void>> _markAsSynced(
    String id, {
    String? firebaseId,
  }) async {
    try {
      final companion = MaintenancesCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
        firebaseId: firebaseId != null
            ? Value(firebaseId)
            : const Value.absent(),
      );

      final query = db.update(db.maintenances)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        );

      await query.write(companion);

      developer.log(
        'Marked maintenance as synced: $id${firebaseId != null ? ' (firebaseId: $firebaseId)' : ''}',
        name: 'MaintenanceDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to mark as synced',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to mark maintenance as synced: $e'));
    }
  }

  // ==========================================================================
  // HELPERS ESPECÍFICOS
  // ==========================================================================

  /// Busca manutenções pendentes de um veículo
  Future<List<MaintenanceEntity>> getPendingMaintenances(
    String vehicleFirebaseId,
  ) async {
    try {
      // Buscar veículo por firebaseId para obter localId
      final vehicleQuery = db.select(db.vehicles)
        ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
        ..limit(1);

      final vehicle = await vehicleQuery.getSingleOrNull();
      if (vehicle == null) {
        developer.log(
          'Vehicle not found: $vehicleFirebaseId',
          name: 'MaintenanceDriftSyncAdapter',
        );
        return [];
      }

      // Buscar manutenções pendentes (concluida = false)
      final query = db.select(db.maintenances)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) &
              tbl.concluida.equals(false) &
              tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.data)]);

      final rows = await query.get();
      return rows.map((row) => toDomainEntity(row)).toList();
    } catch (e) {
      developer.log(
        'Error getting pending maintenances',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
      );
      return [];
    }
  }

  /// Busca manutenções de um veículo por tipo
  Future<List<MaintenanceEntity>> getMaintenancesByType(
    String vehicleFirebaseId,
    String tipo,
  ) async {
    try {
      // Buscar veículo por firebaseId
      final vehicleQuery = db.select(db.vehicles)
        ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
        ..limit(1);

      final vehicle = await vehicleQuery.getSingleOrNull();
      if (vehicle == null) {
        return [];
      }

      // Buscar manutenções por tipo
      final query = db.select(db.maintenances)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) &
              tbl.tipo.like('%$tipo%') &
              tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

      final rows = await query.get();
      return rows.map((row) => toDomainEntity(row)).toList();
    } catch (e) {
      developer.log(
        'Error getting maintenances by type',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
      );
      return [];
    }
  }

  /// Busca todas as manutenções de um veículo
  Future<List<MaintenanceEntity>> getMaintenancesByVehicle(
    String vehicleFirebaseId,
  ) async {
    try {
      // Buscar veículo por firebaseId
      final vehicleQuery = db.select(db.vehicles)
        ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
        ..limit(1);

      final vehicle = await vehicleQuery.getSingleOrNull();
      if (vehicle == null) {
        return [];
      }

      // Buscar todas as manutenções
      final query = db.select(db.maintenances)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

      final rows = await query.get();
      return rows.map((row) => toDomainEntity(row)).toList();
    } catch (e) {
      developer.log(
        'Error getting maintenances by vehicle',
        name: 'MaintenanceDriftSyncAdapter',
        error: e,
      );
      return [];
    }
  }

  /// Stream de manutenções de um veículo (reactive UI)
  Stream<List<MaintenanceEntity>> watchMaintenancesByVehicle(
    String vehicleFirebaseId,
  ) async* {
    // Primeiro, resolver vehicleId local
    final vehicleQuery = db.select(db.vehicles)
      ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
      ..limit(1);

    final vehicle = await vehicleQuery.getSingleOrNull();
    if (vehicle == null) {
      yield [];
      return;
    }

    // Assistir mudanças nas manutenções
    final query = db.select(db.maintenances)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.data)]);

    yield* query.watch().map(
      (rows) => rows.map((row) => toDomainEntity(row)).toList(),
    );
  }
}
