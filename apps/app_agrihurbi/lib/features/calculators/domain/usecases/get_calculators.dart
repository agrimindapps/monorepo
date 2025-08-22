import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/calculator_entity.dart';
import '../entities/calculator_category.dart';
import '../repositories/calculator_repository.dart';

class GetCalculators {
  final CalculatorRepository repository;

  GetCalculators(this.repository);

  Future<Either<Failure, List<CalculatorEntity>>> call() async {
    return await repository.getAllCalculators();
  }
}

class GetCalculatorsByCategory {
  final CalculatorRepository repository;

  GetCalculatorsByCategory(this.repository);

  Future<Either<Failure, List<CalculatorEntity>>> call(
    CalculatorCategory category,
  ) async {
    return await repository.getCalculatorsByCategory(category);
  }
}

class GetCalculatorById {
  final CalculatorRepository repository;

  GetCalculatorById(this.repository);

  Future<Either<Failure, CalculatorEntity>> call(String id) async {
    return await repository.getCalculatorById(id);
  }
}

class SearchCalculators {
  final CalculatorRepository repository;

  SearchCalculators(this.repository);

  Future<Either<Failure, List<CalculatorEntity>>> call(
    String searchTerm,
  ) async {
    return await repository.searchCalculators(searchTerm);
  }
}