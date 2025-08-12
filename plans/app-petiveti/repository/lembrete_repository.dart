// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../models/14_lembrete_model.dart';

class LembreteRepository {
  // MARK: - Constants
  static const String _boxName = 'box_vet_lembrete';
  static const String collectionName = 'box_vet_lembrete';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Box<LembreteVet> get _box => Hive.box<LembreteVet>(_boxName);

  // MARK: - Constructor
  LembreteRepository();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<LembreteVet>> getLembretes(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) =>
      _getAll(animalId, dataInicial: dataInicial, dataFinal: dataFinal);
  Future<LembreteVet?> getLembreteById(String id) => _getById(id);
  Future<bool> addLembrete(LembreteVet lembrete) => _add(lembrete);
  Future<bool> updateLembrete(LembreteVet lembrete) => _update(lembrete);
  Future<bool> deleteLembrete(LembreteVet lembrete) => _delete(lembrete);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(14)) {
        Hive.registerAdapter(LembreteVetAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing LembreteRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<LembreteVet>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - CRUD Operations
  Future<List<LembreteVet>> _getAll(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      await _openBox();
      return _box.values
          .where((lembrete) =>
              lembrete.animalId == animalId &&
              !lembrete.isDeleted &&
              (dataInicial == null || lembrete.dataHora >= dataInicial) &&
              (dataFinal == null || lembrete.dataHora <= dataFinal))
          .toList()
        ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
    } catch (e) {
      debugPrint('Error getting lembretes: $e');
      return [];
    } finally {
      await _closeBox();
    }
  }

  Future<LembreteVet?> _getById(String id) async {
    try {
      await _openBox();
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting Lembrete by ID: $e');
      return null;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(LembreteVet lembrete) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(lembrete);

      // Cria o registro no Firebase e captura o objectId retornado
      final String newObjectId = await _firestore.createRecord(
        collection: collectionName,
        data: lembrete.toMap(),
      );

      // The id field should already be set in BaseModel, no need to update objectId
      await _box.put(key, lembrete);

      return true;
    } catch (e) {
      debugPrint('Error adding Lembrete: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(LembreteVet lembrete) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == lembrete.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com a data/hora atual (em microsegundos)
        lembrete.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, lembrete);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: lembrete.id,
          data: lembrete.toMap(),
        );

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Lembrete: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(LembreteVet lembrete) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == lembrete.id);

      if (index != -1) {
        // Define o registro como deletado e atualiza o campo updatedAt
        lembrete.isDeleted = true;
        lembrete.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, lembrete);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: lembrete.id,
          data: lembrete.toMap(),
        );

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Lembrete: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }
}
