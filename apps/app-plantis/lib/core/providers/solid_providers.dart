import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/solid_di_factory.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/form_validation_service.dart';
import '../services/image_management_service.dart';
import '../services/plantis_sync_service.dart';
import '../services/plants_care_calculator.dart';
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart';

part 'solid_providers.g.dart';

/// === SOLID-COMPLIANT PROVIDERS ===
/// Providers que seguem princípios SOLID com Dependency Injection usando @riverpod

@riverpod
SolidDIFactory solidDIFactory(Ref ref) {
  return SolidDIFactory.instance;
}

/// === CORE SERVICES ===

@riverpod
IAuthStateProvider authStateService(Ref ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createAuthStateProvider();
}

@riverpod
FormValidationService formValidationService(Ref ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createFormValidationService();
}

@riverpod
ImageManagementService imageManagementService(Ref ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createImageManagementService();
}

/// === PLANTS SERVICES ===

@riverpod
PlantsDataService plantsDataService(Ref ref) {
  final factory = ref.read(solidDIFactoryProvider);
  final authProvider = ref.read(authStateServiceProvider);
  return factory.createPlantsDataService(authProvider: authProvider);
}

@riverpod
PlantsFilterService plantsFilterService(Ref ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createPlantsFilterService();
}

@riverpod
PlantsCareCalculator plantsCareCalculator(Ref ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createPlantsCareCalculator();
}

/// === SYNC SERVICES ===

@riverpod
PlantisSyncService plantisSyncService(Ref ref) {
  return GetIt.instance<PlantisSyncService>();
}

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
