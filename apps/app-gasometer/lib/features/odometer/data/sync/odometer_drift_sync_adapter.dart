import 'package:drift/drift.dart';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../database/gasometer_database.dart';
import '../../../../database/tables/gasometer_tables.dart';
import '../../domain/entities/odometer_entity.dart';

/// Adapter de sincronização para Leituras de Odômetro (Drift ↔ Firestore)
///
/// Implementa conversões bidirecionais entre:
/// - **Drift Row** (OdometerReading): Dados do SQLite via Drift ORM
/// - **Domain Entity** (OdometerEntity): Entidade de negócio
/// - **Firestore Document** (Map<String, dynamic>): JSON para Firebase
///
/// **Mapeamento de Campos:**
///
/// | OdometerEntity       | Drift Table (OdometerReadings) | Firestore          |
/// |----------------------|--------------------------------|--------------------|
/// | id (String)          | firebaseId                     | id                 |
/// | vehicleId (String)   | vehicleId (int FK)             | vehicle_id         |
/// | value                | reading                        | reading            |
/// | registrationDate     | date (timestamp)               | date               |
/// | description          | notes                          | notes              |
/// | type                 | N/A                            | type               |
///
/// **Validações:**
/// - vehicleId não vazio
/// - value >= 0
/// - registrationDate não futuro
///
/// **Conflict Resolution:**
/// - Last Write Wins (LWW) com version checking

