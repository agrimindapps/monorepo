import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Configurações de consulta Firebase
class WhereCondition {
  final String field;
  final dynamic value;
  final String operator;

  const WhereCondition(
    this.field, {
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    List<dynamic>? arrayContains,
    List<dynamic>? arrayContainsAny,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
  }) : value = isEqualTo ?? isNotEqualTo ?? isLessThan ?? isLessThanOrEqualTo ?? 
              isGreaterThan ?? isGreaterThanOrEqualTo ?? arrayContains ?? 
              arrayContainsAny ?? whereIn ?? whereNotIn ?? isNull,
       operator = isEqualTo != null ? '==' :
                 isNotEqualTo != null ? '!=' :
                 isLessThan != null ? '<' :
                 isLessThanOrEqualTo != null ? '<=' :
                 isGreaterThan != null ? '>' :
                 isGreaterThanOrEqualTo != null ? '>=' :
                 arrayContains != null ? 'array-contains' :
                 arrayContainsAny != null ? 'array-contains-any' :
                 whereIn != null ? 'in' :
                 whereNotIn != null ? 'not-in' :
                 isNull != null ? 'isNull' : '==';
}

class OrderByCondition {
  final String field;
  final bool descending;

  const OrderByCondition(this.field, {this.descending = false});
}

/// Serviço centralizado para operações Firebase
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Obtém documento único por ID
  Future<T?> getDocument<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic>) fromMap,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return fromMap(doc.data()!);
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Erro ao buscar documento: ${e.toString()}',
        code: 'get-document-error',
      );
    }
  }

  /// Obtém coleção completa com filtros opcionais
  Future<List<T>> getCollection<T>(
    String collection, {
    List<WhereCondition>? where,
    List<OrderByCondition>? orderBy,
    int? limit,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Aplicar filtros WHERE
      if (where != null) {
        for (final condition in where) {
          query = _applyWhereCondition(query, condition);
        }
      }

      // Aplicar ordenação
      if (orderBy != null) {
        for (final order in orderBy) {
          query = query.orderBy(order.field, descending: order.descending);
        }
      }

      // Aplicar limite
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => fromMap({...(doc.data() as Map<String, dynamic>? ?? {}), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Erro ao buscar coleção: ${e.toString()}',
        code: 'get-collection-error',
      );
    }
  }

  /// Cria ou atualiza documento
  Future<void> setDocument<T>(
    String collection,
    String documentId,
    T data,
    Map<String, dynamic> Function(T) toMap, {
    bool merge = false,
  }) async {
    try {
      final docData = toMap(data);
      docData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(collection).doc(documentId).set(
        docData,
        SetOptions(merge: merge),
      );
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Erro ao salvar documento: ${e.toString()}',
        code: 'set-document-error',
      );
    }
  }

  /// Adiciona documento com ID automático
  Future<String> addDocument<T>(
    String collection,
    T data,
    Map<String, dynamic> Function(T) toMap,
  ) async {
    try {
      final docData = toMap(data);
      docData['createdAt'] = FieldValue.serverTimestamp();
      docData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore.collection(collection).add(docData);
      return docRef.id;
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Erro ao adicionar documento: ${e.toString()}',
        code: 'add-document-error',
      );
    }
  }

  /// Atualiza campos específicos de um documento
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Erro ao atualizar documento: ${e.toString()}',
        code: 'update-document-error',
      );
    }
  }

  /// Deleta documento
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Erro ao deletar documento: ${e.toString()}',
        code: 'delete-document-error',
      );
    }
  }

  /// Stream de documento único
  Stream<T?> streamDocument<T>(
    String collection,
    String documentId,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return fromMap({...snapshot.data()!, 'id': snapshot.id});
    });
  }

  /// Stream de coleção com filtros
  Stream<List<T>> streamCollection<T>(
    String collection, {
    List<WhereCondition>? where,
    List<OrderByCondition>? orderBy,
    int? limit,
    required T Function(Map<String, dynamic>) fromMap,
  }) {
    Query query = _firestore.collection(collection);

    // Aplicar filtros WHERE
    if (where != null) {
      for (final condition in where) {
        query = _applyWhereCondition(query, condition);
      }
    }

    // Aplicar ordenação
    if (orderBy != null) {
      for (final order in orderBy) {
        query = query.orderBy(order.field, descending: order.descending);
      }
    }

    // Aplicar limite
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => fromMap({...(doc.data() as Map<String, dynamic>? ?? {}), 'id': doc.id}))
          .toList();
    });
  }

  /// Executa transação batch
  Future<void> executeBatch(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final docRef = _firestore.collection(operation.collection).doc(operation.documentId);
        
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(docRef, operation.data!, SetOptions(merge: operation.merge));
            break;
          case BatchOperationType.update:
            batch.update(docRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Erro ao executar batch: ${e.toString()}',
        code: 'batch-error',
      );
    }
  }

  /// Aplicar condição WHERE específica
  Query _applyWhereCondition(Query query, WhereCondition condition) {
    switch (condition.operator) {
      case '==':
        return query.where(condition.field, isEqualTo: condition.value);
      case '!=':
        return query.where(condition.field, isNotEqualTo: condition.value);
      case '<':
        return query.where(condition.field, isLessThan: condition.value);
      case '<=':
        return query.where(condition.field, isLessThanOrEqualTo: condition.value);
      case '>':
        return query.where(condition.field, isGreaterThan: condition.value);
      case '>=':
        return query.where(condition.field, isGreaterThanOrEqualTo: condition.value);
      case 'array-contains':
        return query.where(condition.field, arrayContains: condition.value);
      case 'array-contains-any':
        return query.where(condition.field, arrayContainsAny: (condition.value as Iterable<Object?>?) ?? []);
      case 'in':
        return query.where(condition.field, whereIn: (condition.value as Iterable<Object?>?) ?? []);
      case 'not-in':
        return query.where(condition.field, whereNotIn: (condition.value as Iterable<Object?>?) ?? []);
      case 'isNull':
        return query.where(condition.field, isNull: (condition.value as bool?) ?? false);
      default:
        return query.where(condition.field, isEqualTo: condition.value);
    }
  }

  /// Obtém usuário autenticado atual
  User? get currentUser => _auth.currentUser;

  /// Obtém ID do usuário atual
  String? get currentUserId => _auth.currentUser?.uid;
}

/// Tipos de operações batch
enum BatchOperationType { set, update, delete }

/// Operação para batch
class BatchOperation {
  final String collection;
  final String documentId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;
  final bool merge;

  const BatchOperation({
    required this.collection,
    required this.documentId,
    required this.type,
    this.data,
    this.merge = false,
  });
}

/// Nomes das coleções Firebase
class FirebaseCollections {
  static const String animals = 'animals';
  static const String appointments = 'appointments';
  static const String medications = 'medications';
  static const String vaccines = 'vaccines';
  static const String weights = 'weights';
  static const String reminders = 'reminders';
  static const String expenses = 'expenses';
  static const String users = 'users';
  static const String subscriptions = 'subscriptions';
}