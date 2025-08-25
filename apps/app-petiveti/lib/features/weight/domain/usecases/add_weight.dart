import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/weight.dart';
import '../repositories/weight_repository.dart';

class AddWeight implements UseCase<void, Weight> {
  final WeightRepository repository;

  AddWeight(this.repository);

  @override
  Future<Either<Failure, void>> call(Weight weight) async {
    // Validate weight data
    if (weight.animalId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }
    
    if (weight.weight <= 0) {
      return const Left(ValidationFailure(message: 'Peso deve ser maior que zero'));
    }
    
    if (weight.weight > 200) {
      return const Left(ValidationFailure(message: 'Peso muito alto. Verifique o valor informado'));
    }
    
    if (weight.bodyConditionScore != null && 
        (weight.bodyConditionScore! < 1 || weight.bodyConditionScore! > 9)) {
      return const Left(ValidationFailure(message: 'Score de condição corporal deve estar entre 1 e 9'));
    }
    
    if (weight.date.isAfter(DateTime.now())) {
      return const Left(ValidationFailure(message: 'Data não pode ser no futuro'));
    }

    return await repository.addWeight(weight);
  }
}