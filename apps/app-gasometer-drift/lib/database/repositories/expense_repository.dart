import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../gasometer_database.dart';
import '../tables/gasometer_tables.dart';

/// Repositório de Despesas usando Drift
///
/// Gerencia operações de CRUD e queries para despesas gerais de veículos
@lazySingleton
class ExpenseRepository extends BaseDriftRepositoryImpl<ExpenseData, Expense> {
  ExpenseRepository(this._db);

  final GasometerDatabase _db;

  @override
  TableInfo<Expenses, Expense> get table => _db.expenses;

  @override
  GeneratedDatabase get database => _db;

  @override
  ExpenseData fromData(Expense data) {
    return ExpenseData(
      id: data.id,
      userId: data.userId,
      moduleName: data.moduleName,
      vehicleId: data.vehicleId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      description: data.description,
      amount: data.amount,
      date: data.date,
      category: data.category,
      notes: data.notes,
      receiptImageUrl: data.receiptImageUrl,
      receiptImagePath: data.receiptImagePath,
    );
  }

  @override
  Insertable<Expense> toCompanion(ExpenseData entity) {
    return ExpensesCompanion(
      // id é autoIncrement, não deve ser especificado no insert
      id: entity.id > 0 ? Value(entity.id) : Value.absent(),
      userId: Value(entity.userId),
      moduleName: Value(entity.moduleName),
      vehicleId: Value(entity.vehicleId),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      lastSyncAt: Value(entity.lastSyncAt),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      description: Value(entity.description),
      amount: Value(entity.amount),
      date: Value(entity.date),
      category: Value(entity.category),
      notes: Value(entity.notes),
      receiptImageUrl: Value(entity.receiptImageUrl),
      receiptImagePath: Value(entity.receiptImagePath),
    );
  }

  @override
  Expression<int> idColumn(Expenses tbl) => tbl.id;

  // ========== QUERIES CUSTOMIZADAS ==========

  /// Busca despesas de um veículo
  Future<List<ExpenseData>> findByVehicleId(int vehicleId) async {
    final query = _db.select(_db.expenses)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de despesas de um veículo
  Stream<List<ExpenseData>> watchByVehicleId(int vehicleId) {
    final query = _db.select(_db.expenses)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca despesas por categoria
  Future<List<ExpenseData>> findByCategory(
    int vehicleId,
    String category,
  ) async {
    final query = _db.select(_db.expenses)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.category.equals(category) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Stream de despesas por categoria
  Stream<List<ExpenseData>> watchByCategory(int vehicleId, String category) {
    final query = _db.select(_db.expenses)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.category.equals(category) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Busca despesas em um período
  Future<List<ExpenseData>> findByPeriod(
    int vehicleId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startMs = startDate.millisecondsSinceEpoch;
    final endMs = endDate.millisecondsSinceEpoch;

    final query = _db.select(_db.expenses)
      ..where(
        (tbl) =>
            tbl.vehicleId.equals(vehicleId) &
            tbl.date.isBiggerOrEqualValue(startMs) &
            tbl.date.isSmallerOrEqualValue(endMs) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Calcula total de despesas
  Future<double> calculateTotalExpenses(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.amount.sum()])
      ..where(
        _db.expenses.vehicleId.equals(vehicleId) &
            _db.expenses.isDeleted.equals(false),
      );

    if (startDate != null) {
      query = query
        ..where(
          _db.expenses.date.isBiggerOrEqualValue(
            startDate.millisecondsSinceEpoch,
          ),
        );
    }
    if (endDate != null) {
      query = query
        ..where(
          _db.expenses.date.isSmallerOrEqualValue(
            endDate.millisecondsSinceEpoch,
          ),
        );
    }

    final result = await query.getSingle();
    return result.read(_db.expenses.amount.sum()) ?? 0.0;
  }

  /// Calcula total de despesas por categoria
  Future<double> calculateTotalByCategory(
    int vehicleId,
    String category,
  ) async {
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.amount.sum()])
      ..where(
        _db.expenses.vehicleId.equals(vehicleId) &
            _db.expenses.category.equals(category) &
            _db.expenses.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.expenses.amount.sum()) ?? 0.0;
  }

  /// Busca estatísticas de despesas por categoria
  Future<Map<String, double>> getExpensesByCategory(int vehicleId) async {
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.category, _db.expenses.amount.sum()])
      ..where(
        _db.expenses.vehicleId.equals(vehicleId) &
            _db.expenses.isDeleted.equals(false),
      )
      ..groupBy([_db.expenses.category]);

    final results = await query.get();
    final map = <String, double>{};

    for (final row in results) {
      final category = row.read(_db.expenses.category);
      final total = row.read(_db.expenses.amount.sum()) ?? 0.0;
      if (category != null && category.isNotEmpty) {
        map[category] = total;
      }
    }

    return map;
  }

