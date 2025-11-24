import 'package:drift/drift.dart';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../database/gasometer_database.dart';
import '../../../../database/tables/gasometer_tables.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart'; // FuelType enum
import '../../domain/entities/fuel_record_entity.dart';

/// Adapter de sincronização para Abastecimentos (Drift ↔ Firestore)
///
/// Implementa conversões bidirecionais entre:
/// - **Drift Row** (FuelSupply): Dados do SQLite via Drift ORM
/// - **Domain Entity** (FuelRecordEntity): Entidade de negócio
/// - **Firestore Document** (Map<String, dynamic>): JSON para Firebase
///
/// **Mapeamento de Campos:**
///
/// | FuelRecordEntity     | Drift Table (FuelSupplies) | Firestore          |
/// |----------------------|----------------------------|--------------------|
/// | id (String)          | firebaseId                 | id                 |
/// | vehicleId (String)   | vehicleId (int FK)         | vehicle_id         |
/// | fuelType (enum)      | fuelType (int)             | fuel_type          |
/// | liters               | liters                     | liters             |
/// | pricePerLiter        | pricePerLiter              | price_per_liter    |
/// | totalPrice           | totalPrice                 | total_price        |
/// | odometer             | odometer                   | odometer           |
/// | date                 | date (timestamp)           | date               |
/// | gasStationName       | gasStationName             | gas_station_name   |
/// | gasStationBrand      | N/A                        | gas_station_brand  |
/// | fullTank             | fullTank                   | full_tank          |
/// | notes                | notes                      | notes              |
/// | previousOdometer     | N/A                        | previous_odometer  |
/// | distanceTraveled     | N/A                        | distance_traveled  |
/// | consumption          | N/A                        | consumption        |
///
/// **Validações:**
/// - vehicleId não vazio
/// - date não futuro
/// - odometer > 0
/// - liters > 0
/// - pricePerLiter > 0
/// - totalPrice = liters * pricePerLiter (validar consistência)
///
/// **Helpers Específicos:**
/// - getSuppliesByVehicle(String vehicleFirebaseId)
/// - getLatestSupply(String vehicleFirebaseId)
///
/// **Conflict Resolution:**
/// - Last Write Wins (LWW) com version checking

