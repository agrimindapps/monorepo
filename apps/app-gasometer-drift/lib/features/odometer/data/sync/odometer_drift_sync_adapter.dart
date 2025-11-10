import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../core/sync/adapters/drift_sync_adapter_base.dart';
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
@lazySingleton
class OdometerDriftSyncAdapter
    extends DriftSyncAdapterBase<OdometerEntity, OdometerReading> {
  OdometerDriftSyncAdapter(
    super.db,
    super.firestore,
    super.connectivityService,
  ) {
    developer.log(
      '🏗️ OdometerDriftSyncAdapter initialized with db: ${db.hashCode}, firestore: ${firestore.hashCode}',
      name: 'OdometerDriftSyncAdapter',
    );
  }

  @override
  String get collectionName => 'odometer_readings';

  @override
  TableInfo<OdometerReadings, OdometerReading> get table =>
      db.odometerReadings as TableInfo<OdometerReadings, OdometerReading>;

  // ==========================================================================
  // CONVERSÕES: DRIFT → DOMAIN ENTITY
  // ==========================================================================

  @override
  OdometerEntity toDomainEntity(OdometerReading driftRow) {
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
  Insertable<OdometerReading> toCompanion(OdometerEntity entity) {
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
  Either<Failure, OdometerEntity> fromFirestoreMap(Map<String, dynamic> doc) {
    try {
      // Parse tipo
      OdometerType type = OdometerType.other;
      if (doc['type'] != null) {
        try {
          type = OdometerType.values.firstWhere(
            (e) => e.name == doc['type'],
            orElse: () => OdometerType.other,
          );
        } catch (_) {
          type = OdometerType.other;
        }
      }

      final entity = OdometerEntity(
        id: doc['id'] as String? ?? '',
        vehicleId: doc['vehicle_id'] as String? ?? '',
        value: (doc['reading'] as num?)?.toDouble() ?? 0.0,
        registrationDate: DateTime.fromMillisecondsSinceEpoch(
          doc['date'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        ),
        description: doc['notes'] as String? ?? '',
        type: type,
        createdAt: doc['created_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
            : null,
        updatedAt: doc['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(doc['updated_at'] as int)
            : null,
        lastSyncAt: doc['last_sync_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(doc['last_sync_at'] as int)
            : null,
        isDirty: doc['is_dirty'] as bool? ?? false,
        isDeleted: doc['is_deleted'] as bool? ?? false,
        version: doc['version'] as int? ?? 1,
        userId: doc['user_id'] as String?,
        moduleName: doc['module_name'] as String? ?? 'gasometer',
      );

      if (entity.id.isEmpty) {
        return const Left(
          ValidationFailure(
            'Odometer reading ID missing from Firestore document',
          ),
        );
      }

      if (entity.vehicleId.isEmpty) {
        return const Left(
          ValidationFailure('Vehicle ID missing from Firestore document'),
        );
      }

      return Right(entity);
    } catch (e) {
      return Left(
        ParseFailure('Failed to parse odometer reading from Firestore: $e'),
      );
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

  // ignore: unused_element
  Future<Either<Failure, List<OdometerEntity>>> _getDirtyRecords(
    String userId,
  ) async {
    try {
      developer.log(
        '🔍 Starting _getDirtyRecords for user: $userId',
        name: 'OdometerDriftSyncAdapter',
      );

      // Verificar se o banco está inicializado
      if (db == null) {
        developer.log('❌ Database is null!', name: 'OdometerDriftSyncAdapter');
        return Left(CacheFailure('Database not initialized'));
      }

      developer.log(
        '🔍 Database instance: ${db.hashCode}, type: ${db.runtimeType}',
        name: 'OdometerDriftSyncAdapter',
      );

      final query = db.select(db.odometerReadings)
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
          final entity = toDomainEntity(row);
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

  // ignore: unused_element
  Future<Either<Failure, OdometerEntity?>> _getLocalEntity(String id) async {
    try {
      final query = db.select(db.odometerReadings)
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
        return Right(toDomainEntity(row));
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

  // ignore: unused_element
  Future<Either<Failure, void>> _insertLocal(OdometerEntity entity) async {
    try {
      final companion = toCompanion(entity);
      await db.into(db.odometerReadings).insert(companion);

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

  // ignore: unused_element
  Future<Either<Failure, void>> _updateLocal(OdometerEntity entity) async {
    try {
      final companion = toCompanion(entity);

      // OdometerEntity não tem firebaseId, apenas id
      final query = db.update(db.odometerReadings)
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
        return _insertLocal(entity);
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

  // ignore: unused_element
  Future<Either<Failure, void>> _markAsSynced(
    String id, {
    String? firebaseId,
  }) async {
    try {
      final companion = OdometerReadingsCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
        firebaseId: firebaseId != null
            ? Value(firebaseId)
            : const Value.absent(),
      );

      final query = db.update(db.odometerReadings)
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
      final vehicle =
          await (db.select(db.vehicles)
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
      final query = db.select(db.odometerReadings)
        ..where((tbl) => tbl.vehicleId.equals(vehicleIdInt))
        ..where((tbl) => tbl.isDeleted.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

      final readings = await query.get();
      return readings.map<OdometerEntity>(toDomainEntity).toList();
    } catch (e) {
      developer.log(
        '❌ Error getting readings by vehicle: $e',
        name: 'OdometerSync',
      );
      return [];
    }
  }

  /// Obtém a leitura mais recente de um veículo
  Future<OdometerEntity?> getLatestReading(String vehicleFirebaseId) async {
    try {
      // Buscar vehicleId (int) do Drift pelo firebaseId usando query gerada
      final vehicle =
          await (db.select(db.vehicles)
                ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
                ..where((tbl) => tbl.isDeleted.equals(false)))
              .getSingleOrNull();

      if (vehicle == null) {
        return null;
      }

      final vehicleIdInt = vehicle.id;

      // Buscar a leitura mais recente
      final query = db.select(db.odometerReadings)
        ..where((tbl) => tbl.vehicleId.equals(vehicleIdInt))
        ..where((tbl) => tbl.isDeleted.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
        ..limit(1);

      final reading = await query.getSingleOrNull();
      return reading != null ? toDomainEntity(reading) : null;
    } catch (e) {
      developer.log('❌ Error getting latest reading: $e', name: 'OdometerSync');
      return null;
    }
  }
}
