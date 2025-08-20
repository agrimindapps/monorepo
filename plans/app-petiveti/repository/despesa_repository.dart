// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../models/13_despesa_model.dart';

class DespesaRepository {
  // MARK: - Constants
  static const String _boxName = 'box_vet_despesas';
  static const String collectionName = 'box_vet_despesas';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Box<DespesaVet> get _box => Hive.box<DespesaVet>(_boxName);

  // MARK: - Constructor
  DespesaRepository();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<DespesaVet>> getDespesas(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) =>
      _getAll(animalId, dataInicial: dataInicial, dataFinal: dataFinal);
  Future<DespesaVet?> getDespesaById(String id) => _getById(id);
  Future<bool> addDespesa(DespesaVet despesa) => _add(despesa);
  Future<bool> updateDespesa(DespesaVet despesa) => _update(despesa);
  Future<bool> deleteDespesa(DespesaVet despesa) => _delete(despesa);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(DespesaVetAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing DespesaRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<DespesaVet>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - CRUD Operations
  Future<List<DespesaVet>> _getAll(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      await _openBox();
      return _box.values
          .where((despesa) =>
              despesa.animalId == animalId &&
              !despesa.isDeleted &&
              (dataInicial == null || despesa.dataDespesa >= dataInicial) &&
              (dataFinal == null || despesa.dataDespesa <= dataFinal))
          .toList()
        ..sort((a, b) => b.dataDespesa.compareTo(a.dataDespesa));
    } catch (e) {
      debugPrint('Error getting despesas: $e');
      return [];
    } finally {
      await _closeBox();
    }
  }

  Future<DespesaVet?> _getById(String id) async {
    try {
      await _openBox();
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting Despesa by ID: $e');
      return null;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(DespesaVet despesa) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(despesa);

      // Cria o registro no Firebase e captura o objectId retornado
      final String newObjectId = await _firestore.createRecord(
        collection: collectionName,
        data: despesa.toMap(),
      );

      // The id field should already be set in BaseModel, no need to update objectId
      await _box.put(key, despesa);

      return true;
    } catch (e) {
      debugPrint('Error adding Despesa: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(DespesaVet despesa) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == despesa.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com a data/hora atual (em microsegundos)
        despesa.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, despesa);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: despesa.id,
          data: despesa.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Despesa: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(DespesaVet despesa) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == despesa.id);

      if (index != -1) {
        // Define o registro como deletado e atualiza o campo updatedAt
        despesa.isDeleted = true;
        despesa.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, despesa);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: despesa.id,
          data: despesa.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Despesa: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }
}
