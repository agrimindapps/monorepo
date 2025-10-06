import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/vaccine.dart';

abstract class VaccineRepository {
  Future<Either<Failure, List<Vaccine>>> getVaccines();
  Future<Either<Failure, List<Vaccine>>> getVaccinesByAnimal(String animalId);
  Future<Either<Failure, Vaccine?>> getVaccineById(String id);
  Future<Either<Failure, Vaccine>> addVaccine(Vaccine vaccine);
  Future<Either<Failure, Vaccine>> updateVaccine(Vaccine vaccine);
  Future<Either<Failure, void>> deleteVaccine(String id);
  Future<Either<Failure, void>> deleteVaccinesByAnimal(String animalId);
  Future<Either<Failure, List<Vaccine>>> getPendingVaccines([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getOverdueVaccines([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getCompletedVaccines([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getRequiredVaccines([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getUpcomingVaccines([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getDueTodayVaccines([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getDueSoonVaccines([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getVaccinesByDateRange(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]);
  Future<Either<Failure, List<Vaccine>>> getVaccinesByMonth(
    int year,
    int month, [
    String? animalId,
  ]);
  Future<Either<Failure, Map<DateTime, List<Vaccine>>>> getVaccineCalendar(
    DateTime startDate,
    DateTime endDate, [
    String? animalId,
  ]);
  Future<Either<Failure, List<Vaccine>>> getVaccinesNeedingReminders();
  Future<Either<Failure, List<Vaccine>>> getVaccinesWithActiveReminders();
  Future<Either<Failure, Vaccine>> scheduleVaccineReminder(
    String vaccineId,
    DateTime reminderDate,
  );
  Future<Either<Failure, void>> removeVaccineReminder(String vaccineId);
  Future<Either<Failure, List<Vaccine>>> searchVaccines(
    String query, [
    String? animalId,
  ]);
  Future<Either<Failure, List<Vaccine>>> getVaccinesByVeterinarian(
    String veterinarian, [
    String? animalId,
  ]);
  Future<Either<Failure, List<Vaccine>>> getVaccinesByName(
    String vaccineName, [
    String? animalId,
  ]);
  Future<Either<Failure, List<Vaccine>>> getVaccinesByManufacturer(
    String manufacturer, [
    String? animalId,
  ]);
  Future<Either<Failure, Map<String, int>>> getVaccineStatistics([String? animalId]);
  Future<Either<Failure, List<Vaccine>>> getVaccineHistory(String animalId);
  Future<Either<Failure, Map<String, List<Vaccine>>>> getVaccinesByStatus([String? animalId]);
  Future<Either<Failure, List<String>>> getVaccineNames();
  Future<Either<Failure, List<String>>> getVeterinarians();
  Future<Either<Failure, List<String>>> getManufacturers();
  Future<Either<Failure, List<Vaccine>>> addMultipleVaccines(List<Vaccine> vaccines);
  Future<Either<Failure, void>> markVaccinesAsCompleted(List<String> vaccineIds);
  Future<Either<Failure, void>> updateVaccineStatuses(
    List<String> vaccineIds,
    VaccineStatus status,
  );
  Future<Either<Failure, void>> syncVaccines();
  Future<Either<Failure, DateTime?>> getLastSyncTime();
  Future<Either<Failure, Map<String, dynamic>>> exportVaccineData([String? animalId]);
  Future<Either<Failure, void>> importVaccineData(Map<String, dynamic> data);
}