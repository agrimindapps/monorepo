import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/vaccine_model.dart';

abstract class VaccineRemoteDataSource {
  /// Basic CRUD operations
  Future<List<VaccineModel>> getVaccines();
  Future<List<VaccineModel>> getVaccinesByAnimalId(String animalId);
  Future<VaccineModel?> getVaccineById(String id);
  Future<VaccineModel> addVaccine(VaccineModel vaccine);
  Future<VaccineModel> updateVaccine(VaccineModel vaccine);
  Future<void> deleteVaccine(String id);
  Future<void> deleteVaccinesByAnimalId(String animalId);

  /// Status-based queries
  Future<List<VaccineModel>> getPendingVaccines([String? animalId]);
  Future<List<VaccineModel>> getOverdueVaccines([String? animalId]);
  Future<List<VaccineModel>> getCompletedVaccines([String? animalId]);
  Future<List<VaccineModel>> getRequiredVaccines([String? animalId]);
  Future<List<VaccineModel>> getUpcomingVaccines([String? animalId]);

  /// Date-based queries
  Future<List<VaccineModel>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]);
  
  /// Reminder functionality
  Future<List<VaccineModel>> getVaccinesNeedingReminders();
  Future<VaccineModel> scheduleVaccineReminder(String vaccineId, DateTime reminderDate);
  Future<void> removeVaccineReminder(String vaccineId);

  /// Search and filtering
  Future<List<VaccineModel>> searchVaccines(String query, [String? animalId]);
  Future<List<VaccineModel>> getVaccinesByVeterinarian(String veterinarian, [String? animalId]);
  Future<List<VaccineModel>> getVaccinesByName(String vaccineName, [String? animalId]);
  Future<List<VaccineModel>> getVaccinesByManufacturer(String manufacturer, [String? animalId]);

  /// Bulk operations
  Future<List<VaccineModel>> addMultipleVaccines(List<VaccineModel> vaccines);
  Future<void> markVaccinesAsCompleted(List<String> vaccineIds);

  /// Reactive streams
  Stream<List<VaccineModel>> watchVaccines();
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(String animalId);

  /// Synchronization
  Future<DateTime?> getLastSyncTime();
  Future<void> updateLastSyncTime();
  Future<List<VaccineModel>> getVaccinesModifiedAfter(DateTime timestamp);
}

