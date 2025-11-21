import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../../database/repositories/expense_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../datasources/expenses_local_datasource.dart';

/// Implementação do repositório de despesas usando Drift

class ExpensesRepositoryDriftImpl implements IExpensesRepository {
  const ExpensesRepositoryDriftImpl(this._dataSource);

  final ExpensesLocalDataSource _dataSource;

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ========== CONVERSÕES ==========

  ExpenseEntity _toEntity(ExpenseData data) {
    return ExpenseEntity(
      id: data.id.toString(),
      vehicleId: data.vehicleId.toString(),
      type: ExpenseType.values.firstWhere(
        (e) => e.name == data.category,
        orElse: () => ExpenseType.other,
      ),
      description: data.description,
      amount: data.amount,
      date: DateTime.fromMillisecondsSinceEpoch(data.date),
      odometer: 0.0, // Não temos este campo na tabela atual
      receiptImagePath: data.receiptImagePath,
      location: null, // Não temos este campo na tabela atual
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastSyncAt: data.lastSyncAt,
      isDirty: data.isDirty,
      isDeleted: data.isDeleted,
      version: data.version,
      userId: data.userId,
      moduleName: data.moduleName,
    );
  }

  // ========== INTERFACE IExpensesRepository ==========

  @override
  Future<void> initialize() async {
    // Drift cuida da inicialização automaticamente
  }

