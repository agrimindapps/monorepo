import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/vaccine.dart';

abstract class VaccineRepository {
  Future<Either<Failure, List<Vaccine>>> getVaccines(String animalId);
  Future<Either<Failure, List<Vaccine>>> getPendingVaccines(String animalId);
  Future<Either<Failure, List<Vaccine>>> getOverdueVaccines(String animalId);
  Future<Either<Failure, Vaccine?>> getVaccineById(String id);
  Future<Either<Failure, Vaccine>> addVaccine(Vaccine vaccine);
  Future<Either<Failure, Vaccine>> updateVaccine(Vaccine vaccine);
  Future<Either<Failure, void>> deleteVaccine(String id);
  Future<Either<Failure, List<Vaccine>>> getVaccinesByDateRange(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  );
}