import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/weight.dart';
import '../repositories/weight_repository.dart';

@lazySingleton
class GetWeightById {
  final WeightRepository repository;

  GetWeightById(this.repository);

  Future<Either<Failure, Weight>> call(String id) async {
    return await repository.getWeightById(id);
  }
}
