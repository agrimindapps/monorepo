import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<List<MedicationModel>> getMedications();
  Future<List<MedicationModel>> getMedicationsByAnimalId(String animalId);
  Future<List<MedicationModel>> getActiveMedications();
  Future<List<MedicationModel>> getActiveMedicationsByAnimalId(String animalId);
  Future<List<MedicationModel>> getExpiringSoonMedications();
  Future<MedicationModel> getMedicationById(String id);
  Future<void> addMedication(MedicationModel medication);
  Future<void> updateMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<void> discontinueMedication(String id, String reason);
  Future<List<MedicationModel>> searchMedications(String query);
  Future<List<MedicationModel>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<MedicationModel>> checkMedicationConflicts(MedicationModel medication);
  Future<int> getActiveMedicationsCount(String animalId);
  Future<List<Map<String, dynamic>>> exportMedicationsData();
  Future<void> importMedicationsData(List<Map<String, dynamic>> data);
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  
  @override
  Future<List<MedicationModel>> getMedications() async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<MedicationModel>> getMedicationsByAnimalId(String animalId) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<MedicationModel>> getActiveMedications() async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<MedicationModel>> getActiveMedicationsByAnimalId(String animalId) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<MedicationModel>> getExpiringSoonMedications() async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<MedicationModel> getMedicationById(String id) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<void> addMedication(MedicationModel medication) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<void> updateMedication(MedicationModel medication) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<void> deleteMedication(String id) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<void> discontinueMedication(String id, String reason) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<MedicationModel>> searchMedications(String query) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<MedicationModel>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<MedicationModel>> checkMedicationConflicts(MedicationModel medication) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<int> getActiveMedicationsCount(String animalId) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<List<Map<String, dynamic>>> exportMedicationsData() async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }

  @override
  Future<void> importMedicationsData(List<Map<String, dynamic>> data) async {
    throw UnimplementedError('Firebase integration not yet implemented');
  }
}