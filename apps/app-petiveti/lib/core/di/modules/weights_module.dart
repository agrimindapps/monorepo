import 'package:core/core.dart' show GetIt;

import '../../../features/weight/data/datasources/weight_local_datasource.dart';
import '../../../features/weight/data/repositories/weight_repository_impl.dart';
import '../../../features/weight/domain/repositories/weight_repository.dart';
import '../../../features/weight/domain/usecases/add_weight.dart';
import '../../../features/weight/domain/usecases/get_weight_statistics.dart';
import '../../../features/weight/domain/usecases/get_weights.dart';
import '../../../features/weight/domain/usecases/get_weights_by_animal_id.dart';
import '../../../features/weight/domain/usecases/update_weight.dart';
import '../di_module.dart';

/// Weights module responsible for weight tracking feature dependencies
///
/// Follows SRP: Single responsibility of weight feature registration
/// Follows OCP: Open for extension via DI module interface
/// Follows DIP: Depends on abstractions (interfaces)
class WeightsModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    getIt.registerLazySingleton<WeightLocalDataSource>(
      () => WeightLocalDataSourceImpl(),
    );

    getIt.registerLazySingleton<WeightRepository>(
      () => WeightRepositoryImpl(
        getIt<WeightLocalDataSource>(),
      ),
    );

    getIt.registerLazySingleton<GetWeights>(
      () => GetWeights(getIt<WeightRepository>()),
    );

    getIt.registerLazySingleton<GetWeightsByAnimalId>(
      () => GetWeightsByAnimalId(getIt<WeightRepository>()),
    );

    getIt.registerLazySingleton<GetWeightStatistics>(
      () => GetWeightStatistics(getIt<WeightRepository>()),
    );

    getIt.registerLazySingleton<AddWeight>(
      () => AddWeight(getIt<WeightRepository>()),
    );

    getIt.registerLazySingleton<UpdateWeight>(
      () => UpdateWeight(getIt<WeightRepository>()),
    );
  }
}
