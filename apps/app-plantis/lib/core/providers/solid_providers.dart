import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../di/solid_di_factory.dart';
import '../interfaces/i_auth_state_provider.dart';
import '../services/form_validation_service.dart';
import '../services/image_management_service.dart';
import '../services/plants_care_calculator.dart';
import '../services/plants_data_service.dart';
import '../services/plants_filter_service.dart';
import 'state/plant_form_state_manager.dart';
import 'state/plants_state_manager.dart';

/// === SOLID-COMPLIANT PROVIDERS ===
/// Providers que seguem princípios SOLID com Dependency Injection

// DI Factory singleton
final solidDIFactoryProvider = Provider<SolidDIFactory>((ref) {
  return SolidDIFactory.instance;
});

/// === CORE SERVICES ===

final authStateServiceProvider = Provider<IAuthStateProvider>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createAuthStateProvider();
});

final formValidationServiceProvider = Provider<FormValidationService>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createFormValidationService();
});

final imageManagementServiceProvider = Provider<ImageManagementService>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createImageManagementService();
});

/// === PLANTS SERVICES ===

final plantsDataServiceProvider = Provider<PlantsDataService>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  final authProvider = ref.read(authStateServiceProvider);
  return factory.createPlantsDataService(authProvider: authProvider);
});

final plantsFilterServiceProvider = Provider<PlantsFilterService>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createPlantsFilterService();
});

final plantsCareCalculatorProvider = Provider<PlantsCareCalculator>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  return factory.createPlantsCareCalculator();
});

/// === STATE MANAGERS ===

/// Provider para PlantsStateManager (usando Provider simples)
final solidPlantsStateManagerProvider = Provider<PlantsStateManager>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  
  // Usar DI puro em vez de Service Locator
  final dataService = ref.read(plantsDataServiceProvider);
  final filterService = ref.read(plantsFilterServiceProvider);
  final careCalculator = ref.read(plantsCareCalculatorProvider);
  final authProvider = ref.read(authStateServiceProvider);
  
  return factory.createPlantsStateManager(
    dataService: dataService,
    filterService: filterService,
    careCalculator: careCalculator,
    authProvider: authProvider,
  );
});

/// Provider para PlantFormStateManager (SOLID-compliant)
/// Usa ChangeNotifierProvider.autoDispose para observar mudanças no estado
/// autoDispose garante que dispose() é chamado quando não há mais listeners
final solidPlantFormStateManagerProvider = ChangeNotifierProvider.autoDispose<PlantFormStateManager>((ref) {
  final factory = ref.read(solidDIFactoryProvider);

  // Usar DI puro em vez de Service Locator
  final validationService = ref.read(formValidationServiceProvider);
  final imageService = ref.read(imageManagementServiceProvider);

  return factory.createPlantFormStateManager(
    validationService: validationService,
    imageService: imageService,
  );
});

/// === CONVENIENCE PROVIDERS ===

/// Provider para estado das plantas (SOLID)
final solidPlantsStateProvider = Provider((ref) {
  final stateManager = ref.watch(solidPlantsStateManagerProvider);
  return stateManager.state;
});

/// Provider para lista de plantas (SOLID)
final solidPlantsListProvider = Provider((ref) {
  final state = ref.watch(solidPlantsStateProvider);
  return state.filteredPlants;
});

/// Provider para loading state (SOLID)
final solidPlantsLoadingProvider = Provider((ref) {
  final state = ref.watch(solidPlantsStateProvider);
  return state.isLoading;
});

/// Provider para error state (SOLID)
final solidPlantsErrorProvider = Provider((ref) {
  final state = ref.watch(solidPlantsStateProvider);
  return state.error;
});

/// Provider para care statistics (SOLID)
final solidPlantsCareStatisticsProvider = Provider((ref) {
  final stateManager = ref.watch(solidPlantsStateManagerProvider);
  return stateManager.getCareStatistics();
});

/// Provider para plants needing water (SOLID)
final solidPlantsNeedingWaterProvider = Provider((ref) {
  final stateManager = ref.watch(solidPlantsStateManagerProvider);
  return stateManager.getPlantsNeedingWaterSoon(2); // Next 2 days
});

/// === FORM PROVIDERS ===

/// Provider para estado do formulário (SOLID)
final solidPlantFormStateProvider = Provider((ref) {
  final manager = ref.watch(solidPlantFormStateManagerProvider);
  return manager.state;
});

