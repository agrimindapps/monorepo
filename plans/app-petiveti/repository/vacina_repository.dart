// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../core/services/firebase_firestore_service.dart';
import '../controllers/vacinas_controller.dart';
import '../models/16_vacina_model.dart';
import '../services/pet_notification_manager.dart';

class VacinaRepository {
  // MARK: - Constants
  static const String _boxName = 'box_vet_vacinas';
  static const String collectionName = 'box_vet_vacinas';

  // MARK: - Dependencies
  final _firestore = FirestoreService();
  final _notificationManager = PetNotificationManager();

  // MARK: - Properties
  Box<VacinaVet> get _box => Hive.box<VacinaVet>(_boxName);

  // MARK: - Constructor
  VacinaRepository();

  // MARK: - Public API
  static Future<void> initialize() => _initialize();
  Future<List<VacinaVet>> getVacinas(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) =>
      _getAll(animalId, dataInicial: dataInicial, dataFinal: dataFinal);
  Future<VacinaVet?> getVacinaById(String id) => _getById(id);
  Future<bool> addVacina(VacinaVet vacina) => _add(vacina);
  Future<bool> updateVacina(VacinaVet vacina) => _update(vacina);
  Future<bool> deleteVacina(VacinaVet vacina) => _delete(vacina);
  Future<String> exportToCsv(String animalId) => _exportToCsv(animalId);

  // MARK: - Initialization
  static Future<void> _initialize() async {
    try {
      if (!Hive.isAdapterRegistered(16)) {
        Hive.registerAdapter(VacinaVetAdapter());
      }

      // O gerenciador de notificações já foi inicializado em LembreteRepository
    } catch (e) {
      debugPrint('Error initializing VacinaRepository: $e');
      rethrow;
    }
  }

  // MARK: - Box Management
  Future<void> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<VacinaVet>(_boxName);
    }
  }

  Future<void> _closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }

  // MARK: - CRUD Operations
  Future<List<VacinaVet>> _getAll(
    String animalId, {
    int? dataInicial,
    int? dataFinal,
  }) async {
    try {
      await _openBox();
      return _box.values
          .where((vacina) =>
              vacina.animalId == animalId &&
              !vacina.isDeleted &&
              (dataInicial == null || vacina.dataAplicacao >= dataInicial) &&
              (dataFinal == null || vacina.dataAplicacao <= dataFinal))
          .toList()
        ..sort((a, b) => b.dataAplicacao.compareTo(a.dataAplicacao));
    } catch (e) {
      debugPrint('Error getting vacinas: $e');
      return [];
    } finally {
      await _closeBox();
    }
  }

  Future<VacinaVet?> _getById(String id) async {
    try {
      await _openBox();
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting Vacina by ID: $e');
      return null;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - Data Modification Operations
  Future<bool> _add(VacinaVet vacina) async {
    try {
      await _openBox();
      // Adiciona o objeto no Hive e captura a chave retornada
      final key = await _box.add(vacina);

      // Cria o registro no Firebase e captura o objectId retornado
      final String newObjectId = await _firestore.createRecord(
        collection: collectionName,
        data: vacina.toMap(),
      );

      // The id field should already be set in BaseModel, no need to update objectId
      await _box.put(key, vacina);

      // Agenda notificações para a próxima dose da vacina
      await _notificationManager.agendarNotificacoesVacina(vacina);

      return true;
    } catch (e) {
      debugPrint('Error adding Vacina: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _update(VacinaVet vacina) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == vacina.id);

      if (index != -1) {
        // Atualiza o campo updatedAt com o timestamp atual (em microsegundos)
        vacina.updatedAt = DateTime.now().millisecondsSinceEpoch;

        // Atualiza o registro no Hive
        await _box.putAt(index, vacina);

        // Atualiza o registro no Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: vacina.id,
          data: vacina.toMap(),
        );

        // Atualiza as notificações para a vacina
        await _notificationManager.agendarNotificacoesVacina(vacina);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating Vacina: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  Future<bool> _delete(VacinaVet vacina) async {
    try {
      await _openBox();
      final index =
          _box.values.toList().indexWhere((item) => item.id == vacina.id);

      if (index != -1) {
        // Marca o registro como deletado e atualiza o campo updatedAt
        vacina.isDeleted = true;
        vacina.updatedAt = DateTime.now().millisecondsSinceEpoch;

        // Atualiza o registro no Hive
        await _box.putAt(index, vacina);

        // Atualiza o registro no Firebase
        await _firestore.updateRecord(
          collection: collectionName,
          recordId: vacina.id,
          data: vacina.toMap(),
        );

        // Cancela as notificações para a vacina
        await _notificationManager.cancelarNotificacoesVacina(vacina.id);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting Vacina: $e');
      return false;
    } finally {
      await _closeBox();
    }
  }

  // MARK: - CSV Export
  Future<String> _exportToCsv(String animalId) async {
    try {
      await _openBox();
      final vacinas = _box.values
          .where(
              (vacina) => vacina.animalId == animalId && !vacina.isDeleted)
          .toList();

      // Define CSV header
      const csvHeader =
          'Nome da Vacina,Data de Aplicação,Próxima Dose,Observações\n';

      // Retorno simples dos dados para que o controller possa formatá-los
      final vacController = Get.find<VacinasController>();

      // Convert each vaccine to a CSV row
      final csvRows = vacinas.map((vacina) {
        final nomeVacina = vacController.escapeFieldForCsv(vacina.nomeVacina);

        // Format dates from timestamp to readable format
        final dataAplicacao = vacController.escapeFieldForCsv(
            DateFormat('dd/MM/yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(vacina.dataAplicacao)));

        final proximaDose = vacController.escapeFieldForCsv(
            DateFormat('dd/MM/yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose)));

        final observacoes =
            vacController.escapeFieldForCsv(vacina.observacoes ?? '');

        return '$nomeVacina,$dataAplicacao,$proximaDose,$observacoes';
      }).join('\n');

      return csvHeader + csvRows;
    } catch (e) {
      debugPrint('Error exporting vacinas to CSV: $e');
      return '';
    } finally {
      await _closeBox();
    }
  }
}