class FuelSupplyDriftSyncAdapter
    extends DriftSyncAdapterBase<FuelRecordEntity, FuelSupply> {
  FuelSupplyDriftSyncAdapter(
    GasometerDatabase db,
    FirebaseFirestore firestore,
    ConnectivityService connectivityService,
  ) : super(db, firestore, connectivityService);

  GasometerDatabase get _db => db as GasometerDatabase;

  @override
  String get collectionName => 'fuel_supplies';

  @override
  TableInfo<FuelSupplies, FuelSupply> get table =>
      _db.fuelSupplies as TableInfo<FuelSupplies, FuelSupply>;

  // ==========================================================================
  // CONVERSÕES: DRIFT → DOMAIN ENTITY
  // ==========================================================================

  @override
  FuelRecordEntity driftToEntity(FuelSupply driftRow) {
    // Converter timestamp (int) → DateTime
    final date = DateTime.fromMillisecondsSinceEpoch(driftRow.date);

    // Mapear fuelType (int) → FuelType enum
    final fuelType = _parseFuelTypeFromIndex(driftRow.fuelType);

    return FuelRecordEntity(
      // ID: usar firebaseId se disponível, senão id.toString()
      id: driftRow.firebaseId ?? driftRow.id.toString(),

      // Vehicle ID: será resolvido para firebaseId no helper
      vehicleId: driftRow.vehicleId.toString(),

      // Dados do abastecimento
      fuelType: fuelType,
      liters: driftRow.liters,
      pricePerLiter: driftRow.pricePerLiter,
      totalPrice: driftRow.totalPrice,
      odometer: driftRow.odometer,
      date: date,

      // Informações adicionais
      gasStationName: driftRow.gasStationName,
      gasStationBrand: null, // Não disponível no Drift legado
      fullTank: driftRow.fullTank ?? true,
      notes: driftRow.notes,

      // Campos não disponíveis no Drift (calculados na UI)
      previousOdometer: null,
      distanceTraveled: null,
      consumption: null,

      // Campos opcionais não disponíveis
      latitude: null,
      longitude: null,

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

  /// Converte índice de combustível para FuelType enum
  FuelType _parseFuelTypeFromIndex(int index) {
    // Mapeamento: 0=Gasolina, 1=Etanol, 2=Diesel, 3=GNV, 4=Flex
    switch (index) {
      case 0:
        return FuelType.gasoline;
      case 1:
        return FuelType.ethanol;
      case 2:
        return FuelType.diesel;
      case 3:
        return FuelType.gas;
      case 4:
        return FuelType.hybrid; // Flex = Hybrid
      default:
        return FuelType.gasoline;
    }
  }

  /// Converte FuelType enum para índice de combustível
  int _fuelTypeToIndex(FuelType fuelType) {
    return switch (fuelType) {
      FuelType.gasoline => 0,
      FuelType.ethanol => 1,
      FuelType.diesel => 2,
      FuelType.gas => 3,
      FuelType.hybrid || FuelType.electric => 4, // Flex/Hybrid
    };
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → DRIFT COMPANION
  // ==========================================================================

  @override
  Insertable<FuelSupply> entityToCompanion(FuelRecordEntity entity) {
    // Parse vehicleId (pode ser firebaseId ou localId)
    int vehicleLocalId;
    try {
      vehicleLocalId = int.parse(entity.vehicleId);
    } catch (e) {
      // Se não for int, tentar buscar veículo por firebaseId
      // Por enquanto, usar 0 (será resolvido na camada de repository)
      vehicleLocalId = 0;
      developer.log(
        'Warning: vehicleId ${entity.vehicleId} is not a valid local ID',
        name: 'FuelSupplyDriftSyncAdapter',
      );
    }

    // Parse firebaseId para localId (se necessário)
    int? localId;
    if (entity.id.isNotEmpty) {
      localId = int.tryParse(entity.id);
    }

    // Converter DateTime → timestamp (int)
    final dateTimestamp = entity.date.millisecondsSinceEpoch;

    return FuelSuppliesCompanion(
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

      // Dados do abastecimento
      date: Value(dateTimestamp),
      odometer: Value(entity.odometer),
      liters: Value(entity.liters),
      pricePerLiter: Value(entity.pricePerLiter),
      totalPrice: Value(entity.totalPrice),
      fullTank: Value(entity.fullTank),
      fuelType: Value(_fuelTypeToIndex(entity.fuelType)),

      // Informações adicionais
      gasStationName: entity.gasStationName != null
          ? Value(entity.gasStationName)
          : const Value.absent(),
      notes: entity.notes != null ? Value(entity.notes) : const Value.absent(),

      // Comprovantes (não utilizados na entidade atual)
      receiptImageUrl: const Value.absent(),
      receiptImagePath: const Value.absent(),
    );
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → FIRESTORE MAP
  // ==========================================================================

  @override
  Map<String, dynamic> toFirestoreMap(FuelRecordEntity entity) {
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
  Either<Failure, FuelRecordEntity> fromFirestoreMap(Map<String, dynamic> map) {
    try {
      // Usar método existente da entidade
      final entity = FuelRecordEntity.fromFirebaseMap(map);

      // Validar campos obrigatórios
      if (entity.id.isEmpty) {
        return const Left(
          ValidationFailure('Fuel supply ID missing from Firestore document'),
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
        'Failed to parse Firestore document to FuelRecordEntity',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(
        ParseFailure('Failed to parse fuel supply from Firestore: $e'),
      );
    }
  }

  // ==========================================================================
  // CONVERSÕES: FIRESTORE → DOMAIN ENTITY
  // ==========================================================================

  @override
  FuelRecordEntity fromFirestoreDoc(Map<String, dynamic> doc) {
    return FuelRecordEntity.fromFirebaseMap(doc);
  }

  // ==========================================================================
  // VALIDAÇÃO
  // ==========================================================================

  @override
  Either<Failure, void> validateForSync(FuelRecordEntity entity) {
    // 1. Validações base (ID, userId)
    final baseValidation = super.validateForSync(entity);
    if (baseValidation.isLeft()) {
      return baseValidation;
    }

    // 2. Validar vehicleId obrigatório
    if (entity.vehicleId.trim().isEmpty) {
      return const Left(ValidationFailure('Vehicle ID cannot be empty'));
    }

    // 3. Validar data (não futuro)
    if (entity.date.isAfter(DateTime.now())) {
      return Left(
        ValidationFailure(
          'Invalid date: ${entity.date.toIso8601String()}. Cannot be in the future',
        ),
      );
    }

    // 4. Validar odômetro (positivo)
    if (entity.odometer <= 0) {
      return Left(
        ValidationFailure(
          'Invalid odometer: ${entity.odometer}. Must be greater than 0',
        ),
      );
    }

    // 5. Validar litros (positivo)
    if (entity.liters <= 0) {
      return Left(
        ValidationFailure(
          'Invalid liters: ${entity.liters}. Must be greater than 0',
        ),
      );
    }

    // 6. Validar preço por litro (positivo)
    if (entity.pricePerLiter <= 0) {
      return Left(
        ValidationFailure(
          'Invalid price per liter: ${entity.pricePerLiter}. Must be greater than 0',
        ),
      );
    }

    // 7. Validar totalPrice (consistência com liters * pricePerLiter)
    final expectedTotal = entity.liters * entity.pricePerLiter;
    final difference = (entity.totalPrice - expectedTotal).abs();
    const tolerance = 0.02; // R$ 0,02 de tolerância para arredondamentos

    if (difference > tolerance) {
      return Left(
        ValidationFailure(
          'Invalid total price: ${entity.totalPrice}. Expected ~$expectedTotal (liters × pricePerLiter)',
        ),
      );
    }

    return const Right(null);
  }

  // ==========================================================================
  // CONFLICT RESOLUTION
  // ==========================================================================

  @override
  Future<Either<Failure, FuelRecordEntity>> resolveConflict(
    FuelRecordEntity local,
    FuelRecordEntity remote,
  ) async {
    // Usar estratégia padrão (Last Write Wins - LWW)
    final result = await super.resolveConflict(local, remote);

    if (result.isRight()) {
      final resolved = result.getOrElse(() => local);
      developer.log(
        'Conflict resolved for fuel supply: ${resolved.id} (${resolved.date}, ${resolved.liters}L)',
        name: 'FuelSupplyDriftSyncAdapter',
      );
    }

    return result;
  }

  // ==========================================================================
  // OPERAÇÕES DRIFT (Implementações de métodos abstratos)
  // ==========================================================================

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      developer.log(
        '🔍 Starting getDirtyRecords for user: $userId',
        name: 'FuelSupplyDriftSyncAdapter',
      );

      developer.log(
        '🔍 Database instance: ${db.hashCode}, type: ${db.runtimeType}',
        name: 'FuelSupplyDriftSyncAdapter',
      );

      final query = _db.select(_db.fuelSupplies)
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
        name: 'FuelSupplyDriftSyncAdapter',
      );

      final rows = await query.get();

      developer.log(
        '🔍 Query executed successfully, got ${rows.length} rows',
        name: 'FuelSupplyDriftSyncAdapter',
      );

      // Verificar se temos rows válidas
      if (rows.isEmpty) {
        developer.log(
          'ℹ️ No dirty fuel supplies found for user $userId',
          name: 'FuelSupplyDriftSyncAdapter',
        );
        return const Right([]);
      }

      // Log details of each row com verificações de segurança
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        try {
          developer.log(
            '🔍 Row $i: id=${row.id}, firebaseId=${row.firebaseId}, date=${row.date}, liters=${row.liters}, userId=${row.userId}',
            name: 'FuelSupplyDriftSyncAdapter',
          );
        } catch (e) {
          developer.log(
            '⚠️ Error logging row $i: $e',
            name: 'FuelSupplyDriftSyncAdapter',
          );
        }
      }

      // Converter entities com tratamento de erro individual
      final entities = <FuelRecordEntity>[];
      for (final row in rows) {
        try {
          var entity = driftToEntity(row);

          final vehicleFirebaseId = await _resolveVehicleFirebaseId(
            row.vehicleId,
          );

          if (vehicleFirebaseId == null) {
            developer.log(
              '⏸️ Skipping fuel supply ${entity.id}: vehicle ${row.vehicleId} not synced yet',
              name: 'FuelSupplyDriftSyncAdapter',
            );
            continue;
          }

          entity = entity.copyWith(vehicleId: vehicleFirebaseId);
          entities.add(entity);
        } catch (e) {
          developer.log(
            '❌ Error converting row to entity: $e',
            name: 'FuelSupplyDriftSyncAdapter',
            error: e,
          );
          // Continuar com outras rows em vez de falhar completamente
        }
      }

      developer.log(
        'Found ${entities.length} dirty fuel supplies for user $userId',
        name: 'FuelSupplyDriftSyncAdapter',
      );

      return Right(entities);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get dirty records',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get dirty fuel supplies: $e'));
    }
  }

  Future<Either<Failure, FuelRecordEntity?>> getLocalEntity(String id) async {
    try {
      final query = _db.select(_db.fuelSupplies)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        )
        ..limit(1);

      final row = await query.getSingleOrNull();

      if (row != null) {
        developer.log(
          'Found local fuel supply: $id',
          name: 'FuelSupplyDriftSyncAdapter',
        );
        return Right(driftToEntity(row));
      }

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get local entity',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get local fuel supply: $e'));
    }
  }

  Future<Either<Failure, void>> insertLocal(FuelRecordEntity entity) async {
    try {
      final resolvedEntity = await _ensureLocalVehicleReference(entity);
      if (resolvedEntity == null) {
        return const Left(
          CacheFailure('Failed to resolve vehicle reference for fuel supply'),
        );
      }

      final companion = entityToCompanion(resolvedEntity);
      await _db.into(_db.fuelSupplies).insert(companion);

      developer.log(
        'Inserted fuel supply: ${entity.id}',
        name: 'FuelSupplyDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to insert local entity',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to insert fuel supply: $e'));
    }
  }

  Future<Either<Failure, void>> updateLocal(FuelRecordEntity entity) async {
    try {
      final resolvedEntity = await _ensureLocalVehicleReference(entity);
      if (resolvedEntity == null) {
        return const Left(
          CacheFailure('Failed to resolve vehicle reference for fuel supply'),
        );
      }

      final companion = entityToCompanion(resolvedEntity);

      // FuelRecordEntity não tem firebaseId, apenas id
      final query = _db.update(_db.fuelSupplies)
        ..where(
          (tbl) => (entity.id.isNotEmpty
              ? tbl.firebaseId.equals(entity.id)
              : tbl.id.equals(int.tryParse(entity.id) ?? -1)),
        );

      final rowsAffected = await query.write(companion);

      if (rowsAffected == 0) {
        developer.log(
          'No rows updated for fuel supply ${entity.id}, inserting instead',
          name: 'FuelSupplyDriftSyncAdapter',
        );
        return insertLocal(entity);
      }

      developer.log(
        'Updated fuel supply: ${entity.id}',
        name: 'FuelSupplyDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update local entity',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to update fuel supply: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String id, {
    String? firebaseId,
  }) async {
    try {
      final companion = FuelSuppliesCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
        firebaseId:
            firebaseId != null ? Value(firebaseId) : const Value.absent(),
      );

      final query = _db.update(_db.fuelSupplies)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        );

      await query.write(companion);

      developer.log(
        'Marked fuel supply as synced: $id${firebaseId != null ? ' (firebaseId: $firebaseId)' : ''}',
        name: 'FuelSupplyDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to mark as synced',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to mark fuel supply as synced: $e'));
    }
  }

  // ==========================================================================
  // HELPERS ESPECÍFICOS
  // ==========================================================================

  /// Busca abastecimentos de um veículo por firebaseId
  ///
  /// Resolve o firebaseId do veículo para localId antes da busca
  Future<List<FuelRecordEntity>> getSuppliesByVehicle(
    String vehicleFirebaseId,
  ) async {
    try {
      // Buscar veículo por firebaseId para obter localId
      final vehicleQuery = _db.select(_db.vehicles)
        ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
        ..limit(1);

      final vehicle = await vehicleQuery.getSingleOrNull();
      if (vehicle == null) {
        developer.log(
          'Vehicle not found: $vehicleFirebaseId',
          name: 'FuelSupplyDriftSyncAdapter',
        );
        return [];
      }

      // Buscar abastecimentos pelo vehicleId local
      final query = _db.select(_db.fuelSupplies)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

      final rows = await query.get();
      return rows.map((row) => driftToEntity(row)).toList();
    } catch (e) {
      developer.log(
        'Error getting supplies by vehicle',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
      );
      return [];
    }
  }

  /// Busca o último abastecimento de um veículo
  Future<FuelRecordEntity?> getLatestSupply(String vehicleFirebaseId) async {
    try {
      // Buscar veículo por firebaseId
      final vehicleQuery = _db.select(_db.vehicles)
        ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
        ..limit(1);

      final vehicle = await vehicleQuery.getSingleOrNull();
      if (vehicle == null) {
        return null;
      }

      // Buscar último abastecimento
      final query = _db.select(_db.fuelSupplies)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
        ..limit(1);

      final row = await query.getSingleOrNull();
      return row != null ? driftToEntity(row) : null;
    } catch (e) {
      developer.log(
        'Error getting latest supply',
        name: 'FuelSupplyDriftSyncAdapter',
        error: e,
      );
      return null;
    }
  }

  /// Stream de abastecimentos de um veículo (reactive UI)
  Stream<List<FuelRecordEntity>> watchSuppliesByVehicle(
    String vehicleFirebaseId,
  ) async* {
    // Primeiro, resolver vehicleId local
    final vehicleQuery = _db.select(_db.vehicles)
      ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
      ..limit(1);

    final vehicle = await vehicleQuery.getSingleOrNull();
    if (vehicle == null) {
      yield [];
      return;
    }

    // Assistir mudanças nos abastecimentos
    final query = _db.select(_db.fuelSupplies)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    yield* query.watch().map(
          (rows) => rows.map((row) => driftToEntity(row)).toList(),
        );
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
        name: 'FuelSupplyDriftSyncAdapter',
      );
      return null;
    }

    return firebaseId;
  }

  Future<FuelRecordEntity?> _ensureLocalVehicleReference(
    FuelRecordEntity entity,
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
        name: 'FuelSupplyDriftSyncAdapter',
      );
      return null;
    }

    return entity.copyWith(vehicleId: vehicleRow.id.toString());
  }
}
