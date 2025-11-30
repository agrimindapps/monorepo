import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../../../../database/gasometer_database.dart';
import '../../../../database/tables/gasometer_tables.dart';
import '../../../vehicles/domain/entities/vehicle_entity.dart';

/// Adapter de sincronização para Veículos (Drift ↔ Firestore)
///
/// Implementa conversões bidirecionais entre:
/// - **Drift Row** (Vehicle): Dados do SQLite via Drift ORM
/// - **Domain Entity** (VehicleEntity): Entidade de negócio
/// - **Firestore Document** (Map\<String, dynamic\>): JSON para Firebase
///
/// **Mapeamento de Campos:**
///
/// | VehicleEntity       | Drift Table (Vehicles) | Firestore          |
/// |---------------------|------------------------|--------------------|
/// | id (String)         | firebaseId             | id                 |
/// | name                | N/A                    | name               |
/// | brand               | marca                  | brand              |
/// | model               | modelo                 | model              |
/// | year                | ano                    | year               |
/// | color               | cor                    | color              |
/// | licensePlate        | placa                  | license_plate      |
/// | type                | N/A                    | type               |
/// | supportedFuels      | combustivel (enum)     | supported_fuels    |
/// | tankCapacity        | N/A                    | tank_capacity      |
/// | engineSize          | N/A                    | engine_size        |
/// | photoUrl            | foto                   | photo_url          |
/// | currentOdometer     | odometroAtual          | current_odometer   |
/// | averageConsumption  | N/A                    | average_consumption|
/// | isActive            | !vendido               | is_active          |
///
/// **Validações:**
/// - ID não vazio
/// - UserId obrigatório
/// - Brand, model, licensePlate obrigatórios
/// - Year range: 1900 <= year <= current_year + 1
/// - License plate uniqueness per user (Firestore constraint)
///
/// **Conflict Resolution:**
/// - Last Write Wins (LWW) com version checking
/// - Se versions iguais, usa updatedAt timestamp

