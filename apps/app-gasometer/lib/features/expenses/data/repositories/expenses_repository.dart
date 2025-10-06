import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/interfaces/i_expenses_repository.dart';
import '../../../../core/logging/entities/log_entry.dart';
import '../../../../core/logging/mixins/loggable_repository_mixin.dart';
import '../../../../core/logging/services/logging_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../core/constants/expense_constants.dart';
import '../../domain/entities/expense_entity.dart';
import '../datasources/expenses_remote_data_source.dart';
import '../models/expense_model.dart';

/// Repository para persistência de despesas usando Hive com cache strategy e sync Firebase
@Injectable(as: IExpensesRepository)
class ExpensesRepository
    with CachedRepository<ExpenseEntity>, LoggableRepositoryMixin
    implements IExpensesRepository {
  ExpensesRepository(
    this._loggingService,
    this._remoteDataSource,
    this._connectivity,
    this._authRepository,
  );
  static const String _boxName = 'expenses';
  late Box<ExpenseModel> _box;
  final LoggingService _loggingService;
  final ExpensesRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity;
  final AuthRepository _authRepository;

  @override
  LoggingService get loggingService => _loggingService;

  @override
  String get repositoryCategory => LogCategory.expenses;

  Future<bool> _isConnected() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }

  Future<String?> _getCurrentUserId() async {
    final userResult = await _authRepository.getCurrentUser();
    return userResult.fold((failure) => null, (user) => user?.id);
  }

  /// Garante que o box está inicializado antes do uso
  Future<void> _ensureInitialized() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
  }

  /// Inicializa o repositório
  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<ExpenseModel>(_boxName);
    initializeCache(
      maxSize: 200, // Mais entradas para expenses frequentes
      defaultTtl: const Duration(
        minutes: 45,
      ), // TTL otimizado para dados financeiros (45 min)
    );
    unawaited(_warmupCache());
  }

  /// Aquece o cache com dados frequentemente acessados
  Future<void> _warmupCache() async {
    try {
      unawaited(getAllExpenses());
      unawaited(getStats());
      final recentModels =
          _box.values.where((model) => !model.isDeleted).toList()
            ..sort((a, b) => b.data.compareTo(a.data));

      if (recentModels.isNotEmpty) {
        for (int i = 0; i < recentModels.length && i < 10; i++) {
          final entity = _modelToEntity(recentModels[i]);
          cacheEntity(entityCacheKey(entity.id), entity);
        }
        final lastMonth = DateTime.now().subtract(const Duration(days: 30));
        unawaited(getExpensesByPeriod(lastMonth, DateTime.now()));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache warmup failed (non-critical): $e');
      }
    }
  }

  /// Salva nova despesa
  @override
  Future<ExpenseEntity?> saveExpense(ExpenseEntity expense) async {
    return await withLogging<ExpenseEntity?>(
      operation: LogOperation.create,
      entityType: 'Expense',
      entityId: expense.id,
      metadata: {
        'vehicle_id': expense.vehicleId,
        'type': expense.type.name,
        'amount': expense.amount,
      },
      operationFunc: () async {
        final model = _entityToModel(expense);
        await _box.put(expense.id, model);

        final entity = _modelToEntity(model);
        await logLocalStorage(
          action: 'saved',
          entityType: 'Expense',
          entityId: expense.id,
          metadata: {'storage_type': 'hive'},
        );
        cacheEntity(entityCacheKey(expense.id), entity);
        invalidateListCache('all_expenses');
        invalidateListCache(vehicleCacheKey(expense.vehicleId, 'expenses'));
        invalidateListCache(typeCacheKey(expense.type.name, 'expenses'));
        unawaited(_syncExpenseToRemoteInBackground(expense));

        return entity;
      },
    );
  }

  /// Atualiza despesa existente
  @override
  Future<ExpenseEntity?> updateExpense(ExpenseEntity expense) async {
    return await withLogging<ExpenseEntity?>(
      operation: LogOperation.update,
      entityType: 'Expense',
      entityId: expense.id,
      metadata: {
        'vehicle_id': expense.vehicleId,
        'type': expense.type.name,
        'amount': expense.amount,
      },
      operationFunc: () async {
        if (!_box.containsKey(expense.id)) {
          throw Exception('Despesa não encontrada');
        }

        final model = _entityToModel(expense);
        await _box.put(expense.id, model);

        final entity = _modelToEntity(model);
        await logLocalStorage(
          action: 'updated',
          entityType: 'Expense',
          entityId: expense.id,
          metadata: {'storage_type': 'hive'},
        );
        cacheEntity(entityCacheKey(expense.id), entity);
        invalidateListCache('all_expenses');
        invalidateListCache(vehicleCacheKey(expense.vehicleId, 'expenses'));
        invalidateListCache(typeCacheKey(expense.type.name, 'expenses'));
        unawaited(_syncExpenseToRemoteInBackground(expense));

        return entity;
      },
    );
  }

  /// Remove despesa por ID
  @override
  Future<bool> deleteExpense(String expenseId) async {
    return await withLogging<bool>(
      operation: LogOperation.delete,
      entityType: 'Expense',
      entityId: expenseId,
      operationFunc: () async {
        final expenseToDelete = _box.get(expenseId);

        await _box.delete(expenseId);
        await logLocalStorage(
          action: 'deleted',
          entityType: 'Expense',
          entityId: expenseId,
          metadata: {'storage_type': 'hive'},
        );
        invalidateCache(entityCacheKey(expenseId));
        if (expenseToDelete != null) {
          invalidateListCache('all_expenses');
          invalidateListCache(
            vehicleCacheKey(expenseToDelete.veiculoId, 'expenses'),
          );
          invalidateListCache(typeCacheKey(expenseToDelete.tipo, 'expenses'));
        } else {
          invalidateListCache('all_expenses');
        }

        return true;
      },
    );
  }

  /// Busca despesa por ID
  @override
  Future<ExpenseEntity?> getExpenseById(String expenseId) async {
    try {
      await _ensureInitialized();
      final cacheKey = entityCacheKey(expenseId);
      final cached = getCachedEntity(cacheKey);
      if (cached != null) {
        return cached;
      }

      final model = _box.get(expenseId);
      if (model == null) return null;

      final entity = _modelToEntity(model);
      cacheEntity(cacheKey, entity);

      return entity;
    } catch (e) {
      throw Exception('Erro ao buscar despesa: $e');
    }
  }

  /// Carrega todas as despesas
  @override
  Future<List<ExpenseEntity>> getAllExpenses() async {
    try {
      await _ensureInitialized();
      const cacheKey = 'all_expenses';
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }

      final models = _box.values.where((model) => !model.isDeleted).toList();
      final entities = models.map((model) => _modelToEntity(model)).toList();
      cacheList(cacheKey, entities);

      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar despesas: $e');
    }
  }

  /// Carrega despesas por veículo
  @override
  Future<List<ExpenseEntity>> getExpensesByVehicle(String vehicleId) async {
    try {
      await _ensureInitialized();
      final cacheKey = vehicleCacheKey(vehicleId, 'expenses');
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }

      final models =
          _box.values
              .where(
                (model) => model.veiculoId == vehicleId && !model.isDeleted,
              )
              .toList();
      final entities = models.map((model) => _modelToEntity(model)).toList();
      cacheList(cacheKey, entities);

      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar despesas do veículo: $e');
    }
  }

  /// Carrega despesas por tipo
  @override
  Future<List<ExpenseEntity>> getExpensesByType(ExpenseType type) async {
    try {
      final cacheKey = typeCacheKey(type.name, 'expenses');
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }

      final models =
          _box.values
              .where((model) => model.tipo == type.name && !model.isDeleted)
              .toList();
      final entities = models.map((model) => _modelToEntity(model)).toList();
      cacheList(cacheKey, entities);

      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar despesas por tipo: $e');
    }
  }

  /// Carrega despesas por período
  @override
  Future<List<ExpenseEntity>> getExpensesByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final periodKey =
          'period_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';
      final cached = getCachedList(periodKey);
      if (cached != null) {
        return cached;
      }

      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;

      final models =
          _box.values.where((model) {
            return model.data >= startMs &&
                model.data <= endMs &&
                !model.isDeleted;
          }).toList();

      final entities = models.map((model) => _modelToEntity(model)).toList();
      cacheList(periodKey, entities, ttl: const Duration(minutes: 20));

      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar despesas por período: $e');
    }
  }

  /// Busca despesas por texto
  @override
  Future<List<ExpenseEntity>> searchExpenses(String query) async {
    try {
      final searchKey = 'search_${query.toLowerCase().replaceAll(' ', '_')}';
      final cached = getCachedList(searchKey);
      if (cached != null) {
        return cached;
      }

      final lowerQuery = query.toLowerCase();
      final models =
          _box.values.where((model) {
            return !model.isDeleted &&
                model.descricao.toLowerCase().contains(lowerQuery);
          }).toList();

      final entities = models.map((model) => _modelToEntity(model)).toList();
      cacheList(searchKey, entities, ttl: const Duration(minutes: 10));

      return entities;
    } catch (e) {
      throw Exception('Erro ao buscar despesas: $e');
    }
  }

  /// Carrega estatísticas básicas
  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      await _ensureInitialized();

      final models = _box.values.where((model) => !model.isDeleted).toList();

      if (models.isEmpty) {
        return {'totalRecords': 0, 'totalAmount': 0.0, 'averageAmount': 0.0};
      }

      final totalAmount = models.fold<double>(
        0,
        (sum, model) => sum + model.valor,
      );

      return {
        'totalRecords': models.length,
        'totalAmount': totalAmount,
        'averageAmount': totalAmount / models.length,
        'lastExpense': _modelToEntity(
          models.reduce((a, b) => a.data > b.data ? a : b),
        ),
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Verifica se há despesas duplicadas
  @override
  Future<List<ExpenseEntity>> findDuplicates() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final duplicates = <ExpenseModel>[];

      for (int i = 0; i < models.length; i++) {
        for (int j = i + 1; j < models.length; j++) {
          final model1 = models[i];
          final model2 = models[j];
          final date1 = DateTime.fromMillisecondsSinceEpoch(model1.data);
          final date2 = DateTime.fromMillisecondsSinceEpoch(model2.data);

          if (model1.veiculoId == model2.veiculoId &&
              model1.tipo == model2.tipo &&
              date1.day == date2.day &&
              date1.month == date2.month &&
              date1.year == date2.year &&
              (model1.valor - model2.valor).abs() < 0.01) {
            duplicates.add(model2);
          }
        }
      }

      return duplicates.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar duplicatas: $e');
    }
  }

  /// Limpa todas as despesas (apenas para debug/reset)
  @override
  Future<void> clearAllExpenses() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Erro ao limpar despesas: $e');
    }
  }

  /// Converte ExpenseEntity para ExpenseModel
  ExpenseModel _entityToModel(ExpenseEntity entity) {
    return ExpenseModel.create(
      id: entity.id,
      userId: entity.userId,
      veiculoId: entity.vehicleId,
      tipo: entity.type.name,
      descricao: entity.description,
      valor: entity.amount,
      data: entity.date.millisecondsSinceEpoch,
      odometro: entity.odometer,
      receiptImagePath: entity.receiptImagePath,
      location: entity.location,
      notes: entity.notes,
      metadata: entity.metadata,
    );
  }

  /// Converte ExpenseModel para ExpenseEntity
  ExpenseEntity _modelToEntity(ExpenseModel model) {
    return ExpenseEntity(
      id: model.id,
      userId: model.userId ?? '',
      vehicleId: model.veiculoId,
      type: ExpenseType.values.firstWhere(
        (e) => e.name == model.tipo,
        orElse: () => ExpenseType.other,
      ),
      description: model.descricao,
      amount: model.valor,
      date: DateTime.fromMillisecondsSinceEpoch(model.data),
      odometer: model.odometro,
      receiptImagePath: model.receiptImagePath,
      location: model.location,
      notes: model.notes,
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: model.metadata,
    );
  }

  /// Batch save expenses
  @override
  Future<List<ExpenseEntity>> saveExpenses(List<ExpenseEntity> expenses) async {
    try {
      final results = <ExpenseEntity>[];
      for (final expense in expenses) {
        final result = await saveExpense(expense);
        if (result != null) {
          results.add(result);
        }
      }
      return results;
    } catch (e) {
      throw Exception('Erro ao salvar despesas em lote: $e');
    }
  }

  /// Batch delete expenses
  @override
  Future<bool> deleteExpenses(List<String> expenseIds) async {
    try {
      for (final id in expenseIds) {
        await deleteExpense(id);
      }
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar despesas em lote: $e');
    }
  }

  /// Advanced filtering
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
      final filterKey = _buildFilterCacheKey(
        vehicleId: vehicleId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        minAmount: minAmount,
        maxAmount: maxAmount,
        searchText: searchText,
      );

      final cached = getCachedList(filterKey);
      if (cached != null) {
        return cached;
      }

      final models =
          _box.values.where((model) {
            if (model.isDeleted) return false;

            if (vehicleId != null && model.veiculoId != vehicleId) return false;
            if (type != null && model.tipo != type.name) return false;

            if (startDate != null &&
                model.data < startDate.millisecondsSinceEpoch) {
              return false;
            }
            if (endDate != null && model.data > endDate.millisecondsSinceEpoch) {
              return false;
            }

            if (minAmount != null && model.valor < minAmount) return false;
            if (maxAmount != null && model.valor > maxAmount) return false;

            if (searchText != null &&
                !model.descricao.toLowerCase().contains(
                  searchText.toLowerCase(),
                )) {
              return false;
            }

            return true;
          }).toList();

      final entities = models.map((model) => _modelToEntity(model)).toList();
      cacheList(filterKey, entities, ttl: const Duration(minutes: 25));

      return entities;
    } catch (e) {
      throw Exception('Erro ao filtrar despesas: $e');
    }
  }

  /// Constrói chave de cache para filtros complexos
  String _buildFilterCacheKey({
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchText,
  }) {
    final parts = <String>['filter'];

    if (vehicleId != null) parts.add('v_$vehicleId');
    if (type != null) parts.add('t_${type.name}');
    if (startDate != null) parts.add('sd_${startDate.millisecondsSinceEpoch}');
    if (endDate != null) parts.add('ed_${endDate.millisecondsSinceEpoch}');
    if (minAmount != null) parts.add('min_$minAmount');
    if (maxAmount != null) parts.add('max_$maxAmount');
    if (searchText != null) {
      parts.add('q_${searchText.toLowerCase().replaceAll(' ', '_')}');
    }

    return parts.join('_');
  }

  /// Paginated expenses
  @override
  Future<PagedResult<ExpenseEntity>> getExpensesPaginated({
    int page = 0,
    int pageSize = ExpenseConstants.defaultPageSize,
    String? vehicleId,
    ExpenseType? type,
    DateTime? startDate,
    DateTime? endDate,
    ExpenseSortBy sortBy = ExpenseSortBy.date,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      final allExpenses = await getExpensesWithFilters(
        vehicleId: vehicleId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
      allExpenses.sort((a, b) {
        int comparison = 0;
        switch (sortBy) {
          case ExpenseSortBy.date:
            comparison = a.date.compareTo(b.date);
            break;
          case ExpenseSortBy.amount:
            comparison = a.amount.compareTo(b.amount);
            break;
          case ExpenseSortBy.type:
            comparison = a.type.name.compareTo(b.type.name);
            break;
          case ExpenseSortBy.description:
            comparison = a.description.compareTo(b.description);
            break;
          case ExpenseSortBy.odometer:
            comparison = a.odometer.compareTo(b.odometer);
            break;
        }

        return sortOrder == SortOrder.ascending ? comparison : -comparison;
      });
      final totalItems = allExpenses.length;
      final totalPages = (totalItems / pageSize).ceil();
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalItems);

      final paginatedItems = allExpenses.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      return PagedResult<ExpenseEntity>(
        items: paginatedItems,
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: totalPages,
        hasNext: page < totalPages - 1,
        hasPrevious: page > 0,
      );
    } catch (e) {
      throw Exception('Erro ao paginar despesas: $e');
    }
  }

  /// Sincroniza despesa com Firebase em background
  Future<void> _syncExpenseToRemoteInBackground(ExpenseEntity expense) async {
    try {
      if (!await _isConnected()) {
        return;
      }
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return;
      }
      await _remoteDataSource.addExpense(userId, expense);
      await logRemoteSync(
        action: 'synced',
        entityType: 'Expense',
        entityId: expense.id,
        success: true,
        metadata: {
          'vehicle_id': expense.vehicleId,
          'type': expense.type.name,
          'amount': expense.amount,
        },
      );
    } catch (e) {
      await logRemoteSync(
        action: 'sync_failed',
        entityType: 'Expense',
        entityId: expense.id,
        success: false,
        metadata: {
          'error': e.toString(),
          'vehicle_id': expense.vehicleId,
          'type': expense.type.name,
        },
      );
      if (kDebugMode) {
        print('Background sync failed for expense ${expense.id}: $e');
      }
    }
  }

  /// Fecha o box (cleanup)
  @override
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fechar box de despesas: $e');
      }
    }
  }
}
