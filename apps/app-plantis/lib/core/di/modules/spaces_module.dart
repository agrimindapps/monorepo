import 'package:core/core.dart' hide Column;

import '../../../features/plants/data/datasources/local/spaces_local_datasource.dart';
import '../../../features/plants/data/datasources/remote/spaces_remote_datasource.dart';
import '../../../features/plants/data/repositories/spaces_repository_impl.dart';
import '../../../features/plants/domain/repositories/spaces_repository.dart';

class SpacesModule {
  static void init(GetIt sl) {
    sl.registerLazySingleton<SpacesLocalDatasource>(
      () => SpacesLocalDatasourceImpl(),
    );

    sl.registerLazySingleton<SpacesRemoteDatasource>(
      () => SpacesRemoteDatasourceImpl(firestore: sl(), rateLimiter: sl()),
    );
    sl.registerLazySingleton<SpacesRepository>(
      () => SpacesRepositoryImpl(
        localDatasource: sl(),
        remoteDatasource: sl(),
        networkInfo: sl(),
        authService: sl(),
      ),
    );

    // Use Cases are registered automatically by injectable
  }
}
