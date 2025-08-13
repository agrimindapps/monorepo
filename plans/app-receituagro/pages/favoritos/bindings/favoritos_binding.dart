// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/favoritos_repository.dart';
import '../controller/favoritos_controller.dart';
import '../services/favoritos_data_service.dart';
import '../services/favoritos_search_service.dart';
import '../services/favoritos_ui_state_service.dart';

/// Favoritos Dependency Binding following consistent lifecycle strategy
///
/// **Lifecycle Strategy:**
/// - **Permanent (App-wide)**: Repositories, data services, navigation services
/// - **Temporary (Page-specific)**: Controllers, UI state, search state
///
/// **Rationale:**
/// - Repositories should persist to maintain cache and avoid re-initialization
/// - Data services manage app-wide favorite data that can be shared
/// - Navigation services are stateless and can be reused safely
/// - Controllers coordinate page-specific logic and should be disposed
/// - UI/Search state is page-specific and should not leak between navigations
class FavoritosBinding extends Bindings {
  @override
  void dependencies() {
    _registerPermanentDependencies();
    _registerTemporaryDependencies();
  }

  /// Register app-wide persistent dependencies
  void _registerPermanentDependencies() {
    // Repository - shared across app, maintains cache
    if (!Get.isRegistered<FavoritosRepository>()) {
      Get.put<FavoritosRepository>(
        FavoritosRepository(),
        permanent: true,
      );
    }

    // Data Service - manages app-wide favorite data
    if (!Get.isRegistered<FavoritosDataService>()) {
      Get.put<FavoritosDataService>(
        FavoritosDataService(),
        permanent: true,
      );
    }

    // Navigation Service é registrado centralmente via NavigationBindings
    // Removido para usar o NavigationService unificado

    // Search Service - precisa ser permanent para manter controllers entre abas
    if (!Get.isRegistered<FavoritosSearchService>()) {
      Get.put<FavoritosSearchService>(
        FavoritosSearchService(),
        permanent: true,
      );
    }
  }

  /// Register page-specific temporary dependencies
  void _registerTemporaryDependencies() {
    // UI State Service - page-specific state
    Get.put<FavoritosUIStateService>(
      FavoritosUIStateService(),
      permanent: false,
    );

    // Controller - coordinates page-specific logic
    Get.put<FavoritosController>(
      FavoritosController(),
      permanent: false,
    );
  }

  /// Clean up temporary dependencies when page is disposed
  void dispose() {
    // GetX automatically disposes temporary dependencies
    // but we can add logging for debugging
  }
}