  /// Conta total de despesas de um veículo
  Future<int> countByVehicleId(int vehicleId) async {
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.id.count()])
      ..where(
        _db.expenses.vehicleId.equals(vehicleId) &
            _db.expenses.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_db.expenses.id.count()) ?? 0;
  }

  /// Busca categorias distintas de um veículo
  Future<List<String>> findDistinctCategories(int vehicleId) async {
    final query = _db.selectOnly(_db.expenses, distinct: true)
      ..addColumns([_db.expenses.category])
      ..where(
        _db.expenses.vehicleId.equals(vehicleId) &
            _db.expenses.isDeleted.equals(false),
      )
      ..orderBy([OrderingTerm.asc(_db.expenses.category)]);

    final results = await query.get();
    return results
        .map((row) => row.read(_db.expenses.category))
        .where((cat) => cat != null && cat.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// Busca despesas mais recentes
  Future<List<ExpenseData>> findRecent(int vehicleId, {int limit = 10}) async {
    final query = _db.select(_db.expenses)
      ..where(
        (tbl) => tbl.vehicleId.equals(vehicleId) & tbl.isDeleted.equals(false),
      )
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])
      ..limit(limit);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Busca despesas que precisam ser sincronizadas
  Future<List<ExpenseData>> findDirtyRecords() async {
    final query = _db.select(_db.expenses)
      ..where((tbl) => tbl.isDirty.equals(true));

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Marca registros como sincronizados
  Future<void> markAsSynced(List<int> expenseIds) async {
    await _db.executeTransaction(() async {
      for (final id in expenseIds) {
        await (_db.update(
          _db.expenses,
        )..where((tbl) => tbl.id.equals(id))).write(
          ExpensesCompanion(
            isDirty: const Value(false),
            lastSyncAt: Value(DateTime.now()),
          ),
        );
      }
    }, operationName: 'Mark expenses as synced');
  }

  /// Soft delete de uma despesa
  Future<bool> softDelete(int expenseId) async {
    final rowsAffected =
        await (_db.update(
          _db.expenses,
        )..where((tbl) => tbl.id.equals(expenseId))).write(
          ExpensesCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }
}

/// Classe auxiliar para transferência de dados de despesas
class ExpenseData {
  const ExpenseData({
    required this.id,
    required this.userId,
    required this.moduleName,
    required this.vehicleId,
    required this.createdAt,
    this.updatedAt,
    this.lastSyncAt,
    required this.isDirty,
    required this.isDeleted,
    required this.version,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.receiptImageUrl,
    this.receiptImagePath,
  });

  final int id;
  final String userId;
  final String moduleName;
  final int vehicleId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncAt;
  final bool isDirty;
  final bool isDeleted;
  final int version;
  final String description;
  final double amount;
  final int date;
  final String category;
  final String? notes;
  final String? receiptImageUrl;
  final String? receiptImagePath;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  ExpenseData copyWith({
    int? id,
    String? userId,
    String? moduleName,
    int? vehicleId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? description,
    double? amount,
    int? date,
    String? category,
    String? notes,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) {
    return ExpenseData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      vehicleId: vehicleId ?? this.vehicleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }
}
