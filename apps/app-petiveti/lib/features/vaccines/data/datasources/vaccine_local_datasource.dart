import 'package:core/core.dart';

import '../../../../core/storage/hive_service.dart';
import '../models/vaccine_model.dart';

abstract class VaccineLocalDataSource {
  /// Basic CRUD operations
  Future<List<VaccineModel>> getVaccines();
  Future<List<VaccineModel>> getVaccinesByAnimalId(String animalId);
  Future<VaccineModel?> getVaccineById(String id);
  Future<void> addVaccine(VaccineModel vaccine);
  Future<void> updateVaccine(VaccineModel vaccine);
  Future<void> deleteVaccine(String id);
  Future<void> deleteVaccinesByAnimalId(String animalId);

  /// Status-based queries
  Future<List<VaccineModel>> getPendingVaccines([String? animalId]);
  Future<List<VaccineModel>> getOverdueVaccines([String? animalId]);
  Future<List<VaccineModel>> getCompletedVaccines([String? animalId]);
  Future<List<VaccineModel>> getRequiredVaccines([String? animalId]);
  Future<List<VaccineModel>> getUpcomingVaccines([String? animalId]);
  Future<List<VaccineModel>> getDueTodayVaccines([String? animalId]);
  Future<List<VaccineModel>> getDueSoonVaccines([String? animalId]);

  /// Date-based queries
  Future<List<VaccineModel>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]);
  Future<List<VaccineModel>> getVaccinesByMonth(
    int year,
    int month, [
    String? animalId,
  ]);

  /// Reminder functionality
  Future<List<VaccineModel>> getVaccinesNeedingReminders();
  Future<List<VaccineModel>> getVaccinesWithActiveReminders();

  /// Search and filtering
  Future<List<VaccineModel>> searchVaccines(String query, [String? animalId]);
  Future<List<VaccineModel>> getVaccinesByVeterinarian(
    String veterinarian, [
    String? animalId,
  ]);
  Future<List<VaccineModel>> getVaccinesByName(
    String vaccineName, [
    String? animalId,
  ]);
  Future<List<VaccineModel>> getVaccinesByManufacturer(
    String manufacturer, [
    String? animalId,
  ]);

  /// Bulk operations
  Future<void> addMultipleVaccines(List<VaccineModel> vaccines);
  Future<void> updateMultipleVaccines(List<VaccineModel> vaccines);
  Future<void> markVaccinesAsCompleted(List<String> vaccineIds);

  /// Caching and synchronization
  Future<void> cacheVaccines(List<VaccineModel> vaccines);
  Future<void> clearCache();

  /// Reactive streams
  Stream<List<VaccineModel>> watchVaccines();
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(String animalId);
}

class VaccineLocalDataSourceImpl implements VaccineLocalDataSource {
  final HiveService _hiveService;

  VaccineLocalDataSourceImpl(this._hiveService);

  Future<Box<VaccineModel>> get _box async {
    return await _hiveService.getBox<VaccineModel>('vaccines');
  }

  List<VaccineModel> _filterActive(Iterable<VaccineModel> vaccines) {
    return vaccines.where((vaccine) => !vaccine.isDeleted).toList();
  }

  List<VaccineModel> _filterByAnimal(
    List<VaccineModel> vaccines,
    String? animalId,
  ) {
    if (animalId == null) return vaccines;
    return vaccines.where((vaccine) => vaccine.animalId == animalId).toList();
  }

  // Basic CRUD operations
  @override
  Future<List<VaccineModel>> getVaccines() async {
    final vaccinesBox = await _box;
    final vaccines = _filterActive(vaccinesBox.values);
    vaccines.sort((a, b) => b.dateTimestamp.compareTo(a.dateTimestamp));
    return vaccines;
  }

  @override
  Future<List<VaccineModel>> getVaccinesByAnimalId(String animalId) async {
    final vaccines = await getVaccines();
    return _filterByAnimal(vaccines, animalId);
  }

  @override
  Future<VaccineModel?> getVaccineById(String id) async {
    final vaccinesBox = await _box;
    final vaccine = vaccinesBox.get(id);
    return (vaccine != null && !vaccine.isDeleted) ? vaccine : null;
  }

  @override
  Future<void> addVaccine(VaccineModel vaccine) async {
    final vaccinesBox = await _box;
    await vaccinesBox.put(vaccine.id, vaccine);
  }

  @override
  Future<void> updateVaccine(VaccineModel vaccine) async {
    final vaccinesBox = await _box;
    await vaccinesBox.put(vaccine.id, vaccine);
  }

  @override
  Future<void> deleteVaccine(String id) async {
    final vaccinesBox = await _box;
    final vaccine = vaccinesBox.get(id);
    if (vaccine != null) {
      final deletedVaccine = VaccineModel.fromEntity(
        vaccine.toEntity().copyWith(isDeleted: true, updatedAt: DateTime.now()),
      );
      await vaccinesBox.put(id, deletedVaccine);
    }
  }

  @override
  Future<void> deleteVaccinesByAnimalId(String animalId) async {
    final vaccines = await getVaccinesByAnimalId(animalId);
    final vaccinesBox = await _box;

    for (final vaccine in vaccines) {
      final deletedVaccine = VaccineModel.fromEntity(
        vaccine.toEntity().copyWith(isDeleted: true, updatedAt: DateTime.now()),
      );
      await vaccinesBox.put(vaccine.id, deletedVaccine);
    }
  }

  // Status-based queries
  @override
  Future<List<VaccineModel>> getPendingVaccines([String? animalId]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered.where((vaccine) => vaccine.toEntity().isPending).toList();
  }

