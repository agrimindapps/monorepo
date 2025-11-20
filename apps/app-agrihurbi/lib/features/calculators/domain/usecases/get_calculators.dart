import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import '../entities/calculator_category.dart';
import '../entities/calculator_entity.dart';
import '../repositories/calculator_repository.dart';

@lazySingleton
class GetCalculators {
  final CalculatorRepository repository;

  GetCalculators(this.repository);

  Future<Either<Failure, List<CalculatorEntity>>> call() async {
    return repository.getAllCalculators();
  }
}

@lazySingleton
class GetCalculatorsByCategory {
  final CalculatorRepository repository;

  GetCalculatorsByCategory(this.repository);

  Future<Either<Failure, List<CalculatorEntity>>> call(
    CalculatorCategory category,
  ) async {
    return repository.getCalculatorsByCategory(category);
  }
}

@lazySingleton
class GetCalculatorById {
  final CalculatorRepository repository;

  GetCalculatorById(this.repository);

  Future<Either<Failure, CalculatorEntity>> call(String id) async {
    return repository.getCalculatorById(id);
  }
}

@lazySingleton
class SearchCalculators {
  final CalculatorRepository repository;

  SearchCalculators(this.repository);

  Future<Either<Failure, List<CalculatorEntity>>> call(
    String searchTerm,
  ) async {
    return repository.searchCalculators(searchTerm);
  }
}
