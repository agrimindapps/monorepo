import '../../../../core/error/exceptions.dart';
import '../../../../core/network/firebase_service.dart';
import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<List<MedicationModel>> getMedications(String userId);
  Future<List<MedicationModel>> getMedicationsByAnimalId(
      String userId, String animalId);
  Future<List<MedicationModel>> getActiveMedications(String userId);
  Future<List<MedicationModel>> getActiveMedicationsByAnimalId(
      String userId, String animalId);
  Future<List<MedicationModel>> getExpiringSoonMedications(String userId);
  Future<MedicationModel?> getMedicationById(String id);
  Future<String> addMedication(MedicationModel medication, String userId);
  Future<void> updateMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<void> discontinueMedication(String id, String reason);
  Future<List<MedicationModel>> searchMedications(String userId, String query);
  Future<List<MedicationModel>> getMedicationHistory(
    String userId,
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<MedicationModel>> checkMedicationConflicts(
      String userId, MedicationModel medication);
  Future<int> getActiveMedicationsCount(String userId, String animalId);
  Future<List<Map<String, dynamic>>> exportMedicationsData(String userId);
  Future<void> importMedicationsData(
      String userId, List<Map<String, dynamic>> data);
  Stream<List<MedicationModel>> streamMedications(String userId);
  Stream<List<MedicationModel>> streamMedicationsByAnimalId(
      String userId, String animalId);
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final FirebaseService _firebaseService;

  MedicationRemoteDataSourceImpl({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<List<MedicationModel>> getMedications(String userId) async {
    try {
      // Query medications through animals belonging to userId
      final animals = await _firebaseService.getCollection(
        FirebaseCollections.animals,
        where: [WhereCondition('userId', isEqualTo: userId)],
        fromMap: (map) => map,
      );

      if (animals.isEmpty) {
        return [];
      }

      final animalIds =
          animals.map((animal) => animal['id'] as String).toList();

      final medications =
          await _firebaseService.getCollection<MedicationModel>(
        FirebaseCollections.medications,
        where: [
          WhereCondition('animalId', whereIn: animalIds),
          const WhereCondition('isDeleted', isEqualTo: false),
        ],
        orderBy: [const OrderByCondition('startDate', descending: true)],
        fromMap: MedicationModel.fromMap,
      );

      return medications;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar medicamentos do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MedicationModel>> getMedicationsByAnimalId(
      String userId, String animalId) async {
    try {
      final medications =
          await _firebaseService.getCollection<MedicationModel>(
        FirebaseCollections.medications,
        where: [
          WhereCondition('animalId', isEqualTo: animalId),
          const WhereCondition('isDeleted', isEqualTo: false),
        ],
        orderBy: [const OrderByCondition('startDate', descending: true)],
        fromMap: MedicationModel.fromMap,
      );

      return medications;
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao buscar medicamentos do animal do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MedicationModel>> getActiveMedications(String userId) async {
    try {
      final allMedications = await getMedications(userId);
      final now = DateTime.now();

      return allMedications.where((medication) {
        return medication.startDate.isBefore(now) &&
            (medication.endDate?.isAfter(now) ?? false) &&
            !medication.isDeleted;
      }).toList();
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao buscar medicamentos ativos do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MedicationModel>> getActiveMedicationsByAnimalId(
      String userId, String animalId) async {
    try {
      final medications = await getMedicationsByAnimalId(userId, animalId);
      final now = DateTime.now();

      return medications.where((medication) {
        return medication.startDate.isBefore(now) &&
            (medication.endDate?.isAfter(now) ?? false) &&
            !medication.isDeleted;
      }).toList();
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao buscar medicamentos ativos do animal do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MedicationModel>> getExpiringSoonMedications(
      String userId) async {
    try {
      final allMedications = await getMedications(userId);
      final now = DateTime.now();
      final sevenDaysFromNow = now.add(const Duration(days: 7));

      return allMedications.where((medication) {
        return (medication.endDate?.isAfter(now) ?? false) &&
            (medication.endDate?.isBefore(sevenDaysFromNow) ?? false) &&
            !medication.isDeleted;
      }).toList();
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao buscar medicamentos próximos ao vencimento do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<MedicationModel?> getMedicationById(String id) async {
    try {
      final medication = await _firebaseService.getDocument<MedicationModel>(
        FirebaseCollections.medications,
        id,
        MedicationModel.fromMap,
      );

      return medication;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar medicamento do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> addMedication(
      MedicationModel medication, String userId) async {
    try {
      final medicationData = medication.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _firebaseService.addDocument<MedicationModel>(
        FirebaseCollections.medications,
        medicationData,
        (medication) => medication.toMap(),
      );

      return id;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao adicionar medicamento no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateMedication(MedicationModel medication) async {
    try {
      final updatedMedication = medication.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firebaseService.setDocument<MedicationModel>(
        FirebaseCollections.medications,
        medication.id.toString(),
        updatedMedication,
        (medication) => medication.toMap(),
        merge: true,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao atualizar medicamento no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteMedication(String id) async {
    try {
      // Soft delete - mark as deleted
      final medication = await getMedicationById(id);
      if (medication != null) {
        final deletedMedication = medication.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
        );

        await _firebaseService.setDocument<MedicationModel>(
          FirebaseCollections.medications,
          id,
          deletedMedication,
          (medication) => medication.toMap(),
          merge: true,
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Erro ao deletar medicamento do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> discontinueMedication(String id, String reason) async {
    try {
      final medication = await getMedicationById(id);
      if (medication != null) {
        final discontinuedMedication = medication.copyWith(
          updatedAt: DateTime.now(),
        );

        await _firebaseService.setDocument<MedicationModel>(
          FirebaseCollections.medications,
          id,
          discontinuedMedication,
          (medication) => medication.toMap(),
          merge: true,
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Erro ao descontinuar medicamento no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MedicationModel>> searchMedications(
      String userId, String query) async {
    try {
      final allMedications = await getMedications(userId);
      final lowerQuery = query.toLowerCase();

      return allMedications.where((medication) {
        return medication.name.toLowerCase().contains(lowerQuery) ||
            medication.type.toLowerCase().contains(lowerQuery) ||
            (medication.veterinarian?.toLowerCase().contains(lowerQuery) ??
                false);
      }).toList();
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar medicamentos no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MedicationModel>> getMedicationHistory(
    String userId,
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final medications = await getMedicationsByAnimalId(userId, animalId);

      return medications.where((medication) {
        return (medication.startDate.isAfter(startDate) ||
                medication.startDate.isAtSameMomentAs(startDate)) &&
            ((medication.endDate?.isBefore(endDate) ?? false) ||
                (medication.endDate?.isAtSameMomentAs(endDate) ?? false));
      }).toList();
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao buscar histórico de medicamentos do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MedicationModel>> checkMedicationConflicts(
      String userId, MedicationModel medication) async {
    try {
      final activeMedications = await getActiveMedicationsByAnimalId(
          userId, medication.animalId.toString());

      // Check for time conflicts (same time period)
      return activeMedications.where((existing) {
        if (existing.id == medication.id) return false;

        return (medication.startDate.isBefore(existing.endDate!) &&
                (medication.endDate?.isAfter(existing.startDate) ?? false)) ||
            (existing.startDate.isBefore(medication.endDate!) &&
                (existing.endDate?.isAfter(medication.startDate) ?? false));
      }).toList();
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao verificar conflitos de medicamentos no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> getActiveMedicationsCount(String userId, String animalId) async {
    try {
      final activeMedications =
          await getActiveMedicationsByAnimalId(userId, animalId);
      return activeMedications.length;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao contar medicamentos ativos no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> exportMedicationsData(
      String userId) async {
    try {
      final medications = await getMedications(userId);
      return medications.map((medication) => medication.toMap()).toList();
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao exportar dados de medicamentos do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> importMedicationsData(
      String userId, List<Map<String, dynamic>> data) async {
    try {
      for (final medicationData in data) {
        final medication = MedicationModel.fromMap(medicationData);
        await _firebaseService.setDocument<MedicationModel>(
          FirebaseCollections.medications,
          medication.id.toString(),
          medication,
          (medication) => medication.toMap(),
        );
      }
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao importar dados de medicamentos no servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<MedicationModel>> streamMedications(String userId) {
    try {
      // Note: This is a simplified version that streams all medications
      // In production, you might want to optimize by streaming only from specific animals
      return _firebaseService.streamCollection<MedicationModel>(
        FirebaseCollections.medications,
        where: [const WhereCondition('isDeleted', isEqualTo: false)],
        orderBy: [const OrderByCondition('startDate', descending: true)],
        fromMap: MedicationModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message: 'Erro ao escutar medicamentos do servidor: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<MedicationModel>> streamMedicationsByAnimalId(
      String userId, String animalId) {
    try {
      return _firebaseService.streamCollection<MedicationModel>(
        FirebaseCollections.medications,
        where: [
          WhereCondition('animalId', isEqualTo: animalId),
          const WhereCondition('isDeleted', isEqualTo: false),
        ],
        orderBy: [const OrderByCondition('startDate', descending: true)],
        fromMap: MedicationModel.fromMap,
      );
    } catch (e) {
      throw ServerException(
        message:
            'Erro ao escutar medicamentos do animal do servidor: ${e.toString()}',
      );
    }
  }
}
