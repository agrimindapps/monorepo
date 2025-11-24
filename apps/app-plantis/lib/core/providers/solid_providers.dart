import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/plants/presentation/providers/plants_providers.dart';
import '../data/adapters/auth_state_provider_adapter.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/form_validation_service.dart';
import '../services/image_management_service.dart';
import '../services/plants_care_calculator.dart';
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart';

part 'solid_providers.g.dart';

/// === SOLID-COMPLIANT PROVIDERS ===
/// Providers que seguem princípios SOLID com Dependency Injection usando @riverpod

/// === CORE SERVICES ===

@riverpod
IAuthStateProvider authStateService(Ref ref) {
  return AuthStateProviderAdapter.instance();
}

@riverpod
FormValidationService formValidationService(Ref ref) {
  return FormValidationService();
}

@riverpod
ImageManagementService imageManagementService(Ref ref) {
  return ImageManagementService.create();
}

/// === PLANTS SERVICES ===

@riverpod
PlantsDataService plantsDataService(Ref ref) {
  final authProvider = ref.read(authStateServiceProvider);
  final getPlants = ref.watch(getPlantsUseCaseProvider);
  final addPlant = ref.watch(addPlantUseCaseProvider);
  final updatePlant = ref.watch(updatePlantUseCaseProvider);
  final deletePlant = ref.watch(deletePlantUseCaseProvider);

  return PlantsDataService(
    authProvider: authProvider,
    getPlantsUseCase: getPlants,
    addPlantUseCase: addPlant,
    updatePlantUseCase: updatePlant,
    deletePlantUseCase: deletePlant,
  );
}

@riverpod
PlantsFilterService plantsFilterService(Ref ref) {
  return PlantsFilterService();
}

@riverpod
PlantsCareCalculator plantsCareCalculator(Ref ref) {
  return PlantsCareCalculator();
}

/// === SYNC SERVICES ===

// Removed PlantisSyncService provider - moved to repository_providers.dart

/// === UTILITY PROVIDERS ===

/// Provider para image list info
@riverpod
ImageListInfo imageListInfo(Ref ref, List<String> images) {
  final imageService = ref.read(imageManagementServiceProvider);
  return imageService.getImageListInfo(images);
}

/// Provider para image validation
@riverpod
ImageListValidation imageValidation(Ref ref, List<String> images) {
  final imageService = ref.read(imageManagementServiceProvider);
  return imageService.validateImageList(images);
}
