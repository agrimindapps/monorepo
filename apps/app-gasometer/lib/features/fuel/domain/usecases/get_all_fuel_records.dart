import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@lazySingleton
class GetAllFuelRecords implements NoParamsUseCase<List<FuelRecordEntity>> {

  GetAllFuelRecords(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call() async {
    return await repository.getAllFuelRecords();
  }
}