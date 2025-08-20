// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../models/17_peso_model.dart';

class PesoRepository {
  // MARK: - Constants
  static const String _boxName = 'box_vet_pesos';
  static const String collectionName = 'box_vet_pesos';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Box<PesoAnimal> get _box => Hive.box<PesoAnimal>(_boxName);

  // MARK: - Constructor
  PesoRepository();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<PesoAnimal>> getPesos(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) =>
      _getAll(animalId, dataInicial: dataInicial, dataFinal: dataFinal);
  Future<PesoAnimal?> getPesoById(String id) => _getById(id);
  Future<bool> addPeso(PesoAnimal peso) => _add(peso);
  Future<bool> updatePeso(PesoAnimal peso) => _update(peso);
  Future<bool> deletePeso(PesoAnimal peso) => _delete(peso);
  Future<String> exportToCsv(String animalId) => _exportToCsv(animalId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(17)) {
        Hive.registerAdapter(PesoAnimalAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing PesoRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<PesoAnimal>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - CRUD Operations
  Future<List<PesoAnimal>> _getAll(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      await _openBox();
      return _box.values
          .where((peso) =>
              peso.animalId == animalId &&
              !peso.isDeleted &&
              (dataInicial == null || peso.dataPesagem >= dataInicial) &&
              (dataFinal == null || peso.dataPesagem <= dataFinal))
          .toList()
        ..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
    } catch (e) {
      debugPrint('Error getting pesos: $e');
      return [];
    } finally {
      await _closeBox();
    }
  }

  Future<PesoAnimal?> _getById(String id) async {
    try {
      await _openBox();
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting Peso by ID: $e');
      return null;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(PesoAnimal peso) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(peso);

      // Cria o registro no Firebase e captura o objectId retornado
      final String newObjectId = await _firestore.createRecord(
        collection: collectionName,
        data: peso.toMap(),
      );

      // The id field should already be set in BaseModel, no need to update objectId
      await _box.put(key, peso);

      return true;
    } catch (e) {
      debugPrint('Error adding Peso: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(PesoAnimal peso) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == peso.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com a data/hora atual (em microsegundos)
        peso.updatedAt = DateTime.now().millisecondsSinceEpoch;

        // Atualiza o registro no Hive
        await _box.putAt(index, peso);

        // Envia a atualização para o Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: peso.id,
          data: peso.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Peso: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(PesoAnimal peso) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == peso.id);

      if (index != -1) {
        // Marca o registro como deletado e atualiza o campo updatedAt
        peso.isDeleted = true;
        peso.updatedAt = DateTime.now().millisecondsSinceEpoch;

        // Atualiza o registro no Hive
        await _box.putAt(index, peso);

        // Envia a atualização para o Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: peso.id,
          data: peso.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Peso: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv(String animalId) async {
    try {
      await _openBox();
      final pesos = _box.values
          .where((peso) => peso.animalId == animalId && !peso.isDeleted)
          .toList()
        ..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));

      // Define CSV header with relevant fields
      const csvHeader = 'Data da Pesagem,Peso (kg),Observações\n';

      // Convert each peso record to a CSV row
      final csvRows = pesos.map((peso) {
        // Format date from timestamp to readable format
        final dataPesagem = _escapeField(DateFormat('dd/MM/yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem)));

        final pesoEmKg = peso.peso.toStringAsFixed(2);
        final observacoes = _escapeField(peso.observacoes ?? '');

        return '$dataPesagem,$pesoEmKg,$observacoes';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting pesos to CSV: $e');
      return '';
    } finally {
      await _closeBox();
    }
  }

  // Helper to escape fields that may contain commas, quotes, or newlines
  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Replace double quotes with two double quotes and wrap in quotes
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
