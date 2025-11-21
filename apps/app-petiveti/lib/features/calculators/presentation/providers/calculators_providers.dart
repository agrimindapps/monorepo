import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/calculator_local_datasource.dart';
import '../../data/repositories/calculator_repository_impl.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../../domain/usecases/get_calculation_history.dart';
import '../../domain/usecases/get_calculators.dart';
import '../../domain/usecases/perform_calculation.dart';

part 'calculators_providers.g.dart';

@riverpod
CalculatorLocalDataSource calculatorLocalDataSource(CalculatorLocalDataSourceRef ref) {
  final database = ref.watch(petivetiDatabaseProvider);
  return CalculatorLocalDataSourceImpl(database);
}

@riverpod
CalculatorRepository calculatorRepository(CalculatorRepositoryRef ref) {
  final localDataSource = ref.watch(calculatorLocalDataSourceProvider);
  return CalculatorRepositoryImpl(localDataSource);
}

@riverpod
PerformCalculation performCalculation(PerformCalculationRef ref) {
  return PerformCalculation(ref.watch(calculatorRepositoryProvider));
}

@riverpod
GetCalculators getCalculators(GetCalculatorsRef ref) {
  return GetCalculators(ref.watch(calculatorRepositoryProvider));
}

@riverpod
GetCalculationHistory getCalculationHistory(GetCalculationHistoryRef ref) {
  return GetCalculationHistory(ref.watch(calculatorRepositoryProvider));
}