class VehicleDriftSyncAdapter
    extends DriftSyncAdapterBase<VehicleEntity, Vehicle> {
  VehicleDriftSyncAdapter(
    GasometerDatabase super.db,
    super.firestore,
    super.connectivityService,
  );

  GasometerDatabase get _db => db as GasometerDatabase;

  @override
  String get collectionName => 'vehicles';

  @override
  TableInfo<Vehicles, Vehicle> get table =>
      _db.vehicles as TableInfo<Vehicles, Vehicle>;

  // ==========================================================================
  // CONVERSÕES: DRIFT → DOMAIN ENTITY
  // ==========================================================================

  @override
  VehicleEntity driftToEntity(Vehicle driftRow) {
    // Mapear combustivel (int) → FuelType list
    final fuelType = _parseFuelTypeFromIndex(driftRow.combustivel);
    final supportedFuels = [fuelType];

    // Mapear type baseado em combustivel/metadata (default: car)
    const vehicleType = VehicleType.car;

    return VehicleEntity(
      // ID: usar firebaseId se disponível, senão id.toString()
      id: driftRow.firebaseId ?? driftRow.id.toString(),
      firebaseId: driftRow.firebaseId,

      // Campos obrigatórios
      name: '${driftRow.marca} ${driftRow.modelo}',
      brand: driftRow.marca,
      model: driftRow.modelo,
      year: driftRow.ano,
      color: driftRow.cor,
      licensePlate: driftRow.placa,

      // Enums e listas
      type: vehicleType,
      supportedFuels: supportedFuels,

      // Campos opcionais (não disponíveis no Drift legado)
      tankCapacity: null, // Não disponível no Drift
      engineSize: null, // Não disponível no Drift
      photoUrl: driftRow.foto,
      currentOdometer: driftRow.odometroAtual,
      averageConsumption: null, // Calculado dinamicamente
      // Status
      isActive: !driftRow.vendido,

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
    switch (fuelType) {
      case FuelType.gasoline:
        return 0;
      case FuelType.ethanol:
        return 1;
      case FuelType.diesel:
        return 2;
      case FuelType.gas:
        return 3;
      case FuelType.hybrid:
      case FuelType.electric:
        return 4; // Flex/Hybrid
    }
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → DRIFT COMPANION
  // ==========================================================================

  @override
  Insertable<Vehicle> entityToCompanion(VehicleEntity entity) {
    // Parse firebaseId para localId (se necessário)
    int? localId;
    if (entity.firebaseId != null) {
      localId = int.tryParse(entity.id);
    }

    // Pegar primeiro combustível suportado
    final primaryFuel = entity.supportedFuels.isNotEmpty
        ? entity.supportedFuels.first
        : FuelType.gasoline;

    return VehiclesCompanion(
      // ID: usar Value() se existe, senão Value.absent() (autoIncrement)
      id: localId != null ? Value(localId) : const Value.absent(),

      // Firebase ID
      firebaseId: entity.firebaseId != null
          ? Value(entity.firebaseId)
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

      // Dados do veículo
      marca: Value(entity.brand),
      modelo: Value(entity.model),
      ano: Value(entity.year),
      placa: Value(entity.licensePlate),
      cor: Value(entity.color),

      // Odômetro
      odometroInicial: const Value(0.0), // Não disponível em VehicleEntity
      odometroAtual: Value(entity.currentOdometer),

      // Combustível
      combustivel: Value(_fuelTypeToIndex(primaryFuel)),

      // Documentação
      renavan: const Value(''),
      chassi: const Value(''),

      // Foto
      foto: entity.photoUrl != null
          ? Value(entity.photoUrl)
          : const Value.absent(),

      // Status de venda
      vendido: Value(!entity.isActive),
      valorVenda: const Value(0.0),
    );
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → FIRESTORE MAP
  // ==========================================================================

  @override
  Map<String, dynamic> toFirestoreMap(VehicleEntity entity) {
    try {
      developer.log(
        '🔄 Converting entity to Firestore map: ${entity.id}',
        name: 'VehicleDriftSyncAdapter',
      );

      // Usar método existente da entidade
      final map = entity.toFirebaseMap();

      developer.log(
        '🔄 toFirebaseMap() completed, map has ${map.keys.length} keys',
        name: 'VehicleDriftSyncAdapter',
      );

      // Garantir que user_id está presente (security rules)
      if (!map.containsKey('user_id') && entity.userId != null) {
        map['user_id'] = entity.userId;
      }

      developer.log(
        '✅ Firestore map conversion successful',
        name: 'VehicleDriftSyncAdapter',
      );

      return map;
    } catch (e, stackTrace) {
      developer.log(
        '❌ ERROR in toFirestoreMap: $e',
        name: 'VehicleDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ==========================================================================
  // CONVERSÕES: FIRESTORE MAP → DOMAIN ENTITY
  // ==========================================================================

  @override
  VehicleEntity fromFirestoreDoc(Map<String, dynamic> doc) {
    try {
      // Usar método existente da entidade
      final entity = VehicleEntity.fromFirebaseMap(doc);

      // Validar campos obrigatórios
      if (entity.id.isEmpty) {
        throw const ValidationFailure(
          'Vehicle ID missing from Firestore document',
        );
      }

      if (entity.brand.isEmpty || entity.model.isEmpty) {
        throw const ValidationFailure(
          'Brand or model missing from Firestore document',
        );
      }

      return entity;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to parse Firestore document to VehicleEntity',
        name: 'VehicleDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      throw ParseFailure('Failed to parse vehicle from Firestore: $e');
    }
  }

  // ==========================================================================
  // VALIDAÇÃO
  // ==========================================================================

  @override
  Either<Failure, void> validateForSync(VehicleEntity entity) {
    // 1. Validações base (ID, userId)
    final baseValidation = super.validateForSync(entity);
    if (baseValidation.isLeft()) {
      return baseValidation;
    }

    // 2. Validar campos obrigatórios
    if (entity.brand.trim().isEmpty) {
      return const Left(ValidationFailure('Vehicle brand cannot be empty'));
    }

    if (entity.model.trim().isEmpty) {
      return const Left(ValidationFailure('Vehicle model cannot be empty'));
    }

    if (entity.licensePlate.trim().isEmpty) {
      return const Left(ValidationFailure('License plate cannot be empty'));
    }

    // 3. Validar ano (range válido)
    final currentYear = DateTime.now().year;
    if (entity.year < 1900 || entity.year > currentYear + 1) {
      return Left(
        ValidationFailure(
          'Invalid year: ${entity.year}. Must be between 1900 and ${currentYear + 1}',
        ),
      );
    }

    // 4. Validar combustíveis suportados
    if (entity.supportedFuels.isEmpty) {
      return const Left(
        ValidationFailure('At least one fuel type must be supported'),
      );
    }

    // 5. Validar odômetro (não negativo)
    if (entity.currentOdometer < 0) {
      return Left(
        ValidationFailure(
          'Invalid odometer: ${entity.currentOdometer}. Cannot be negative',
        ),
      );
    }

    return const Right(null);
  }

  // ==========================================================================
  // CONFLICT RESOLUTION
  // ==========================================================================

  @override
  Future<Either<Failure, VehicleEntity>> resolveConflict(
    VehicleEntity local,
    VehicleEntity remote,
  ) async {
    // Usar estratégia padrão (Last Write Wins - LWW)
    final resolvedResult = await super.resolveConflict(local, remote);

    resolvedResult.fold(
      (failure) => null,
      (resolved) => developer.log(
        'Conflict resolved for vehicle: ${resolved.id} (${resolved.brand} ${resolved.model})',
        name: 'VehicleDriftSyncAdapter',
      ),
    );

    return resolvedResult;
  }

  // ==========================================================================
  // OPERAÇÕES DRIFT (Implementações de métodos abstratos)
  // ==========================================================================
  //
  // Esses métodos são chamados pela base class DriftSyncAdapterBase,
  // então warnings de "unused" são falsos positivos.

  @override
  Future<Either<Failure, List<VehicleEntity>>> getDirtyRecords(
    String userId,
  ) async {
    try {
      developer.log(
        '🔍 Starting getDirtyRecords for user: $userId',
        name: 'VehicleDriftSyncAdapter',
      );

      developer.log(
        '🔍 Database instance: ${db.hashCode}, type: ${db.runtimeType}',
        name: 'VehicleDriftSyncAdapter',
      );

      final query = _db.select(_db.vehicles)
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
        name: 'VehicleDriftSyncAdapter',
      );

      final rows = await query.get();

      developer.log(
        '🔍 Query executed successfully, got ${rows.length} rows',
        name: 'VehicleDriftSyncAdapter',
      );

      // Verificar se temos rows válidas
      if (rows.isEmpty) {
        developer.log(
          'ℹ️ No dirty vehicles found for user $userId',
          name: 'VehicleDriftSyncAdapter',
        );
        return const Right([]);
      }

      // Log details of each row com verificações de segurança
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        try {
          developer.log(
            '🔍 Row $i: id=${row.id}, firebaseId=${row.firebaseId}, marca=${row.marca}, modelo=${row.modelo}',
            name: 'VehicleDriftSyncAdapter',
          );
        } catch (e) {
          developer.log(
            '⚠️ Error logging row $i: $e',
            name: 'VehicleDriftSyncAdapter',
          );
        }
      }

      // Converter entities com tratamento de erro individual
      final entities = <VehicleEntity>[];
      for (final row in rows) {
        try {
          final entity = driftToEntity(row);
          entities.add(entity);
        } catch (e) {
          developer.log(
            '❌ Error converting row to entity: $e',
            name: 'VehicleDriftSyncAdapter',
            error: e,
          );
          // Continuar com outras rows em vez de falhar completamente
        }
      }

      developer.log(
        'Found ${entities.length} dirty vehicles for user $userId',
        name: 'VehicleDriftSyncAdapter',
      );

      return Right(entities);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get dirty records',
        name: 'VehicleDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get dirty vehicle records: $e'));
    }
  }

  // @override removed as it is not in the interface
  Future<Either<Failure, VehicleEntity?>> getLocalEntity(String id) async {
    try {
      // Buscar por firebaseId OU por id (local autoIncrement)
      final query = _db.select(_db.vehicles)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        )
        ..limit(1);

      final row = await query.getSingleOrNull();

      if (row != null) {
        developer.log(
          'Found local vehicle: $id',
          name: 'VehicleDriftSyncAdapter',
        );
        return Right(driftToEntity(row));
      }

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get local entity',
        name: 'VehicleDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get local vehicle: $e'));
    }
  }

  // @override removed as it is not in the interface
  Future<Either<Failure, void>> insertLocal(VehicleEntity entity) async {
    try {
      final companion = entityToCompanion(entity);
      await _db.into(_db.vehicles).insert(companion);

      developer.log(
        'Inserted vehicle: ${entity.id} (${entity.brand} ${entity.model})',
        name: 'VehicleDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to insert local entity',
        name: 'VehicleDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to insert vehicle: $e'));
    }
  }

  // @override removed as it is not in the interface
  Future<Either<Failure, void>> updateLocal(VehicleEntity entity) async {
    try {
      final companion = entityToCompanion(entity);

      // Atualizar por firebaseId OU por id local
      final query = _db.update(_db.vehicles)
        ..where(
          (tbl) => (entity.firebaseId != null
              ? tbl.firebaseId.equals(entity.firebaseId!)
              : tbl.id.equals(int.tryParse(entity.id) ?? -1)),
        );

      final rowsAffected = await query.write(companion);

      if (rowsAffected == 0) {
        developer.log(
          'No rows updated for vehicle ${entity.id}, inserting instead',
          name: 'VehicleDriftSyncAdapter',
        );
        return insertLocal(entity);
      }

      developer.log(
        'Updated vehicle: ${entity.id} (${entity.brand} ${entity.model})',
        name: 'VehicleDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update local entity',
        name: 'VehicleDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to update vehicle: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced(
    String id, {
    String? firebaseId,
  }) async {
    try {
      final companion = VehiclesCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
        // 🔥 FIX: Atualizar firebaseId se fornecido (UUID gerado durante push)
        firebaseId:
            firebaseId != null ? Value(firebaseId) : const Value.absent(),
      );

      final query = _db.update(_db.vehicles)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        );

      await query.write(companion);

      developer.log(
        'Marked vehicle as synced: $id${firebaseId != null ? ' (firebaseId: $firebaseId)' : ''}',
        name: 'VehicleDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to mark as synced',
        name: 'VehicleDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to mark vehicle as synced: $e'));
    }
  }

  // ==========================================================================
  // HELPERS ESPECÍFICOS
  // ==========================================================================

  /// Verifica se placa já existe para outro veículo (mesmo usuário)
  Future<bool> licensePlateExists(
    String userId,
    String licensePlate, {
    String? excludeVehicleId,
  }) async {
    try {
      final query = _db.select(_db.vehicles)
        ..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.placa.equals(licensePlate) &
              tbl.isDeleted.equals(false),
        );

      final results = await query.get();

      // Filtrar veículo atual (se editing)
      if (excludeVehicleId != null) {
        final filtered = results.where(
          (v) =>
              v.firebaseId != excludeVehicleId &&
              v.id.toString() != excludeVehicleId,
        );
        return filtered.isNotEmpty;
      }

      return results.isNotEmpty;
    } catch (e) {
      developer.log(
        'Error checking license plate existence',
        name: 'VehicleDriftSyncAdapter',
        error: e,
      );
      return false;
    }
  }

  /// Busca veículos ativos do usuário (helper para UI)
  Future<List<VehicleEntity>> getActiveVehicles(String userId) async {
    try {
      final query = _db.select(_db.vehicles)
        ..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.vendido.equals(false) &
              tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

      final rows = await query.get();
      return rows.map((row) => driftToEntity(row)).toList();
    } catch (e) {
      developer.log(
        'Error getting active vehicles',
        name: 'VehicleDriftSyncAdapter',
        error: e,
      );
      return [];
    }
  }

  /// Stream de veículos ativos (reactive UI)
  Stream<List<VehicleEntity>> watchActiveVehicles(String userId) {
    final query = _db.select(_db.vehicles)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.vendido.equals(false) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.modelo)]);

    return query.watch().map(
          (rows) => rows.map((row) => driftToEntity(row)).toList(),
        );
  }
}
