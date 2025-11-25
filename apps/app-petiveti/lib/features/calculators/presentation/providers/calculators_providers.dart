import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_services_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/calculator_local_datasource.dart';
import '../../data/repositories/calculator_repository_impl.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../../domain/usecases/get_calculators.dart';
import '../../domain/usecases/manage_calculation_history.dart';
import '../../domain/usecases/perform_calculation.dart';

part 'calculators_providers.g.dart';


@riverpod
CalculatorLocalDatasource calculatorLocalDataSource(Ref ref) {
  final database = ref.watch(petivetiDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return CalculatorLocalDatasourceImpl(database, prefs);
}

@riverpod
CalculatorRepository calculatorRepository(Ref ref) {
  final localDataSource = ref.watch(calculatorLocalDataSourceProvider);
  return CalculatorRepositoryImpl(localDataSource);
}

@riverpod
PerformCalculation performCalculation(Ref ref) {
  return PerformCalculation(ref.watch(calculatorRepositoryProvider));
}

@riverpod
GetCalculators getCalculators(Ref ref) {
  return GetCalculators(ref.watch(calculatorRepositoryProvider));
}

@riverpod
ManageCalculationHistory manageCalculationHistory(Ref ref) {
  return ManageCalculationHistory(ref.watch(calculatorRepositoryProvider));
}
