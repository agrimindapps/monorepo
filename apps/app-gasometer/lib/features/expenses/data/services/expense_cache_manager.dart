import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../models/expense_model.dart';

/// Serviço responsável por operações de cache local de despesas
///
/// Gerencia persistência no Hive, queries otimizadas e limpeza de cache.
@lazySingleton
class ExpenseCacheManager {
  ExpenseCacheManager();

  static const String boxName = 'expenses';
  Box<ExpenseModel>? _box;

  /// Inicializa o box do Hive
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<ExpenseModel>(boxName);
    } else {
      _box = Hive.box<ExpenseModel>(boxName);
    }
  }

  /// Garante que o box está inicializado
  Future<Box<ExpenseModel>> _ensureBox() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
    return _box!;
  }

  /// Salva uma despesa no cache
  Future<void> saveExpense(ExpenseModel expense) async {
    final box = await _ensureBox();
    await box.put(expense.id, expense);
  }

  /// Salva múltiplas despesas em lote
  Future<void> saveExpensesBatch(List<ExpenseModel> expenses) async {
    final box = await _ensureBox();
    final map = {for (var e in expenses) e.id: e};
    await box.putAll(map);
  }

  /// Obtém uma despesa por ID
  Future<ExpenseModel?> getExpense(String id) async {
    final box = await _ensureBox();
    return box.get(id);
  }

  /// Obtém todas as despesas não deletadas
  Future<List<ExpenseModel>> getAllExpenses() async {
    final box = await _ensureBox();
    return box.values.where((model) => !model.isDeleted).toList();
  }

  /// Obtém despesas por veículo
  Future<List<ExpenseModel>> getExpensesByVehicle(String vehicleId) async {
    final box = await _ensureBox();
    return box.values
        .where((model) => model.veiculoId == vehicleId && !model.isDeleted)
        .toList();
  }

  /// Obtém despesas por período
  Future<List<ExpenseModel>> getExpensesByPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final box = await _ensureBox();
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    return box.values
        .where(
          (model) =>
              !model.isDeleted && model.data >= startMs && model.data <= endMs,
        )
        .toList();
  }

  /// Obtém despesas por tipo
  Future<List<ExpenseModel>> getExpensesByType(String type) async {
    final box = await _ensureBox();
    return box.values
        .where((model) => model.tipo == type && !model.isDeleted)
        .toList();
  }

  /// Busca despesas por texto (descrição, notas, localização)
  Future<List<ExpenseModel>> searchExpenses(String query) async {
    final box = await _ensureBox();
    final lowerQuery = query.toLowerCase();

    return box.values.where((model) {
      if (model.isDeleted) return false;

      final description = model.descricao.toLowerCase();
      final notes = model.notes?.toLowerCase() ?? '';
      final location = model.location?.toLowerCase() ?? '';

      return description.contains(lowerQuery) ||
          notes.contains(lowerQuery) ||
          location.contains(lowerQuery);
    }).toList();
  }

  /// Marca uma despesa como deletada (soft delete)
  Future<void> deleteExpense(String id) async {
    final box = await _ensureBox();
    final expense = box.get(id);

    if (expense != null) {
      final updated = expense.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      await box.put(id, updated);
    }
  }

  /// Remove permanentemente uma despesa do cache
  Future<void> permanentlyDeleteExpense(String id) async {
    final box = await _ensureBox();
    await box.delete(id);
  }

  /// Limpa despesas antigas (> 90 dias deletadas)
  Future<int> cleanupOldDeletedExpenses() async {
    final box = await _ensureBox();
    final now = DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: 90));

    final toDelete = <String>[];

    for (final model in box.values) {
      if (model.isDeleted && model.updatedAt != null) {
        if (model.updatedAt!.isBefore(cutoffDate)) {
          toDelete.add(model.id);
        }
      }
    }

    await box.deleteAll(toDelete);
    return toDelete.length;
  }

  /// Obtém estatísticas do cache
  Future<CacheStatistics> getStatistics() async {
    final box = await _ensureBox();
    final allExpenses = box.values.toList();

    final active = allExpenses.where((e) => !e.isDeleted).length;
    final deleted = allExpenses.where((e) => e.isDeleted).length;
    final total = allExpenses.length;

    // Calcula tamanho aproximado em bytes
    final sizeInBytes = total * 500; // Estimativa: ~500 bytes por despesa

    return CacheStatistics(
      totalExpenses: total,
      activeExpenses: active,
      deletedExpenses: deleted,
      estimatedSizeBytes: sizeInBytes,
    );
  }

  /// Limpa todo o cache
  Future<void> clearCache() async {
    final box = await _ensureBox();
    await box.clear();
  }

  /// Fecha o box do Hive
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  /// Obtém as N despesas mais recentes
  Future<List<ExpenseModel>> getRecentExpenses({int limit = 10}) async {
    final box = await _ensureBox();
    final expenses = box.values.where((model) => !model.isDeleted).toList()
      ..sort((a, b) => b.data.compareTo(a.data));

    return expenses.take(limit).toList();
  }

  /// Verifica se existe uma despesa com o ID
  Future<bool> existsExpense(String id) async {
    final box = await _ensureBox();
    return box.containsKey(id);
  }

  /// Conta despesas por veículo
  Future<Map<String, int>> countExpensesByVehicle() async {
    final box = await _ensureBox();
    final counts = <String, int>{};

    for (final model in box.values) {
      if (!model.isDeleted) {
        counts[model.veiculoId] = (counts[model.veiculoId] ?? 0) + 1;
      }
    }

    return counts;
  }
}

/// Estatísticas do cache
class CacheStatistics {
  const CacheStatistics({
    required this.totalExpenses,
    required this.activeExpenses,
    required this.deletedExpenses,
    required this.estimatedSizeBytes,
  });

  final int totalExpenses;
  final int activeExpenses;
  final int deletedExpenses;
  final int estimatedSizeBytes;

  double get estimatedSizeMB => estimatedSizeBytes / (1024 * 1024);

  @override
  String toString() {
    return 'CacheStatistics(total: $totalExpenses, active: $activeExpenses, '
        'deleted: $deletedExpenses, size: ${estimatedSizeMB.toStringAsFixed(2)}MB)';
  }
}
