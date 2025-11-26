import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/construction_local_datasource.dart';
import '../../data/repositories/construction_calculator_repository_impl.dart';
import '../../domain/repositories/construction_calculator_repository.dart';

part 'construction_calculator_providers.g.dart';

/// Provider for construction local datasource
@riverpod
ConstructionLocalDataSource constructionLocalDataSource(
  Ref ref,
) {
  return ConstructionLocalDataSourceImpl();
}

/// Provider for construction calculator repository
@riverpod
ConstructionCalculatorRepository constructionCalculatorRepository(
  Ref ref,
) {
  final localDataSource = ref.watch(constructionLocalDataSourceProvider);
  return ConstructionCalculatorRepositoryImpl(
    localDataSource: localDataSource,
  );
}