class VaccineRemoteDataSourceImpl implements VaccineRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _userId;
  
  VaccineRemoteDataSourceImpl(this._firestore, this._userId);
  
  CollectionReference get _vaccinesCollection => 
    _firestore.collection('users').doc(_userId).collection('vaccines');

  List<VaccineModel> _parseVaccines(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return VaccineModel.fromMap(data);
    }).where((vaccine) => !vaccine.isDeleted).toList();
  }

  Query _applyAnimalFilter(Query query, String? animalId) {
    if (animalId != null) {
      return query.where('animalId', isEqualTo: animalId);
    }
    return query;
  }
  @override
  Future<List<VaccineModel>> getVaccines() async {
    try {
      final snapshot = await _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .orderBy('dataAplicacao', descending: true)
          .get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getVaccinesByAnimalId(String animalId) async {
    try {
      final snapshot = await _vaccinesCollection
          .where('animalId', isEqualTo: animalId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('dataAplicacao', descending: true)
          .get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas do animal: $e');
    }
  }

  @override
  Future<VaccineModel?> getVaccineById(String id) async {
    try {
      final doc = await _vaccinesCollection.doc(id).get();
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final vaccine = VaccineModel.fromMap(data);
      
      return vaccine.isDeleted ? null : vaccine;
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacina: $e');
    }
  }

  @override
  Future<VaccineModel> addVaccine(VaccineModel vaccine) async {
    try {
      final doc = _vaccinesCollection.doc(vaccine.id?.toString());
      await doc.set(vaccine.toMap());
      return vaccine;
    } catch (e) {
      throw ServerException(message: 'Erro ao adicionar vacina: $e');
    }
  }

  @override
  Future<VaccineModel> updateVaccine(VaccineModel vaccine) async {
    try {
      await _vaccinesCollection.doc(vaccine.id?.toString()).update(vaccine.toMap());
      return vaccine;
    } catch (e) {
      throw ServerException(message: 'Erro ao atualizar vacina: $e');
    }
  }

  @override
  Future<void> deleteVaccine(String id) async {
    try {
      await _vaccinesCollection.doc(id).update({
        'isDeleted': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw ServerException(message: 'Erro ao deletar vacina: $e');
    }
  }

  @override
  Future<void> deleteVaccinesByAnimalId(String animalId) async {
    try {
      final batch = _firestore.batch();
      final snapshots = await _vaccinesCollection
          .where('animalId', isEqualTo: animalId)
          .where('isDeleted', isEqualTo: false)
          .get();

      for (final doc in snapshots.docs) {
        batch.update(doc.reference, {
          'isDeleted': true,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Erro ao deletar vacinas do animal: $e');
    }
  }
  @override
  Future<List<VaccineModel>> getPendingVaccines([String? animalId]) async {
    try {
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('status', isEqualTo: 1); // VaccineStatus.pending
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas pendentes: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getOverdueVaccines([String? animalId]) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('concluida', isEqualTo: false)
          .where('obrigatoria', isEqualTo: true)
          .where('proximaDose', isLessThan: now);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas atrasadas: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getCompletedVaccines([String? animalId]) async {
    try {
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('concluida', isEqualTo: true);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas concluídas: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getRequiredVaccines([String? animalId]) async {
    try {
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('obrigatoria', isEqualTo: true);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas obrigatórias: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getUpcomingVaccines([String? animalId]) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final futureDate = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
      
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('concluida', isEqualTo: false)
          .where('proximaDose', isGreaterThan: now)
          .where('proximaDose', isLessThan: futureDate);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar próximas vacinas: $e');
    }
  }
  @override
  Future<List<VaccineModel>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]) async {
    try {
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('dataAplicacao', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('dataAplicacao', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas por período: $e');
    }
  }
  @override
  Future<List<VaccineModel>> getVaccinesNeedingReminders() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final snapshot = await _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('concluida', isEqualTo: false)
          .where('dataLembrete', isLessThanOrEqualTo: now)
          .get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas para lembrete: $e');
    }
  }

  @override
  Future<VaccineModel> scheduleVaccineReminder(String vaccineId, DateTime reminderDate) async {
    try {
      await _vaccinesCollection.doc(vaccineId).update({
        'dataLembrete': reminderDate.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      final updatedVaccine = await getVaccineById(vaccineId);
      if (updatedVaccine == null) {
        throw const ServerException(message: 'Vacina não encontrada após agendamento de lembrete');
      }
      return updatedVaccine;
    } catch (e) {
      throw ServerException(message: 'Erro ao agendar lembrete: $e');
    }
  }

  @override
  Future<void> removeVaccineReminder(String vaccineId) async {
    try {
      await _vaccinesCollection.doc(vaccineId).update({
        'dataLembrete': 0,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw ServerException(message: 'Erro ao remover lembrete: $e');
    }
  }
  @override
  Future<List<VaccineModel>> searchVaccines(String query, [String? animalId]) async {
    try {
      final vaccines = animalId != null 
          ? await getVaccinesByAnimalId(animalId)
          : await getVaccines();
      
      final queryLower = query.toLowerCase();
      return vaccines.where((vaccine) {
        return vaccine.name.toLowerCase().contains(queryLower) ||
               vaccine.veterinarian.toLowerCase().contains(queryLower) ||
               (vaccine.manufacturer?.toLowerCase().contains(queryLower) ?? false) ||
               (vaccine.notes?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Erro ao pesquisar vacinas: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getVaccinesByVeterinarian(String veterinarian, [String? animalId]) async {
    try {
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('veterinario', isEqualTo: veterinarian);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas por veterinário: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getVaccinesByName(String vaccineName, [String? animalId]) async {
    try {
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('nomeVacina', isEqualTo: vaccineName);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas por nome: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getVaccinesByManufacturer(String manufacturer, [String? animalId]) async {
    try {
      var query = _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .where('fabricante', isEqualTo: manufacturer);
      
      query = _applyAnimalFilter(query, animalId);
      final snapshot = await query.get();
      return _parseVaccines(snapshot);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas por fabricante: $e');
    }
  }
  @override
  Future<List<VaccineModel>> addMultipleVaccines(List<VaccineModel> vaccines) async {
    try {
      final batch = _firestore.batch();
      
      for (final vaccine in vaccines) {
        final doc = _vaccinesCollection.doc(vaccine.id?.toString());
        batch.set(doc, vaccine.toMap());
      }
      
      await batch.commit();
      return vaccines;
    } catch (e) {
      throw ServerException(message: 'Erro ao adicionar múltiplas vacinas: $e');
    }
  }

  @override
  Future<void> markVaccinesAsCompleted(List<String> vaccineIds) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      for (final id in vaccineIds) {
        batch.update(_vaccinesCollection.doc(id), {
          'concluida': true,
          'status': 0, // VaccineStatus.applied
          'updatedAt': now,
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Erro ao marcar vacinas como concluídas: $e');
    }
  }
  @override
  Stream<List<VaccineModel>> watchVaccines() {
    try {
      return _vaccinesCollection
          .where('isDeleted', isEqualTo: false)
          .orderBy('dataAplicacao', descending: true)
          .snapshots()
          .map(_parseVaccines);
    } catch (e) {
      throw ServerException(message: 'Erro ao observar vacinas: $e');
    }
  }

  @override
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(String animalId) {
    try {
      return _vaccinesCollection
          .where('animalId', isEqualTo: animalId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('dataAplicacao', descending: true)
          .snapshots()
          .map(_parseVaccines);
    } catch (e) {
      throw ServerException(message: 'Erro ao observar vacinas do animal: $e');
    }
  }
  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('metadata')
          .doc('vaccines_sync')
          .get();
      
      if (!doc.exists) return null;
      
      final timestamp = doc.data()?['lastSync'] as int?;
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      throw ServerException(message: 'Erro ao obter tempo de sincronização: $e');
    }
  }

  @override
  Future<void> updateLastSyncTime() async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('metadata')
          .doc('vaccines_sync')
          .set({
        'lastSync': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw ServerException(message: 'Erro ao atualizar tempo de sincronização: $e');
    }
  }

  @override
  Future<List<VaccineModel>> getVaccinesModifiedAfter(DateTime timestamp) async {
    try {
      final snapshot = await _vaccinesCollection
          .where('updatedAt', isGreaterThan: timestamp.millisecondsSinceEpoch)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return VaccineModel.fromMap(data);
      }).toList(); // Include deleted items for sync
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar vacinas modificadas: $e');
    }
  }
}