  @override
  Future<ExpenseEntity?> saveExpense(ExpenseEntity expense) async {
    try {
      final id = await _dataSource.create(
        userId: _userId,
        vehicleId: int.parse(expense.vehicleId),
        description: expense.description,
        amount: expense.amount,
        date: expense.date,
        category: expense.type.name,
        notes: expense.notes,
        receiptImagePath: expense.receiptImagePath,
      );

      // Buscar o registro criado para retornar
      final createdData = await _dataSource.findById(id);
      if (createdData == null) {
        return null;
      }

      return _toEntity(createdData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ExpenseEntity?> updateExpense(ExpenseEntity expense) async {
    try {
      final idInt = int.parse(expense.id);
      final success = await _dataSource.update(
        id: idInt,
        userId: _userId,
        vehicleId: int.parse(expense.vehicleId),
        description: expense.description,
        amount: expense.amount,
        date: expense.date,
        category: expense.type.name,
        notes: expense.notes,
        receiptImagePath: expense.receiptImagePath,
      );

      if (!success) {
        return null;
      }

      // Buscar o registro atualizado para retornar
      final updatedData = await _dataSource.findById(idInt);
      if (updatedData == null) {
        return null;
      }

      return _toEntity(updatedData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteExpense(String expenseId) async {
    try {
      final idInt = int.parse(expenseId);
      return await _dataSource.delete(idInt);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ExpenseEntity?> getExpenseById(String expenseId) async {
    try {
      final idInt = int.parse(expenseId);
      final data = await _dataSource.findById(idInt);
      return data != null ? _toEntity(data) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async {
    try {
      final dataList = await _dataSource.findAll();
      return dataList.map<ExpenseEntity>(_toEntity).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByVehicle(String vehicleId) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final dataList = await _dataSource.findByVehicleId(vehicleIdInt);
      return dataList.map<ExpenseEntity>(_toEntity).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByType(ExpenseType type) async {
    try {
      // Buscar todos os registros e filtrar por tipo
      final allData = await _dataSource.findAll();
      final filteredData = allData
          .where((data) => data.category == type.name)
          .toList();
      return filteredData.map<ExpenseEntity>(_toEntity).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Buscar todos os registros e filtrar por período
      final allData = await _dataSource.findAll();
      final filteredData = allData.where((data) {
        final expenseDate = DateTime.fromMillisecondsSinceEpoch(data.date);
        return expenseDate.isAfter(start) && expenseDate.isBefore(end);
      }).toList();
      return filteredData.map<ExpenseEntity>(_toEntity).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ExpenseEntity>> searchExpenses(String query) async {
    try {
      // Buscar todos os registros e filtrar por busca
      final allData = await _dataSource.findAll();
      final lowerQuery = query.toLowerCase();
      final filteredData = allData
          .where(
            (data) =>
                data.description.toLowerCase().contains(lowerQuery) ||
                data.category.toLowerCase().contains(lowerQuery) ||
                (data.notes?.toLowerCase().contains(lowerQuery) ?? false),
          )
          .toList();
      return filteredData.map<ExpenseEntity>(_toEntity).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final allData = await _dataSource.findAll();
      final totalExpenses = allData.length;
      final totalAmount = allData.fold<double>(
        0.0,
        (sum, data) => sum + data.amount,
      );

      // Estatísticas por categoria
      final categoryStats = <String, double>{};
      for (final data in allData) {
        categoryStats[data.category] =
            (categoryStats[data.category] ?? 0.0) + data.amount;
      }

      return {
        'totalExpenses': totalExpenses,
        'totalAmount': totalAmount,
        'categoryStats': categoryStats,
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<ExpenseEntity>> findDuplicates() async {
    try {
      // Implementação simples: despesas com mesma descrição e valor no mesmo dia
      final allData = await _dataSource.findAll();
      final duplicates = <ExpenseEntity>[];

      for (int i = 0; i < allData.length; i++) {
        for (int j = i + 1; j < allData.length; j++) {
          final data1 = allData[i];
          final data2 = allData[j];

          if (data1.description == data2.description &&
              data1.amount == data2.amount &&
              data1.date == data2.date) {
            duplicates.add(_toEntity(data1));
            break;
          }
        }
      }

      return duplicates;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearAllExpenses() async {
    // Não implementado para evitar perda acidental de dados
    // Em produção, isso seria implementado com confirmação do usuário
  }

  @override
  Future<void> close() async {
    // Drift cuida do fechamento automaticamente
  }

  @override
  Future<List<ExpenseEntity>> saveExpenses(List<ExpenseEntity> expenses) async {
    final savedExpenses = <ExpenseEntity>[];

    for (final expense in expenses) {
      final saved = await saveExpense(expense);
      if (saved != null) {
        savedExpenses.add(saved);
      }
    }

    return savedExpenses;
  }

  @override
  Future<bool> deleteExpenses(List<String> expenseIds) async {
    try {
      for (final expenseId in expenseIds) {
        final success = await deleteExpense(expenseId);
        if (!success) return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesWithFilters({
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchText,
  }) async {
    try {
      var dataList = await _dataSource.findAll();

      // Aplicar filtros
      if (vehicleId != null) {
        final vehicleIdInt = int.parse(vehicleId);
        dataList = await _dataSource.findByVehicleId(vehicleIdInt);
      }

      if (type != null) {
        dataList = dataList
            .where((data) => data.category == type.name)
            .toList();
      }

      if (startDate != null && endDate != null) {
        dataList = dataList.where((data) {
          final expenseDate = DateTime.fromMillisecondsSinceEpoch(data.date);
          return expenseDate.isAfter(startDate) &&
              expenseDate.isBefore(endDate);
        }).toList();
      }

      if (minAmount != null) {
        dataList = dataList.where((data) => data.amount >= minAmount).toList();
      }

      if (maxAmount != null) {
        dataList = dataList.where((data) => data.amount <= maxAmount).toList();
      }

      if (searchText != null && searchText.isNotEmpty) {
        final lowerQuery = searchText.toLowerCase();
        dataList = dataList
            .where(
              (data) =>
                  data.description.toLowerCase().contains(lowerQuery) ||
                  data.category.toLowerCase().contains(lowerQuery) ||
                  (data.notes?.toLowerCase().contains(lowerQuery) ?? false),
            )
            .toList();
      }

      return dataList.map<ExpenseEntity>(_toEntity).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PagedResult<ExpenseEntity>> getExpensesPaginated({
    int page = 0,
    int pageSize = 20,
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    ExpenseSortBy sortBy = ExpenseSortBy.date,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      var dataList = await _dataSource.findAll();

      // Aplicar filtros
      if (vehicleId != null) {
        final vehicleIdInt = int.parse(vehicleId);
        dataList = await _dataSource.findByVehicleId(vehicleIdInt);
      }

      if (type != null) {
        dataList = dataList
            .where((data) => data.category == type.name)
            .toList();
      }

      if (startDate != null && endDate != null) {
        dataList = dataList.where((data) {
          final expenseDate = DateTime.fromMillisecondsSinceEpoch(data.date);
          return expenseDate.isAfter(startDate) &&
              expenseDate.isBefore(endDate);
        }).toList();
      }

      // Ordenação
      dataList.sort((a, b) {
        int comparison = 0;

        switch (sortBy) {
          case ExpenseSortBy.date:
            comparison = a.date.compareTo(b.date);
            break;
          case ExpenseSortBy.amount:
            comparison = a.amount.compareTo(b.amount);
            break;
          case ExpenseSortBy.type:
            comparison = a.category.compareTo(b.category);
            break;
          case ExpenseSortBy.description:
            comparison = a.description.compareTo(b.description);
            break;
          case ExpenseSortBy.odometer:
            // Não temos odometer na tabela, usar data como fallback
            comparison = a.date.compareTo(b.date);
            break;
        }

        return sortOrder == SortOrder.ascending ? comparison : -comparison;
      });

      // Paginação
      final totalItems = dataList.length;
      final totalPages = (totalItems / pageSize).ceil();
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalItems);

      final pagedData = dataList.sublist(startIndex, endIndex);
      final entities = pagedData.map<ExpenseEntity>(_toEntity).toList();

      return PagedResult(
        items: entities,
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: totalPages,
        hasNext: page < totalPages - 1,
        hasPrevious: page > 0,
      );
    } catch (e) {
      return PagedResult(
        items: [],
        currentPage: page,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
        hasNext: false,
        hasPrevious: false,
      );
    }
  }
}
