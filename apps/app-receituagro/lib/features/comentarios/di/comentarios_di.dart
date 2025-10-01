import 'package:core/core.dart';

import '../../../core/data/repositories/comentarios_hive_repository.dart';
import '../../../core/services/error_handler_service.dart';
import '../data/repositories/comentarios_repository_impl.dart';
import '../domain/repositories/i_comentarios_repository.dart';
import '../domain/usecases/add_comentario_usecase.dart';
import '../domain/usecases/delete_comentario_usecase.dart';
import '../domain/usecases/get_comentarios_usecase.dart';
import '../presentation/providers/comentarios_provider.dart';

/// Dependency Injection setup for Comentarios module following Clean Architecture.
/// Registers all dependencies required for the comentarios feature.
class ComentariosDI {
  static void register(GetIt getIt) {
    // Core services
    if (!getIt.isRegistered<ErrorHandlerService>()) {
      getIt.registerSingleton<ErrorHandlerService>(ErrorHandlerService());
    }

    // Repository layer
    getIt.registerFactory<IComentariosRepository>(
      () => ComentariosRepositoryImpl(getIt<ComentariosHiveRepository>()),
    );

    // Use cases layer
    getIt.registerFactory<GetComentariosUseCase>(
      () => GetComentariosUseCase(getIt<IComentariosRepository>()),
    );

    getIt.registerFactory<AddComentarioUseCase>(
      () => AddComentarioUseCase(getIt<IComentariosRepository>()),
    );

    getIt.registerFactory<DeleteComentarioUseCase>(
      () => DeleteComentarioUseCase(getIt<IComentariosRepository>()),
    );

    // Provider layer
    getIt.registerFactory<ComentariosProvider>(
      () => ComentariosProvider(
        getComentariosUseCase: getIt<GetComentariosUseCase>(),
        addComentarioUseCase: getIt<AddComentarioUseCase>(),
        deleteComentarioUseCase: getIt<DeleteComentarioUseCase>(),
        errorHandler: getIt<ErrorHandlerService>(),
      ),
    );

    // Register as singleton for provider persistence
    getIt.registerLazySingleton<ComentariosProvider>(
      () => ComentariosProvider(
        getComentariosUseCase: getIt<GetComentariosUseCase>(),
        addComentarioUseCase: getIt<AddComentarioUseCase>(),
        deleteComentarioUseCase: getIt<DeleteComentarioUseCase>(),
        errorHandler: getIt<ErrorHandlerService>(),
      ),
      instanceName: 'singleton',
    );
  }

  /// Unregister all dependencies (useful for testing)
  static void unregister(GetIt getIt) {
    if (getIt.isRegistered<ComentariosProvider>()) {
      getIt.unregister<ComentariosProvider>();
    }

    if (getIt.isRegistered<ComentariosProvider>(instanceName: 'singleton')) {
      getIt.unregister<ComentariosProvider>(instanceName: 'singleton');
    }

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