import 'package:hive/hive.dart';
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';
import '../../../../core/cache/cache_manager.dart';

/// Repository para persistência de despesas usando Hive com cache strategy
class ExpensesRepository with CachedRepository<ExpenseEntity> {
  static const String _boxName = 'expenses';
  late Box<ExpenseModel> _box;

  /// Inicializa o repositório
  Future<void> initialize() async {
    _box = await Hive.openBox<ExpenseModel>(_boxName);
    
    // Inicializar cache com configurações otimizadas para expenses
    initializeCache(
      maxSize: 150, // Mais entradas para expenses frequentes
      defaultTtl: const Duration(minutes: 10), // TTL maior para dados financeiros
    );
  }

  /// Salva nova despesa
  Future<ExpenseEntity?> saveExpense(ExpenseEntity expense) async {
    try {
      final model = _entityToModel(expense);
      await _box.put(expense.id, model);
      
      final entity = _modelToEntity(model);
      
      // Cache a entidade
      cacheEntity(entityCacheKey(expense.id), entity);
      
      // Invalidar caches de listas relacionadas
      invalidateListCache('all_expenses');
      invalidateListCache(vehicleCacheKey(expense.vehicleId, 'expenses'));
      invalidateListCache(typeCacheKey(expense.type.name, 'expenses'));
      
      return entity;
    } catch (e) {
      throw Exception('Erro ao salvar despesa: $e');
    }
  }

  /// Atualiza despesa existente
  Future<ExpenseEntity?> updateExpense(ExpenseEntity expense) async {
    try {
      if (!_box.containsKey(expense.id)) {
        throw Exception('Despesa não encontrada');
      }
      
      final model = _entityToModel(expense);
      await _box.put(expense.id, model);
      
      final entity = _modelToEntity(model);
      
      // Atualizar cache da entidade
      cacheEntity(entityCacheKey(expense.id), entity);
      
      // Invalidar caches de listas relacionadas
      invalidateListCache('all_expenses');
      invalidateListCache(vehicleCacheKey(expense.vehicleId, 'expenses'));
      invalidateListCache(typeCacheKey(expense.type.name, 'expenses'));
      
      return entity;
    } catch (e) {
      throw Exception('Erro ao atualizar despesa: $e');
    }
  }

  /// Remove despesa por ID
  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _box.delete(expenseId);
      
      // Remover do cache
      invalidateCache(entityCacheKey(expenseId));
      
      // Invalidar todos os caches de listas (não sabemos veículo/tipo)
      clearAllCache();
      
      return true;
    } catch (e) {
      throw Exception('Erro ao remover despesa: $e');
    }
  }

  /// Busca despesa por ID
  Future<ExpenseEntity?> getExpenseById(String expenseId) async {
    try {
      // Verificar cache primeiro
      final cacheKey = entityCacheKey(expenseId);
      final cached = getCachedEntity(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      final model = _box.get(expenseId);
      if (model == null) return null;
      
      final entity = _modelToEntity(model);
      
      // Cache o resultado
      cacheEntity(cacheKey, entity);
      
      return entity;
    } catch (e) {
      throw Exception('Erro ao buscar despesa: $e');
    }
  }

  /// Carrega todas as despesas
  Future<List<ExpenseEntity>> getAllExpenses() async {
    try {
      // Verificar cache primeiro
      const cacheKey = 'all_expenses';
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final entities = models.map((model) => _modelToEntity(model)).toList();
      
      // Cache o resultado
      cacheList(cacheKey, entities);
      
      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar despesas: $e');
    }
  }

  /// Carrega despesas por veículo
  Future<List<ExpenseEntity>> getExpensesByVehicle(String vehicleId) async {
    try {
      // Verificar cache primeiro
      final cacheKey = vehicleCacheKey(vehicleId, 'expenses');
      final cached = getCachedList(cacheKey);
      if (cached != null) {
        return cached;
      }
      
      final models = _box.values
          .where((model) => model.veiculoId == vehicleId && !model.isDeleted)
          .toList();
      final entities = models.map((model) => _modelToEntity(model)).toList();
      
      // Cache o resultado
      cacheList(cacheKey, entities);
      
      return entities;
    } catch (e) {
      throw Exception('Erro ao carregar despesas do veículo: $e');
    }
  }

  /// Carrega despesas por tipo
  Future<List<ExpenseEntity>> getExpensesByType(ExpenseType type) async {
    try {
      final models = _box.values
          .where((model) => model.tipo == type.name && !model.isDeleted)
          .toList();
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar despesas por tipo: $e');
    }
  }

  /// Carrega despesas por período
  Future<List<ExpenseEntity>> getExpensesByPeriod(DateTime start, DateTime end) async {
    try {
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      
      final models = _box.values.where((model) {
        return model.data >= startMs && 
               model.data <= endMs && 
               !model.isDeleted;
      }).toList();
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar despesas por período: $e');
    }
  }

  /// Busca despesas por texto
  Future<List<ExpenseEntity>> searchExpenses(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final models = _box.values.where((model) {
        return !model.isDeleted && 
               model.descricao.toLowerCase().contains(lowerQuery);
      }).toList();
      
      return models.map((model) => _modelToEntity(model)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar despesas: $e');
    }
  }

  /// Carrega estatísticas básicas
  Future<Map<String, dynamic>> getStats() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      
      if (models.isEmpty) {
        return {
          'totalRecords': 0,
          'totalAmount': 0.0,
          'averageAmount': 0.0,
        };
      }

      final totalAmount = models.fold<double>(0, (sum, model) => sum + model.valor);
      
      return {
        'totalRecords': models.length,
        'totalAmount': totalAmount,
        'averageAmount': totalAmount / models.length,
        'lastExpense': _modelToEntity(models.reduce((a, b) => 
            a.data > b.data ? a : b)),
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  /// Verifica se há despesas duplicadas
  Future<List<ExpenseEntity>> findDuplicates() async {
    try {
      final models = _box.values.where((model) => !model.isDeleted).toList();
      final duplicates = <ExpenseModel>[];
      
      for (int i = 0; i < models.length; i++) {
        for (int j = i + 1; j < models.length; j++) {
          final model1 = models[i];
          final model2 = models[j];
          
          // Considera duplicata se mesmo veículo, tipo, data (mesmo dia) e valor muito próximo
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
      location: null, // Não disponível no modelo legacy
      notes: null, // Não disponível no modelo legacy
      receiptImagePath: null, // Não disponível no modelo legacy
      createdAt: model.createdAt ?? DateTime.now(),
      updatedAt: model.updatedAt ?? DateTime.now(),
      metadata: const {},
    );
  }

  /// Fecha o box (cleanup)
  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      // Log error mas não trava
      print('Erro ao fechar box de despesas: $e');
    }
  }
}