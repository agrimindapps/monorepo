import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';

/// Serviço responsável por converter documentos Firestore em entidades
///
/// Isola a lógica de conversão de dados Firestore,
/// seguindo o princípio Single Responsibility.

class FirestoreExpenseConverter {
  FirestoreExpenseConverter();

  /// Converte um DocumentSnapshot do Firestore em ExpenseEntity
  ExpenseEntity? documentToEntity(DocumentSnapshot doc) {
    try {
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Adiciona o ID ao mapa se não existir
      final dataWithId = {...data};
      if (!dataWithId.containsKey('id')) {
        dataWithId['id'] = doc.id;
      }

      final model = ExpenseModel.fromFirebaseMap(dataWithId);
      return _modelToEntity(model);
    } catch (e) {
      // Log do erro mas não quebra o fluxo
      return null;
    }
  }

  /// Converte uma lista de DocumentSnapshots em lista de ExpenseEntity
  List<ExpenseEntity> documentsToEntities(List<QueryDocumentSnapshot> docs) {
    final entities = <ExpenseEntity>[];

    for (final doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        // Adiciona o ID ao mapa se não existir
        final dataWithId = {...data};
        if (!dataWithId.containsKey('id')) {
          dataWithId['id'] = doc.id;
        }

        final model = ExpenseModel.fromFirebaseMap(dataWithId);
        final entity = _modelToEntity(model);
        entities.add(entity);
      } catch (e) {
        // Continua processando outros documentos
        continue;
      }
    }

    return entities;
  }

  /// Converte ExpenseModel em ExpenseEntity
  ExpenseEntity _modelToEntity(ExpenseModel model) {
    return ExpenseEntity(
      id: model.id,
      vehicleId: model.veiculoId,
      type: _parseExpenseType(model.tipo),
      description: model.descricao,
      amount: model.valor,
      date: DateTime.fromMillisecondsSinceEpoch(model.data),
      odometer: model.odometro,
      receiptImagePath: model.receiptImagePath,
      location: model.location,
      notes: model.notes,
      metadata: model.metadata,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Converte ExpenseEntity em ExpenseModel para persistência
  ExpenseModel entityToModel(ExpenseEntity entity, String userId) {
    return ExpenseModel.create(
      id: entity.id,
      userId: userId,
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

  /// Converte string para ExpenseType enum
  ExpenseType _parseExpenseType(String tipo) {
    try {
      return ExpenseType.values.firstWhere(
        (e) => e.name.toLowerCase() == tipo.toLowerCase(),
        orElse: () => ExpenseType.other,
      );
    } catch (e) {
      return ExpenseType.other;
    }
  }

  /// Converte ExpenseEntity em mapa Firebase
  Map<String, dynamic> entityToFirebaseMap(
    ExpenseEntity entity,
    String userId,
  ) {
    final model = entityToModel(entity, userId);
    return model.toFirebaseMap();
  }

  /// Verifica se um documento contém dados válidos de despesa
  bool isValidExpenseDocument(DocumentSnapshot doc) {
    if (!doc.exists) return false;

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return false;

    // Valida campos obrigatórios
    return data.containsKey('tipo') &&
        data.containsKey('descricao') &&
        data.containsKey('valor') &&
        data.containsKey('data') &&
        data.containsKey('veiculoId');
  }

  /// Extrai ID do usuário de um documento de despesa
  String? extractUserId(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['userId'] as String?;
    } catch (e) {
      return null;
    }
  }
}
