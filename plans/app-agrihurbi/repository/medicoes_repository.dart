// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../core/services/firebase_firestore_service.dart';
import '../models/medicoes_models.dart';

class MedicoesRepository {
  // MARK: - Constants
  static const String _boxName = 'box_agr_medicoes';
  static const String collectionName = 'box_agr_medicoes';

  // MARK: - Dependencies
  final _firestore = FirestoreService();

  // MARK: - Properties
  Box<Medicoes> get _box => Hive.box<Medicoes>(_boxName);

  // MARK: - Singleton Implementation
  static final MedicoesRepository _instance = MedicoesRepository._internal();
  factory MedicoesRepository() => _instance;
  MedicoesRepository._internal();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<Medicoes>> getMedicoes(String pluviometroId) =>
      _getAll(pluviometroId);
  Future<bool> addMedicao(Medicoes medicao) => _add(medicao);
  Future<bool> updateMedicao(Medicoes medicao) => _update(medicao);
  Future<bool> deleteMedicao(Medicoes medicao) => _delete(medicao);
  Future<String> exportToCsv({String? pluviometroId}) =>
      _exportToCsv(pluviometroId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(30)) {
        Hive.registerAdapter(MedicoesAdapter());
      }
    } catch (e) {
      debugPrint('Error initializing MedicoesRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Medicoes>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - CRUD Operations
  Future<List<Medicoes>> _getAll(String pluviometroId) async {
    try {
      await _openBox();
      return _box.values
          .where((medicao) =>
              medicao.fkPluviometro == pluviometroId && !medicao.isDeleted)
          .toList()
        ..sort((a, b) => b.dtMedicao.compareTo(a.dtMedicao));
    } catch (e) {
      debugPrint('Error getting Medicoes: $e');
      return [];
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(Medicoes medicao) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(medicao);

      // Try to create record in Firebase with enhanced error handling
      String newObjectId;
      try {
        newObjectId = await _firestore.createRecord(
          collection: collectionName,
          data: medicao.toMap(),
        );
      } catch (e) {
        debugPrint('Firebase error while adding medicao: $e');
        // Use a temporary ID if Firebase fails
        newObjectId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Atualiza o ID se necessário (BaseModel já tem ID)
      await _box.put(key, medicao);

      return true;
    } catch (e) {
      debugPrint('Error adding Medicao: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(Medicoes medicao) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == medicao.id);

      if (index != -1) {
        // Atualiza a propriedade updatedAt com a data/hora atual (em microsegundos)
        medicao.updatedAt = DateTime.now().millisecondsSinceEpoch;

        // Atualiza o registro no Hive
        await _box.putAt(index, medicao);

        // Envia a atualização para o Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: medicao.id,
          data: medicao.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Medicao: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(Medicoes medicao) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == medicao.id);

      if (index != -1) {
        // Marca o registro como deletado
        medicao.markAsDeleted();

        // Atualiza o registro no Hive
        await _box.putAt(index, medicao);

        // Envia a atualização para o Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: medicao.id,
          data: medicao.toMap(),
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Medicao: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Analysis Methods
  List<DateTime> getMonthsList(List<Medicoes> medicoes) {
    if (medicoes.isEmpty) return [];

    final dates = medicoes.map((medicao) {
      return DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
    }).toList();

    final oldestDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final newestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    List<DateTime> allMonths = [];
    DateTime currentDate = DateTime(oldestDate.year, oldestDate.month);
    final lastDate = DateTime(newestDate.year, newestDate.month);

    while (!currentDate.isAfter(lastDate)) {
      allMonths.add(currentDate);
      currentDate = DateTime(
        currentDate.year + (currentDate.month == 12 ? 1 : 0),
        currentDate.month == 12 ? 1 : currentDate.month + 1,
      );
    }

    return allMonths.reversed.toList();
  }

  List<Medicoes> getMedicoesDoMes(List<Medicoes> medicoes, DateTime date) {
    return medicoes.where((medicao) {
      final medicaoDate =
          DateTime.fromMillisecondsSinceEpoch(medicao.dtMedicao);
      return medicaoDate.year == date.year && medicaoDate.month == date.month;
    }).toList();
  }

  double getTotalMedicoesDoMes(List<Medicoes> medicoesDoMes) {
    return medicoesDoMes.fold(0.0, (sum, medicao) => sum + medicao.quantidade);
  }

  double getMediaDiaria(List<Medicoes> medicoesDoMes) {
    if (medicoesDoMes.isEmpty) return 0.0;
    final total = getTotalMedicoesDoMes(medicoesDoMes);
    return total / medicoesDoMes.length;
  }

  String formatDate(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv(String? pluviometroId) async {
    try {
      await _openBox();
      List<Medicoes> medicoes;

      // Filter medicoes by pluviometro ID if provided, otherwise export all active medicoes
      if (pluviometroId != null) {
        medicoes = _box.values
            .where((medicao) =>
                !medicao.isDeleted && medicao.fkPluviometro == pluviometroId)
            .toList();
      } else {
        medicoes = _box.values.where((medicao) => !medicao.isDeleted).toList();
      }

      // Sort by date (most recent first)
      medicoes.sort((a, b) => b.dtMedicao.compareTo(a.dtMedicao));

      // Define CSV header with relevant fields
      const csvHeader =
          'Pluviômetro ID,Data Medição,Data Formatada,Quantidade (mm)\n';

      // Convert each measurement to a CSV row
      final csvRows = medicoes.map((medicao) {
        final pluviometroId = _escapeField(medicao.fkPluviometro);
        final dataFormatada = _escapeField(formatDate(medicao.dtMedicao));

        return '$pluviometroId,${medicao.dtMedicao},$dataFormatada,${medicao.quantidade}';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting medicoes to CSV: $e');
      return '';
    } finally {
      await _closeBox();
    }
  }

  // Helper para escapar campos que podem conter vírgulas
  String _escapeField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Substitui aspas duplas por duas aspas duplas e envolve em aspas
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
