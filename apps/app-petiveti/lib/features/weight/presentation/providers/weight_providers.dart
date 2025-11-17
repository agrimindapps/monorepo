import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../data/datasources/weight_local_datasource.dart';
import '../../data/repositories/weight_repository_impl.dart';
import '../../data/services/weight_error_handling_service.dart';
import '../../domain/repositories/weight_repository.dart';
import '../../domain/services/weight_validation_service.dart';
import '../../domain/usecases/add_weight.dart';
import '../../domain/usecases/delete_weight.dart' as del;
import '../../domain/usecases/get_weight_by_id.dart' as getWeight;
import '../../domain/usecases/get_weight_statistics.dart';
import '../../domain/usecases/get_weights.dart';
import '../../domain/usecases/get_weights_by_animal_id.dart';
import '../../domain/usecases/update_weight.dart';

part 'weight_providers.g.dart';

// ============================================================================
// SERVICES
// ============================================================================

@riverpod
WeightValidationService weightValidationService(
  WeightValidationServiceRef ref,
) {
  return WeightValidationService();
}

@riverpod
WeightErrorHandlingService weightErrorHandlingService(
  WeightErrorHandlingServiceRef ref,
) {
  return WeightErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
WeightLocalDataSource weightLocalDataSource(WeightLocalDataSourceRef ref) {
  return WeightLocalDataSourceImpl(ref.watch(petivetiDatabaseProvider));
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
WeightRepository weightRepository(WeightRepositoryRef ref) {
  return WeightRepositoryImpl(ref.watch(weightLocalDataSourceProvider));
}

// ============================================================================
// USE CASES
// ============================================================================

@riverpod
GetWeights getWeights(GetWeightsRef ref) {
  return GetWeights(ref.watch(weightRepositoryProvider));
}

@riverpod
GetWeightsByAnimalId getWeightsByAnimalId(GetWeightsByAnimalIdRef ref) {
  return GetWeightsByAnimalId(ref.watch(weightRepositoryProvider));
}

@riverpod
GetWeightStatistics getWeightStatistics(GetWeightStatisticsRef ref) {
  return GetWeightStatistics(ref.watch(weightRepositoryProvider));
}

@riverpod
getWeight.GetWeightById getWeightById(GetWeightByIdRef ref) {
  return getWeight.GetWeightById(ref.watch(weightRepositoryProvider));
}

@riverpod
AddWeight addWeight(AddWeightRef ref) {
  return AddWeight(ref.watch(weightRepositoryProvider));
}

@riverpod
UpdateWeight updateWeight(UpdateWeightRef ref) {
  return UpdateWeight(ref.watch(weightRepositoryProvider));
}

@riverpod
del.DeleteWeight deleteWeight(DeleteWeightRef ref) {
  return del.DeleteWeight(ref.watch(weightRepositoryProvider));
}
