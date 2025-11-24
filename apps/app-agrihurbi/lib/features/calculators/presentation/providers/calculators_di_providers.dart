import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/calculator_local_datasource.dart';
import '../../data/repositories/calculator_data_repository_impl.dart';
import '../../data/repositories/calculator_repository_impl.dart';
import '../../domain/repositories/calculator_data_repository.dart';
import '../../domain/repositories/calculator_repository.dart';
import '../../domain/usecases/execute_calculation.dart';
import '../../domain/usecases/get_calculators.dart';
import '../../domain/usecases/manage_calculation_history.dart';
import '../../domain/usecases/manage_favorites.dart';
import '../../domain/usecases/save_calculation_to_history.dart';

// Datasources
final calculatorLocalDataSourceProvider = Provider<CalculatorLocalDataSource>((ref) {
  return CalculatorLocalDataSourceImpl();
});

// Repositories
final calculatorRepositoryProvider = Provider<CalculatorRepository>((ref) {
  final localDataSource = ref.watch(calculatorLocalDataSourceProvider);
  return CalculatorRepositoryImpl(localDataSource);
});

final calculatorDataRepositoryProvider = Provider<ICalculatorDataRepository>((ref) {
  return CalculatorDataRepositoryImpl();
});

// Usecases
final getCalculatorsUseCaseProvider = Provider<GetCalculators>((ref) {
  return GetCalculators(ref.watch(calculatorRepositoryProvider));
});

final executeCalculationUseCaseProvider = Provider<ExecuteCalculation>((ref) {
  return ExecuteCalculation(ref.watch(calculatorRepositoryProvider));
});

final getCalculatorByIdUseCaseProvider = Provider<GetCalculatorById>((ref) {
  return GetCalculatorById(ref.watch(calculatorRepositoryProvider));
});

final getCalculationHistoryUseCaseProvider = Provider<GetCalculationHistory>((ref) {
  return GetCalculationHistory(ref.watch(calculatorRepositoryProvider));
});

final deleteCalculationHistoryUseCaseProvider = Provider<DeleteCalculationHistory>((ref) {
  return DeleteCalculationHistory(ref.watch(calculatorRepositoryProvider));
});

final saveCalculationToHistoryUseCaseProvider = Provider<SaveCalculationToHistory>((ref) {
  return SaveCalculationToHistory(ref.watch(calculatorRepositoryProvider));
});

final manageFavoritesUseCaseProvider = Provider<ManageFavorites>((ref) {
  return ManageFavorites(ref.watch(calculatorRepositoryProvider));
});
