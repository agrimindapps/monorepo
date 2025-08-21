import 'package:get_it/get_it.dart';
import '../../../features/plants/domain/repositories/spaces_repository.dart';
import '../../../features/plants/domain/usecases/spaces_usecases.dart';
import '../../../features/plants/data/datasources/local/spaces_local_datasource.dart';
import '../../../features/plants/data/datasources/remote/spaces_remote_datasource.dart';
import '../../../features/plants/data/repositories/spaces_repository_impl.dart';
import '../../../features/plants/presentation/providers/spaces_provider.dart';

class SpacesModule {
  static void init(GetIt sl) {
    // Data sources
    sl.registerLazySingleton<SpacesLocalDatasource>(
      () => SpacesLocalDatasourceImpl(),
    );

    sl.registerLazySingleton<SpacesRemoteDatasource>(
      () => SpacesRemoteDatasourceImpl(firestore: sl()),
    );

    // Repository
    sl.registerLazySingleton<SpacesRepository>(
      () => SpacesRepositoryImpl(
        localDatasource: sl(),
        remoteDatasource: sl(),
        networkInfo: sl(),
        authService: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => GetSpacesUseCase(sl()));
    sl.registerLazySingleton(() => GetSpaceByIdUseCase(sl()));
    sl.registerLazySingleton(() => AddSpaceUseCase(sl()));
    sl.registerLazySingleton(() => UpdateSpaceUseCase(sl()));
    sl.registerLazySingleton(() => DeleteSpaceUseCase(sl()));

    // Provider
    sl.registerFactory(
      () => SpacesProvider(
        getSpacesUseCase: sl(),
        getSpaceByIdUseCase: sl(),
        addSpaceUseCase: sl(),
        updateSpaceUseCase: sl(),
        deleteSpaceUseCase: sl(),
      ),
    );
  }
}