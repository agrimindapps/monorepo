// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart' as drift;

// Project imports:
import '../../../../core/services/firebase_firestore_service.dart';
import '../../../../drift_database/nutrituti_database.dart';
import '../../../../drift_database/daos/peso_dao.dart';
import '../../../../drift_database/tables/pesos_table.dart';
import '../models/peso_model.dart';

@injectable
class PesoRepository {
  static const String collectionName = 'box_peso';
  final FirestoreService _firestore;
  final NutitutiDatabase _database;

  // Observable state
  final ValueNotifier<List<PesoModel>> pesos = ValueNotifier([]);

  PesoRepository(this._firestore, this._database);

  PesoDao get _dao => _database.pesoDao;

  Future<List<PesoModel>> getAll() async {
    try {
      final String perfilId = ''; // TODO: Get from auth/perfil
      final registros = await _dao.getAllPesos(perfilId);
      final models = registros.map(_fromDrift).toList();
      pesos.value = models;
      return models;
    } catch (e) {
      debugPrint('Error getting registros: $e');
      return [];
    }
  }

  Future<PesoModel?> get(String id) async {
    try {
      final peso = await _dao.getPesoById(id);
      return peso != null ? _fromDrift(peso) : null;
    } catch (e) {
      debugPrint('Error getting Peso by ID: $e');
      return null;
    }
  }

  Future<void> add(PesoModel registro) async {
    try {
      await _dao.createPeso(_toCompanion(registro));
      await _firestore.createRecord(
        collectionName,
        registro.toMap(),
      );
      await getAll(); // Update observable list
    } catch (e) {
      debugPrint('Error adding Peso: $e');
    }
  }

  Future<void> updated(PesoModel registro) async {
    try {
      await _dao.updatePeso(registro.id ?? '', _toCompanion(registro));
      await _firestore.updateRecord(
        collectionName,
        registro.id ?? '',
        registro.toMap(),
      );
      await getAll(); // Update observable list
    } catch (e) {
      debugPrint('Error updating Peso: $e');
    }
  }

  Future<void> delete(PesoModel registro) async {
    try {
      await _dao.softDeletePeso(registro.id ?? '');
      final deletedModel = registro.markAsDeleted();
      await _firestore.updateRecord(
        collectionName,
        registro.id ?? '',
        deletedModel.toMap(),
      );
      await getAll(); // Update observable list
    } catch (e) {
      debugPrint('Error deleting Peso: $e');
    }
  }

  Future<void> initialize() async {
    await getAll(); // Load initial data
  }

  void dispose() {
    pesos.dispose();
  }

  // Conversion methods
  PesoModel _fromDrift(Peso peso) {
    return PesoModel(
      id: peso.id,
      createdAt: peso.createdAt,
      updatedAt: peso.updatedAt,
      dataRegistro: peso.dataRegistro,
      peso: peso.peso,
      fkIdPerfil: peso.fkIdPerfil,
      isDeleted: peso.isDeleted,
    );
  }

  PesosCompanion _toCompanion(PesoModel model) {
    return PesosCompanion(
      id: drift.Value(model.id ?? ''),
      dataRegistro: drift.Value(model.dataRegistro),
      peso: drift.Value(model.peso),
      fkIdPerfil: drift.Value(model.fkIdPerfil),
      isDeleted: drift.Value(model.isDeleted),
      createdAt: model.createdAt != null 
        ? drift.Value(model.createdAt!) 
        : const drift.Value.absent(),
      updatedAt: model.updatedAt != null 
        ? drift.Value(model.updatedAt!) 
        : drift.Value(DateTime.now()),
    );
  }
}
