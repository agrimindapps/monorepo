import 'package:get_it/get_it.dart';
import '../../../features/spaces/domain/repositories/spaces_repository.dart';
import '../../../features/spaces/domain/usecases/get_spaces_usecase.dart';
import '../../../features/spaces/domain/usecases/add_space_usecase.dart';
import '../../../features/spaces/domain/usecases/update_space_usecase.dart';
import '../../../features/spaces/domain/usecases/delete_space_usecase.dart';
import '../../../features/spaces/data/datasources/local/spaces_local_datasource.dart';
import '../../../features/spaces/data/datasources/remote/spaces_remote_datasource.dart';
import '../../../features/spaces/data/repositories/spaces_repository_impl.dart';
import '../../../features/spaces/presentation/providers/spaces_provider.dart';
import '../../../features/spaces/presentation/providers/space_form_provider.dart';

class SpacesDIModule {
  static void init(GetIt sl) {
    // Data sources
    sl.registerLazySingleton<SpacesLocalDatasource>(
      () => SpacesLocalDatasourceImpl(storage: sl()),
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
    sl.registerLazySingleton(() => SearchSpacesUseCase(sl()));
    sl.registerLazySingleton(() => AddSpaceUseCase(sl()));
    sl.registerLazySingleton(() => UpdateSpaceUseCase(sl()));
    sl.registerLazySingleton(() => DeleteSpaceUseCase(sl()));
    
    // Providers
    sl.registerFactory(() => SpacesProvider(
      getSpacesUseCase: sl(),
      searchSpacesUseCase: sl(),
      addSpaceUseCase: sl(),
      updateSpaceUseCase: sl(),
      deleteSpaceUseCase: sl(),
    ));
    
    sl.registerFactory(() => SpaceFormProvider(
      getSpaceByIdUseCase: sl(),
      addSpaceUseCase: sl(),
      updateSpaceUseCase: sl(),
    ));
  }
}