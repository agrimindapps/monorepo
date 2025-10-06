import 'package:core/core.dart' show Hive, Box;

import '../models/medication_model.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getMedications();
  Future<List<MedicationModel>> getMedicationsByAnimalId(String animalId);
  Future<List<MedicationModel>> getActiveMedications();
  Future<List<MedicationModel>> getActiveMedicationsByAnimalId(String animalId);
  Future<List<MedicationModel>> getExpiringSoonMedications();
  Future<MedicationModel?> getMedicationById(String id);
  Future<void> cacheMedication(MedicationModel medication);
  Future<void> cacheMedications(List<MedicationModel> medications);
  Future<void> updateMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<void> hardDeleteMedication(String id);
  Future<void> discontinueMedication(String id, String reason);
  Future<List<MedicationModel>> searchMedications(String query);
  Future<List<MedicationModel>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<MedicationModel>> checkMedicationConflicts(
    MedicationModel medication,
  );
  Future<int> getActiveMedicationsCount(String animalId);
  Future<void> clearAllMedications();
  Stream<List<MedicationModel>> watchMedications();
  Stream<List<MedicationModel>> watchMedicationsByAnimalId(String animalId);
  Stream<List<MedicationModel>> watchActiveMedications();
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  static const String _boxName = 'medications';
  Box<MedicationModel>? _medicationBox;

  Future<Box<MedicationModel>> get medicationBox async {
    if (_medicationBox?.isOpen != true) {
      _medicationBox = await Hive.openBox<MedicationModel>(_boxName);
    }
    return _medicationBox!;
  }

  @override
  Future<List<MedicationModel>> getMedications() async {
    final box = await medicationBox;
    return box.values.where((medication) => !medication.isDeleted).toList();
  }

  @override
  Future<List<MedicationModel>> getMedicationsByAnimalId(
    String animalId,
  ) async {
    final box = await medicationBox;
    return box.values
        .where(
          (medication) =>
              medication.animalId == animalId && !medication.isDeleted,
        )
        .toList();
  }

  @override
  Future<List<MedicationModel>> getActiveMedications() async {
    final box = await medicationBox;
    final now = DateTime.now();

    return box.values
        .where(
          (medication) =>
              !medication.isDeleted &&
              now.isAfter(medication.startDate) &&
              now.isBefore(medication.endDate),
        )
        .toList();
  }

  @override
  Future<List<MedicationModel>> getActiveMedicationsByAnimalId(
    String animalId,
  ) async {
    final box = await medicationBox;
    final now = DateTime.now();

    return box.values
        .where(
          (medication) =>
              medication.animalId == animalId &&
              !medication.isDeleted &&
              now.isAfter(medication.startDate) &&
              now.isBefore(medication.endDate),
        )
        .toList();
  }

  @override
  Future<List<MedicationModel>> getExpiringSoonMedications() async {
    final box = await medicationBox;
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));

    return box.values
        .where(
          (medication) =>
              !medication.isDeleted &&
              medication.endDate.isAfter(now) &&
              medication.endDate.isBefore(threeDaysFromNow),
        )
        .toList();
  }

  @override
  Future<MedicationModel?> getMedicationById(String id) async {
    final box = await medicationBox;
    final medication = box.get(id);

    if (medication != null && !medication.isDeleted) {
      return medication;
    }
    return null;
  }

  @override
  Future<void> cacheMedication(MedicationModel medication) async {
    final box = await medicationBox;
    await box.put(medication.id, medication);
  }

  @override
  Future<void> cacheMedications(List<MedicationModel> medications) async {
    final box = await medicationBox;
    final medicationMap = <String, MedicationModel>{};

    for (final medication in medications) {
      medicationMap[medication.id] = medication;
    }

    await box.putAll(medicationMap);
  }

  @override
  Future<void> updateMedication(MedicationModel medication) async {
    final box = await medicationBox;
    await box.put(medication.id, medication);
  }

  @override
  Future<void> deleteMedication(String id) async {
    final box = await medicationBox;
    final medication = box.get(id);

    if (medication != null) {
      final updatedMedication = medication.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      await box.put(id, updatedMedication);
    }
  }

  @override
  Future<void> hardDeleteMedication(String id) async {
    final box = await medicationBox;
    await box.delete(id);
  }

  @override
  Future<void> discontinueMedication(String id, String reason) async {
    final box = await medicationBox;
    final medication = box.get(id);

    if (medication != null) {
      final updatedMedication = medication.copyWith(
        discontinuedReason: reason,
        discontinuedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await box.put(id, updatedMedication);
    }
  }

  @override
  Future<List<MedicationModel>> searchMedications(String query) async {
    final box = await medicationBox;
    final lowerQuery = query.toLowerCase();

    return box.values
        .where(
          (medication) =>
              !medication.isDeleted &&
              (medication.name.toLowerCase().contains(lowerQuery) ||
                  medication.type.toLowerCase().contains(lowerQuery) ||
                  (medication.prescribedBy?.toLowerCase().contains(
                        lowerQuery,
                      ) ??
                      false)),
        )
        .toList();
  }

  @override
  Future<List<MedicationModel>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final box = await medicationBox;

    return box.values
        .where(
          (medication) =>
              medication.animalId == animalId &&
              !medication.isDeleted &&
              medication.startDate.isBefore(endDate) &&
              medication.endDate.isAfter(startDate),
        )
        .toList();
  }

  @override
  Future<List<MedicationModel>> checkMedicationConflicts(
    MedicationModel medication,
  ) async {
    final box = await medicationBox;

    // Check for medications with overlapping periods for the same animal
    return box.values
        .where(
          (existing) =>
              existing.id != medication.id &&
              existing.animalId == medication.animalId &&
              !existing.isDeleted &&
              existing.startDate.isBefore(medication.endDate) &&
              existing.endDate.isAfter(medication.startDate),
        )
        .toList();
  }

  @override
  Future<int> getActiveMedicationsCount(String animalId) async {
    final activeMedications = await getActiveMedicationsByAnimalId(animalId);
    return activeMedications.length;
  }

  @override
  Future<void> clearAllMedications() async {
    final box = await medicationBox;
    await box.clear();
  }

  @override
  Stream<List<MedicationModel>> watchMedications() async* {
    final box = await medicationBox;

    yield box.values.where((medication) => !medication.isDeleted).toList();

    await for (final _ in box.watch()) {
      yield box.values.where((medication) => !medication.isDeleted).toList();
    }
  }

  @override
  Stream<List<MedicationModel>> watchMedicationsByAnimalId(
    String animalId,
  ) async* {
    final box = await medicationBox;

    yield box.values
        .where(
          (medication) =>
              medication.animalId == animalId && !medication.isDeleted,
        )
        .toList();

    await for (final _ in box.watch()) {
      yield box.values
          .where(
            (medication) =>
                medication.animalId == animalId && !medication.isDeleted,
          )
          .toList();
    }
  }

  @override
  Stream<List<MedicationModel>> watchActiveMedications() async* {
    final box = await medicationBox;
    final now = DateTime.now();

    yield box.values
        .where(
          (medication) =>
              !medication.isDeleted &&
              now.isAfter(medication.startDate) &&
              now.isBefore(medication.endDate),
        )
        .toList();

    await for (final _ in box.watch()) {
      final currentNow = DateTime.now();
      yield box.values
          .where(
            (medication) =>
                !medication.isDeleted &&
                currentNow.isAfter(medication.startDate) &&
                currentNow.isBefore(medication.endDate),
          )
          .toList();
    }
  }
}
