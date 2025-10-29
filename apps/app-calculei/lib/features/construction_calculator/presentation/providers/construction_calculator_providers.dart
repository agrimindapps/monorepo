import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/construction_local_datasource.dart';
import '../../data/repositories/construction_calculator_repository_impl.dart';
import '../../domain/repositories/construction_calculator_repository.dart';
import '../../domain/usecases/index.dart';

/// Provider for construction local datasource
final constructionLocalDataSourceProvider =
    Provider<ConstructionLocalDataSource>((ref) {
  return ConstructionLocalDataSourceImpl();
});

/// Provider for construction calculator repository
final constructionCalculatorRepositoryProvider =
    Provider<ConstructionCalculatorRepository>((ref) {
  final localDataSource = ref.watch(constructionLocalDataSourceProvider);
  return ConstructionCalculatorRepositoryImpl(
    localDataSource: localDataSource,
  );
});

/// Provider for calculate concrete use case
final calculateConcreteUseCaseProvider =
    Provider<CalculateConcreteUseCase>((ref) {
  final repository = ref.watch(constructionCalculatorRepositoryProvider);
  return CalculateConcreteUseCase(repository: repository);
});