/// Provider para validation errors (SOLID)
final solidPlantFormErrorsProvider = Provider((ref) {
  final state = ref.watch(solidPlantFormStateProvider);
  return state.fieldErrors;
});

/// Provider para form validity (SOLID)
final solidPlantFormValidityProvider = Provider((ref) {
  final state = ref.watch(solidPlantFormStateProvider);
  return state.isFormValid;
});

/// Provider para can save state (SOLID)
final solidPlantFormCanSaveProvider = Provider((ref) {
  final state = ref.watch(solidPlantFormStateProvider);
  return state.canSave;
});

/// === UTILITY PROVIDERS ===

/// Provider para image list info
final solidImageListInfoProvider = Provider.family<ImageListInfo, List<String>>((ref, images) {
  final imageService = ref.read(imageManagementServiceProvider);
  return imageService.getImageListInfo(images);
});

/// Provider para image validation
final solidImageValidationProvider = Provider.family<ImageListValidation, List<String>>((ref, images) {
  final imageService = ref.read(imageManagementServiceProvider);
  return imageService.validateImageList(images);
});

/// === INITIALIZATION PROVIDER ===

/// Provider para inicialização das dependências SOLID
final solidDIInitializationProvider = Provider<bool>((ref) {
  final factory = ref.read(solidDIFactoryProvider);
  
  // Configurar DI baseado no ambiente
  const isDevelopment = kDebugMode;
  
  if (isDevelopment) {
    SolidDIConfigurator.configure(DIMode.development);
  } else {
    SolidDIConfigurator.configure(DIMode.production);
  }
  
  return factory.areSolidDependenciesRegistered();
});

/// === MIGRATION HELPERS ===
/// Providers para facilitar migração gradual do código legado

/// Provider que expõe interface compatível com o antigo PlantsProvider
final migrationPlantsProvider = Provider((ref) {
  // Garantir que SOLID DI está inicializado
  ref.watch(solidDIInitializationProvider);
  
  final solidState = ref.watch(solidPlantsStateProvider);
  
  // Retornar objeto compatível com código legado
  return MigrationPlantsAdapter(
    allPlants: solidState.allPlants,
    filteredPlants: solidState.filteredPlants,
    isLoading: solidState.isLoading,
    error: solidState.error,
    selectedPlant: solidState.selectedPlant,
  );
});

/// Provider que expõe interface compatível com o antigo PlantFormProvider
final migrationPlantFormProvider = Provider((ref) {
  // Garantir que SOLID DI está inicializado
  ref.watch(solidDIInitializationProvider);
  
  final solidState = ref.watch(solidPlantFormStateProvider);
  
  // Retornar objeto compatível com código legado
  return MigrationPlantFormAdapter(
    name: solidState.name,
    species: solidState.species,
    spaceId: solidState.spaceId,
    notes: solidState.notes,
    isLoading: solidState.isLoading,
    isSaving: solidState.isSaving,
    errorMessage: solidState.errorMessage,
    fieldErrors: solidState.fieldErrors,
    isFormValid: solidState.isFormValid,
    hasChanges: solidState.hasChanges,
    canSave: solidState.canSave,
  );
});

/// === MIGRATION ADAPTERS ===

/// Adapter para compatibilidade com código legado do PlantsProvider
class MigrationPlantsAdapter {
  final List<dynamic> allPlants;
  final List<dynamic> filteredPlants;
  final bool isLoading;
  final String? error;
  final dynamic selectedPlant;
  
  const MigrationPlantsAdapter({
    required this.allPlants,
    required this.filteredPlants,
    required this.isLoading,
    required this.error,
    required this.selectedPlant,
  });
  
  bool get isEmpty => allPlants.isEmpty;
  bool get hasError => error != null;
  int get plantsCount => allPlants.length;
}

/// Adapter para compatibilidade com código legado do PlantFormProvider
class MigrationPlantFormAdapter {
  final String name;
  final String species;
  final String? spaceId;
  final String notes;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final bool isFormValid;
  final bool hasChanges;
  final bool canSave;
  
  const MigrationPlantFormAdapter({
    required this.name,
    required this.species,
    required this.spaceId,
    required this.notes,
    required this.isLoading,
    required this.isSaving,
    required this.errorMessage,
    required this.fieldErrors,
    required this.isFormValid,
    required this.hasChanges,
    required this.canSave,
  });
  
  bool get hasError => errorMessage != null;
  bool get isEditMode => false; // Simplificado para compatibilidade
}