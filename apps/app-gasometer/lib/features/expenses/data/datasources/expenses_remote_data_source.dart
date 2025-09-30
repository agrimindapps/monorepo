import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';

abstract class ExpensesRemoteDataSource {
  Future<List<ExpenseEntity>> getAllExpenses(String userId);
  Future<List<ExpenseEntity>> getExpensesByVehicle(String userId, String vehicleId);
  Future<ExpenseEntity?> getExpenseById(String userId, String id);
  Future<ExpenseEntity> addExpense(String userId, ExpenseEntity expense);
  Future<ExpenseEntity> updateExpense(String userId, ExpenseEntity expense);
  Future<void> deleteExpense(String userId, String id);
  Future<List<ExpenseEntity>> searchExpenses(String userId, String query);
  Stream<List<ExpenseEntity>> watchExpenses(String userId);
  Stream<List<ExpenseEntity>> watchExpensesByVehicle(String userId, String vehicleId);
}

@LazySingleton(as: ExpensesRemoteDataSource)
class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {

  ExpensesRemoteDataSourceImpl(this._firestore);
  final FirebaseFirestore _firestore;
  static const String _collection = 'expenses';

  CollectionReference _getUserExpensesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collection);
  }

  @override
  Future<List<ExpenseEntity>> getAllExpenses(String userId) async {
    try {
      final QuerySnapshot snapshot = await _getUserExpensesCollection(userId)
          .orderBy('date', descending: true)
          .get();

      final entities = <ExpenseEntity>[];
      for (final doc in snapshot.docs) {
        final entity = _documentToEntity(doc);
        if (entity != null) entities.add(entity);
      }
      return entities;
    } catch (e) {
      throw ServerException('Failed to fetch expenses from remote: $e');
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByVehicle(String userId, String vehicleId) async {
    try {
      final QuerySnapshot snapshot = await _getUserExpensesCollection(userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('date', descending: true)
          .get();

      final entities = <ExpenseEntity>[];
      for (final doc in snapshot.docs) {
        final entity = _documentToEntity(doc);
        if (entity != null) entities.add(entity);
      }
      return entities;
    } catch (e) {
      throw ServerException('Failed to fetch expenses by vehicle from remote: $e');
    }
  }

  @override
  Future<ExpenseEntity?> getExpenseById(String userId, String id) async {
    try {
      final DocumentSnapshot doc = await _getUserExpensesCollection(userId).doc(id).get();
      return _documentToEntity(doc);
    } catch (e) {
      throw ServerException('Failed to fetch expense by id from remote: $e');
    }
  }

  @override
  Future<ExpenseEntity> addExpense(String userId, ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.create(
        id: expense.id,
        userId: userId,
        veiculoId: expense.vehicleId,
        tipo: expense.type.name,
        descricao: expense.description,
        valor: expense.amount,
        data: expense.date.millisecondsSinceEpoch,
        odometro: expense.odometer,
        receiptImagePath: expense.receiptImagePath,
        location: expense.location,
        notes: expense.notes,
        metadata: expense.metadata,
      );
      
      final docRef = _getUserExpensesCollection(userId).doc(expense.id);
      await docRef.set(model.toFirebaseMap());
      
      // Return the same entity since we're using the provided ID
      return expense;
    } catch (e) {
      throw ServerException('Failed to add expense to remote: $e');
    }
  }

  @override
  Future<ExpenseEntity> updateExpense(String userId, ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.create(
        id: expense.id,
        userId: userId,
        veiculoId: expense.vehicleId,
        tipo: expense.type.name,
        descricao: expense.description,
        valor: expense.amount,
        data: expense.date.millisecondsSinceEpoch,
        odometro: expense.odometer,
        receiptImagePath: expense.receiptImagePath,
        location: expense.location,
        notes: expense.notes,
        metadata: expense.metadata,
      );
      
      await _getUserExpensesCollection(userId)
          .doc(expense.id)
          .update(model.toFirebaseMap());
      
      return expense;
    } catch (e) {
      throw ServerException('Failed to update expense in remote: $e');
    }
  }

  @override
  Future<void> deleteExpense(String userId, String id) async {
    try {
      await _getUserExpensesCollection(userId).doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete expense from remote: $e');
    }
  }

  @override
  Future<List<ExpenseEntity>> searchExpenses(String userId, String query) async {
    try {
      // Firebase text search is limited, so we'll fetch all and filter locally
      final allExpenses = await getAllExpenses(userId);
      final lowercaseQuery = query.toLowerCase();
      
      return allExpenses.where((expense) {
        return expense.description.toLowerCase().contains(lowercaseQuery) ||
               expense.type.name.toLowerCase().contains(lowercaseQuery) ||
               (expense.location?.toLowerCase().contains(lowercaseQuery) ?? false) ||
               (expense.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to search expenses in remote: $e');
    }
  }

  @override
  Stream<List<ExpenseEntity>> watchExpenses(String userId) {
    try {
      return _getUserExpensesCollection(userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        final entities = <ExpenseEntity>[];
        for (final doc in snapshot.docs) {
          final entity = _documentToEntity(doc);
          if (entity != null) entities.add(entity);
        }
        return entities;
      });
    } catch (e) {
      throw ServerException('Failed to watch expenses from remote: $e');
    }
  }

  @override
  Stream<List<ExpenseEntity>> watchExpensesByVehicle(String userId, String vehicleId) {
    try {
      return _getUserExpensesCollection(userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        final entities = <ExpenseEntity>[];
        for (final doc in snapshot.docs) {
          final entity = _documentToEntity(doc);
          if (entity != null) entities.add(entity);
        }
        return entities;
      });
    } catch (e) {
      throw ServerException('Failed to watch expenses by vehicle from remote: $e');
    }
  }

  ExpenseEntity? _documentToEntity(DocumentSnapshot doc) {
    try {
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;
      
      final model = ExpenseModel.fromFirebaseMap(data);
      return _modelToEntity(model);
    } catch (e) {
      // Log the error but don't throw to avoid breaking the entire list
      print('Error converting document to expense entity: $e');
      return null;
    }
  }

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
}