  @override
  Future<List<VaccineModel>> getOverdueVaccines([String? animalId]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered.where((vaccine) => vaccine.toEntity().isOverdue).toList();
  }

  @override
  Future<List<VaccineModel>> getCompletedVaccines([String? animalId]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered.where((vaccine) => vaccine.isCompleted).toList();
  }

  @override
  Future<List<VaccineModel>> getRequiredVaccines([String? animalId]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered.where((vaccine) => vaccine.isRequired).toList();
  }

  @override
  Future<List<VaccineModel>> getUpcomingVaccines([String? animalId]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    final now = DateTime.now();
    final futureDate = now.add(const Duration(days: 30)); // Next 30 days

    return filtered.where((vaccine) {
      if (vaccine.nextDueDateTimestamp == null) return false;
      final nextDueDate = DateTime.fromMillisecondsSinceEpoch(
        vaccine.nextDueDateTimestamp!,
      );
      return nextDueDate.isAfter(now) && nextDueDate.isBefore(futureDate);
    }).toList();
  }

  @override
  Future<List<VaccineModel>> getDueTodayVaccines([String? animalId]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered.where((vaccine) => vaccine.toEntity().isDueToday).toList();
  }

  @override
  Future<List<VaccineModel>> getDueSoonVaccines([String? animalId]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered.where((vaccine) => vaccine.toEntity().isDueSoon).toList();
  }

  // Date-based queries
  @override
  Future<List<VaccineModel>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);

    return filtered.where((vaccine) {
      final vaccineDate = DateTime.fromMillisecondsSinceEpoch(
        vaccine.dateTimestamp,
      );
      return vaccineDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          vaccineDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<VaccineModel>> getVaccinesByMonth(
    int year,
    int month, [
    String? animalId,
  ]) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    return await getVaccinesByDateRange(startDate, endDate, animalId);
  }

  // Reminder functionality
  @override
  Future<List<VaccineModel>> getVaccinesNeedingReminders() async {
    final vaccines = await getVaccines();
    return vaccines
        .where((vaccine) => vaccine.toEntity().needsReminder)
        .toList();
  }

  @override
  Future<List<VaccineModel>> getVaccinesWithActiveReminders() async {
    final vaccines = await getVaccines();
    return vaccines
        .where(
          (vaccine) =>
              vaccine.reminderDateTimestamp != null && !vaccine.isCompleted,
        )
        .toList();
  }

  // Search and filtering
  @override
  Future<List<VaccineModel>> searchVaccines(
    String query, [
    String? animalId,
  ]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    final queryLower = query.toLowerCase();

    return filtered.where((vaccine) {
      return vaccine.name.toLowerCase().contains(queryLower) ||
          vaccine.veterinarian.toLowerCase().contains(queryLower) ||
          (vaccine.manufacturer?.toLowerCase().contains(queryLower) ?? false) ||
          (vaccine.notes?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  @override
  Future<List<VaccineModel>> getVaccinesByVeterinarian(
    String veterinarian, [
    String? animalId,
  ]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered
        .where((vaccine) => vaccine.veterinarian == veterinarian)
        .toList();
  }

  @override
  Future<List<VaccineModel>> getVaccinesByName(
    String vaccineName, [
    String? animalId,
  ]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered.where((vaccine) => vaccine.name == vaccineName).toList();
  }

  @override
  Future<List<VaccineModel>> getVaccinesByManufacturer(
    String manufacturer, [
    String? animalId,
  ]) async {
    final vaccines = await getVaccines();
    final filtered = _filterByAnimal(vaccines, animalId);
    return filtered
        .where((vaccine) => vaccine.manufacturer == manufacturer)
        .toList();
  }

  // Bulk operations
  @override
  Future<void> addMultipleVaccines(List<VaccineModel> vaccines) async {
    final vaccinesBox = await _box;
    final vaccineMap = Map.fromEntries(
      vaccines.map((vaccine) => MapEntry(vaccine.id, vaccine)),
    );
    await vaccinesBox.putAll(vaccineMap);
  }

  @override
  Future<void> updateMultipleVaccines(List<VaccineModel> vaccines) async {
    await addMultipleVaccines(vaccines); // Same implementation
  }

  @override
  Future<void> markVaccinesAsCompleted(List<String> vaccineIds) async {
    final vaccinesBox = await _box;

    for (final id in vaccineIds) {
      final vaccine = vaccinesBox.get(id);
      if (vaccine != null && !vaccine.isDeleted) {
        final entity = vaccine.toEntity();
        if (entity.canBeMarkedAsCompleted()) {
          final completedVaccine = VaccineModel.fromEntity(
            entity.markAsCompleted(),
          );
          await vaccinesBox.put(id, completedVaccine);
        }
      }
    }
  }

  // Caching and synchronization
  @override
  Future<void> cacheVaccines(List<VaccineModel> vaccines) async {
    await addMultipleVaccines(vaccines);
  }

  @override
  Future<void> clearCache() async {
    final vaccinesBox = await _box;
    await vaccinesBox.clear();
  }

  // Reactive streams
  @override
  Stream<List<VaccineModel>> watchVaccines() async* {
    final vaccinesBox = await _box;

    yield* Stream.periodic(const Duration(milliseconds: 500), (_) {
      final vaccines = _filterActive(vaccinesBox.values);
      vaccines.sort((a, b) => b.dateTimestamp.compareTo(a.dateTimestamp));
      return vaccines;
    });
  }

  @override
  Stream<List<VaccineModel>> watchVaccinesByAnimalId(String animalId) async* {
    await for (final vaccines in watchVaccines()) {
      yield _filterByAnimal(vaccines, animalId);
    }
  }
}
