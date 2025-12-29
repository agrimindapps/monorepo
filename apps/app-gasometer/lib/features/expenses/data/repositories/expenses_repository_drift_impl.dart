import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../../database/repositories/expense_repository.dart';
import '../../../vehicles/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/expense_entity.dart';
import '../datasources/expenses_local_datasource.dart';
import '../sync/expense_drift_sync_adapter.dart';

/// Implementação do repositório de despesas usando Drift
///
/// Padrão "Sync-on-Write": Sincroniza imediatamente com Firebase quando online,
/// seguindo o padrão do app-plantis. Background sync permanece como fallback.

class ExpensesRepositoryDriftImpl implements IExpensesRepository {
  const ExpensesRepositoryDriftImpl(
    this._dataSource,
    this._connectivityService,
    this._syncAdapter,
    this._vehicleRepository,
  );

  final ExpensesLocalDataSource _dataSource;
  final ConnectivityService _connectivityService;
  final ExpenseDriftSyncAdapter _syncAdapter;
  final VehicleRepository _vehicleRepository;

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
      developer.log(
        '🔵 ExpensesRepository.saveExpense() - Starting',
        name: 'ExpensesRepository',
      );

      // 1. Salvar localmente primeiro (sempre)
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

      var entity = _toEntity(createdData);
      developer.log(
        '✅ ExpensesRepository.saveExpense() - Saved locally with id=$id',
        name: 'ExpensesRepository',
      );

      // 2. Atualizar odômetro do veículo se for maior que o atual
      if (expense.odometer > 0) {
        await _vehicleRepository.updateVehicleOdometer(
          expense.vehicleId,
          expense.odometer.toInt(),
        );
      }

      // 3. Sync-on-Write: Se online, sincronizar imediatamente com Firebase
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 ExpensesRepository.saveExpense() - Online, syncing to Firebase...',
          name: 'ExpensesRepository',
        );
        try {
          // Push para Firebase usando o adapter
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ ExpensesRepository.saveExpense() - Sync failed: ${failure.message}. Will retry via background sync.',
                name: 'ExpensesRepository',
              );
            },
            (result) {
              developer.log(
                '✅ ExpensesRepository.saveExpense() - Synced to Firebase (${result.recordsPushed} pushed, ${result.recordsFailed} failed)',
                name: 'ExpensesRepository',
              );
            },
          );

          // Reload entity com estado atualizado (isDirty=false, firebaseId set)
          final refreshed = await _dataSource.findById(id);
          if (refreshed != null) {
            entity = _toEntity(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ ExpensesRepository.saveExpense() - Sync error: $e. Will retry via background sync.',
            name: 'ExpensesRepository',
          );
          // Falhou remoto, mas local já está salvo - retorna local
        }
      } else {
        developer.log(
          '📴 ExpensesRepository.saveExpense() - Offline, will sync later via background sync',
          name: 'ExpensesRepository',
        );
      }

      return entity;
    } catch (e) {
      developer.log(
        '❌ ExpensesRepository.saveExpense() - Error: $e',
        name: 'ExpensesRepository',
      );
      return null;
    }
  }

  @override
  Future<ExpenseEntity?> updateExpense(ExpenseEntity expense) async {
    try {
      developer.log(
        '🔵 ExpensesRepository.updateExpense() - Starting for id=${expense.id}',
        name: 'ExpensesRepository',
      );

      // 1. Atualizar localmente primeiro
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

      var entity = _toEntity(updatedData);
      developer.log(
        '✅ ExpensesRepository.updateExpense() - Updated locally',
        name: 'ExpensesRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 ExpensesRepository.updateExpense() - Online, syncing to Firebase...',
          name: 'ExpensesRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ ExpensesRepository.updateExpense() - Sync failed: ${failure.message}',
                name: 'ExpensesRepository',
              );
            },
            (result) {
              developer.log(
                '✅ ExpensesRepository.updateExpense() - Synced to Firebase',
                name: 'ExpensesRepository',
              );
            },
          );

          // Reload entity com estado atualizado
          final refreshed = await _dataSource.findById(idInt);
          if (refreshed != null) {
            entity = _toEntity(refreshed);
          }
        } catch (e) {
          developer.log(
            '⚠️ ExpensesRepository.updateExpense() - Sync error: $e',
            name: 'ExpensesRepository',
          );
        }
      }

      return entity;
    } catch (e) {
      developer.log(
        '❌ ExpensesRepository.updateExpense() - Error: $e',
        name: 'ExpensesRepository',
      );
      return null;
    }
  }

  @override
  Future<bool> deleteExpense(String expenseId) async {
    try {
      developer.log(
        '🔵 ExpensesRepository.deleteExpense() - Starting for id=$expenseId',
        name: 'ExpensesRepository',
      );

      // 1. Soft delete localmente primeiro (marca isDeleted=true, isDirty=true)
      final idInt = int.parse(expenseId);
      final success = await _dataSource.delete(idInt);

      if (!success) {
        return false;
      }

      developer.log(
        '✅ ExpensesRepository.deleteExpense() - Marked as deleted locally',
        name: 'ExpensesRepository',
      );

      // 2. Sync-on-Write: Se online, sincronizar imediatamente
      final isOnlineResult = await _connectivityService.isOnline();
      final isOnline = isOnlineResult.fold((_) => false, (online) => online);

      if (isOnline) {
        developer.log(
          '🌐 ExpensesRepository.deleteExpense() - Online, syncing deletion to Firebase...',
          name: 'ExpensesRepository',
        );
        try {
          final pushResult = await _syncAdapter.pushDirtyRecords(_userId);

          pushResult.fold(
            (failure) {
              developer.log(
                '⚠️ ExpensesRepository.deleteExpense() - Sync failed: ${failure.message}',
                name: 'ExpensesRepository',
              );
            },
            (result) {
              developer.log(
                '✅ ExpensesRepository.deleteExpense() - Synced deletion to Firebase',
                name: 'ExpensesRepository',
              );
            },
          );
        } catch (e) {
          developer.log(
            '⚠️ ExpensesRepository.deleteExpense() - Sync error: $e',
            name: 'ExpensesRepository',
          );
        }
      }

      return true;
    } catch (e) {
      developer.log(
        '❌ ExpensesRepository.deleteExpense() - Error: $e',
        name: 'ExpensesRepository',
      );
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
  Future<List<ExpenseEntity>> getRecentExpenses(
    String vehicleId, {
    int limit = 3,
  }) async {
    try {
      final vehicleIdInt = int.parse(vehicleId);
      final dataList = await _dataSource.findByVehicleId(vehicleIdInt);

      // Ordenar por data DESC e aplicar limite
      dataList.sort((a, b) => b.date.compareTo(a.date));
      return dataList.take(limit).map<ExpenseEntity>(_toEntity).toList();
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
        (total, data) => total + data.amount,
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
