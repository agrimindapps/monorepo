import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../core/sync/adapters/drift_sync_adapter_base.dart';
import '../../../../database/gasometer_database.dart';
import '../../../../database/tables/gasometer_tables.dart';
import '../../domain/entities/expense_entity.dart';

/// Adapter de sincronização para Despesas (Drift ↔ Firestore)
///
/// Implementa conversões bidirecionais entre:
/// - **Drift Row** (Expense): Dados do SQLite via Drift ORM
/// - **Domain Entity** (ExpenseEntity): Entidade de negócio
/// - **Firestore Document** (Map<String, dynamic>): JSON para Firebase
///
/// **Mapeamento de Campos:**
///
/// | ExpenseEntity        | Drift Table (Expenses)     | Firestore          |
/// |----------------------|----------------------------|--------------------|
/// | id (String)          | firebaseId                 | id                 |
/// | vehicleId (String)   | vehicleId (int FK)         | vehicle_id         |
/// | type (enum)          | category (String)          | type               |
/// | description          | description                | description        |
/// | amount               | amount                     | amount             |
/// | date                 | date (timestamp)           | date               |
/// | odometer             | N/A                        | odometer           |
/// | receiptImagePath     | receiptImagePath           | receipt_image_path |
/// | location             | N/A                        | location           |
/// | notes                | notes                      | notes              |
/// | metadata             | N/A                        | metadata           |
///
/// **Validações:**
/// - vehicleId não vazio
/// - category e description não vazios
/// - amount > 0
/// - date válido (não futuro)
///
/// **Helpers Específicos:**
/// - getExpensesByCategory(String vehicleFirebaseId, String category)
/// - getTotalExpenses(String vehicleFirebaseId, {DateTime? startDate, DateTime? endDate})
///
/// **Conflict Resolution:**
/// - Last Write Wins (LWW) com version checking
@lazySingleton
class ExpenseDriftSyncAdapter
    extends DriftSyncAdapterBase<ExpenseEntity, Expense> {
  ExpenseDriftSyncAdapter(super.db, super.firestore, super.connectivityService);

  @override
  String get collectionName => 'expenses';

  @override
  TableInfo<Expenses, Expense> get table =>
      db.expenses as TableInfo<Expenses, Expense>;

  // ==========================================================================
  // CONVERSÕES: DRIFT → DOMAIN ENTITY
  // ==========================================================================

  @override
  ExpenseEntity toDomainEntity(Expense driftRow) {
    // Converter timestamp (int) → DateTime
    final date = DateTime.fromMillisecondsSinceEpoch(driftRow.date);

    // Mapear category (String) → ExpenseType enum
    final type = ExpenseType.fromString(driftRow.category);

    return ExpenseEntity(
      // ID: usar firebaseId se disponível, senão id.toString()
      id: driftRow.firebaseId ?? driftRow.id.toString(),

      // Vehicle ID: será resolvido para firebaseId no helper
      vehicleId: driftRow.vehicleId.toString(),

      // Tipo e descrição
      type: type,
      description: driftRow.description,

      // Valores financeiros
      amount: driftRow.amount,

      // Data
      date: date,

      // Odômetro (não disponível no Drift legado)
      odometer: 0.0,

      // Comprovante
      receiptImagePath: driftRow.receiptImagePath,

      // Localização (não disponível no Drift legado)
      location: null,

      // Observações
      notes: driftRow.notes,

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

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → DRIFT COMPANION
  // ==========================================================================

  @override
  Insertable<Expense> toCompanion(ExpenseEntity entity) {
    // Parse vehicleId (pode ser firebaseId ou localId)
    int vehicleLocalId;
    try {
      vehicleLocalId = int.parse(entity.vehicleId);
    } catch (e) {
      // Se não for int, usar 0 (será resolvido na camada de repository)
      vehicleLocalId = 0;
      developer.log(
        'Warning: vehicleId ${entity.vehicleId} is not a valid local ID',
        name: 'ExpenseDriftSyncAdapter',
      );
    }

    // Parse firebaseId para localId (se necessário)
    int? localId;
    if (entity.id.isNotEmpty) {
      localId = int.tryParse(entity.id);
    }

    // Converter DateTime → timestamp (int)
    final dateTimestamp = entity.date.millisecondsSinceEpoch;

    return ExpensesCompanion(
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

      // Dados da despesa
      category: Value(entity.type.name),
      description: Value(entity.description),
      amount: Value(entity.amount),
      date: Value(dateTimestamp),

      // Observações
      notes: entity.notes != null ? Value(entity.notes) : const Value.absent(),

      // Comprovante
      receiptImagePath: entity.receiptImagePath != null
          ? Value(entity.receiptImagePath)
          : const Value.absent(),
      receiptImageUrl: const Value.absent(),
    );
  }

  // ==========================================================================
  // CONVERSÕES: DOMAIN ENTITY → FIRESTORE MAP
  // ==========================================================================

  @override
  Map<String, dynamic> toFirestoreMap(ExpenseEntity entity) {
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
  Either<Failure, ExpenseEntity> fromFirestoreMap(Map<String, dynamic> map) {
    try {
      // Usar método existente da entidade
      final entity = ExpenseEntity.fromFirebaseMap(map);

      // Validar campos obrigatórios
      if (entity.id.isEmpty) {
        return const Left(
          ValidationFailure('Expense ID missing from Firestore document'),
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
        'Failed to parse Firestore document to ExpenseEntity',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(ParseFailure('Failed to parse expense from Firestore: $e'));
    }
  }

  // ==========================================================================
  // VALIDAÇÃO
  // ==========================================================================

  @override
  Either<Failure, void> validateForSync(ExpenseEntity entity) {
    // 1. Validações base (ID, userId)
    final baseValidation = super.validateForSync(entity);
    if (baseValidation.isLeft()) {
      return baseValidation;
    }

    // 2. Validar vehicleId obrigatório
    if (entity.vehicleId.trim().isEmpty) {
      return const Left(ValidationFailure('Vehicle ID cannot be empty'));
    }

    // 3. Validar descrição obrigatória
    if (entity.description.trim().isEmpty) {
      return const Left(
        ValidationFailure('Expense description cannot be empty'),
      );
    }

    // 4. Validar amount (positivo)
    if (entity.amount <= 0) {
      return Left(
        ValidationFailure(
          'Invalid amount: ${entity.amount}. Must be greater than 0',
        ),
      );
    }

    // 5. Validar data (não futuro)
    if (entity.date.isAfter(DateTime.now())) {
      return Left(
        ValidationFailure(
          'Invalid date: ${entity.date.toIso8601String()}. Cannot be in the future',
        ),
      );
    }

    return const Right(null);
  }

  // ==========================================================================
  // CONFLICT RESOLUTION
  // ==========================================================================

  @override
  ExpenseEntity resolveConflict(ExpenseEntity local, ExpenseEntity remote) {
    // Usar estratégia padrão (Last Write Wins - LWW)
    final resolved = super.resolveConflict(local, remote);

    developer.log(
      'Conflict resolved for expense: ${resolved.id} (${resolved.type.displayName})',
      name: 'ExpenseDriftSyncAdapter',
    );

    return resolved;
  }

  // ==========================================================================
  // OPERAÇÕES DRIFT (Implementações de métodos abstratos)
  // ==========================================================================

  // ignore: unused_element
  Future<Either<Failure, List<ExpenseEntity>>> _getDirtyRecords(
    String userId,
  ) async {
    try {
      developer.log(
        '🔍 Starting _getDirtyRecords for user: $userId',
        name: 'ExpenseDriftSyncAdapter',
      );

      developer.log(
        '🔍 Database instance: ${db.hashCode}, type: ${db.runtimeType}',
        name: 'ExpenseDriftSyncAdapter',
      );

      final query = db.select(db.expenses)
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
        name: 'ExpenseDriftSyncAdapter',
      );

      final rows = await query.get();

      developer.log(
        '🔍 Query executed successfully, got ${rows.length} rows',
        name: 'ExpenseDriftSyncAdapter',
      );

      // Verificar se temos rows válidas
      if (rows.isEmpty) {
        developer.log(
          'ℹ️ No dirty expenses found for user $userId',
          name: 'ExpenseDriftSyncAdapter',
        );
        return const Right([]);
      }

      // Log details of each row com verificações de segurança
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        try {
          developer.log(
            '🔍 Row $i: id=${row.id}, firebaseId=${row.firebaseId}, vehicleId=${row.vehicleId}, amount=${row.amount}',
            name: 'ExpenseDriftSyncAdapter',
          );
        } catch (e) {
          developer.log(
            '⚠️ Error logging row $i: $e',
            name: 'ExpenseDriftSyncAdapter',
          );
        }
      }

      // Converter entities com tratamento de erro individual
      final entities = <ExpenseEntity>[];
      for (final row in rows) {
        try {
          final entity = toDomainEntity(row);
          entities.add(entity);
        } catch (e) {
          developer.log(
            '❌ Error converting row to entity: $e',
            name: 'ExpenseDriftSyncAdapter',
            error: e,
          );
          // Continuar com outras rows em vez de falhar completamente
        }
      }

      developer.log(
        'Found ${entities.length} dirty expenses for user $userId',
        name: 'ExpenseDriftSyncAdapter',
      );

      return Right(entities);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get dirty records',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get dirty expense records: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, ExpenseEntity?>> _getLocalEntity(String id) async {
    try {
      // Buscar por firebaseId OU por id (local autoIncrement)
      final query = db.select(db.expenses)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        )
        ..limit(1);

      final row = await query.getSingleOrNull();

      if (row != null) {
        developer.log(
          'Found local expense: $id',
          name: 'ExpenseDriftSyncAdapter',
        );
        return Right(toDomainEntity(row));
      }

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get local entity',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to get local expense: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, void>> _insertLocal(ExpenseEntity entity) async {
    try {
      final companion = toCompanion(entity);
      await db.into(db.expenses).insert(companion);

      developer.log(
        'Inserted expense: ${entity.id} (${entity.type.displayName})',
        name: 'ExpenseDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to insert local entity',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to insert expense: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, void>> _updateLocal(ExpenseEntity entity) async {
    try {
      final companion = toCompanion(entity);

      // Atualizar por firebaseId OU por id local
      final query = db.update(db.expenses)
        ..where(
          (tbl) => (entity.id.isNotEmpty && int.tryParse(entity.id) == null
              ? tbl.firebaseId.equals(entity.id)
              : tbl.id.equals(int.tryParse(entity.id) ?? -1)),
        );

      final rowsAffected = await query.write(companion);

      if (rowsAffected == 0) {
        developer.log(
          'No rows updated for expense ${entity.id}, inserting instead',
          name: 'ExpenseDriftSyncAdapter',
        );
        return _insertLocal(entity);
      }

      developer.log(
        'Updated expense: ${entity.id} (${entity.type.displayName})',
        name: 'ExpenseDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update local entity',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to update expense: $e'));
    }
  }

  // ignore: unused_element
  Future<Either<Failure, void>> _markAsSynced(
    String id, {
    String? firebaseId,
  }) async {
    try {
      final companion = ExpensesCompanion(
        isDirty: const Value(false),
        lastSyncAt: Value(DateTime.now()),
        firebaseId: firebaseId != null
            ? Value(firebaseId)
            : const Value.absent(),
      );

      final query = db.update(db.expenses)
        ..where(
          (tbl) =>
              tbl.firebaseId.equals(id) | tbl.id.equals(int.tryParse(id) ?? -1),
        );

      await query.write(companion);

      developer.log(
        'Marked expense as synced: $id${firebaseId != null ? ' (firebaseId: $firebaseId)' : ''}',
        name: 'ExpenseDriftSyncAdapter',
      );

      return const Right(null);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to mark as synced',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
        stackTrace: stackTrace,
      );

      return Left(CacheFailure('Failed to mark expense as synced: $e'));
    }
  }

  // ==========================================================================
  // HELPERS ESPECÍFICOS
  // ==========================================================================

  /// Busca despesas de um veículo por categoria
  Future<List<ExpenseEntity>> getExpensesByCategory(
    String vehicleFirebaseId,
    String category,
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
          name: 'ExpenseDriftSyncAdapter',
        );
        return [];
      }

      // Buscar despesas por categoria
      final query = db.select(db.expenses)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) &
              tbl.category.equals(category) &
              tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

      final rows = await query.get();
      return rows.map((row) => toDomainEntity(row)).toList();
    } catch (e) {
      developer.log(
        'Error getting expenses by category',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
      );
      return [];
    }
  }

  /// Calcula o total de despesas de um veículo em um período
  Future<double> getTotalExpenses(
    String vehicleFirebaseId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Buscar veículo por firebaseId
      final vehicleQuery = db.select(db.vehicles)
        ..where((tbl) => tbl.firebaseId.equals(vehicleFirebaseId))
        ..limit(1);

      final vehicle = await vehicleQuery.getSingleOrNull();
      if (vehicle == null) {
        return 0.0;
      }

      // Montar query com filtros de data
      var query = db.select(db.expenses)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
        );

      // Aplicar filtro de data inicial
      if (startDate != null) {
        final startTimestamp = startDate.millisecondsSinceEpoch;
        query = query
          ..where((tbl) => tbl.date.isBiggerOrEqualValue(startTimestamp));
      }

      // Aplicar filtro de data final
      if (endDate != null) {
        final endTimestamp = endDate.millisecondsSinceEpoch;
        query = query
          ..where((tbl) => tbl.date.isSmallerOrEqualValue(endTimestamp));
      }

      final rows = await query.get();
      final entities = rows.map((row) => toDomainEntity(row)).toList();

      // Somar total
      final total = entities.fold<double>(
        0.0,
        (acc, expense) => acc + expense.amount,
      );

      developer.log(
        'Total expenses for vehicle $vehicleFirebaseId: R\$ ${total.toStringAsFixed(2)}',
        name: 'ExpenseDriftSyncAdapter',
      );

      return total;
    } catch (e) {
      developer.log(
        'Error calculating total expenses',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
      );
      return 0.0;
    }
  }

  /// Busca todas as despesas de um veículo
  Future<List<ExpenseEntity>> getExpensesByVehicle(
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

      // Buscar todas as despesas
      final query = db.select(db.expenses)
        ..where(
          (tbl) =>
              tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

      final rows = await query.get();
      return rows.map((row) => toDomainEntity(row)).toList();
    } catch (e) {
      developer.log(
        'Error getting expenses by vehicle',
        name: 'ExpenseDriftSyncAdapter',
        error: e,
      );
      return [];
    }
  }

  /// Stream de despesas de um veículo (reactive UI)
  Stream<List<ExpenseEntity>> watchExpensesByVehicle(
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

    // Assistir mudanças nas despesas
    final query = db.select(db.expenses)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicle.id) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    yield* query.watch().map(
      (rows) => rows.map((row) => toDomainEntity(row)).toList(),
    );
  }
}
