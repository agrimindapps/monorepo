import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/weight_repository.dart';

@lazySingleton
class DeleteWeight {
  final WeightRepository repository;

  DeleteWeight(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteWeight(id);
  }
}
