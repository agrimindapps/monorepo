import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class GetVaccineCalendar implements UseCase<Map<DateTime, List<Vaccine>>, GetVaccineCalendarParams> {
  final VaccineRepository repository;

  GetVaccineCalendar(this.repository);

  @override
  Future<Either<Failure, Map<DateTime, List<Vaccine>>>> call(GetVaccineCalendarParams params) async {
    if (params.animalId != null && params.animalId!.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal inválido'));
    }

    if (params.startDate.isAfter(params.endDate)) {
      return const Left(ValidationFailure(message: 'Data inicial deve ser anterior à data final'));
    }

    return await repository.getVaccineCalendar(
      params.startDate,
      params.endDate,
      params.animalId,
    );
  }
}

class GetVaccineCalendarParams {
  final DateTime startDate;
  final DateTime endDate;
  final String? animalId;
  
  const GetVaccineCalendarParams({
    required this.startDate,
    required this.endDate,
    this.animalId,
  });
  factory GetVaccineCalendarParams.currentMonth({String? animalId}) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    return GetVaccineCalendarParams(
      startDate: startDate,
      endDate: endDate,
      animalId: animalId,
    );
  }
  
  factory GetVaccineCalendarParams.nextMonth({String? animalId}) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month + 1, 1);
    final endDate = DateTime(now.year, now.month + 2, 0);
    return GetVaccineCalendarParams(
      startDate: startDate,
      endDate: endDate,
      animalId: animalId,
    );
  }
}