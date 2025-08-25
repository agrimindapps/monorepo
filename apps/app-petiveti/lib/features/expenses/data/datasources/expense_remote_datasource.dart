import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../../domain/entities/expense.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<List<ExpenseModel>> getExpensesByAnimal(String userId, String animalId);
  Future<List<ExpenseModel>> getExpensesByDateRange(String userId, DateTime startDate, DateTime endDate);
  Future<List<ExpenseModel>> getExpensesByCategory(String userId, ExpenseCategory category);
  Future<ExpenseModel?> getExpenseById(String id);
  Future<String> addExpense(ExpenseModel expense, String userId);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Stream<List<ExpenseModel>> streamExpenses(String userId);
  Stream<ExpenseModel?> streamExpense(String id);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseService _firebaseService;

  ExpenseRemoteDataSourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    try {
      final expenses = await _firebaseService.getCollection<ExpenseModel>(
        FirebaseCollections.expenses,
        where: [
          WhereCondition('userId', isEqualTo: userId),
        ],
        orderBy: [
          const OrderByCondition('date', descending: true),
        ],
        fromMap: ExpenseModel.fromMap,
      );
      
      return expenses;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar despesas do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByAnimal(String userId, String animalId) async {
    try {
      final expenses = await _firebaseService.getCollection<ExpenseModel>(
        FirebaseCollections.expenses,
        where: [
          WhereCondition('userId', isEqualTo: userId),
          WhereCondition('animalId', isEqualTo: animalId),
        ],
        orderBy: [
          const OrderByCondition('date', descending: true),
        ],
        fromMap: ExpenseModel.fromMap,
      );
      
      return expenses;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar despesas por animal do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final expenses = await _firebaseService.getCollection<ExpenseModel>(
        FirebaseCollections.expenses,
        where: [
          WhereCondition('userId', isEqualTo: userId),
          WhereCondition('date', isGreaterThanOrEqualTo: startDate.toIso8601String()),
          WhereCondition('date', isLessThanOrEqualTo: endDate.toIso8601String()),
        ],
        orderBy: [
          const OrderByCondition('date', descending: true),
        ],
        fromMap: ExpenseModel.fromMap,
      );
      
      return expenses;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar despesas por período do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(String userId, ExpenseCategory category) async {
    try {
      final expenses = await _firebaseService.getCollection<ExpenseModel>(
        FirebaseCollections.expenses,
        where: [
          WhereCondition('userId', isEqualTo: userId),
          WhereCondition('category', isEqualTo: category.name),
        ],
        orderBy: [
          const OrderByCondition('date', descending: true),
        ],
        fromMap: ExpenseModel.fromMap,
      );
      
      return expenses;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar despesas por categoria do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final expense = await _firebaseService.getDocument<ExpenseModel>(
        FirebaseCollections.expenses,
        id,
        ExpenseModel.fromMap,
      );
      
      return expense;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar despesa do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> addExpense(ExpenseModel expense, String userId) async {
    try {
      final expenseData = expense.copyWith(
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final id = await _firebaseService.addDocument<ExpenseModel>(
        FirebaseCollections.expenses,
        expenseData,
        (expense) => expense.toMap(),
      );
      
      return id;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao adicionar despesa no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final updatedExpense = expense.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.setDocument<ExpenseModel>(
        FirebaseCollections.expenses,
        expense.id,
        updatedExpense,
        (expense) => expense.toMap(),
        merge: true,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao atualizar despesa no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _firebaseService.deleteDocument(
        FirebaseCollections.expenses,
        id,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao deletar despesa do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<ExpenseModel>> streamExpenses(String userId) {
    try {
      return _firebaseService.streamCollection<ExpenseModel>(
        FirebaseCollections.expenses,
        where: [
          WhereCondition('userId', isEqualTo: userId),
        ],
        orderBy: [
          const OrderByCondition('date', descending: true),
        ],
        fromMap: ExpenseModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao escutar despesas do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<ExpenseModel?> streamExpense(String id) {
    try {
      return _firebaseService.streamDocument<ExpenseModel>(
        FirebaseCollections.expenses,
        id,
        ExpenseModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao escutar despesa do servidor: ${e.toString()}',
      );
    }
  }
}