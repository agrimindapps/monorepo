// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../core/navigation/i_navigation_service.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../repository/defensivos_repository.dart';
import '../../../services/mock_admob_service.dart';
import '../../comentarios/controller/comentarios_controller.dart';
import '../../comentarios/services/comentarios_service.dart';
import '../controller/detalhes_defensivos_controller.dart';
import '../interfaces/i_diagnostic_filter_service.dart';
import '../interfaces/i_favorite_service.dart';
import '../interfaces/i_load_defensivo_use_case.dart';
import '../interfaces/i_tts_service.dart';
import '../services/diagnostic_filter_service.dart';
import '../services/favorite_service.dart';
import '../services/tts_service.dart';
import '../use_cases/load_defensivo_data_use_case.dart';

/// Bindings refatorados para a página de detalhes de defensivos
/// Implementa dependency injection adequado seguindo Clean Architecture
class DetalhesDefensivosBindings extends Bindings {
  @override
  void dependencies() {
    // Garantir que dependências básicas estejam disponíveis
    _ensureBasicDependencies();

    // Registrar services
    _registerServices();

    // Registrar use cases
    _registerUseCases();

    // Registrar controller
    _registerController();
  }

  void _ensureBasicDependencies() {
    if (!Get.isRegistered<DefensivosRepository>()) {
      Get.lazyPut<DefensivosRepository>(() => DefensivosRepository());
    }

    if (!Get.isRegistered<MockAdmobService>()) {
      Get.lazyPut<MockAdmobService>(() => MockAdmobService());
    }
  }

  void _registerServices() {
    // TTS Service
    Get.lazyPut<ITtsService>(
      () => TtsService(),
      fenix: true,
      tag: 'defensivos',
    );

    // Favorite Service
    Get.lazyPut<IFavoriteService>(
      () => FavoriteService(),
      fenix: true,
      tag: 'defensivos',
    );

    // Navigation Service
    Get.lazyPut<INavigationService>(
      () => NavigationService(),
      fenix: true,
    );

    // Diagnostic Filter Service
    Get.lazyPut<IDiagnosticFilterService>(
      () => DiagnosticFilterService(),
      fenix: true,
    );

    // Comentarios Service
    Get.lazyPut<ComentariosService>(
      () => ComentariosService(),
      fenix: true,
    );
  }

  void _registerUseCases() {
    // Load Defensivo Use Case
    Get.lazyPut<ILoadDefensivoUseCase>(
      () => LoadDefensivoDataUseCase(),
      fenix: true,
    );
  }

  void _registerController() {
    Get.lazyPut<DetalhesDefensivosController>(
      () => DetalhesDefensivosController(
        ttsService: Get.find<ITtsService>(tag: 'defensivos'),
        favoriteService: Get.find<IFavoriteService>(tag: 'defensivos'),
        navigationService: Get.find<INavigationService>(),
        filterService: Get.find<IDiagnosticFilterService>(),
        loadDefensivoUseCase: Get.find<ILoadDefensivoUseCase>(),
        admobService: Get.find<MockAdmobService>(),
      ),
    );

    // Comentarios Controller
    Get.lazyPut<ComentariosController>(
      () => ComentariosController(),
      fenix: true,
    );
  }
}
