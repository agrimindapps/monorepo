import 'package:core/core.dart' hide Column;

import '../../../core/data/repositories/comentarios_hive_repository.dart';
import '../../../core/services/error_handler_service.dart';
import '../data/repositories/comentarios_repository_impl.dart';
import '../data/services/comentarios_id_service.dart';
import '../data/services/comentarios_mapper.dart';
import '../data/services/comentarios_search_service.dart';
import '../domain/repositories/i_comentarios_repository.dart';
import '../domain/usecases/add_comentario_usecase.dart';
import '../domain/usecases/delete_comentario_usecase.dart';
import '../domain/usecases/get_comentarios_usecase.dart';

/// Dependency Injection setup for Comentarios module following Clean Architecture.
///
/// SOLID Refactoring:
/// - Separates specialized services (Mapper, IdService, SearchService)
/// - Follows the pattern established in diagnosticos feature
/// - Improves testability through dependency injection
///
/// Registers all dependencies required for the comentarios feature.
class ComentariosDI {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<ErrorHandlerService>()) {
      getIt.registerSingleton<ErrorHandlerService>(ErrorHandlerService());
    }

    // Register specialized services
    if (!getIt.isRegistered<IComentariosMapper>()) {
      getIt.registerSingleton<IComentariosMapper>(ComentariosMapper());
    }

    if (!getIt.isRegistered<IComentariosIdService>()) {
      getIt.registerSingleton<IComentariosIdService>(
        ComentariosIdService(),
      );
    }

    if (!getIt.isRegistered<IComentariosSearchService>()) {
      getIt.registerSingleton<IComentariosSearchService>(
        ComentariosSearchService(),
      );
    }

    // Register repository with mapper dependency
    getIt.registerFactory<IComentariosRepository>(
      () => ComentariosRepositoryImpl(
        getIt<ComentariosHiveRepository>(),
        getIt<IComentariosMapper>(),
      ),
    );

    // Register use cases
    getIt.registerFactory<GetComentariosUseCase>(
      () => GetComentariosUseCase(getIt<IComentariosRepository>()),
    );

    getIt.registerFactory<AddComentarioUseCase>(
      () => AddComentarioUseCase(getIt<IComentariosRepository>()),
    );

    getIt.registerFactory<DeleteComentarioUseCase>(
      () => DeleteComentarioUseCase(getIt<IComentariosRepository>()),
    );
  }

  /// Unregister all dependencies (useful for testing)
  static void unregister(GetIt getIt) {

    if (getIt.isRegistered<DeleteComentarioUseCase>()) {
      getIt.unregister<DeleteComentarioUseCase>();
    }

    if (getIt.isRegistered<AddComentarioUseCase>()) {
      getIt.unregister<AddComentarioUseCase>();
    }

    if (getIt.isRegistered<GetComentariosUseCase>()) {
      getIt.unregister<GetComentariosUseCase>();
    }

    if (getIt.isRegistered<IComentariosRepository>()) {
      getIt.unregister<IComentariosRepository>();
    }
  }
}