class OdometerDriftSyncAdapter
    extends DriftSyncAdapterBase<OdometerEntity, OdometerReading> {
  OdometerDriftSyncAdapter(GasometerDatabase db, FirebaseFirestore firestore)
      : super(db, firestore) {
    developer.log(
      '🏗️ OdometerDriftSyncAdapter initialized with db: ${db.hashCode}, firestore: ${firestore.hashCode}',
      name: 'OdometerDriftSyncAdapter',
    );
  }

  GasometerDatabase get _db => db as GasometerDatabase;

  @override
  String get collectionName => 'odometer_readings';

  @override
  TableInfo<OdometerReadings, OdometerReading> get table =>
      _db.odometerReadings as TableInfo<OdometerReadings, OdometerReading>;

  // ==========================================================================
  // CONVERSÕES: DRIFT → DOMAIN ENTITY
  // ==========================================================================

  @override
  OdometerEntity driftToEntity(OdometerReading driftRow) {
    // Converter timestamp (int) → DateTime
    final date = DateTime.fromMillisecondsSinceEpoch(driftRow.date);

    return OdometerEntity(
      // ID: usar firebaseId se disponível, senão id.toString()
      id: driftRow.firebaseId ?? driftRow.id.toString(),

      // Vehicle ID: será resolvido para firebaseId no helper
      vehicleId: driftRow.vehicleId.toString(),

      // Dados da leitura
      value: driftRow.reading,
      registrationDate: date,
      description: driftRow.notes ?? '',
      type: OdometerType.other, // Default type
      // Metadata base (BaseSyncEntity)
      createdAt: driftRow.createdAt,
      updatedAt: driftRow.updatedAt,
      lastSyncAt: driftRow.lastSyncAt,
      isDirty: driftRow.isDirty,
      isDeleted: driftRow.isDeleted,
      version: driftRow.version,
      userId: driftRow.userId,
      moduleName: driftRow.moduleName,
    );
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → DRIFT
  // ==========================================================================

  @override
  Insertable<OdometerReading> entityToCompanion(OdometerEntity entity) {
    // Resolver vehicleId (String do Firestore) → vehicleId (int do Drift)
    final vehicleIdInt = int.tryParse(entity.vehicleId) ?? 0;

    // Parse firebaseId para localId (se necessário)
    int? localId;
    if (entity.id.isNotEmpty) {
      localId = int.tryParse(entity.id);
    }

    return OdometerReadingsCompanion(
      id: localId != null ? Value(localId) : const Value.absent(),
      firebaseId: entity.id.isNotEmpty && localId == null
          ? Value(entity.id)
          : const Value.absent(),
      userId: Value(entity.userId ?? ''),
      moduleName: Value(entity.moduleName ?? 'gasometer'),
      vehicleId: Value(vehicleIdInt),
      reading: Value(entity.value),
      date: Value(entity.registrationDate.millisecondsSinceEpoch),
      notes: Value(entity.description.isEmpty ? null : entity.description),
      createdAt: Value(entity.createdAt ?? DateTime.now()),
      updatedAt: Value(entity.updatedAt ?? DateTime.now()),
      lastSyncAt: entity.lastSyncAt != null
          ? Value(entity.lastSyncAt)
          : const Value.absent(),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
    );
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → FIRESTORE
  // ==========================================================================

  @override
  Map<String, dynamic> toFirestoreMap(OdometerEntity entity) {
    return {
      'id': entity.id,
      'user_id': entity.userId,
      'module_name': entity.moduleName ?? 'gasometer',
      'vehicle_id': entity.vehicleId,
      'reading': entity.value,
      'date': entity.registrationDate.millisecondsSinceEpoch,
      'notes': entity.description.isEmpty ? null : entity.description,
      'type': entity.type.name, // Salva como string
      'created_at': entity.createdAt?.millisecondsSinceEpoch,
      'updated_at': entity.updatedAt?.millisecondsSinceEpoch,
      'last_sync_at': entity.lastSyncAt?.millisecondsSinceEpoch,
      'is_dirty': entity.isDirty,
      'is_deleted': entity.isDeleted,
      'version': entity.version,
    };
  }

  // ==========================================================================
  // CONVERSÕES: FIRESTORE → DOMAIN ENTITY
  // ==========================================================================

  @override
  OdometerEntity fromFirestoreDoc(Map<String, dynamic> doc) {
    try {
      // Usar método existente da entidade
      final entity = OdometerEntity.fromFirebaseMap(doc);

      // Validar campos obrigatórios
      if (entity.vehicleId.isEmpty) {
        throw const ValidationFailure(
          'Vehicle ID missing from Firestore document',
        );
      }

      return entity;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to parse Firestore document to OdometerEntity',
        name: 'OdometerDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      throw ParseFailure('Failed to parse odometer from Firestore: $e');
    }
  }

  // ==========================================================================
  // VALIDAÇÃO
  // ==========================================================================

  @override
  Either<Failure, void> validateForSync(OdometerEntity entity) {
    // 1. Validações base (ID, userId)
    final baseValidation = super.validateForSync(entity);
    if (baseValidation.isLeft()) {
      return baseValidation;
    }

    // 2. Validar vehicleId obrigatório
    if (entity.vehicleId.trim().isEmpty) {
      return const Left(
        ValidationFailure('vehicleId is required for odometer reading'),
      );
    }

    // 3. Validar valor >= 0
    if (entity.value < 0) {
      return const Left(
        ValidationFailure('Odometer reading value must be >= 0'),
      );
    }

    // 4. Validar data não futura
    if (entity.registrationDate.isAfter(DateTime.now())) {
      return const Left(
        ValidationFailure('Odometer reading date cannot be in the future'),
      );
    }

    return const Right(null);
  }

  // ==========================================================================
  // OPERAÇÕES DRIFT (Implementações de métodos abstratos)
  // ==========================================================================

  @override
  Future<Either<Failure, List<OdometerEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      developer.log(
        '🔍 Starting getDirtyRecords for user: $userId',
        name: 'OdometerDriftSyncAdapter',
      );

      developer.log(
        '🔍 Database instance: ${db.hashCode}, type: ${db.runtimeType}',
        name: 'OdometerDriftSyncAdapter',
      );

      final query = _db.select(_db.odometerReadings)
        ..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.isDirty.equals(true) &
              tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.updatedAt)])
        ..limit(50);

      developer.log(
        '🔍 Query created successfully',
        name: 'OdometerDriftSyncAdapter',
      );

      final rows = await query.get();

      developer.log(
        '🔍 Query executed successfully, got ${rows.length} rows',
        name: 'OdometerDriftSyncAdapter',
      );

      // Verificar se temos rows válidas
      if (rows.isEmpty) {
        developer.log(
          'ℹ️ No dirty odometer readings found for user $userId',
          name: 'OdometerDriftSyncAdapter',
        );
        return const Right([]);
      }

      // Log details of each row com verificações de segurança
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        try {
          developer.log(
            '🔍 Row $i: id=${row.id}, firebaseId=${row.firebaseId}, date=${row.date}, reading=${row.reading}, userId=${row.userId}',
            name: 'OdometerDriftSyncAdapter',
          );
        } catch (e) {
          developer.log(
            '⚠️ Error logging row $i: $e',
            name: 'OdometerDriftSyncAdapter',
          );
        }
      }

      // Converter entities com tratamento de erro individual
      final entities = <OdometerEntity>[];
      for (final row in rows) {
        try {
          var entity = driftToEntity(row);

          final vehicleFirebaseId = await _resolveVehicleFirebaseId(
            row.vehicleId,
          );

          if (vehicleFirebaseId == null) {
            developer.log(
              '⏸️ Skipping odometer ${entity.id}: vehicle ${row.vehicleId} not synced yet',
              name: 'OdometerDriftSyncAdapter',
            );
            continue;
          }

          entity = entity.copyWith(vehicleId: vehicleFirebaseId);
          entities.add(entity);
        } catch (e) {
          developer.log(
            '❌ Error converting row to entity: $e',
            name: 'OdometerDriftSyncAdapter',
            error: e,
          );
          // Continuar com outras rows em vez de falhar completamente
        }
      }

      developer.log(
        'Found ${entities.length} dirty odometer readings for user $userId',
        name: 'OdometerDriftSyncAdapter',
      );

      return Right(entities);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get dirty records',
        name: 'OdometerDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get dirty odometer readings: $e'));
    }
  }

  // @override removed as it is not in the interface
  Future<Either<Failure, OdometerEntity?>> getLocalEntity(String id) async {
    try {
      final query = _db.select(_db.odometerReadings)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        )
        ..limit(1);

      final row = await query.getSingleOrNull();

      if (row != null) {
        developer.log(
          'Found local odometer reading: $id',
          name: 'OdometerDriftSyncAdapter',
        );
        return Right(driftToEntity(row));
      }

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get local entity',
        name: 'OdometerDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get local odometer reading: $e'));
    }
  }

  // @override removed as it is not in the interface
  Future<Either<Failure, void>> insertLocal(OdometerEntity entity) async {
    try {
      final resolvedEntity = await _ensureLocalVehicleReference(entity);
      if (resolvedEntity == null) {
        return const Left(
          CacheFailure('Failed to resolve vehicle reference for odometer'),
        );
      }

      final companion = entityToCompanion(resolvedEntity);
      await _db.into(_db.odometerReadings).insert(companion);

      developer.log(
        'Inserted odometer reading: ${entity.id}',
        name: 'OdometerDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to insert local entity',
        name: 'OdometerDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to insert odometer reading: $e'));
    }
  }

  // @override removed as it is not in the interface
  Future<Either<Failure, void>> updateLocal(OdometerEntity entity) async {
    try {
      final resolvedEntity = await _ensureLocalVehicleReference(entity);
      if (resolvedEntity == null) {
        return const Left(
          CacheFailure('Failed to resolve vehicle reference for odometer'),
        );
      }

      final companion = entityToCompanion(resolvedEntity);

      // OdometerEntity não tem firebaseId, apenas id
      final query = _db.update(_db.odometerReadings)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(entity.id) |
              tbl.id.equals(int.tryParse(entity.id) ?? -1),
        );

      final rowsAffected = await query.write(companion);

      if (rowsAffected == 0) {
        developer.log(
          'No rows updated for odometer reading ${entity.id}, inserting instead',
          name: 'OdometerDriftSyncAdapter',
        );
        return insertLocal(entity);
      }

      developer.log(
        'Updated odometer reading: ${entity.id}',
        name: 'OdometerDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update local entity',
        name: 'OdometerDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to update odometer reading: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String id, {
    String? firebaseId,
  }) async {
    try {
      final companion = OdometerReadingsCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
        firebaseId:
            firebaseId != null ? Value(firebaseId) : const Value.absent(),
      );

      final query = _db.update(_db.odometerReadings)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        );

      await query.write(companion);

      developer.log(
        'Marked odometer reading as synced: $id${firebaseId != null ? ' (firebaseId: $firebaseId)' : ''}',
        name: 'OdometerDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to mark as synced',
        name: 'OdometerDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(
        CacheFailure('Failed to mark odometer reading as synced: $e'),
      );
    }
  }

  // ==========================================================================
  // HELPERS ESPECÍFICOS
  // ==========================================================================

  /// Obtém todas as leituras de odômetro de um veículo
  Future<List<OdometerEntity>> getReadingsByVehicle(
    String vehicleFirebaseId,
  ) async {
    try {
      // Buscar vehicleId (int) do Drift pelo firebaseId usando query gerada
      final vehicle = await (_db.select(_db.vehicles)
            ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
            ..where((tbl) => tbl.isDeleted.equals(false)))
          .getSingleOrNull();

      if (vehicle == null) {
        developer.log(
          '⚠️ Vehicle not found: $vehicleFirebaseId',
          name: 'OdometerSync',
        );
        return [];
      }

      final vehicleIdInt = vehicle.id;

      // Buscar todas as leituras do veículo
      final query = _db.select(_db.odometerReadings)
        ..where((tbl) => tbl.vehicleId.equals(vehicleIdInt))
        ..where((tbl) => tbl.isDeleted.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

      final readings = await query.get();
      return readings.map<OdometerEntity>(driftToEntity).toList();
    } catch (e) {
      developer.log(
        '❌ Error getting readings by vehicle: $e',
        name: 'OdometerSync',
      );
      return [];
    }
  }

  /// Obtém a última leitura de odômetro de um veículo
  Future<OdometerEntity?> getLatestReading(String vehicleFirebaseId) async {
    try {
      // Buscar vehicleId (int) do Drift pelo firebaseId usando query gerada
      final vehicle = await (_db.select(_db.vehicles)
            ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
            ..where((tbl) => tbl.isDeleted.equals(false)))
          .getSingleOrNull();

      if (vehicle == null) {
        return null;
      }

      final vehicleIdInt = vehicle.id;

      // Buscar a leitura mais recente
      final query = _db.select(_db.odometerReadings)
        ..where((tbl) => tbl.vehicleId.equals(vehicleIdInt))
        ..where((tbl) => tbl.isDeleted.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
        ..limit(1);

      final reading = await query.getSingleOrNull();
      return reading != null ? driftToEntity(reading) : null;
    } catch (e) {
      developer.log('❌ Error getting latest reading: $e', name: 'OdometerSync');
      return null;
    }
  }

  Future<String?> _resolveVehicleFirebaseId(int localVehicleId) async {
    final vehicleRow = await (_db.select(
      _db.vehicles,
    )..where((tbl) => tbl.id.equals(localVehicleId)))
        .getSingleOrNull();

    final firebaseId = vehicleRow?.firebaseId;

    if (firebaseId == null || firebaseId.isEmpty) {
      developer.log(
        'Vehicle $localVehicleId does not have a firebaseId yet',
        name: 'OdometerDriftSyncAdapter',
      );
      return null;
    }

    return firebaseId;
  }

  Future<OdometerEntity?> _ensureLocalVehicleReference(
    OdometerEntity entity,
  ) async {
    if (int.tryParse(entity.vehicleId) != null) {
      return entity;
    }

    final vehicleRow = await (_db.select(_db.vehicles)
          ..where((tbl) => tbl.firebaseId.equals(entity.vehicleId)))
        .getSingleOrNull();

    if (vehicleRow == null) {
      developer.log(
        'Unable to find local vehicle for firebaseId ${entity.vehicleId}',
        name: 'OdometerDriftSyncAdapter',
      );
      return null;
    }

    return entity.copyWith(vehicleId: vehicleRow.id.toString());
  }
}
