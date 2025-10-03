import 'package:core/core.dart';

import '../../../features/plants/data/datasources/local/spaces_local_datasource.dart';
import '../../../features/plants/data/datasources/remote/spaces_remote_datasource.dart';
import '../../../features/plants/data/repositories/spaces_repository_impl.dart';
import '../../../features/plants/domain/repositories/spaces_repository.dart';

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

    // Use cases - Todos já registrados via Injectable (@injectable)

    // SpacesProvider migrado para Riverpod - agora usa SpacesNotifier
    // Acesso via ref.read(spacesNotifierProvider.notifier)
  }
}
