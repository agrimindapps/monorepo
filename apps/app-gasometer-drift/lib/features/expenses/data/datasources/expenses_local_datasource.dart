import 'package:injectable/injectable.dart';
import '../../../../database/repositories/expense_repository.dart';

/// DataSource local para despesas usando Drift
@lazySingleton
class ExpensesLocalDataSource {
  const ExpensesLocalDataSource(this._repository);

  final ExpenseRepository _repository;

  // ========== CRUD BÁSICO ==========

  Future<int> create({
    required String userId,
    required int vehicleId,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    String? notes,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) async {
    final now = DateTime.now();
    final expenseData = ExpenseData(
      id: 0, // Auto-increment
      userId: userId,
      moduleName: 'gasometer',
      vehicleId: vehicleId,
      createdAt: now,
      updatedAt: now,
      lastSyncAt: null,
      isDirty: true,
      isDeleted: false,
      version: 1,
      description: description,
      amount: amount,
      date: date.millisecondsSinceEpoch,
      category: category,
      notes: notes,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );

    return await _repository.insert(expenseData);
  }

  Future<ExpenseData?> findById(int id) async {
    return await _repository.findById(id);
  }

  Future<List<ExpenseData>> findAll() async {
    return await _repository.findAll();
  }

  Stream<List<ExpenseData>> watchAll() {
    return _repository.watchAll();
  }

  Future<List<ExpenseData>> findByVehicleId(int vehicleId) async {
    return await _repository.findByVehicleId(vehicleId);
  }

  Stream<List<ExpenseData>> watchByVehicleId(int vehicleId) {
    return _repository.watchByVehicleId(vehicleId);
  }

  Future<List<ExpenseData>> findByCategory(
    int vehicleId,
    String category,
  ) async {
    final allData = await _repository.findByVehicleId(vehicleId);
    return allData.where((data) => data.category == category).toList();
  }

  Future<List<ExpenseData>> findByPeriod(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allData = await _repository.findByVehicleId(vehicleId);
    return allData.where((data) {
      final expenseDate = DateTime.fromMillisecondsSinceEpoch(data.date);
      return expenseDate.isAfter(startDate) && expenseDate.isBefore(endDate);
    }).toList();
  }

  Future<List<ExpenseData>> search(int vehicleId, String query) async {
    final allData = await _repository.findByVehicleId(vehicleId);
    final lowerQuery = query.toLowerCase();
    return allData
        .where(
          (data) =>
              data.description.toLowerCase().contains(lowerQuery) ||
              data.category.toLowerCase().contains(lowerQuery) ||
              (data.notes?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }

  Future<bool> update({
    required int id,
    required String userId,
    required int vehicleId,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    String? notes,
    String? receiptImageUrl,
    String? receiptImagePath,
  }) async {
    // Buscar registro existente para preservar campos
    final existing = await _repository.findById(id);
    if (existing == null) return false;

    final expenseData = ExpenseData(
      id: id,
      userId: userId,
      moduleName: existing.moduleName,
      vehicleId: vehicleId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      lastSyncAt: existing.lastSyncAt,
      isDirty: true,
      isDeleted: existing.isDeleted,
      version: existing.version + 1,
      description: description,
      amount: amount,
      date: date.millisecondsSinceEpoch,
      category: category,
      notes: notes,
      receiptImageUrl: receiptImageUrl,
      receiptImagePath: receiptImagePath,
    );

    return await _repository.update(expenseData);
  }

  Future<bool> delete(int id) async {
    return await _repository.softDelete(id);
  }

  // ========== ESTATÍSTICAS ==========

  Future<double> calculateTotalAmount(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dataList = await _repository.findByVehicleId(vehicleId);
    var filteredData = dataList;

    if (startDate != null && endDate != null) {
      filteredData = dataList.where((data) {
        final expenseDate = DateTime.fromMillisecondsSinceEpoch(data.date);
        return expenseDate.isAfter(startDate) && expenseDate.isBefore(endDate);
      }).toList();
    }

    return filteredData.fold<double>(0.0, (sum, data) => sum + data.amount);
  }

  Future<Map<String, double>> getExpensesByCategory(int vehicleId) async {
    return await _repository.getExpensesByCategory(vehicleId);
  }

  Future<int> countByVehicleId(int vehicleId) async {
    return await _repository.countByVehicleId(vehicleId);
  }

  Future<List<String>> findDistinctCategories(int vehicleId) async {
    return await _repository.findDistinctCategories(vehicleId);
  }

  Future<List<ExpenseData>> findRecent(int vehicleId, {int limit = 10}) async {
    return await _repository.findRecent(vehicleId, limit: limit);
  }

  Future<ExpenseData?> findLastByVehicle(int vehicleId) async {
    final recent = await _repository.findRecent(vehicleId, limit: 1);
    return recent.isNotEmpty ? recent.first : null;
  }

  // ========== SINCRONIZAÇÃO ==========

  Future<List<ExpenseData>> findDirtyRecords() async {
    return await _repository.findDirtyRecords();
  }

  Future<void> markAsSynced(List<int> expenseIds) async {
    return await _repository.markAsSynced(expenseIds);
  }
}
