// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../models/12_consulta_model.dart';

class ConsultaRepository {
  // MARK: - Constants
  static const String _boxName = 'box_vet_consultas';
  static const String collectionName = 'box_vet_consultas';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Box<Consulta> get _box => Hive.box<Consulta>(_boxName);

  // MARK: - Singleton Implementation
  static final ConsultaRepository _instance = ConsultaRepository._internal();
  factory ConsultaRepository() => _instance;
  ConsultaRepository._internal();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<Consulta>> getConsultas(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) =>
      _getAll(animalId, dataInicial: dataInicial, dataFinal: dataFinal);
  Future<Consulta?> getConsultaById(String id) => _getById(id);
  Future<bool> addConsulta(Consulta consulta) => _add(consulta);
  Future<bool> updateConsulta(Consulta consulta) => _update(consulta);
  Future<bool> deleteConsulta(Consulta consulta) => _delete(consulta);
  Future<String> exportToCsv(String animalId) => _exportToCsv(animalId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(ConsultaAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing ConsultaRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Consulta>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - CRUD Operations
  Future<List<Consulta>> _getAll(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      await _openBox();
      return _box.values
          .where((consulta) =>
              consulta.animalId == animalId &&
              !consulta.isDeleted &&
              (dataInicial == null || consulta.dataConsulta >= dataInicial) &&
              (dataFinal == null || consulta.dataConsulta <= dataFinal))
          .toList()
        ..sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));
    } catch (e) {
      debugPrint('Error getting consultas: $e');
      return [];
    } finally {
      await _closeBox();
    }
  }

  Future<Consulta?> _getById(String id) async {
    try {
      await _openBox();
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting Consulta by ID: $e');
      return null;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(Consulta consulta) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(consulta);

      // Cria o registro no Firebase e captura a chave (objectId) retornada
      final String newObjectId = await _firestore.createRecord(
        collection: collectionName,
        data: consulta.toMap(),
      );

      // The id field should already be set in BaseModel, no need to update objectId
      await _box.put(key, consulta);

      return true;
    } catch (e) {
      debugPrint('Error adding Consulta: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(Consulta consulta) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == consulta.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com a data/hora atual (em microsegundos)
        consulta.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, consulta);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: consulta.id,
          data: consulta.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Consulta: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(Consulta consulta) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == consulta.id);

      if (index != -1) {
        // Define o registro como deletado e atualiza o campo updatedAt com a data atual
        consulta.isDeleted = true;
        consulta.updatedAt = DateTime.now().millisecondsSinceEpoch;

        await _box.putAt(index, consulta);
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: consulta.id,
          data: consulta.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Consulta: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv(String animalId) async {
    try {
      await _openBox();
      final consultas = _box.values
          .where((consulta) =>
              consulta.animalId == animalId && !consulta.isDeleted)
          .toList();

      // Define CSV header with relevant fields
      const csvHeader =
          'Data da Consulta,Veterinário,Motivo,Diagnóstico,Valor,Observações\n';

      // Convert each consulta to a CSV row
      final csvRows = consultas.map((consulta) {
        final dataConsulta = _escapeField(DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta)));
        final veterinario = _escapeField(consulta.veterinario);
        final motivo = _escapeField(consulta.motivo);
        final diagnostico = _escapeField(consulta.diagnostico);
        final valor = consulta.valor.toStringAsFixed(2);
        final observacoes = _escapeField(consulta.observacoes ?? '');

        return '$dataConsulta,$veterinario,$motivo,$diagnostico,$valor,$observacoes';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting consultas to CSV: $e');
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
