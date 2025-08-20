// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../models/15_medicamento_model.dart';

class MedicamentoRepository {
  // MARK: - Constants
  static const String _boxName = 'box_vet_medicamentos';
  static const String collectionName = 'box_vet_medicamentos';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Box<MedicamentoVet> get _box => Hive.box<MedicamentoVet>(_boxName);

  // MARK: - Constructor
  MedicamentoRepository();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<MedicamentoVet>> getMedicamentos(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) =>
      _getAll(animalId, dataInicial: dataInicial, dataFinal: dataFinal);
  Future<MedicamentoVet?> getMedicamentoById(String id) => _getById(id);
  Future<bool> addMedicamento(MedicamentoVet medicamento) => _add(medicamento);
  Future<bool> updateMedicamento(MedicamentoVet medicamento) =>
      _update(medicamento);
  Future<bool> deleteMedicamento(MedicamentoVet medicamento) =>
      _delete(medicamento);
  Future<String> exportToCsv(String animalId) => _exportToCsv(animalId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(15)) {
        Hive.registerAdapter(MedicamentoVetAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing MedicamentoRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<MedicamentoVet>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - CRUD Operations
  Future<List<MedicamentoVet>> _getAll(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      await _openBox();
      return _box.values
          .where((medicamento) =>
              medicamento.animalId == animalId &&
              !medicamento.isDeleted &&
              (dataInicial == null ||
                  medicamento.inicioTratamento >= dataInicial) &&
              (dataFinal == null || medicamento.inicioTratamento <= dataFinal))
          .toList()
        ..sort((a, b) => b.inicioTratamento.compareTo(a.inicioTratamento));
    } catch (e) {
      debugPrint('Error getting medicamentos: $e');
      return [];
    } finally {
      await _closeBox();
    }
  }

  Future<MedicamentoVet?> _getById(String id) async {
    try {
      await _openBox();
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting Medicamento by ID: $e');
      return null;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(MedicamentoVet medicamento) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(medicamento);

      // Cria o registro no Firebase e captura o objectId retornado
      final String newObjectId = await _firestore.createRecord(
        collection: collectionName,
        data: medicamento.toMap(),
      );

      // The id field should already be set in BaseModel, no need to update objectId
      await _box.put(key, medicamento);

      return true;
    } catch (e) {
      debugPrint('Error adding Medicamento: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(MedicamentoVet medicamento) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == medicamento.id);

      if (index != -1) {
        // Atualiza updatedAt com o timestamp atual (em microsegundos)
        medicamento.updatedAt = DateTime.now().millisecondsSinceEpoch;

        // Atualiza o registro no Hive
        await _box.putAt(index, medicamento);
        // Atualiza o registro no Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: medicamento.id,
          data: medicamento.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Medicamento: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(MedicamentoVet medicamento) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == medicamento.id);

      if (index != -1) {
        // Marca o registro como deletado e atualiza updatedAt
        medicamento.isDeleted = true;
        medicamento.updatedAt = DateTime.now().millisecondsSinceEpoch;

        // Atualiza o registro no Hive
        await _box.putAt(index, medicamento);
        // Envia a atualização para o Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: medicamento.id,
          data: medicamento.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Medicamento: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv(String animalId) async {
    try {
      await _openBox();
      final medicamentos = _box.values
          .where((medicamento) =>
              medicamento.animalId == animalId && !medicamento.isDeleted)
          .toList();

      // Define CSV header with relevant fields
      const csvHeader =
          'Nome do Medicamento,Dosagem,Frequência,Duração,Início do Tratamento,Fim do Tratamento,Observações\n';

      // Convert each medicamento to a CSV row
      final csvRows = medicamentos.map((medicamento) {
        final nomeMedicamento = _escapeField(medicamento.nomeMedicamento);
        final dosagem = _escapeField(medicamento.dosagem);
        final frequencia = _escapeField(medicamento.frequencia);
        final duracao = _escapeField(medicamento.duracao);

        // Format dates from timestamp to readable format
        final inicioTratamento = _escapeField(DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento)));

        final fimTratamento = _escapeField(DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento)));

        final observacoes = _escapeField(medicamento.observacoes ?? '');

        return '$nomeMedicamento,$dosagem,$frequencia,$duracao,$inicioTratamento,$fimTratamento,$observacoes';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting medicamentos to CSV: $e');
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
