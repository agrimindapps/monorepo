// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/localstorage_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../repository/pragas_repository.dart';
import '../../comentarios/controller/comentarios_controller.dart';
import '../../comentarios/services/comentarios_service.dart';
import '../controller/detalhes_pragas_controller.dart';
import '../services/cache_service.dart';
import '../services/error_handler_service.dart';
import '../services/favorite_service.dart';
import '../services/praga_data_service.dart';

/// Bindings para a página de detalhes de pragas seguindo injeção de dependência
class DetalhesPragasBindings extends Bindings {
  @override
  void dependencies() {
    // Registrar serviços base primeiro
    _registerBaseServices();
    
    // Registrar serviços especializados
    _registerSpecializedServices();
    
    // Registrar controller principal
    _registerController();
  }

  /// Registra serviços base que já existem
  void _registerBaseServices() {
    // Verificar se já estão registrados para evitar duplicação
    if (!Get.isRegistered<PragasRepository>()) {
      Get.lazyPut<PragasRepository>(() => PragasRepository());
    }
    
    if (!Get.isRegistered<TtsService>()) {
      Get.lazyPut<TtsService>(() => TtsService());
    }
    
    if (!Get.isRegistered<LocalStorageService>()) {
      Get.lazyPut<LocalStorageService>(() => LocalStorageService());
    }
    
    if (!Get.isRegistered<ErrorHandlerService>()) {
      Get.lazyPut<ErrorHandlerService>(() => ErrorHandlerService());
    }
    
    if (!Get.isRegistered<PragaCacheService>()) {
      Get.lazyPut<PragaCacheService>(() => PragaCacheService());
    }
  }

  /// Registra serviços especializados criados para este módulo
  void _registerSpecializedServices() {
    // PragaDataService
    Get.lazyPut<PragaDataService>(
      () => PragaDataService(
        pragasRepository: Get.find<PragasRepository>(),
        errorHandler: Get.find<ErrorHandlerService>(),
        cacheService: Get.find<PragaCacheService>(),
      ),
    );

    // FavoriteService
    Get.lazyPut<FavoriteService>(
      () => FavoriteService(
        localStorageService: Get.find<LocalStorageService>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );

    // NavigationService (usando serviço global)
    if (!Get.isRegistered<NavigationService>()) {
      Get.lazyPut<NavigationService>(() => NavigationService());
    }

    // Comentarios Service
    if (!Get.isRegistered<ComentariosService>()) {
      Get.lazyPut<ComentariosService>(
        () => ComentariosService(),
        fenix: true,
      );
    }

    // Comentarios Controller
    if (!Get.isRegistered<ComentariosController>()) {
      Get.lazyPut<ComentariosController>(
        () => ComentariosController(),
        fenix: true,
      );
    }
  }

  /// Registra o controller principal
  void _registerController() {
    Get.lazyPut<DetalhesPragasController>(
      () => DetalhesPragasController(
        dataService: Get.find<PragaDataService>(),
        favoriteService: Get.find<FavoriteService>(),
        ttsService: Get.find<TtsService>(),
        navigationService: Get.find<NavigationService>(),
        errorHandler: Get.find<ErrorHandlerService>(),
      ),
    );
  }
}
